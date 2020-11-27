/*******************************************************************************
 * Test routines for Absolute Encoder Kuebler 8.5863.1234.G721
 *
 * Thomas Effenberger, 2020
 * 
 ******************************************************************************/


//define control pins
#define RX_DATA       7
#define TX_DATA       8
#define RW_DATA       11

#define RX_CLOCK      9
#define TX_CLOCK      10
#define RW_CLOCK      12


// Encoder Definitions



void setup()
{
    //configure Pins
    pinMode(TX_DATA, OUTPUT);
    pinMode(RW_DATA, OUTPUT);
    pinMode(TX_CLOCK, OUTPUT);
    pinMode(RW_CLOCK, OUTPUT);
    
    //digitalWrite(RW_DATA, 1);
    //digitalWrite(RW_CLOCK, 0);
    
    // Start Serial Communication
    Serial.begin(9600);
    
    /*Serial1.setTX(TX_DATA);
    Serial1.setRX(RX_DATA);
    Serial1.transmitterEnable(RW_DATA);
    Serial1.begin(1000000);*/
    
    Serial2.transmitterEnable(RW_CLOCK);
    Serial2.begin(100000);

    Serial3.transmitterEnable(RW_DATA);
    Serial3.begin(100000);
    
}

/** Returns 16bit analog data from LTC231116
 * Automatically wakes device if in nap or sleep mode
 */


void loop()
{

    //Serial2.write(0xAA);
    Serial3.write(0x55);
    //delayMicroseconds(10);
    //Serial2.write(0x55);
    //Serial3.write(0x55);
    
    delayMicroseconds(10);
    
    if (Serial2.available())
    {
        Serial.println(String(Serial2.read()));
    }
    
//    digitalWrite(TX_DATA, 1);
//    digitalWrite(RW_DATA, 1);
//    delayMicroseconds(1);
//    digitalWrite(RW_DATA, 0);
//    delayMicroseconds(1);
    

    
    delay(100);
}
