/*******************************************************************************
 * Test routines for ADC chip LTC231116
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

/** Returns 16bit analog data from LTC231116
 * Automatically wakes device if in nap or sleep mode
 */
int16_t LTC231116_read()
{
    digitalWrite(N_CVN, 1);
    
    delayMicroseconds(T_ACQ);
    
    digitalWrite(N_CVN, 0);

    delayMicroseconds(T_DCNVSCKL);

    uint8_t val1 = SPI.transfer(0x00);
    uint8_t val2 = SPI.transfer(0x00);

    return (int16_t) ((val1 << 8) | val2);
}

/** Puts device in nap mode by pulsing N_CVN twice
 * Wake up with positive edge on SCK or by calling LTC231116_read()
 */
void LTC231116_NapMode()
{
    digitalWrite(N_CVN, 1);
    delayMicroseconds(T_ACQ);
    digitalWrite(N_CVN, 0);
    delayMicroseconds(T_ACQ);
    digitalWrite(N_CVN, 1);
    delayMicroseconds(T_ACQ);
    digitalWrite(N_CVN, 0);
}

/** Puts device in sleep mode by pulsing N_CVN four times
 * Wake up with positive edge on SCK or by calling LTC231116_read()
 */
void LTC231116_SleepMode()
{
    LTC231116_NapMode();
    LTC231116_NapMode();
}

void loop()
{

    Serial.print(String(LTC231116_read()) + "\n");


    
    
    delay(100);
}
