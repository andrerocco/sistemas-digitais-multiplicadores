LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY flipflop IS
PORT (clk: IN STD_LOGIC;
	  d : IN STD_LOGIC;
	  q : OUT STD_LOGIC);
END flipflop;

ARCHITECTURE estrutura OF flipflop IS
BEGIN
	PROCESS(clk)
	BEGIN
		IF (clk'EVENT AND clk = '1') THEN
			q <= d;
		END IF;
	END PROCESS;
END estrutura;