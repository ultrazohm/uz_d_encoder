----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.03.2021 14:11:41
-- Design Name: 
-- Module Name: Controller - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ResolverController is
    Port (
        test                : out std_logic;
        clk                 : in std_logic;
        reset               : in std_logic;
        data_in             : in std_logic_vector (7 downto 0);
        data_out            : out std_logic_vector (7 downto 0);
        send                : out std_logic;
        busy                : in std_logic;
        dataMode            : in std_logic; -- 0 = position mode, 1 = velocity mode
        configMode          : in std_logic; -- if 1, dataMode is ignored
        mode_A0             : out std_logic;
        mode_A1             : out std_logic;
        n_sample            : out std_logic := '1';
        fsync               : out std_logic := '1';
        resolver_return     : out std_logic_vector (15 downto 0);
        resolver_reg_addr   : in std_logic_vector (7 downto 0)
    );
end ResolverController;

architecture Behavioral of ResolverController is

    type STATE_TYPE IS (S0, S1, S2, S3, S4, S5, S6, S7);
    signal state        : STATE_TYPE;
    signal durchlauf    : std_logic := '0';

begin

    main_process : process(clk, reset, busy)
    begin
        
        if reset = '0' then
            state <= S0;
        else
        
            if (rising_edge(clk) and busy = '0') then
            
                case state is
                
                    --State 0: Clear n_sample (normal mode) or fsync (config mode)
                    when S0 =>
                        
                        --Toggle test pin
        --                durchlauf <= not durchlauf;
                        test <= '1';
                        
                        --Reset send signal
                        send <= '0';
                        
                        if configMode = '0' then
                            --Normal mode
                            n_sample <= '0';
                        else
                            --Configuration mode
                            fsync <= '0';
                        end if;
                        
                        state <= S1;
                        
                    --State 1: Do nothing (normal mode) or send address (config mode)
                    when S1 =>
                    
                        test <= '0';
                    
                        if configMode = '1' then
                            --Configuration mode
                            data_out <= resolver_reg_addr;
                            send <= '1';
                        end if;
                        
                        state <= S2;
                        
                    --State 2: Set n_sample (normal mode) or fsync (config mode)
                    when S2 =>
                        
                        --Reset send signal
                        send <= '0';
                        
                        if configMode = '0' then
                            --Normal mode
                            n_sample <= '1';
                        else
                            --Configuration mode
                            fsync <= '1';
                        end if;
                        
                        state <= S3;
                        
                    --State 3: Clear fsync
                    when S3 =>
                        
                        fsync <= '0';
                        
                        state <= S4;
                        
                    --State 4: Read first byte (normal mode) or only byte (config mode)
                    when S4 =>
                        
                        if configMode = '0' then
                            --Normal mode
                            data_out <= "00000000";
                        else
                            --Configuration mode
                            data_out <= "11111111";
                        end if;
                        
                        send <= '1';
                        
                        state <= S5;
                        
                    --State 5: Reset send signal
                    when S5 =>
                        
                        --Reset send signal
                        send <= '0';
                        
                        state <= S6;
                        
                    --State 6: Read second byte (normal mode) or do nothing (config mode)
                    when S6 =>
                        
                        --TODO: Correct return value
                        resolver_return(7 downto 0) <= data_in;
                        
                        if configMode = '0' then
                            --Normal mode
                            data_out <= "00000000";
                            send <= '1';
                        end if;
                        
                        state <= S7;
                        
                    --State 7:
                    when S7 =>
                        
                        if configMode = '0' then
                            --Normal mode
                            --TODO: Correct return value
                            resolver_return(7 downto 0) <= data_in;
                        end if;
                        
                        fsync <= '1';
                        
                        state <= S0;
                        
                end case;
            
            end if;
            
        end if;
        
    end process;
    
    -- Set A0 and A1 according to mode
    mode_A1 <= dataMode or configMode;
    mode_A0 <= configMode;

end Behavioral;
