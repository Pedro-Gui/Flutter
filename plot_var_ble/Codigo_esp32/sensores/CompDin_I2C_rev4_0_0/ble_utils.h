#ifndef BLE_UTILS_H
#define BLE_UTILS_H

#include <Arduino.h>

#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

// --- Funções Públicas ---
void initBluetooth(double* p_h, unsigned int* p_m, double* b, double* a, bool* updateOk);
void sendData(unsigned long t_atual, double yk, double yc, double yf, double ya);
void gerenciarReconexaoBluetooth();
void sync_updateOK(bool updateOK);
#endif