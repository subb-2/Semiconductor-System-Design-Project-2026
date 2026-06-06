TC ?= ram_test
SEED ?= 1234

VCS_OPTS := -full64 -sverilog
VCS_OPTS += -ntb_opts uvm-1.2
VCS_OPTS += -timescale=1ns/1ps
VCS_OPTS += -debug_access+all -kdb -lca

SIM_OPTS := +UVM_TESTNAME=$(TC)
SIM_OPTS += +UVM_VERBOSITY=UVM_HIGH
SIM_OPTS += +ntb_random_seed=$(SEED)

.PHONY: compile sim clean

compile:
	vcs $(VCS_OPTS) -f filelist.f -o simv
	@echo "타겟 [$@] 완료"

sim: compile
	./simv $(SIM_OPTS)
	@echo "의존 타겟 [$<] 완료"
	@echo "타겟 [$@] 완료"

clean:
	rm -rf simv* csrc *.key *.h
