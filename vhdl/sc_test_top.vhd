--
--	scio_test_top.vhd
--
--	The top level to test SimpCon IO devices.
--	Do the address decoding here for the various slaves.
--	
--	Author: Martin Schoeberl	martin@jopdesign.com
--
--
--	2005-11-30	first version with two simple test slaves
--
--
--


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.jop_types.all;

entity scio is
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
end scio;

architecture rtl of scio is

	constant SLAVE_CNT : integer := 2;
	constant SLAVE_ADDR_BITS : integer := 4;

	type slave_bit is array(0 to SLAVE_CNT-1) of std_logic;
	signal sc_rd, sc_wr		: slave_bit;

	type slave_dout is array(0 to SLAVE_CNT-1) of std_logic_vector(31 downto 0);
	signal sc_dout			: slave_dout;

	type slave_rdy_cnt is array(0 to SLAVE_CNT-1) of unsigned(1 downto 0);
	signal sc_rdy_cnt		: slave_rdy_cnt;

	signal rd_mux			: std_logic;

begin

	--
	-- Connect two simple test slaves
	--
	gsl: for i in 0 to SLAVE_CNT-1 generate
		wbsl: entity work.sc_test_slave
			generic map (
				-- shall we use less address bits inside the slaves?
				addr_bits => SLAVE_ADDR_BITS
			)
			port map (
				clk => clk,
				reset => reset,

				address => address(SLAVE_ADDR_BITS-1 downto 0),
				wr_data => wr_data,
				rd => sc_rd(i),
				wr => sc_wr(i),
				rd_data => sc_dout(i),
				rdy_cnt => sc_rdy_cnt(i)
		);
	end generate;



--
--	Address decoding
--
process(address, rd, wr)
begin

	-- How can we formulate this more elegant?
	sc_rd(0) <= '0';
	sc_wr(0) <= '0';
	sc_rd(1) <= '0';
	sc_wr(1) <= '0';

	if address(SLAVE_ADDR_BITS)='0' then
		sc_rd(0) <= rd;
		sc_wr(0) <= wr;
	else
		sc_rd(1) <= rd;
		sc_wr(1) <= wr;
	end if;

end process;

--
--	Read mux selector
--
process(clk, reset)
begin

	if (reset='1') then
		rd_mux <= '0';
	elsif rising_edge(clk) then
		if rd='1' then
			rd_mux <= address(SLAVE_ADDR_BITS);
		end if;
	end if;
end process;
			
--
--	Read data and rdy_cnt mux
--
--		Or should we simple or the rdy_cnt values?
--
process(rd_mux, sc_dout, sc_rdy_cnt)
begin

	if rd_mux='0' then
		rd_data <= sc_dout(0);
		rdy_cnt <= sc_rdy_cnt(0);
	else
		rd_data <= sc_dout(1);
		rdy_cnt <= sc_rdy_cnt(1);
	end if;
end process;

end rtl;
