#include "ble_utils.h" 

#define SIN_UUID "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"
#define STEP_CARAC_UUID "bec5483e-36e1-4688-b7f5-ea07361b26a8"

#define LED_ACTUATOR_UUID "4fbfc201-1fb5-459e-8fcc-c5c9c331914b"
#define LED_CARAC_UUID "beb9483e-36e1-4688-b7f5-ea07361b26a8"

BLEServer* server = NULL;
BLECharacteristic* TX_SIN = NULL;
BLECharacteristic* RX_LED = NULL;
BLECharacteristic* RX_STEP = NULL;
bool deviceConnected = false;
bool oldDeviceConnected = false;
float step = 0.1; 

class MyServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer* server) {
    Serial.println("Conectado");
    deviceConnected = true;
  };
  void onDisconnect(BLEServer* server) {
    Serial.println("Desconectado");
    deviceConnected = false;
  }
};

class CharacteristicCallbacksLED : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic* characteristic) {
    std::string rxValue = characteristic->getValue().c_str();
    if (rxValue.length() > 0) {
      Serial.println("*********");
      Serial.print("Received Value Actuator: ");
      for (int i = 0; i < rxValue.length(); i++) {
        Serial.print(rxValue[i]);
      }
      Serial.println();

      if (rxValue.find("1") != -1) {
        Serial.print("Ligando LED");
        digitalWrite(LED_BUILTIN, HIGH);
      } else if (rxValue.find("0") != -1) {
        Serial.print("Desligando LED");
        digitalWrite(LED_BUILTIN, LOW);
      }
      Serial.println("\n*********");
    }
  }
};

class CharacteristicCallbacksSTEP : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic* characteristic) {
    uint8_t* rxData = characteristic->getData();
    size_t rxLength = characteristic->getLength();

    if (rxLength == sizeof(double)) {
      double novoStep;
      memcpy(&novoStep, rxData, sizeof(double));
      step = (float)novoStep;

      Serial.println("*********");
      Serial.print("Novo Step Recebido: ");
      Serial.println(step);
      Serial.println("*********");
    }
  }
};

// --- Função Auxiliar de Criação de Características ---
BLECharacteristic* createMyCharacteristic(
  BLEService* pService,
  const char* uuid,
  uint32_t properties,
  const char* descriptorText,
  BLECharacteristicCallbacks* pCallbacks = nullptr) {
  
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

// --- Funções Públicas ---
void inicializarBluetooth() {

  BLEDevice::init("ESP32_Senoide");
  server = BLEDevice::createServer();
  server->setCallbacks(new MyServerCallbacks());

  // === SERVIÇO 1: SENOIDE ===
  BLEService* sinService = server->createService(SIN_UUID);
  TX_SIN = createMyCharacteristic(
    sinService,
    CHARACTERISTIC_UUID,
    BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_NOTIFY,
    "SIN");
  RX_STEP = createMyCharacteristic(
    sinService,
    STEP_CARAC_UUID,
    BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE,
    "STEP VALUE",
    new CharacteristicCallbacksSTEP());
  RX_STEP->setValue((uint8_t*)&step, 4);
  sinService->start();

  // === SERVIÇO 2: LED ===
  BLEService* ledService = server->createService(LED_ACTUATOR_UUID);
  RX_LED = createMyCharacteristic(
    ledService,
    LED_CARAC_UUID,
    BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE,
    "LED SWITCH",
    new CharacteristicCallbacksLED());
  RX_LED->setValue("0");
  ledService->start();

  // === ADVERTISING ===
  BLEAdvertising* pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SIN_UUID);
  pAdvertising->addServiceUUID(LED_ACTUATOR_UUID);
  BLEDevice::startAdvertising();
}

void gerenciarReconexaoBluetooth() {
  if (!deviceConnected && oldDeviceConnected) {
    static unsigned long t_debounce_adv = 0;
    if (millis() - t_debounce_adv > 500) {
      server->startAdvertising();
      Serial.println("Reiniciando advertising...");
      oldDeviceConnected = deviceConnected;
      t_debounce_adv = millis();
    }
  }

  if (deviceConnected && !oldDeviceConnected) {
    oldDeviceConnected = deviceConnected;
  }
}
