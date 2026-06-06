`ifndef RAM_SEQ_ITEM_SV
`define RAM_SEQ_ITEM_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

class apb_seq_item extends uvm_sequence_item;
    //item은 보통 소문자로 적음 
    rand logic [ 7:0] paddr;
    rand logic        pwrite;
    rand logic        penable;
    rand logic [31:0] pwdata;
    rand logic        psel;
    logic      [31:0] prdata;
    logic             pready;

    //addr는 4의 배수로 나와야함 
    //이렇게 하면 4의 배수로 나옴 
    constraint c_paddr {paddr % 4 == 0;}

    //factory에 등록하는 절차 
    `uvm_object_utils_begin(apb_seq_item)
        `uvm_field_int(paddr, UVM_ALL_ON)
        `uvm_field_int(pwrite, UVM_ALL_ON)
        `uvm_field_int(penable, UVM_ALL_ON)
        `uvm_field_int(pwdata, UVM_ALL_ON)
        `uvm_field_int(psel, UVM_ALL_ON)
        `uvm_field_int(prdata, UVM_ALL_ON)
        `uvm_field_int(pready, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "apb_seq_item");
        super.new(name);
    endfunction  //new()

    function string convert2string();
        string op = pwrite ? "WRITE" : "READ";
        return $sformatf(
            "%s paddr = 0x%02h pwdata = 0x%08h, prdata = 0x%08h",
            op,
            paddr,
            pwdata,
            prdata
        );

    endfunction
endclass  //component 

`endif
