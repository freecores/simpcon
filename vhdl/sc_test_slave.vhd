--
--	sc_test_slave.vhd
--
--	A simple test slave for the SimpCon interface
--	
--	Author: Martin Schoeberl	martin@jopdesign.com
--
--
--	resources on Cyclone
--
--		xx LCs, max xx MHz
--
--
--	2005-11-29	first version
--
--	todo:
--
--


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sc_test_slave is
generic (addr_bits : integer);

port (
	clk		: in std_logic;
	reset	: in std_logic;

-- SimpCon interface

	address		: in std_logic_vector(addr_bits-1 downto 0);
	wr_data		: in std_logic_vector(31 downto 0);
	rd, wr		: in std_logic;
	rd_data		: out std_logic_vector(31 downto 0);
	rdy_cnt		: out unsigned(1 downto 0)

);
end sc_test_slave;

architecture rtl of sc_test_slave is

	signal xyz			: std_logic_vector(31 downto 0);
	signal cnt			: unsigned(31 downto 0);

begin

	rdy_cnt <= "00";	-- no wait states

--
--	The registered MUX is all we need for a SimpCon read.
--	The read data is stored in registered rd_data.
--
process(clk, reset)
begin

	if (reset='1') then
		rd_data <= (others => '0');
	elsif rising_edge(clk) then

		if rd='1' then
			-- that's our very simple address decoder
			if address(0)='0' then
				rd_data <= std_logic_vector(cnt);
			else
				rd_data <= xyz;
			end if;
		end if;
	end if;

end process;


--
--	SimpCon write is very simple
--
process(clk, reset)

begin

	if (reset='1') then
		xyz <= (others => '0');
		cnt <= (others => '0');

	elsif rising_edge(clk) then

		if wr='1' then
			xyz <= wr_data;
		end if;

		cnt <= cnt+1;

	end if;

end process;


end rtl;
