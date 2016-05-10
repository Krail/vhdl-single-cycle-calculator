library ieee;
use ieee.std_logic_1164.all;

entity calculator is 
	port(
		clk               	 : in  std_logic;
		i_reset           	 : in  std_logic;
		i_enable          	 : in  std_logic;
		i_num_instructions	 : in  std_logic_vector (7 downto 0);
		i_instruction	  	 : in  std_logic_vector (7 downto 0);
		o_pc              	 : out std_logic_vector (7 downto 0);
		o_print           	 : out std_logic_vector (7 downto 0)
	);
end calculator;

architecture structural of calculator is
	
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
	component comparator2
		generic (LENGTH : integer);
		port(
			i_A	 : in  std_logic_vector (LENGTH-1 downto 0);
			i_B	 : in  std_logic_vector (LENGTH-1 downto 0);
			o_A	 : out std_logic_vector (LENGTH-1 downto 0);
			o_Z	 : out std_logic_vector (1 downto 0)
		);
	end component;
	component and2
		port(
			i_A	 : in  std_logic;
			i_B	 : in  std_logic;
			o_Z	 : out std_logic
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
	component sign_extend
		generic (IN_WORD_LENGTH  : integer;
				 OUT_WORD_LENGTH : integer);
		port(
			i_A   : in  std_logic_vector (IN_WORD_LENGTH-1 downto 0);
			o_Z   : out std_logic_vector (OUT_WORD_LENGTH-1 downto 0) := (others => '0')
		);
	end component;
	component control_unit
		port(
			c_enable     	 : in  std_logic;
			i_control   	 : in  std_logic_vector (2 downto 0);
			o_regDst     	 : out std_logic;
			o_branch     	 : out std_logic;
			o_ALUOp      	 : out std_logic_vector (2 downto 0);
			o_ALUSrc     	 : out std_logic;
			o_regWrite   	 : out std_logic
		);
	end component;
	component register_file
		generic (REG_VALUE	 : integer);
		port(
			c_enable    	 : in  std_logic := '0';
			c_reset     	 : in  std_logic := '1';
			c_regWrite  	 : in  std_logic := '0';
			c_clk       	 : in  std_logic := '0';
			i_read_reg1 	 : in  std_logic_vector (1 downto 0) := (others => 'X');
			i_read_reg2 	 : in  std_logic_vector (1 downto 0) := (others => 'X');
			i_write_reg 	 : in  std_logic_vector (1 downto 0) := (others => 'X');
			i_write_data	 : in  std_logic_vector (REG_VALUE-1 downto 0) := (others => 'X');
			o_read_data1	 : out std_logic_vector (REG_VALUE-1 downto 0);
			o_read_data2	 : out std_logic_vector (REG_VALUE-1 downto 0)
		);
	end component;
	component alu
	    port(
	        c_enable	 : in  std_logic;
	        c_ALUOp 	 : in  std_logic_vector (2 downto 0);
	        i_A     	 : in  std_logic_vector (7 downto 0);
	        i_B     	 : in  std_logic_vector (7 downto 0);
	        o_result	 : out std_logic_vector (7 downto 0);
	        o_print 	 : out std_logic_vector (7 downto 0);
	        o_oflow 	 : out std_logic;
	        o_uflow 	 : out std_logic;
	        o_zero  	 : out std_logic
	    );
	end component;
	
	
	-- for printing to console
	signal s_curr_instruction	 : std_logic_vector (7 downto 0) := (others => 'X');
	
	-- Control signals
	signal c_clk          	 : std_logic := '0';
	signal c_enable       	 : std_logic := '0';
	signal c_reset        	 : std_logic := '1';
	signal c_regDst       	 : std_logic := 'X';
	signal c_branch       	 : std_logic := '0';
	signal c_ALUOp        	 : std_logic_vector (2 downto 0) := "XXX";
	signal c_ALUSrc       	 : std_logic := 'X';
	signal c_regWrite     	 : std_logic := '0';
	signal c_zero         	 : std_logic := '0';
	signal c_oflow        	 : std_logic := '0';
	signal c_uflow        	 : std_logic := '0';
	signal c_pc_mux_select	 : std_logic := '0';
	
	-- PC registers
	signal s_num_instructions     	 : std_logic_vector (7 downto 0) := x"00";
	signal s_pc                   	 : std_logic_vector (7 downto 0) := x"00";
	signal s_pc_plus_1            	 : std_logic_vector (7 downto 0);
	signal s_skip_plus_1          	 : std_logic_vector (1 downto 0);
	signal s_pc_plus_1_plus_branch	 : std_logic_vector (7 downto 0);
	signal s_pc_next_buffer       	 : std_logic_vector (7 downto 0);
	signal s_pc_next              	 : std_logic_vector (7 downto 0);
	signal s_max_pc               	 : std_logic_vector (1 downto 0); -- "00" if at max pc
	
	-- IF/ID registers
	signal s_control	 : std_logic_vector (2 downto 0) := "XXX";
	signal s_rs     	 : std_logic_vector (1 downto 0) := "XX";
	signal s_rt     	 : std_logic_vector (1 downto 0) := "XX";
	signal s_rd     	 : std_logic_vector (1 downto 0) := "XX";
	signal s_imm    	 : std_logic_vector (3 downto 0) := "0000";
	
	-- ID/EX registers
	signal s_read_data1   	 : std_logic_vector (7 downto 0) := (others => 'X');
	signal s_read_data2   	 : std_logic_vector (7 downto 0) := (others => 'X');
	signal s_alu_src      	 : std_logic_vector (7 downto 0) := (others => 'X');
	signal s_sign_extended	 : std_logic_vector (7 downto 0) := x"00";
	
	-- EX/WB registers
	signal s_write_reg 	 : std_logic_vector (1 downto 0) := "XX";
	signal s_write_data	 : std_logic_vector (7 downto 0) := (others => 'X');
	
	
	-- Jose showed us this
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
	
	-- Ours
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
	dst_reg_mux: mux2
		generic map (LENGTH => 2)
		port map (
			i_A  	 => s_rs,
			i_B  	 => s_rd,
			i_SEL	 => c_regDst,
			o_Z  	 => s_write_reg
		);
	alu_src_mux: mux2
		generic map (LENGTH => 8)
		port map (
			i_A  	 => s_read_data2,
			i_B  	 => s_sign_extended,
			i_SEL	 => c_ALUSrc,
			o_Z  	 => s_alu_src
		);
	pc_src_mux: mux2
		generic map (LENGTH => 8)
		port map (
			i_A  	 => s_pc_plus_1,
			i_B  	 => s_pc_plus_1_plus_branch,
			i_SEL	 => c_pc_mux_select,
			o_Z  	 => s_pc_next_buffer
		);
	sign_extend_4_to_8: sign_extend
		generic map (IN_WORD_LENGTH  => 4,
					 OUT_WORD_LENGTH => 8)
		port map (
			i_A	 => s_imm,
			o_Z	 => s_sign_extended
		);
	pc_adder: add2
		generic map (LENGTH => 8)
		port map (
			c_op  	 => '0',
			i_A   	 => s_pc,
			i_B   	 => "00000001",
			o_Z   	 => s_pc_plus_1,
			o_flow	 => open -- TODO on overflow, set s_max_pc high
		);
	branch_adder: add2
		generic map (LENGTH => 8)
		port map (
			c_op           	 => '0',
			i_A            	 => s_pc_plus_1,
			i_B(7 downto 2)	 => "000000",
			i_B(1 downto 0)	 => s_skip_plus_1,
			o_Z            	 => s_pc_plus_1_plus_branch,
			o_flow         	 => open  -- TODO on overflow, set s_max_pc high
		);
	skip_adder: add2
		generic map (LENGTH => 2)
		port map (
			c_op  	 => '0',
			i_A(1)	 => '0',
			i_A(0)	 => s_sign_extended(1),
			i_B   	 => "01",
			o_Z   	 => s_skip_plus_1,
			o_flow	 => open
		);
	max_pc_comparator: comparator2
		generic map (LENGTH => 8)
		port map (
			i_A	 => s_pc_next_buffer,
			i_B	 => s_num_instructions,
			o_A	 => s_pc_next,
			o_Z	 => s_max_pc
		);
	control_unit_0: control_unit
		port map (
			c_enable  	 => c_enable,
			i_control 	 => s_control,
			o_regDst  	 => c_regDst,
			o_branch  	 => c_branch,
			o_ALUOp   	 => c_ALUOp,
			o_ALUSrc  	 => c_ALUSrc,
			o_regWrite	 => c_regWrite
		);
	regfile_0: register_file
		generic map (REG_VALUE => 8)
		port map(
			c_enable    	 => c_enable,
			c_reset     	 => c_reset,
			c_regWrite  	 => c_regWrite,
			c_clk       	 => c_clk,
			i_read_reg1 	 => s_rs,
			i_read_reg2 	 => s_rt,
			i_write_reg 	 => s_write_reg,
			i_write_data	 => s_write_data,
			o_read_data1	 => s_read_data1,
			o_read_data2	 => s_read_data2
		);
	alu_0: alu
		port map(
			c_enable	 => c_enable,
			c_ALUOp 	 => c_ALUOp,
			i_A     	 => s_read_data1,
			i_B     	 => s_alu_src,
			o_result	 => s_write_data,
			o_print 	 => o_print,
			o_oflow 	 => c_oflow,
			o_uflow 	 => c_uflow,
			o_zero  	 => c_zero
		);
	
	-- logic below
	process (clk, i_enable, i_reset) is
	begin
		if rising_edge(i_reset) then
			c_clk <= '0';  -- set register file's clock low
			c_reset <= '1';
			-- noop instruction
			s_control <= "XXX";
			s_rs <= "XX";
			s_rt <= "XX";
			s_rd <= "XX";
			s_imm <= "0000";
			-- update pc
			s_num_instructions <= i_num_instructions;
			s_pc <= x"FF";
			
		elsif rising_edge(clk) then
			if i_enable = '1' and is_valid(i_instruction) then
				-- check pc
				if not (s_max_pc = "10") then
					-- disable calculator
					c_enable <= '0';
				else
					-- enable calculator
					c_enable <= '1';
					c_reset <= '0';
					
					-- for printing, store current pc value
					s_curr_instruction <= i_instruction;
					
					-- decode instruction
					c_clk <= '1';  -- read from regfile (set regfile's clock high)
					s_control <= i_instruction(7 downto 6) & i_instruction(0);
					s_rs <= i_instruction(5 downto 4);
					s_rt <= i_instruction(3 downto 2);
					s_rd <= i_instruction(1 downto 0);
					s_imm <= i_instruction(3 downto 0);
					
					-- update pc
					s_pc <= s_pc_next;
					
				end if;
			else
				-- disable calculator
				c_enable <= '0';
			end if;
			
		elsif falling_edge(clk) then
			c_clk <= '0';  -- set register file's clock low
			if c_enable = '1' and is_valid(s_curr_instruction) then
				report "  "&to_bstring(s_pc)&"  "&to_bstring(s_curr_instruction) severity note;
			end if;
		end if;
		
	end process;
	
	-- Update o_pc when s_pc_next changes
	process (s_pc_next, s_max_pc) is
	begin
		if c_enable = '1' and (s_max_pc = "10") then
			o_pc <= s_pc_next;
		else
			o_pc <= x"00";
		end if;
	end process;

end structural;
