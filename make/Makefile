GHDL        = ghdl
COMPONENTS  = ../components
TESTBENCHES = ../test_benches


all: add2 alu and2 calculator comparator2 control_unit full_adder half_adder mux2 or2 register_file sign_extend xor2 debug_aluregfile debug_pc


add2: full_adder xor2 $(COMPONENTS)/add2.vhdl $(TESTBENCHES)/add2_tb.vhdl
	$(GHDL) -a $(COMPONENTS)/add2.vhdl      # component
	$(GHDL) -a $(TESTBENCHES)/add2_tb.vhdl  # test bench
	$(GHDL) -e add2_tb                      # binary

alu: add2 comparator2 $(COMPONENTS)/alu.vhdl $(TESTBENCHES)/alu_tb.vhdl
	$(GHDL) -a $(COMPONENTS)/alu.vhdl      # component
	$(GHDL) -a $(TESTBENCHES)/alu_tb.vhdl  # test bench
	$(GHDL) -e alu_tb                      # binary

and2: $(COMPONENTS)/and2.vhdl $(TESTBENCHES)/and2_tb.vhdl
	$(GHDL) -a $(COMPONENTS)/and2.vhdl      # component
	$(GHDL) -a $(TESTBENCHES)/and2_tb.vhdl  # test bench
	$(GHDL) -e and2_tb                      # binary

#######################################
calculator: add2 comparator2 and2 mux2 sign_extend control_unit register_file alu $(COMPONENTS)/calculator.vhdl $(TESTBENCHES)/calculator_tb.vhdl
	$(GHDL) -a $(COMPONENTS)/calculator.vhdl      # component
	$(GHDL) -a $(TESTBENCHES)/calculator_tb.vhdl  # test bench
	$(GHDL) -e calculator_tb                      # binary
#######################################

comparator2: $(COMPONENTS)/comparator2.vhdl $(TESTBENCHES)/comparator2_tb.vhdl
	$(GHDL) -a $(COMPONENTS)/comparator2.vhdl      # component
	$(GHDL) -a $(TESTBENCHES)/comparator2_tb.vhdl  # test bench
	$(GHDL) -e comparator2_tb                      # binary

control_unit: $(COMPONENTS)/control_unit.vhdl $(TESTBENCHES)/control_unit_tb.vhdl
	$(GHDL) -a $(COMPONENTS)/control_unit.vhdl      # component
	$(GHDL) -a $(TESTBENCHES)/control_unit_tb.vhdl  # test bench
	$(GHDL) -e control_unit_tb                      # binary

full_adder: half_adder or2 $(COMPONENTS)/full_adder.vhdl $(TESTBENCHES)/full_adder_tb.vhdl
	$(GHDL) -a $(COMPONENTS)/full_adder.vhdl      # component
	$(GHDL) -a $(TESTBENCHES)/full_adder_tb.vhdl  # test bench
	$(GHDL) -e full_adder_tb                      # binary

half_adder: and2 xor2 $(COMPONENTS)/half_adder.vhdl $(TESTBENCHES)/half_adder_tb.vhdl
	$(GHDL) -a $(COMPONENTS)/half_adder.vhdl      # component
	$(GHDL) -a $(TESTBENCHES)/half_adder_tb.vhdl  # test bench
	$(GHDL) -e half_adder_tb                      # binary

mux2: $(COMPONENTS)/mux2.vhdl $(TESTBENCHES)/mux2_tb.vhdl
	$(GHDL) -a $(COMPONENTS)/mux2.vhdl      # component
	$(GHDL) -a $(TESTBENCHES)/mux2_tb.vhdl  # test bench
	$(GHDL) -e mux2_tb                      # binary

or2: $(COMPONENTS)/or2.vhdl $(TESTBENCHES)/or2_tb.vhdl
	$(GHDL) -a $(COMPONENTS)/or2.vhdl      # component
	$(GHDL) -a $(TESTBENCHES)/or2_tb.vhdl  # test bench
	$(GHDL) -e or2_tb                      # binary

register_file: $(COMPONENTS)/register_file.vhdl $(TESTBENCHES)/register_file_tb.vhdl
	$(GHDL) -a $(COMPONENTS)/register_file.vhdl      # component
	$(GHDL) -a $(TESTBENCHES)/register_file_tb.vhdl  # test bench
	$(GHDL) -e register_file_tb                      # binary

sign_extend: $(COMPONENTS)/sign_extend.vhdl $(TESTBENCHES)/sign_extend_tb.vhdl
	$(GHDL) -a $(COMPONENTS)/sign_extend.vhdl      # component
	$(GHDL) -a $(TESTBENCHES)/sign_extend_tb.vhdl  # test bench
	$(GHDL) -e sign_extend_tb                      # binary

xor2: $(COMPONENTS)/xor2.vhdl $(TESTBENCHES)/xor2_tb.vhdl
	$(GHDL) -a $(COMPONENTS)/xor2.vhdl      # component
	$(GHDL) -a $(TESTBENCHES)/xor2_tb.vhdl  # test bench
	$(GHDL) -e xor2_tb                      # binary

# Debugging test benches
debug_aluregfile: calculator $(TESTBENCHES)/debug_aluregfile_tb.vhdl
	$(GHDL) -a $(TESTBENCHES)/debug_aluregfile_tb.vhdl  # test bench
	$(GHDL) -e debug_aluregfile_tb                      # binary

debug_pc: calculator $(TESTBENCHES)/debug_pc_tb.vhdl
	$(GHDL) -a $(TESTBENCHES)/debug_pc_tb.vhdl  # test bench
	$(GHDL) -e debug_pc_tb                      # binary



clean:
	rm -f *.o *.cf *_tb *.out
