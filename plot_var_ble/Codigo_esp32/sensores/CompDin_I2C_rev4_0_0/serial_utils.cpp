#include "serial_utils.h"

// --- Variáveis internas ---
String inputString = ""; 
bool stringRxComplete = false; 

// --- Ponteiros para as variáveis globais ---
static double* ptr_h = nullptr;
static unsigned int* ptr_m = nullptr;
static double* ptr_b = nullptr;
static double* ptr_a = nullptr;
static bool* ptr_updateOk = nullptr;

void initSerial(double* p_h, unsigned int* p_m, double* b, double* a, bool* updateOk) {
  ptr_h = p_h;
  ptr_m = p_m;
  ptr_b = b;
  ptr_a = a;
  ptr_updateOk = updateOk;
}

void interpretMessage() {
    String stringAux = "aux"; 
    String stringEdt = "par = 1234567"; 
    int parNameIndex = -1;
    int msgIndex = -1;
    boolean passToNext = false;
    
    msgIndex = inputString.indexOf(';'); // Índice do caracter de fim de mensagem

    if(msgIndex != -1) { 
      stringEdt = inputString.substring(0, msgIndex); // Mensagem a ser interpretada     
      inputString = inputString.substring(msgIndex+1); // Restante da msg para o próximo passo

      // Verifica sempre se o ponteiro não é nulo antes de escrever para evitar crashes
      
      // case "h"
      parNameIndex = stringEdt.indexOf("h=");
      if (parNameIndex != -1 && !passToNext && ptr_h != nullptr) { 
        stringAux = stringEdt.substring(parNameIndex+2);
        *ptr_h = stringAux.toDouble(); 
        passToNext = true;
      }
      
      // case "m"
      parNameIndex = stringEdt.indexOf("m=");
      if (parNameIndex != -1 && !passToNext && ptr_m != nullptr) { 
        stringAux = stringEdt.substring(parNameIndex+2);
        *ptr_m = (unsigned int) stringAux.toInt(); 
        passToNext = true;
      }
      
      // case "b":
      parNameIndex = stringEdt.indexOf("b=");
      if (parNameIndex != -1 && !passToNext && ptr_b != nullptr) { 
        stringAux = stringEdt.substring(parNameIndex+2);
        *ptr_b = stringAux.toDouble();
        passToNext = true;
      }
      
      // case "a":
      parNameIndex = stringEdt.indexOf("a=");
      if (parNameIndex != -1 && !passToNext && ptr_a != nullptr) { 
        stringAux = stringEdt.substring(parNameIndex+2);
        *ptr_a = stringAux.toDouble();
        passToNext = true;
      }
      
      // case "ok":
      parNameIndex = stringEdt.indexOf("ok=");
      if (parNameIndex != -1 && !passToNext && ptr_updateOk != nullptr) { 
        stringAux = stringEdt.substring(parNameIndex+3);
        *ptr_updateOk = (stringAux.toInt() != 0);
        passToNext = true;
      }
    } else { 
      // Fim da mensagem: limpa tudo e aguarda nova string
      inputString = ""; 
      stringRxComplete = false; 
    }
}

// --- Função Pública Principal ---
void handleSerial() {
  // 1. Lê a porta serial
  while (Serial.available()) {
    char inChar = (char)Serial.read();
    inputString += inChar;
    
    if (inChar == '\n') {
      stringRxComplete = true;
    }
  }

  // 2. Se a mensagem está completa, passa para o interpretador
  if (stringRxComplete) {
    interpretMessage();
  }
}