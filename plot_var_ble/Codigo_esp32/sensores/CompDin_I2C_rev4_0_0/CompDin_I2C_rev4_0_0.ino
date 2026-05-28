/* COMPENSAÇÃO DIGITAL DE UM SENSOR
*  A dinâmica dominante de um sensor representado por uma 
*  Função de Transferência G(s) = 1/(Tau * s + 1), em que Tau é 
*  a constante de tempo em segundos, é compensada por um filtro
*  Gc(s) = (b*s + 1)/(a*s + 1), em que b e a são constantes sintonizáveis.
*  Fazendo-se b =Tau e a=Tau/n, em que n é um número que representa quantas 
*  vezes se deseja acelerar a resposta do sensor, obtemos uma aceleração da 
*  resposta dinâmic ado sensor. 
*  Como ao acelerar aumenta-se o ruído, é importante filtrar o sinal 
*  compensado por um filtro passa-baixas: Gf(s) = 1/(a_f * s + 1), 
*  sendo a constante a_f = 1s ou aproximadamente Tau/10.
* A implementação digital do compensador Gc(s) e do filtro digital 
* utiliza a Transformada de Tustin, que produz coeficientes mais robustos 
* no caso de intervalo de amostragem não muito pequenos, i.e. h ~ Tau/10.
* Aproximação de Tustin com hs = intervalo de amostragem em segundos:
* // G = (b*s + 1)/(a*s + 1)
* gama   =  (2*b + hs)/(2*a + hs);
* beta   =  (2*b - hs)/(2*b + hs);
* alfa   =  (2*a - hs)/(2*a + hs);
* alfa_f =  (2*a_f - hs)/(2*a_f + hs); 
* Gc(z)  = gama*(1-beta*z^-1)/(1-alfa*z^-1) % FT compensador digital
* Gf(z)  = (1-alfa_f)*z^-1/(1-alfa_f*z^-1) % FT do filtro digital
* ---------------------------------------
*  Padrão de envio de dados para o monitor serial/plotter:
*  <variável> : <valor>  ex: yk: 377.0 
 -------------------------------------------
 ==============================================================================
 Regularização da amostragem por enquete (polling)
    t_atual = millis(); // obtém o valor atual do relógio de tempo real
    t_alvo  = t_atual + h; // instante de tempo para realizar a próxima amostragem
    Exemplo: t_atual = t0, t_alvo  = t0 + h
  O t_alvo é atualizado após {(t_atual-t_alvo)>=h}  para evitar problemas com estouro do relógio.
 |----------|----------|----------|----------|----------|----------|----------|
            t0       t0+h
 |----------| h  : intervalo de amostragem de largura h segundos.
 |***-------| tac: Parte do intervalo h usada para cálculo de Ações de Comando .   
 |---=======| toc: Parte ociosa do intervalo h (tocIOSO)
 
 ------------------------------------------------------------------------------
 Release CompensatorDigital: testes com degrau via chave manual
 $Rev 7.0(a): Ajuste de fundo de escala dos ADCs.
      7.1(b): Correção do overflow de relógio para execução em loop inifinito.
      7.2(c): usando variáveis u, x e y
      8.0(a): interpretador de mensagens; 
              comunicação com Matlab app: Compdin_rev23_0_0.mlapp 
       9.0.0: Adaptado para implementação no ESP32C6
       9.1.0: Adaptado para implementação no ESP32C3 super mini
      10.0.0: Modificado para usar o sensor DS18B20
 ------------------------------------------------------------------------------  
 MIT license terms.           
 Copyright (c) 2019-10-12, 2025-09-01 Anisio R. Braga, COLTEC-UFMG
*/
// Bibliotecas do sensor digital de temperatura - DS18B20
#include <OneWireNg_CurrentPlatform.h>
#include <drivers/DSTherm.h>
#include <utils/Placeholder.h>
#include "ble_utils.h"
#include "serial_utils.h"
namespace {
// GPIO pin where DS18B20 is connected
//const int ONE_WIRE_BUS = A2; // você pode mudar a porta utilizada para conectar o pino de dados I2C
//const int ONE_WIRE_BUS = A5; // Pino de dados I2C no ESP32C3 super Mini
const int ONE_WIRE_BUS = D8;  // Pino de dados I2C no ESP32S3
//----------
static Placeholder<OneWireNg_CurrentPlatform> ow;
//===============================================

//#include <driver/adc.h>
// Declaração de Variáveis Globais
unsigned long h = 1000;  // intervalo de amostragem em ms
double p_h = 1;          // intervalo de amostragem em s (auxiliar)
double hs = h / 1000.0;  // intervalo de amostragem em s
unsigned long t_atual;
unsigned long t_alvo;

//--- Variáveis do modelo do sensor
double b;  // constante de tempo do sensor
double a;  // constante de tempo desejada para o compensador
//---  Variáveis para a aproximação de Tustin
double gama = 0.0;
double beta = 0.0;
double alfa = 0.0;
double alfa_f = 0.0;

int updateOk = 0;  // Semáforo para controle de atualização via mensagens

unsigned int m = 1;      // Fator de decimação
unsigned int p_m;        // Fator de decimação auxiliar
unsigned long int mCtr;  // Contador para decimação por m
// ----- Variaveis amostradas
double yk = 0.0;        // sinal de entrada com atraso dinâmico simulado por um filtro RC
double yk_1 = 0.0;      // sinal de entrada
double yc = 0.0;        // sinal compensado
double yf = 0.0;        // sinal compensado filtrado
double ya = 0.0;        // sinal amostrado decimado
double Temp_max = 100;  // valor máximo de temperatura para limitar o compensador
double Temp_min = -10;  // valor mínimo de temperatura para limitar o compensador
int u_LED;
}

//==============================
void setup() {
  // Start serial communication for debugging
  Serial.begin(115200);
  //while (!Serial); // Wait for serial connection for native USB
  //Serial.println("DS18B20 Temperature Sensor with XIAO ESP32C6 using OneWireNG");
  // Initialize OneWireNG
  new (&ow) OneWireNg_CurrentPlatform(ONE_WIRE_BUS, false);

  pinMode(LED_BUILTIN, OUTPUT);  // configura o pino do LED_BUILTIN como saida
  //--- Setup -----------------------------------------------
  h = 1000;
  p_h = h / 1000.0;  // intervalo de amostragem auxiliar em s
  hs = p_h;
  b = 10.0;  // constante de tempo a ser compensada
  a = 2.0;   // constante de tempo desejada
  m = 2;      // Fator de decimação que define constante de tempo do filtro digital
  p_m =2;    
  mCtr = 0;  // Contador para decimação por m
  Temp_max = 100.0;
  Temp_min = -10.0;
  // Função de Transferência do compensador em s
  // G = (b*s + 1)/(a*s + 1) e as respectivas constantes com a aproximação de Tustin
  atualizaCompensador(hs, m, b, a);
  //String TxStr = "gama:"+String(gama)+" "+ "beta:"+String(beta)+" "+"alfa:" + String(alfa)+" "+"alfa_f:" + String(alfa_f);
  // Serial.println(TxStr);

  // Bibliotecas auxiliares para fragmentar o codigo complexo
  initBluetooth(&p_h, &p_m, &b, &a, &updateOk);
  initSerial(&p_h, &p_m, &b, &a, &updateOk);
  //*** LE -  Ler Entradas iniciais ......................................
  yk = 25;
  yc = yk;
  yk_1 = yk;
  yf = yk;
  ya = yk;

  // Amostra o relógio para iniciar o loop()
  mCtr = 0;
  t_atual = millis();
  t_alvo = t_atual;  // partida com as leituras iniciais do setup{}

  u_LED = HIGH;
  //digitalWrite(LED_BUILTIN, u_LED);   // turn the LED on
}

void loop() {
  DSTherm drv(ow);
  Placeholder<DSTherm::Scratchpad> scrpd;

  t_atual = millis();  // Lê o tempo atual
  // Verifica se o talvo foi alcançado e executa a tarefa LE-RL-ES cadenciada
  //*** Início de LE-RL-ES *********************************************
  // Ler Entradas -> Resolver  Lógica -> Escrever Saídas
  if ((unsigned long)(t_atual - t_alvo) >= h) {
    //*** TAC: Tempo Ativo de Comando **********************************
    t_alvo = t_alvo + h;  // atualiza o tempo alvo
    mCtr = mCtr + 1;      // incrementa o contador de decimação
    //*** LE -  Ler Entrada .................................................
    // Start temperature conversion
    if (drv.convertTempAll(DSTherm::MAX_CONV_TIME, false) == OneWireNg::EC_SUCCESS) {
      // Read temperature from the first device
      if (drv.readScratchpadSingle(scrpd) == OneWireNg::EC_SUCCESS) {
        // Get the temperature in Celsius
        float tempC = scrpd->getTemp();
        yk = tempC / 1000.0;
      } else {
        Serial.println("Error: Scratchpad read failed");
      }
    } else {
      Serial.println("Error: Temperature conversion failed");
    }


    //*** RL - Resolver Lógica ..............................................
    // --- filtro de compensação
    yc = alfa * yc + gama * (yk - beta * yk_1);  // compensação de yk
    yc = min(yc, Temp_max);
    yc = max(yc, Temp_min);  // limitando a saída yc

    // --- Calcula o filtro digital 1a. ordem sem atraso de amostragem
    yf = yf + alfa_f * (yc - yf);  // filtro digital (decimador) de yk

    if (mCtr % m == 0) {  // Decimação por m
      ya = yf;            // amostra a variável yc filtrada decimada por m.
      u_LED = !u_LED;
      //digitalWrite(LED_BUILTIN, u_LED);   // turn the LED on/off
    }
    //*** ES - Escrever Saídas ..............................................
    yk_1 = yk;  // Salva o valor medido yk para calcular a compensação!

    // Imprime detalhadamente as amostras
    String TxStr = "t:" + String(t_atual) + "," + "yk:" + String(yk) + "," + "yc:" + String(yc) + "," + "yf:" + String(yf) + "," + "ya:" + String(ya) + ",";
    Serial.println(TxStr);  // envia mensagem para o terminal
    sendData(t_atual, yk, yc, yf, ya);// envia mensagem para o bluetooth

  }  //*** Fim de LE-RL-ES **********************************************

  //=== TOC: Tempo OCioso ==============================================
  gerenciarReconexaoBluetooth();  // Verifica se a conexão BLE esta ativa

  if (updateOk == 1) {
    atualizaCompensador(p_h, p_m, b, a);
    updateOk = 0;
  }
  //=== Fim do TOC: Tempo OCioso =======================================

}  // fim do loop()
//=============================================================================================

void atualizaCompensador(double h_x, unsigned int m_x, double b_x, double a_x) {
  // Função de Transferência do compensador em s
  // G = (b*s + 1)/(a*s + 1) e as respectivas constantes com a aproximação de Tustin
  m = m_x;                                // fator de decimação
  h = (unsigned long)(1000 * h_x + 0.5);  // intervalo de amostragem, transforma segundos em milli-segundos (round)
  hs = h_x;                               // intervalo de amostragem em s
  gama = (2.0 * b_x + hs) / (2.0 * a_x + hs);
  beta = (2.0 * b_x - hs) / (2.0 * b_x + hs);
  alfa = (2.0 * a_x - hs) / (2.0 * a_x + hs);
  alfa_f = 2.0 / (2.0 * m_x + 1.0);
  // String TxStr ="m:"+String(m_x)+" "+"h:"+String(h)+" "+"bx:"+String(b_x)+" "+"ax:"+String(a_x)+" "+ "gama:"+String(gama)+" "+ "beta:"+String(beta)+" "+"alfa:" + String(alfa)+" "+"alfa_f:" + String(alfa_f);
  // Serial.println(TxStr);
  //--- Fim do ajuste de parâmetros do filtro compensador ------
}
