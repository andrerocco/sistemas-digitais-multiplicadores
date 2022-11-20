LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY mux2para1_1bit IS
  -- GENERIC ( N : INTEGER );
  PORT ( a, b : IN STD_LOGIC;
         sel: IN STD_LOGIC;
         y : OUT STD_LOGIC);
  END mux2para1_1bit;

ARCHITECTURE comportamento OF mux2para1_1bit IS
BEGIN
     WITH sel SELECT
         y <= a WHEN '0',
              b WHEN OTHERS;
END comportamento;