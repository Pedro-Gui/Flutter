#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <math.h>

#define LED_BUILTIN 2
// --- Configurações BLE ---
#define SIN_UUID "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"
#define STEP_CARAC_UUID     "bec5483e-36e1-4688-b7f5-ea07361b26a8"

#define LED_ACTUATOR_UUID   "4fbfc201-1fb5-459e-8fcc-c5c9c331914b"
#define LED_CARAC_UUID "beb9483e-36e1-4688-b7f5-ea07361b26a8"

BLEServer* pServer = NULL;
BLECharacteristic* TX_SIN = NULL;
BLECharacteristic* RX_LED = NULL;
BLECharacteristic* RX_STEP = NULL;
bool deviceConnected = false;
bool oldDeviceConnected = false;

// --- Variáveis de Temporização (Non-blocking) ---
unsigned long t_atual = 0;
unsigned long t_alvo = 0;
const unsigned long h = 20;  // Intervalo de 20ms (50Hz)

// --- Variáveis da Senoide ---
float sineValue = 0;
float angle = 0;
float step = 0.1;

class MyServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer* pServer) {
    Serial.println("Conectado");
    deviceConnected = true;
  };
  void onDisconnect(BLEServer* pServer) {
    Serial.println("Desconectado");
    deviceConnected = false;
  }
};

class CharacteristicCallbacksLED: public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *characteristic) {
      //retorna ponteiro para o registrador contendo o valor atual da caracteristica
      std::string rxValue = characteristic->getValue().c_str(); 
      //verifica se existe dados (tamanho maior que zero)
      if (rxValue.length() > 0) {
        Serial.println("*********");
        Serial.print("Received Value Actuator: ");

        for (int i = 0; i < rxValue.length(); i++) {
          Serial.print(rxValue[i]);
        }

        Serial.println();

        // Do stuff based on the command received
        if (rxValue.find("1") != -1) { 
          Serial.print("Ligando LED");         
          digitalWrite(LED_BUILTIN, HIGH);
        }
        else if (rxValue.find("0") != -1) {
          Serial.print("Desligando LED"); 
          digitalWrite(LED_BUILTIN, LOW);
        }

        Serial.println();
        Serial.println("*********");
      }
    }
};

class CharacteristicCallbacksSTEP: public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *characteristic) {
      //retorna ponteiro para o registrador contendo o valor atual da caracteristica
      std::string rxValue = characteristic->getValue().c_str(); 
      //verifica se existe dados (tamanho maior que zero)
      if (rxValue.length() > 0) {
        Serial.println("*********");
        Serial.print("Received Value Actuator: ");

        for (int i = 0; i < rxValue.length(); i++) {
          Serial.print(rxValue[i]);
        }

        Serial.println();

        // Do stuff based on the command received
        if (rxValue.length() != -1) { 
          Serial.println("Step alterado");
          step = (float)atof(rxValue.c_str());
        }

        Serial.println();
        Serial.println("*********");
      }
    }
};

// Função auxiliar para criar características de forma enxuta
BLECharacteristic* createMyCharacteristic(
    BLEService* pService, 
    const char* uuid, 
    uint32_t properties, 
    const char* descriptorText, 
    BLECharacteristicCallbacks* pCallbacks = nullptr 
) {
    BLECharacteristic* pChar = pService->createCharacteristic(uuid, properties);

    BLEDescriptor* pDesc = new BLEDescriptor(BLEUUID((uint16_t)0x2901));
    pDesc->setAccessPermissions(ESP_GATT_PERM_READ);
    pDesc->setValue(descriptorText);
    pChar->addDescriptor(pDesc);

    if (properties & BLECharacteristic::PROPERTY_NOTIFY) {
        pChar->addDescriptor(new BLE2902());
    }

    if (pCallbacks != nullptr) {
        pChar->setCallbacks(pCallbacks);
    }

    return pChar;
}

void setup() {
  Serial.begin(115200);
  pinMode(LED_BUILTIN, OUTPUT);

  BLEDevice::init("ESP32_Senoide");
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  // === SERVIÇO 1: SENOIDE ===
  BLEService* pService = pServer->createService(SIN_UUID);
  TX_SIN = createMyCharacteristic(
      pService, 
      CHARACTERISTIC_UUID, 
      BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_NOTIFY, 
      "SIN"
  );
  RX_STEP = createMyCharacteristic(
      pService, 
      STEP_CARAC_UUID, 
      BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE, 
      "STEP VALUE", 
      new CharacteristicCallbacksSTEP() 
  );  
  pService->start();


  // === SERVIÇO 2: LED ===
  BLEService* ledService = pServer->createService(LED_ACTUATOR_UUID);
  RX_LED = createMyCharacteristic(
      ledService, 
      LED_CARAC_UUID, 
      BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE, 
      "LED SWITCH", 
      new CharacteristicCallbacksLED() 
  );
  ledService->start();


  // === ADVERTISING ===
  BLEAdvertising* pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SIN_UUID);
  pAdvertising->addServiceUUID(LED_ACTUATOR_UUID);
  BLEDevice::startAdvertising();

  t_atual = millis();
  t_alvo = t_atual;
  Serial.println("Sistema iniciado. Aguardando conexão...");
}

void loop() {
  t_atual = millis();

  // --- TAC: Tempo Ativo de Comando (Cadenciado por h) ---
  if ((unsigned long)(t_atual - t_alvo) >= h) {
    t_alvo = t_alvo + h;
    // LE: Ler Entradas (Neste caso, o ângulo atual)
    // RL: Resolver Lógica
    if (deviceConnected) {
      sineValue = sin(angle);
      angle += step;
      if (angle > 2 * PI) angle = 0;
      // ES: Escrever Saídas (Notificação BLE)

      /* 
      // Escrevendo em utf8 string
      String buff = String(sineValue);
      TX_SIN->setValue((uint8_t*)buff.c_str(), buff.length());
      */
      
      // Escrevendo em utf8 float little endian
      TX_SIN->setValue((uint8_t*)&sineValue, 4);
      
      TX_SIN->notify();
    }
  }

  // === TOC: Tempo OCioso (Tarefas de baixa prioridade ou assíncronas) ===

  // Gerenciamento de reconexão automática
  if (!deviceConnected && oldDeviceConnected) {
    static unsigned long t_debounce_adv = 0;
    if (millis() - t_debounce_adv > 500) {
      pServer->startAdvertising();
      Serial.println("Reiniciando advertising...");
      oldDeviceConnected = deviceConnected;
      t_debounce_adv = millis();
    }
  }

  if (deviceConnected && !oldDeviceConnected) {
    oldDeviceConnected = deviceConnected;
  }
}