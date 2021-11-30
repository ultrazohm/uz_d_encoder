library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


ENTITY StateMachineTest IS
   PORT(
      clk_in      : IN   STD_LOGIC;
      reset_n    : IN   STD_LOGIC;
      output_A   : OUT  STD_LOGIC;
      output_B   : OUT  STD_LOGIC);
END StateMachineTest;

ARCHITECTURE Behavioral OF StateMachineTest IS
   TYPE STATE_TYPE IS (s0, s1, s2);
   SIGNAL state   : STATE_TYPE;-- := s0;
BEGIN
   PROCESS (clk_in, reset_n)
   BEGIN
   --   IF reset_n = '0' THEN
  --       state <= s2;
   --   ELSIF (clk_in'EVENT AND clk_in = '1') THEN
   IF (clk_in'EVENT AND clk_in = '1') THEN -- DEBUG
         CASE state IS
            WHEN s0=>
                  state <= s2;
            WHEN s1=>
                  state <= s1;
            WHEN s2=>
                  state <= s1;
         END CASE;
      END IF;
   END PROCESS;
   
   PROCESS (state)
   BEGIN
      CASE state IS
         WHEN s0 =>
            output_A <= '0';
            output_B <= '1';
         WHEN s1 =>
            output_A <= '1';
            output_B <= '0';
         WHEN s2 =>
            output_A <= '1';
            output_B <= '1';
      END CASE;
   END PROCESS;
   
END Behavioral;
