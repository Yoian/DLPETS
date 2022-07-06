library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Generador is
	Generic(
		N : integer := 15;
		Pulsos : integer := 50_000_000);
	Port(
		clk: in STD_LOGIC;
		UP,DN : in STD_LOGIC;
		SEL_SET : in STD_LOGIC;
		START_STOP : in STD_LOGIC;
		Reset : in STD_LOGIC;
		
		display: out STD_LOGIC_VECTOR(7 downto 0):="00000001";
		AN: out STD_LOGIC_VECTOR(3 downto 0);	
		Salida: out STD_LOGIC);
end Generador;

architecture Behavioral of Generador is
	
	type edos is(Gen,Stop,Rst,SetF,SetD);
	signal Maq : edos := Stop;
	
	signal SStop: STD_LOGIC_VECTOR(1 downto 0):="00"; 

	signal clkdiv : STD_LOGIC_VECTOR(N downto 0);

	signal Freq : integer range 1 to 99_000:=1;
	signal Base : integer range 1 to 99;
	signal Exp : integer range 0 to 3;
	
	signal Temp_Tot : integer;
	signal High : integer;
	signal Low : integer;
	
	signal duty: integer range 0 to 100:=50;
	
	signal enable : STD_LOGIC:='0';
	
	signal CntSet : integer range 0 to 10_000:=0;
	signal ConfSet : STD_LOGIC_VECTOR(1 downto 0):="00";
	
	signal SelBase: STD_LOGIC;
begin
	
	divisor : process(clk)
	begin
		if rising_edge(clk) then
			clkdiv<=clkdiv+1;
		end if;
	end process divisor;

	SetUp: process(clkdiv,SEL_SET)
	begin
		if rising_edge(clkdiv(N)) then
			if SEL_SET='1' then
				CntSet<=CntSet+1;
				if falling_edge(SEL_SET) and CntSet>=9154 then
					ConfSet(1)<=not ConfSet(1);
				elsif falling_edge(SEL_SET) and CntSet<9154 then
					ConfSet(0)<=not ConfSet(0);
				end if;
			else 
				CntSet<=0;
			end if;
		end if;
	end process;

	FSM : process(clkdiv(N),START_STOP,Reset,ConfSet,SEL_SET,UP,DN)
	begin
		if rising_edge(START_STOP) then 
			Maq<=Stop;
		elsif rising_edge(Reset) then 
			Maq<=Rst;
		elsif ConfSet="10" then
			Maq<=SetF;
		elsif ConfSet="11" then
			Maq<=SetD;
		elsif rising_edge(clkdiv(N)) then
			case Maq is
				when Stop=>
					SStop<=SStop+'1';
					if SStop(0)='1' then
						Maq<=Gen;
						enable<='1';
					else
						enable<='0';
					end if;
					
				when Rst=>
					Base<=1;
					Exp<=0;
					SStop(0)<='1';
					Maq<=Stop;
					
				when Gen=>
					case Exp is
						when 0 => Freq<=Base*1;
						when 1 => Freq<=Base*10;
						when 2 => Freq<=Base*100;
						when 3 => Freq<=Base*1000;
						when others => null;
					end case;
					
					Temp_Tot<=Pulsos/Freq;
					High<=Temp_Tot*(duty/100);
					
				when SetF=>
				if rising_edge(SEL_SET) then
					SelBase<=not SelBase;
				end if;
				
				if SelBase='0' then
					if rising_edge(UP) and Base<99 then
						Base<=Base+1;
					elsif rising_edge(DN) and Base>0 then
						Base<=Base-1;
					end if;
				elsif SelBase='1' then
					if rising_edge(UP) and Exp<3 then
						Exp<=Exp+1;
					elsif rising_edge(DN) and Exp>0 then
						Exp<=Exp-1;
					end if;
				end if;
				when SetD=>
					null;
				when others=> null;
			end case;
		end if;
			
	end process FSM;
	
end Behavioral;
