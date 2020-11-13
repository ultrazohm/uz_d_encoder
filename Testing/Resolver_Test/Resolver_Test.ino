/*******************************************************************************
 * Test routines for resolver chip AD2S1210
 *
 * Thomas Effenberger, 2020
 * 
 ******************************************************************************/
#include <SPI.h>


//define SPI pins
//#define MOSI0     11
//#define MISO0     12
//#define SCK0      13
#define CS          2
#define N_SAMPLE    3
#define RESET       4
#define CONF_A0     24
#define CONF_A1     25
#define FSYNC       26



// AD2S1210 Definitions
#define AD2S1210_MSB_IS_HIGH          0x80
#define AD2S1210_MSB_IS_LOW           0x7F
#define AD2S1210_PHASE_LOCK_RANGE_44  0x20
#define AD2S1210_ENABLE_HYSTERESIS    0x10
#define AD2S1210_SET_ENRES1           0x08
#define AD2S1210_SET_ENRES0           0x04
#define AD2S1210_SET_RES1             0x02
#define AD2S1210_SET_RES0             0x01
#define AD2S1210_SET_RESOLUTION       (AD2S1210_SET_RES1 | AD2S1210_SET_RES0)

// AD2S1210 Registers
#define AD2S1210_REG_POSITION_HIGH    0x80    // Read only
#define AD2S1210_REG_POSITION_LOW     0x81    // Read only
#define AD2S1210_REG_VELOCITY_HIGH    0x82    // Read only
#define AD2S1210_REG_VELOCITY_LOW     0x83    // Read only
#define AD2S1210_REG_LOS_THRD         0x88    // Read/Write
#define AD2S1210_REG_DOS_OVR_THRD     0x89    // Read/Write
#define AD2S1210_REG_DOS_MIS_THRD     0x8A    // Read/Write
#define AD2S1210_REG_DOS_RST_MAX_THRD 0x8B    // Read/Write
#define AD2S1210_REG_DOS_RST_MIN_THRD 0x8C    // Read/Write
#define AD2S1210_REG_LOT_HIGH_THRD    0x8D    // Read/Write
#define AD2S1210_REG_LOT_LOW_THRD     0x8E    // Read/Write
#define AD2S1210_REG_EXCIT_FREQ       0x91    // Read/Write
#define AD2S1210_REG_CONTROL          0x92    // Read/Write
#define AD2S1210_REG_SOFT_RESET       0xF0    // Write only
#define AD2S1210_REG_FAULT            0xFF    // Read only

// AD2S1210 Limits
#define AD2S1210_MIN_CLKIN            6144000
#define AD2S1210_MAX_CLKIN            10240000
#define AD2S1210_MIN_EXCIT            2000
#define AD2S1210_MAX_EXCIT            20000
#define AD2S1210_MIN_FCW              0x4
#define AD2S1210_MAX_FCW              0x50

// User definitions
#define AD2S1210_DEF_F_CLKIN          8000000 // Clock Frequency
#define AD2S1210_DEF_EXCIT            10000   // Excitation Frequency
#define AD2S1210_DEF_CONTROL          0x7E    // Control Register


/** Operating Mode of AD2S1210.
 * Position: Directly read position data
 * Velocity: Directly read velocity data
 * Config: Configuration mode for editing registers
 */
typedef enum Mode
{
    Position,
    Velocity,
    Config
};

Mode mode;




void setup()
{
    //configure Pins
    pinMode(CS, OUTPUT);
    pinMode(N_SAMPLE, OUTPUT);
    pinMode(RESET, OUTPUT);
    pinMode(CONF_A0, OUTPUT);
    pinMode(CONF_A1, OUTPUT);
    pinMode(FSYNC, OUTPUT);
    
    //SPI Config
    SPISettings settings(1000000, MSBFIRST, SPI_MODE1);
    SPI.begin();
    SPI.beginTransaction(settings);
    
    // Start Serial Communication
    Serial.begin(9600);
    
    digitalWrite(RESET, 0);
    digitalWrite(CS, 0);
    digitalWrite(N_SAMPLE, 1);
    digitalWrite(FSYNC, 1);
    
    delay(100);
    digitalWrite(RESET, 1);
    
    
    AD2S1210_setMode(Config);

    // Wait some time until AD2S1210 is ready
    delay(1);

    // Configure Control Register:
    // D7: Adress/Data-Bit = 0
    // D6: Reserved = 1
    // D5: Phase Lock Range = 1
    // D4: Hysteresis enabled
    // D3: Encoder Resolution EnRES1 = 1 (for 16bit)
    // D2: Encoder Resolution EnRES0 = 1 (for 16bit)
    // D1: Resolution in config mode RES1 = 1 (for 16bit)
    // D0: Resolution in config mode RES0 = 1 (for 16bit)
    AD2S1210_write_register(AD2S1210_REG_CONTROL, AD2S1210_DEF_CONTROL);

    // Set Excitation Frequency
    // Default at power-up: 0x28 (10kHz at 8MHz System Frequency)
    AD2S1210_set_Excitation_Frequency(AD2S1210_DEF_EXCIT);

    // Set Operating Mode
    AD2S1210_setMode(Velocity);
    //AD2S1210_setMode(Position);
}

//* Sets the operating mode of the AD2S1210
void AD2S1210_setMode(Mode m)
{
    switch (m)
    {
        case Position:
        {
            digitalWrite(CONF_A0, 0);
            digitalWrite(CONF_A1, 0);
        }
        break;
        case Velocity:
        {
            digitalWrite(CONF_A0, 0);
            digitalWrite(CONF_A1, 1);
        }
        break;
        case Config:
        {
            digitalWrite(CONF_A0, 1);
            digitalWrite(CONF_A1, 1);
        }
        break;
    }

    mode = m;
}

//* Returns either position or velocity data depending on the operating mode
uint16_t AD2S1210_readNormal()
{
    // Initiate one sample by toggling the sample pin
    digitalWrite(N_SAMPLE, 0);
    delay(1);
    digitalWrite(N_SAMPLE, 1);

    // Read back data
    digitalWrite(FSYNC, 0);
    uint8_t val_high = SPI.transfer(0x00);
    uint8_t val_low  = SPI.transfer(0x00);
    //uint8_t faults   = SPI.transfer(0x00);
    digitalWrite(FSYNC, 1);
    
    return (val_high << 8) | val_low;
}

/** Reads one byte at given address.
 * Function can only be used in configuration mode
 */
uint8_t AD2S1210_read_register(uint8_t adr)
{
    digitalWrite(FSYNC, 0);
    SPI.transfer(adr);
    digitalWrite(FSYNC, 1);
    
    digitalWrite(FSYNC, 0);
    uint8_t val = SPI.transfer(AD2S1210_REG_FAULT);
    digitalWrite(FSYNC, 1);

    return val;
}

/** Writes one byte into given address.
 * Function can only be used in configuration mode
 */
void AD2S1210_write_register(uint8_t adr, uint8_t val)
{
    digitalWrite(FSYNC, 0);
    SPI.transfer(adr);
    digitalWrite(FSYNC, 1);
    
    digitalWrite(FSYNC, 0);
    SPI.transfer(val & AD2S1210_MSB_IS_LOW);
    digitalWrite(FSYNC, 1);
}

/** Sets excitation frequency.
 * The frequency is limited by AD2S1210_MIN_EXCIT and AD2S1210_MAX_EXCIT
 * The register value calculated from the frequency is limited by AD2S1210_MIN_FCW and AD2S1210_MAX_FCW
 * Function can only be used in configuration mode
 */
void AD2S1210_set_Excitation_Frequency(uint32_t f)
{
    if (f < AD2S1210_MIN_EXCIT) f = AD2S1210_MIN_EXCIT;
    if (f > AD2S1210_MAX_EXCIT) f = AD2S1210_MAX_EXCIT;
    
    uint8_t fcw = (f << 15) / AD2S1210_DEF_F_CLKIN;

    if (fcw < AD2S1210_MIN_FCW) fcw = AD2S1210_MIN_FCW;
    if (fcw > AD2S1210_MAX_FCW) fcw = AD2S1210_MAX_FCW;

    AD2S1210_write_register(AD2S1210_REG_EXCIT_FREQ, fcw);
}

/** Initiates a software reset.
 * Function can only be used in configuration mode
 */
void AD2S1210_software_Reset()
{
    digitalWrite(FSYNC, 0);
    SPI.transfer(AD2S1210_REG_SOFT_RESET);
    digitalWrite(FSYNC, 1);
}

void loop()
{
    /* Testing configuration mode */
    
    // In configuration mode initiate sampling manually
    //digitalWrite(N_SAMPLE, 0);
    //delay(1);
    //digitalWrite(N_SAMPLE, 1);

    // Use for position reading (uint16_t)
    //uint16_t data = ((AD2S1210_read_register(AD2S1210_REG_POSITION_HIGH) << 8) | AD2S1210_read_register(AD2S1210_REG_POSITION_LOW));
    // Use for velocity reading (int16_t)
    //int16_t data = (int16_t)((AD2S1210_read_register(AD2S1210_REG_VELOCITY_HIGH) << 8) | AD2S1210_read_register(AD2S1210_REG_VELOCITY_LOW));
    
    //Serial.print(String(data) + "\n");



    /* Testing normal mode */

    // Use for position reading (uint16_t)
    //Serial.print(String(AD2S1210_readNormal()) + "\n");

    // Use for velocity reading (int16_t)
    Serial.print(String((int16_t)AD2S1210_readNormal()) + "\n");

    
    
    delay(100);
}
