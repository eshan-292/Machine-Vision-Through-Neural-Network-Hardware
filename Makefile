simulate: build
	ghdl -e testbench
	ghdl -r testbench --vcd=wave.vcd
	gtkwave --autosavename wave.vcd

build:
	ghdl -a comparator.vhd
	ghdl -a shifter.vhd
	ghdl -a ram.vhd
	ghdl -a rom.vhd
	ghdl -a reg.vhd
	ghdl -a multiply.vhd
	ghdl -a control.vhd
	ghdl -a fsm.vhd
	ghdl -a design.vhd
	ghdl -a testbench.vhd