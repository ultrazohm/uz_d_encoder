/*******************************************************************************
 * Test routines for resolver chip AD2S1210
 *
 * Thomas Effenberger, 2020
 * 
 ******************************************************************************/
#include <SPI.h>


//define SPI pins
//#define MOSI0     11  // Unused
//#define MISO0     12
//#define SCK0      13
#define N_CVN       3


// LTC2311-16 Definitions
#define T_ACQ       1   // Acquisition Time in us, minimum 28.5ns
#define T_DCNVSCKL  1   // SCK Quiet Time from CNV falling edge in us, minimum 9.5n


void setup()
{
    //configure Pins
    pinMode(N_CVN, OUTPUT);
    
    //SPI Config
    SPISettings settings(1000000, MSBFIRST, SPI_MODE3);
    SPI.begin();
    SPI.beginTransaction(settings);
    
    // Start Serial Communication
    Serial.begin(9600);
    
    digitalWrite(N_CVN, 0);
}

uint16_t LTC231116_read()
{
    digitalWrite(N_CVN, 1);
    
    delayMicroseconds(T_ACQ);
    
    digitalWrite(N_CVN, 0);

    delayMicroseconds(T_DCNVSCKL);

    uint8_t val1 = SPI.transfer(0x00);
    uint8_t val2 = SPI.transfer(0x00);

    return (val1 << 8) | val2;
}



void loop()
{

    Serial.print(String(LTC231116_read()) + "\n");


    
    
    delay(100);
}
