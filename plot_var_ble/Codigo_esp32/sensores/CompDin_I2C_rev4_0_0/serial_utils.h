#ifndef SERIAL_UTIL_H
#define SERIAL_UTIL_H

#include <Arduino.h>

// Função para vincular as variáveis do .ino com a biblioteca no setup()
void initSerial(double* p_h_ref, unsigned int* p_m_ref, double* b_ref, double* a_ref, bool* updateOk_ref);

// Função de gerenciamento que roda no loop()
void handleSerial();

#endif