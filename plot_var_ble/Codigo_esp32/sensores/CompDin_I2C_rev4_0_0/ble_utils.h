#ifndef BLE_UTILS_H
#define BLE_UTILS_H

#include <Arduino.h>

#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

// --- Variáveis globais  ---
extern BLECharacteristic* TX_SIN;
extern bool deviceConnected;
extern bool oldDeviceConnected;
extern float step; 

// --- Funções Públicas ---
void inicializarBluetooth();
void gerenciarReconexaoBluetooth();

#endif