----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.12.2021 14:10:31
-- Design Name: 
-- Module Name: AD2S1210_Parallel_Interface - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity AD2S1210_Parallel_Interface is
    Generic(
        SPI_Datalength     : INTEGER   :=  8                    -- SPI data length
    );
    Port (
        clock              : IN  STD_LOGIC;                      -- system clock
        reset_n            : IN  STD_LOGIC;                      -- synchronous reset
        enable             : IN  STD_LOGIC;                      -- system enable
        go_sig             : IN  STD_LOGIC;                      -- global trigger
        busy               : OUT STD_LOGIC;                      -- busy / data ready signal
        error_flag         : OUT STD_LOGIC;                      -- error occurred, reset needed
        dataMode           : IN  STD_LOGIC;                      -- 0 = position mode, 1 = velocity mode
        configMode         : IN  STD_LOGIC;                      -- if configMode = 1, dataMode is ignored
        register_rw        : IN  STD_LOGIC;                      -- 0 = read register, 1 = write register
        register_adr_in    : IN  STD_LOGIC_VECTOR (7 downto 0);  -- register address
        register_val_in    : IN  STD_LOGIC_VECTOR (7 downto 0);  -- value to write to register
        register_val_out   : OUT STD_LOGIC_VECTOR (7 downto 0);  -- read value from register
        data_out           : OUT STD_LOGIC_VECTOR (15 downto 0); -- read value in normal mode
        --               
        DB_0               : BUFFER STD_LOGIC;                   -- DB0 (connect to chip)
        DB_1               : BUFFER STD_LOGIC;                   -- DB1 (connect to chip)
        DB_2               : BUFFER STD_LOGIC;                   -- DB2 (connect to chip)
        DB_3               : BUFFER STD_LOGIC;                   -- DB3 (connect to chip)
        DB_4               : BUFFER STD_LOGIC;                   -- DB4 (connect to chip)
        DB_5               : BUFFER STD_LOGIC;                   -- DB5 (connect to chip)
        DB_6               : BUFFER STD_LOGIC;                   -- DB6 (connect to chip)
        DB_7               : BUFFER STD_LOGIC;                   -- DB7 (connect to chip)
        
        DB_8               : IN STD_LOGIC;                       -- DB8 (connect to chip)
        DB_9               : IN STD_LOGIC;                       -- DB9 (connect to chip)
        DB_10              : IN STD_LOGIC;                       -- DB10 (connect to chip)
        DB_11              : IN STD_LOGIC;                       -- DB11 (connect to chip)
        DB_12              : IN STD_LOGIC;                       -- DB12 (connect to chip)
        DB_13              : IN STD_LOGIC;                       -- DB13 (connect to chip)
        DB_14              : IN STD_LOGIC;                       -- DB14 (connect to chip)
        DB_15              : IN STD_LOGIC;                       -- DB15 (connect to chip)
        --
        AD2S1210_n_reset   : OUT STD_LOGIC;                      -- reset (connect to chip)
        AD2S1210_n_sample  : OUT STD_LOGIC;                      -- sample start (connect to chip)
        AD2S1210_n_fsync   : OUT STD_LOGIC;                      -- synchronization signal (connect to chip)
        AD2S1210_n_RD      : OUT STD_LOGIC;                      -- RD (connect to chip)
        AD2S1210_n_CS      : OUT STD_LOGIC;                      -- Chip select (connect to chip)
        AD2S1210_mode_A0   : OUT STD_LOGIC;                      -- mode select 0 (connect to chip)
        AD2S1210_mode_A1   : OUT STD_LOGIC                       -- mode select 1 (connect to chip)
    );
end AD2S1210_Interface;

architecture Behavioral of AD2S1210_Interface is

-- Constants ---------------------------------------------------------------------------------------
constant SPI_SEND_DUMMY             : STD_LOGIC_VECTOR  := x"0F";

-- Create signals ----------------------------------------------------------------------------------
type states_AD2S1210_Interface is
(
    Resolver_Powerup,
    Resolver_Resetcounter,
    Resolver_WaitStabilize,
    Resolver_Ready,
    Resolver_StartNormalRead,
    Resolver_WaitSampleTime,
    Resolver_NormalRead,
    Resolver_SendRegisterAddress,
    Resolver_SendRegisterValue,
    Resolver_ReadRegisterValue,
    Resolver_SPI_Waittransmit1,
    Resolver_SPI_Waittransmit2,
    Resolver_Failstate
);
signal state_Resolver_Interface : states_AD2S1210_Interface;
signal laststate_Resolver_Interface : states_AD2S1210_Interface;


signal TX_Data              : std_logic_vector(SPI_Datalength-1 downto 0);  -- Buffer
signal RX_Data              : std_logic_vector(SPI_Datalength-1 downto 0);  -- Buffer


signal wakeup_counter       : unsigned(31 downto 0);
signal sample_counter       : unsigned(7 downto 0);




begin
    
    -- Set A0 and A1 according to mode
    AD2S1210_mode_A1 <= dataMode OR configMode;
    AD2S1210_mode_A0 <= configMode;
    
    AD2S1210_n_CS <= '0';
    
    -- State machine process -----------------------------------------------------------------------
    StateMachine : process (clock,reset_n,enable)
    begin
        if (reset_n = '0') then     -- Reset
            
            TX_Data             <= x"00";
            
            error_flag              <= '0';
            busy                    <= '1';
            
            wakeup_counter          <= (others => '0');
            sample_counter          <= (others => '0');
            
            
            AD2S1210_n_reset        <= '0';
            AD2S1210_n_sample       <= '1';
            AD2S1210_n_fsync        <= '1';
            AD2S1210_n_RD           <= '1';
            AD2S1210_n_CS           <= '0';
            
            register_val_out        <= (others => '0');
            data_out                <= (others => '0');
            
            state_Resolver_Interface        <= Resolver_Powerup;
            laststate_Resolver_Interface    <= Resolver_Powerup;
            
        elsif (reset_n = '1' ) then
            if (rising_edge (clock) AND enable = '1') then
                case (state_Resolver_Interface) is
                ----------------------------------------------------------------------------------------
                    when Resolver_Powerup =>                -- Status at power-up
                        busy                                <= '1';
                        AD2S1210_n_reset                    <= '0';
                        
                        state_Resolver_Interface            <= Resolver_Resetcounter;
                        laststate_Resolver_Interface        <= Resolver_Powerup;
                ----------------------------------------------------------------------------------------
                    when Resolver_Resetcounter =>           -- Wait 10us in reset after power-up
                        if (wakeup_counter >= 1000) then
                            AD2S1210_n_reset                <= '1';
                            wakeup_counter                  <= (others => '0');
                            state_Resolver_Interface        <= Resolver_WaitStabilize;
                            laststate_Resolver_Interface    <= Resolver_Resetcounter;
                        else
                            wakeup_counter                  <= wakeup_counter + 1;
                        end if;
                ----------------------------------------------------------------------------------------
                    when Resolver_WaitStabilize =>          -- Wait 60ms after reset for the internal circuitry to stabilize
                        if (wakeup_counter >= 6000000) then
                            wakeup_counter                  <= (others => '0');
                            state_Resolver_Interface        <= Resolver_Ready;
                            laststate_Resolver_Interface    <= Resolver_WaitStabilize;
                        else
                            wakeup_counter                  <= wakeup_counter + 1;
                        end if;
                ----------------------------------------------------------------------------------------
                    when Resolver_Ready =>                  -- Ready for samples or configuration
                        busy                                <= '0';
                        
                        
                        
                        if (go_sig = '1') then
                            busy                            <= '1';
                            if (configMode = '0') then
                                state_Resolver_Interface    <= Resolver_StartNormalRead;
                            else
                                state_Resolver_Interface    <= Resolver_SendRegisterAddress;
                            end if;
                            
                            laststate_Resolver_Interface    <= Resolver_Ready;
                        end if;
                ----------------------------------------------------------------------------------------
                    when Resolver_StartNormalRead =>        -- Generate sample pulse
                            AD2S1210_n_sample               <= '0';
                            AD2S1210_n_RD                   <= '1';
                            sample_counter                  <= (others => '0');
                            
                            state_Resolver_Interface        <= Resolver_WaitSampleTime;
                            laststate_Resolver_Interface    <= Resolver_StartNormalRead;
                ----------------------------------------------------------------------------------------
                    when Resolver_WaitSampleTime =>         -- Wait sample time 1us (t30 in datasheet)--TODO Timing
                        if (sample_counter >= 100) then
                            sample_counter                  <= (others => '0');
                            state_Resolver_Interface        <= Resolver_NormalRead;
                            laststate_Resolver_Interface    <= Resolver_WaitSampleTime;
                        else
                            sample_counter                  <= sample_counter + 1;
                        end if;
                        
                        if (sample_counter >= 35) then
                            AD2S1210_n_sample               <= '1'; -- Set sample output after 350ns (t16 in datasheet)
                        end if;
                ----------------------------------------------------------------------------------------
                    when Resolver_NormalRead =>             -- Read 16 bits in normal mode
                        
                        --Save results
                        if (byte_tx_counter = 1) then
                            data_out(15 downto 8)           <= SPI_RX_Data(7 downto 0);
                        elsif (byte_tx_counter = 2) then
                            data_out(7 downto 0)            <= SPI_RX_Data(7 downto 0);
                        end if;
                        
                        if (byte_tx_counter < 2) then
                            AD2S1210_n_fsync                <= '0';
                            SPI_TX_Data                     <= SPI_SEND_DUMMY;
                            SPI_enable                      <= '1';
                            SPI_SS                          <= '0';
                            byte_tx_counter                 <= byte_tx_counter + 1;
                            state_Resolver_Interface        <= Resolver_SPI_Waittransmit1;
                            laststate_Resolver_Interface    <= Resolver_NormalRead;
                        else
                            AD2S1210_n_fsync                <= '1';
                            byte_tx_counter                 <= (others => '0');
                            state_Resolver_Interface        <= Resolver_Ready;
                            laststate_Resolver_Interface    <= Resolver_NormalRead;
                        end if;
                ----------------------------------------------------------------------------------------
                    when Resolver_SendRegisterAddress =>    -- Send Register Address
                        if (laststate_Resolver_Interface /= Resolver_SPI_Waittransmit2) then
                            AD2S1210_n_fsync                <= '0';
                            SPI_TX_Data                     <= register_adr_in;
                            SPI_enable                      <= '1';
                            SPI_SS                          <= '0';
                            
                            state_Resolver_Interface        <= Resolver_SPI_Waittransmit1;
                            laststate_Resolver_Interface    <= Resolver_SendRegisterAddress;
                        else
                            AD2S1210_n_fsync                <= '1';
                            
                            if register_rw = '0' then
                                state_Resolver_Interface    <= Resolver_ReadRegisterValue;
                            else
                                state_Resolver_Interface    <= Resolver_SendRegisterValue;
                            end if;
                            
                            laststate_Resolver_Interface    <= Resolver_SendRegisterAddress;
                        end if;
                ----------------------------------------------------------------------------------------
                    when Resolver_ReadRegisterValue =>      -- Read Register Value
                        if (laststate_Resolver_Interface /= Resolver_SPI_Waittransmit2) then
                            AD2S1210_n_fsync                <= '0';
                            SPI_TX_Data                     <= AD2S1210_REG_FAULT;
                            SPI_enable                      <= '1';
                            SPI_SS                          <= '0';
                            
                            state_Resolver_Interface        <= Resolver_SPI_Waittransmit1;
                            laststate_Resolver_Interface    <= Resolver_ReadRegisterValue;
                        else
                            AD2S1210_n_fsync                <= '1';
                            register_val_out                <= SPI_RX_Data;
                            
                            state_Resolver_Interface        <= Resolver_Ready;
                            laststate_Resolver_Interface    <= Resolver_ReadRegisterValue;
                        end if;
                ----------------------------------------------------------------------------------------
                    when Resolver_SendRegisterValue =>      -- Send Register Value
                        if (laststate_Resolver_Interface /= Resolver_SPI_Waittransmit2) then
                            AD2S1210_n_fsync                <= '0';
                            SPI_TX_Data                     <= register_val_in;
                            SPI_enable                      <= '1';
                            SPI_SS                          <= '0';
                            
                            state_Resolver_Interface        <= Resolver_SPI_Waittransmit1;
                            laststate_Resolver_Interface    <= Resolver_SendRegisterValue;
                        else
                            AD2S1210_n_fsync                <= '1';
                            state_Resolver_Interface        <= Resolver_Ready;
                            laststate_Resolver_Interface    <= Resolver_SendRegisterValue;
                        end if;
                ---------------------------------------------------------------------------------------- 
                    when Resolver_Failstate =>              -- Failstate
                        error_flag                      <= '1';
                ---------------------------------------------------------------------------------------- 
                    when Resolver_SPI_Waittransmit1 =>      -- Waitstate 1 for SPI-Core
                        SPI_enable                          <= '0'; -- Reset SPI-enable
                        state_Resolver_Interface            <= Resolver_SPI_Waittransmit2;
                ----------------------------------------------------------------------------------------
                    when Resolver_SPI_Waittransmit2 =>      -- Waitstate 2 for SPI-Core to finish
                        SPI_enable                          <= '0';
                        if (SPI_busy = '0') then
                            SPI_SS                          <= '0';
                            state_Resolver_Interface        <= laststate_Resolver_Interface;
                            laststate_Resolver_Interface    <= Resolver_SPI_Waittransmit2;
                        end if;
                ----------------------------------------------------------------------------------------
                    when others =>
                        state_Resolver_Interface            <= Resolver_Failstate;
                ----------------------------------------------------------------------------------------
                end case;
            end if;
        end if;
    end process;

end Behavioral;

entity AD2S1210_Parallel_Interface is
--  Port ( );
end AD2S1210_Parallel_Interface;

architecture Behavioral of AD2S1210_Parallel_Interface is

begin


end Behavioral;
