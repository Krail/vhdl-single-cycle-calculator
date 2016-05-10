library ieee;
use ieee.std_logic_1164.all;

entity calculator_pc is 
	port(
		c_reset           	 : in  std_logic;
		c_branch          	 : in  std_logic;
		c_zero            	 : in  std_logic;
		i_pc              	 : in  std_logic_vector (7 downto 0);
		i_num_instructions	 : in  std_logic_vector (7 downto 0);
		i_skip_bit        	 : in  std_logic;
		o_pc              	 : out std_logic_vector (7 downto 0);
		o_max_pc          	 : out std_logic_vector (1 downto 0);
	);
end calculator_pc;

architecture structural of calculator_pc is
	
	-- components used
	component add2
		generic (LENGTH : integer);
		port(
			c_op  	 : in  std_logic;
			i_A   	 : in  std_logic_vector (LENGTH-1 downto 0);
			i_B   	 : in  std_logic_vector (LENGTH-1 downto 0);
			o_Z   	 : out std_logic_vector (LENGTH-1 downto 0) := (others => 'X');
			o_flow	 : out std_logic
		);
	end component;
	component and2
		port(
			i_A	 : in  std_logic;
			i_B	 : in  std_logic;
			o_Z	 : out std_logic
		);
	end component;
	component comparator2
		generic (LENGTH : integer);
		port(
			i_A	 : in  std_logic_vector (LENGTH-1 downto 0);
			i_B	 : in  std_logic_vector (LENGTH-1 downto 0);
			o_Z	 : out std_logic_vector (1 downto 0)
		);
	end component;
	component mux2
		generic (LENGTH : integer);
		port(
			i_A   : in  std_logic_vector (LENGTH-1 downto 0);
			i_B   : in  std_logic_vector (LENGTH-1 downto 0);
			i_SEL : in  std_logic := 'X';
			o_Z   : out std_logic_vector (LENGTH-1 downto 0) := (others => 'X')
		);
	end component;
	
	
	-- Control signals
	signal c_pc_mux_select: std_logic := '0';
	
	-- PC registers
	signal s_num_instructions : std_logic_vector (7 downto 0) := x"00";
	signal s_pc : std_logic_vector (7 downto 0) := x"00";
	signal s_pc_plus_1: std_logic_vector (7 downto 0);
	signal s_skip_plus_1: std_logic_vector (1 downto 0);
	signal s_pc_plus_1_plus_branch: std_logic_vector (7 downto 0);
	signal s_pc_next : std_logic_vector (7 downto 0);
	signal s_max_pc  : std_logic_vector (7 downto 0);
	
	-- IF/ID registers
	
	-- ID/EX registers
	
	-- EX/WB registers
	
	
	function to_bstring(sl : std_logic) return string is
	  variable sl_str_v : string(1 to 3);  -- std_logic image with quotes around
	begin
	  sl_str_v := std_logic'image(sl);
	  return "" & sl_str_v(2);  -- "" & character to get string
	end function;
	function to_bstring(slv : std_logic_vector) return string is
	  alias    slv_norm : std_logic_vector(1 to slv'length) is slv;
	  variable sl_str_v : string(1 to 1);  -- String of std_logic
	  variable res_v    : string(1 to slv'length);
	begin
	  for idx in slv_norm'range loop
	    sl_str_v := to_bstring(slv_norm(idx));
	    res_v(idx) := sl_str_v(1);
	  end loop;
	  return res_v;
	end function;
	
	function is_valid(i_vector : std_logic_vector) return boolean is
	begin
		for i in i_vector'range loop
			if i_vector(i) /= '0' and i_vector(i) /= '1' then
				return false;
			end if;
		end loop;
		return true;
	end function;
	
	
begin

	branch_and_gate: and2
		port map (
			i_A	 => c_branch,
			i_B	 => c_zero,
			o_Z	 => c_pc_mux_select
		);
	pc_src_mux: mux2
		generic map (LENGTH => 8)
		port map (
			i_A  	 => s_pc_plus_1,
			i_B  	 => s_pc_plus_branch,
			i_SEL	 => c_pc_mux_select,
			o_Z  	 => s_pc_next
		);
	pc_adder: add2
	generic map (LENGTH => 8)
	port map (
		c_op  	 => '0',
		i_A => s_pc,
		i_B   	 => "00000001",
		o_Z => s_pc_plus_1,
		o_flow	 => open -- TODO on overflow, set s_max_pc high
	);
	branch_adder: add2
		generic map (LENGTH => 8)
		port map (
			c_op  	 => '0',
			i_A => s_pc_plus_1,
			i_B(7 downto 2) => "000000",
			i_B(1 downto 0) => s_skip_plus_1,
			o_Z => s_pc_plus_1_plus_branch,
			o_flow	 => open  -- TODO on overflow, set s_max_pc high
		);
	skip_adder: add2
		generic map (LENGTH => 2)
		port map (
			c_op  	 => '0',
			i_A(1)	 => '0',
			i_A(0)	 => i_skip_bit,
			i_B   	 => "01",
			o_Z   	 => s_skip_plus_1,
			o_flow	 => open
		);
	max_pc_comparator: comparator2
		generic map (LENGTH => 8)
		port map (
			i_A   	 => s_pc_next,  -- not sure if this is right
			i_B   	 => s_num_instructions,
			o_Z   	 => s_max_pc
		);
	
	-- logic below
	process (c_reset,
	         c_branch,
	         c_zero,
	         i_pc,
	         i_num_instructions,
	         i_skip_bit,
	         s_pc_next,
	         s_pc_max) is
	begin
		if rising_edge(c_reset) then
			s_num_instructions <= i_num_instructions;
			s_pc <= x"00";
		else
			s_pc <= i_pc;
			o_pc <= s_pc_next;
			o_max_pc <= s_max_pc;
		end if;
	end process;

end structural;
