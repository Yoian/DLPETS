library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Generador is
	Generic(
		Pulsos : integer := 50_000_000
	);
	Port(
		clk : in STD_LOGIC;
		UP,DN : in STD_LOGIC;
		SEL_SET : in STD_LOGIC;
		START_STOP : in STD_LOGIC;
		Reset : in STD_LOGIC;
		
		display: out STD_LOGIC_VECTOR(7 downto 0):="00000001";
		AN: out STD_LOGIC_VECTOR(3 downto 0);	
		Salida: out STD_LOGIC);
end Generador;

architecture Behavioral of Generador is
	signal Freq : integer range 1 to 99_000:=1;
	signal Temp_Tot : integer;
	signal High : integer;
	signal Low : integer;
	
	signal duty: integer range 0 to 100:=50;
begin
		calc_F: process(clk,Temp_Tot,duty)
		begin
			Temp_Tot<=Pulsos/Freq;
			High<=Temp_Tot*(Duty/100);
			Low<=Temp_Tot-High;
		end process calc_F;


end Behavioral;

