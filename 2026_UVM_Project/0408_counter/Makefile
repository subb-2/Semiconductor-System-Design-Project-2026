TC ?= counter_test
SEED ?= 1234

VCS_OPTS := -full64 -sverilog
VCS_OPTS += -ntb_opts uvm-1.2
VCS_OPTS += -timescale=1ns/1ps
VCS_OPTS += -debug_access+all -kdb -lca
VCS_OPTS += -cm line+cond+fsm+tgl+branch+assert

SIM_OPTS := +UVM_TESTNAME=$(TC)
SIM_OPTS += +UVM_VERBOSITY=UVM_HIGH
SIM_OPTS += +ntb_random_seed=$(SEED)
SIM_OPTS += -cm line+cond+fsm+tgl+branch+assert
SIM_OPTS += -cm_dir coverage.vdb 
SIM_OPTS += -cm_name sim1 

.PHONY: compile sim clean

compile:
	vcs $(VCS_OPTS) -f filelist.f -o simv

sim: compile
	./simv $(SIM_OPTS) 

clean:
	rm -rf simv* csrc *.key *.h *.log
