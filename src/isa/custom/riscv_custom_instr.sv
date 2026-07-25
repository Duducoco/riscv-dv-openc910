/*
 * Copyright 2020 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// Custom instruction class

class riscv_custom_instr extends riscv_instr;

  rand bit [5:0] thead_msb;
  rand bit [5:0] thead_lsb;
  rand bit [5:0] thead_imm;

  constraint thead_bit_range_c {
    if (instr_name inside {THEAD_EXT, THEAD_EXTU}) {
      thead_msb >= thead_lsb;
    }
  }

  constraint thead_imm_c {
    if (instr_name == THEAD_ADDSL) {
      thead_imm inside {[0:3]};
    } else if (instr_name == THEAD_SRRIW) {
      thead_imm inside {[0:31]};
    }
  }

  `uvm_object_utils(riscv_custom_instr)
  `uvm_object_new

  virtual function void set_rand_mode();
    super.set_rand_mode();
    if (instr_name inside {THEAD_SRRI, THEAD_SRRIW, THEAD_TSTNBZ,
                           THEAD_REV, THEAD_FF0, THEAD_FF1, THEAD_TST,
                           THEAD_REVW, THEAD_EXT, THEAD_EXTU}) begin
      has_rs2 = 1'b0;
    end
  endfunction : set_rand_mode

  function void pre_randomize();
    super.pre_randomize();
    thead_msb.rand_mode(instr_name inside {THEAD_EXT, THEAD_EXTU});
    thead_lsb.rand_mode(instr_name inside {THEAD_EXT, THEAD_EXTU});
    thead_imm.rand_mode(instr_name inside {THEAD_ADDSL, THEAD_SRRI,
                                           THEAD_SRRIW, THEAD_TST});
  endfunction : pre_randomize

  // Convert the instruction to assembly code
  virtual function string convert2asm(string prefix = "");
    string asm_str;
    string mnemonic;

    case (instr_name)
      THEAD_ADDSL: mnemonic = "addsl";
      THEAD_SRRI:  mnemonic = "srri";
      THEAD_SRRIW: mnemonic = "srriw";
      THEAD_TSTNBZ: mnemonic = "tstnbz";
      THEAD_REV:   mnemonic = "rev";
      THEAD_FF0:   mnemonic = "ff0";
      THEAD_FF1:   mnemonic = "ff1";
      THEAD_TST:   mnemonic = "tst";
      THEAD_REVW:  mnemonic = "revw";
      THEAD_EXT:   mnemonic = "ext";
      THEAD_EXTU:  mnemonic = "extu";
      THEAD_MVEQZ: mnemonic = "mveqz";
      THEAD_MVNEZ: mnemonic = "mvnez";
      THEAD_MULA:  mnemonic = "mula";
      THEAD_MULS:  mnemonic = "muls";
      THEAD_MULAW: mnemonic = "mulaw";
      THEAD_MULSW: mnemonic = "mulsw";
      THEAD_MULAH: mnemonic = "mulah";
      THEAD_MULSH: mnemonic = "mulsh";
      default: `uvm_fatal("riscv_custom_instr",
                          $sformatf("Unsupported custom instruction %0s", instr_name.name()))
    endcase

    asm_str = format_string(mnemonic, MAX_INSTR_STR_LEN);
    case (instr_name)
      THEAD_TSTNBZ, THEAD_REV, THEAD_FF0, THEAD_FF1, THEAD_REVW:
        asm_str = $sformatf("%0s%0s, %0s", asm_str, rd.name(), rs1.name());
      THEAD_SRRI, THEAD_SRRIW, THEAD_TST:
        asm_str = $sformatf("%0s%0s, %0s, %0d", asm_str, rd.name(), rs1.name(), thead_imm);
      THEAD_ADDSL:
        asm_str = $sformatf("%0s%0s, %0s, %0s, %0d", asm_str, rd.name(), rs1.name(),
                            rs2.name(), thead_imm);
      THEAD_EXT, THEAD_EXTU:
        asm_str = $sformatf("%0s%0s, %0s, %0d, %0d", asm_str, rd.name(), rs1.name(),
                            thead_msb, thead_lsb);
      THEAD_MVEQZ, THEAD_MVNEZ, THEAD_MULA, THEAD_MULS,
      THEAD_MULAW, THEAD_MULSW, THEAD_MULAH, THEAD_MULSH:
        asm_str = $sformatf("%0s%0s, %0s, %0s", asm_str, rd.name(), rs1.name(), rs2.name());
      default: ;
    endcase

    if (comment != "") begin
      asm_str = {asm_str, " #",comment};
    end
    return asm_str.tolower();
  endfunction : convert2asm

endclass : riscv_custom_instr
