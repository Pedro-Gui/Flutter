#include "ble_utils.h"

bool deviceConnected = false;
bool oldDeviceConnected = false;

BLEServer* server = NULL;
// SERVIÇO 1: Transmissão de variáveis
#define SAMPLE_UUID "10000000-1fb5-459e-8fcc-c5c9c331914b"
#define T_UUID "10000001-1fb5-459e-8fcc-c5c9c331914b"
#define YK_UUID "10000002-1fb5-459e-8fcc-c5c9c331914b"
#define YC_UUID "10000003-1fb5-459e-8fcc-c5c9c331914b"
#define YF_UUID "10000004-1fb5-459e-8fcc-c5c9c331914b"
#define YA_UUID "10000005-1fb5-459e-8fcc-c5c9c331914b"
BLECharacteristic* TX_T = NULL;
BLECharacteristic* TX_YK = NULL;
BLECharacteristic* TX_YC = NULL;
BLECharacteristic* TX_YF = NULL;
BLECharacteristic* TX_YA = NULL;
// SERVIÇO 2: Controle de Variáveis de Processo
#define CONTROL_UUID "20000000-1fb5-459e-8fcc-c5c9c331914b"
#define H_UUID "20000001-1fb5-459e-8fcc-c5c9c331914b"
#define M_UUID "20000002-1fb5-459e-8fcc-c5c9c331914b"
#define B_UUID "20000003-1fb5-459e-8fcc-c5c9c331914b"
#define A_UUID "20000004-1fb5-459e-8fcc-c5c9c331914b"
#define OK_UUID "20000005-1fb5-459e-8fcc-c5c9c331914b"
BLECharacteristic* RX_H = NULL;
BLECharacteristic* RX_M = NULL;
BLECharacteristic* RX_B = NULL;
BLECharacteristic* RX_A = NULL;
BLECharacteristic* RX_OK = NULL;

// SERVIÇO 3: Atuadores (LED)
#define LED_ACTUATOR_UUID "30000000-1fb5-459e-8fcc-c5c9c331914b"
#define LED_CARAC_UUID "30000001-1fb5-459e-8fcc-c5c9c331914b"
BLECharacteristic* RX_LED = NULL;


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

template<typename T>  // polimorfismo usando T
class controlCallbacks : public BLECharacteristicCallbacks {
    private:
      T* targetPtr;

    public:
      controlCallbacks(T* ptr): targetPtr(ptr) {}

      void onWrite(BLECharacteristic* characteristic) override {
        uint8_t* rxData = characteristic->getData();
        size_t rxLength = characteristic->getLength();
        if (rxLength == sizeof(T)) {
          T newVal;
          memcpy(&newVal, rxData, sizeof(T));

          if (targetPtr != nullptr) {
            *targetPtr = newVal;
          }

          Serial.println("*********");
          Serial.print("Novo valor recebido: ");
          Serial.println(*targetPtr);
          Serial.println("*********");
        } else {
          characteristic->setValue((uint8_t*)targetPtr, sizeof(T));
        }
      }
  };

class ledCallbacks : public BLECharacteristicCallbacks {
public:
  void onWrite(BLECharacteristic* characteristic) override {
    uint8_t* rxData = characteristic->getData();
    size_t rxLength = characteristic->getLength();

    // Validação: Verifica se o tamanho do dado recebido é exatamente um double (8 bytes)
    if (rxLength == sizeof(double)) {
      double ledCommand;
      memcpy(&ledCommand, rxData, sizeof(double));

      Serial.println("*********");
      Serial.print("Novo Comando LED Recebido: ");
      Serial.println(ledCommand, 1);  // Exibe com 1 casa decimal (ex: 1.0 ou 0.0)

      // Executa a ação baseada no valor numérico do double
      if (ledCommand == 1.0) {
        Serial.println("Acao: Ligando LED");
        digitalWrite(LED_BUILTIN, LOW);
      } else if (ledCommand == 0.0) {
        Serial.println("Acao: Desligando LED");
        digitalWrite(LED_BUILTIN, HIGH);
      }
      Serial.println("*********");
    } else {
      double currentStatus = (digitalRead(LED_BUILTIN) == HIGH) ? 1.0 : 0.0;
      characteristic->setValue((uint8_t*)&currentStatus, sizeof(double));
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
void initBluetooth(double* p_h, unsigned int* p_m, double* p_b, double* p_a, int* p_updateOk) {
  BLEDevice::init("CTR_Termometer");
  server = BLEDevice::createServer();
  server->setCallbacks(new MyServerCallbacks());

  // === SERVIÇO 1: Transmissão de variaveis ===
  BLEService* sampleService = server->createService(SAMPLE_UUID);
  TX_T = createMyCharacteristic(
    sampleService,
    T_UUID,
    BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_NOTIFY,
    "Time");
  TX_YK = createMyCharacteristic(
    sampleService,
    YK_UUID,
    BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_NOTIFY,
    "Sinal de entrada");
  TX_YC = createMyCharacteristic(
    sampleService,
    YC_UUID,
    BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_NOTIFY,
    "Sinal compensado");
  TX_YF = createMyCharacteristic(
    sampleService,
    YF_UUID,
    BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_NOTIFY,
    "Sinal compensado filtrado");
  TX_YA = createMyCharacteristic(
    sampleService,
    YA_UUID,
    BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_NOTIFY,
    "Sinal amostrado decimado");
  sampleService->start();

  // === SERVIÇO 2: Controle de Variaveis de Processo ===
  BLEService* controlService = server->createService(CONTROL_UUID);
  RX_H = createMyCharacteristic(
    controlService,
    H_UUID,
    BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE,
    "Intervalo de amostragem",
    new controlCallbacks<double>(p_h));
  RX_H->setValue((uint8_t*)p_h, 8);

  RX_M = createMyCharacteristic(
    controlService,
    M_UUID,
    BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE,
    "Fator de decimação",
    new controlCallbacks<unsigned int>(p_m));
  RX_M->setValue((uint8_t*)p_m, 4);

  RX_B = createMyCharacteristic(
    controlService,
    B_UUID,
    BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE,
    "Constante de tempo a ser compensada",
    new controlCallbacks<double>(p_b));
  RX_B->setValue((uint8_t*)p_b, 8);

  RX_A = createMyCharacteristic(
    controlService,
    A_UUID,
    BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE,
    "Constante de tempo desejada",
    new controlCallbacks<double>(p_a));
  RX_A->setValue((uint8_t*)p_a, 8);

  RX_OK = createMyCharacteristic(
    controlService,
    OK_UUID,
    BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE,
    "Semáforo para controle de atualização",
    new controlCallbacks<int>(p_updateOk));
  RX_OK->setValue((uint8_t*)p_updateOk, 4);

  controlService->start();

  // === SERVIÇO 3: LED ===
  BLEService* ledService = server->createService(LED_ACTUATOR_UUID);
  RX_LED = createMyCharacteristic(
    ledService,
    LED_CARAC_UUID,
    BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE,
    "LED SWITCH",
    new ledCallbacks());
  double currentStatus = (digitalRead(LED_BUILTIN) == HIGH) ? 1.0 : 0.0;
  RX_LED->setValue((uint8_t*)&currentStatus, 8);
  ledService->start();

  // === ADVERTISING ===
  BLEAdvertising* pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SAMPLE_UUID);
  pAdvertising->addServiceUUID(CONTROL_UUID);
  pAdvertising->addServiceUUID(LED_ACTUATOR_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);  // functions that help with iPhone connections issue
  pAdvertising->setMinPreferred(0x12);
  BLEDevice::startAdvertising();
}

void sendData(unsigned long t_atual, double yk, double yc, double yf, double ya) {
  if (deviceConnected) {
    uint32_t t_data = (uint32_t)t_atual;
    TX_T->setValue((uint8_t*)&t_data, sizeof(uint32_t));
    TX_T->notify();

    TX_YK->setValue((uint8_t*)&yk, sizeof(double));
    TX_YK->notify();

    TX_YC->setValue((uint8_t*)&yc, sizeof(double));
    TX_YC->notify();

    TX_YF->setValue((uint8_t*)&yf, sizeof(double));
    TX_YF->notify();

    TX_YA->setValue((uint8_t*)&ya, sizeof(double));
    TX_YA->notify();
  }
}

void gerenciarReconexaoBluetooth() {
  if (!deviceConnected && oldDeviceConnected) {
    static unsigned long t_debounce_adv = 0;
    if (millis() - t_debounce_adv > 5000) {
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
