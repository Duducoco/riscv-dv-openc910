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

  typedef enum {
    THEAD_FMT_RR,
    THEAD_FMT_RRI,
    THEAD_FMT_RRRI,
    THEAD_FMT_RRII,
    THEAD_FMT_RRR,
    THEAD_FMT_MEM_INDEXED,
    THEAD_FMT_MEM_INCREMENT,
    THEAD_FMT_MEM_PAIR,
    THEAD_FMT_FP_INDEXED,
    THEAD_FMT_CACHE_ADDR,
    THEAD_FMT_NONE
  } thead_operand_format_t;

  rand bit [5:0]        thead_msb;
  rand bit [5:0]        thead_lsb;
  rand bit [5:0]        thead_imm;
  rand bit [1:0]        thead_scale;
  rand bit signed [4:0] thead_step;
  rand bit [3:0]        thead_pair_imm;
  rand riscv_fpr_t      thead_fpr;

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

  constraint thead_pair_c {
    if (instr_name inside {THEAD_LWD, THEAD_LWUD, THEAD_SWD}) {
      thead_pair_imm inside {[0:7]};
    }
    if (instr_name inside {THEAD_LWD, THEAD_LDD, THEAD_LWUD}) {
      rd != rs1;
      rs2 != rs1;
    }
  }

  `uvm_object_utils(riscv_custom_instr)
  `uvm_object_new

  virtual function thead_operand_format_t get_thead_format();
    case (instr_name)
      THEAD_TSTNBZ, THEAD_REV, THEAD_FF0, THEAD_FF1, THEAD_REVW:
        return THEAD_FMT_RR;
      THEAD_SRRI, THEAD_SRRIW, THEAD_TST:
        return THEAD_FMT_RRI;
      THEAD_ADDSL:
        return THEAD_FMT_RRRI;
      THEAD_EXT, THEAD_EXTU:
        return THEAD_FMT_RRII;
      THEAD_MVEQZ, THEAD_MVNEZ, THEAD_MULA, THEAD_MULS,
      THEAD_MULAW, THEAD_MULSW, THEAD_MULAH, THEAD_MULSH:
        return THEAD_FMT_RRR;

      THEAD_LRB, THEAD_LRBU, THEAD_LRH, THEAD_LRHU, THEAD_LRW, THEAD_LRWU,
      THEAD_LRD, THEAD_SRB, THEAD_SRH, THEAD_SRW, THEAD_SRD,
      THEAD_LURB, THEAD_LURBU, THEAD_LURH, THEAD_LURHU, THEAD_LURW,
      THEAD_LURWU, THEAD_LURD, THEAD_SURB, THEAD_SURH, THEAD_SURW, THEAD_SURD:
        return THEAD_FMT_MEM_INDEXED;

      THEAD_LBIA, THEAD_LBIB, THEAD_LBUIA, THEAD_LBUIB,
      THEAD_LHIA, THEAD_LHIB, THEAD_LHUIA, THEAD_LHUIB,
      THEAD_LWIA, THEAD_LWIB, THEAD_LWUIA, THEAD_LWUIB,
      THEAD_LDIA, THEAD_LDIB, THEAD_SBIA, THEAD_SBIB,
      THEAD_SHIA, THEAD_SHIB, THEAD_SWIA, THEAD_SWIB, THEAD_SDIA, THEAD_SDIB:
        return THEAD_FMT_MEM_INCREMENT;

      THEAD_LWD, THEAD_LDD, THEAD_LWUD, THEAD_SWD, THEAD_SDD:
        return THEAD_FMT_MEM_PAIR;

      THEAD_FLRW, THEAD_FLRD, THEAD_FLURW, THEAD_FLURD,
      THEAD_FSRW, THEAD_FSRD, THEAD_FSURW, THEAD_FSURD:
        return THEAD_FMT_FP_INDEXED;

      THEAD_DCACHE_ISW, THEAD_DCACHE_CSW, THEAD_DCACHE_CISW,
      THEAD_DCACHE_IVA, THEAD_DCACHE_CVA, THEAD_DCACHE_CVAL1,
      THEAD_DCACHE_CIVA, THEAD_DCACHE_IPA, THEAD_DCACHE_CPA,
      THEAD_DCACHE_CPAL1, THEAD_DCACHE_CIPA,
      THEAD_ICACHE_IVA, THEAD_ICACHE_IPA:
        return THEAD_FMT_CACHE_ADDR;

      THEAD_DCACHE_IALL, THEAD_DCACHE_CALL, THEAD_DCACHE_CIALL,
      THEAD_ICACHE_IALL, THEAD_ICACHE_IALLS,
      THEAD_L2CACHE_IALL, THEAD_L2CACHE_CALL, THEAD_L2CACHE_CIALL,
      THEAD_SYNC, THEAD_SYNC_I, THEAD_SYNC_S, THEAD_SYNC_IS:
        return THEAD_FMT_NONE;

      default: `uvm_fatal("riscv_custom_instr",
                          $sformatf("Unsupported custom instruction %0s", instr_name.name()))
    endcase
  endfunction : get_thead_format

  virtual function string get_thead_mnemonic();
    string name;
    case (instr_name)
      THEAD_DCACHE_IALL:   return "dcache.iall";
      THEAD_DCACHE_CALL:   return "dcache.call";
      THEAD_DCACHE_CIALL:  return "dcache.ciall";
      THEAD_DCACHE_ISW:    return "dcache.isw";
      THEAD_DCACHE_CSW:    return "dcache.csw";
      THEAD_DCACHE_CISW:   return "dcache.cisw";
      THEAD_DCACHE_IVA:    return "dcache.iva";
      THEAD_DCACHE_CVA:    return "dcache.cva";
      THEAD_DCACHE_CVAL1:  return "dcache.cval1";
      THEAD_DCACHE_CIVA:   return "dcache.civa";
      THEAD_DCACHE_IPA:    return "dcache.ipa";
      THEAD_DCACHE_CPA:    return "dcache.cpa";
      THEAD_DCACHE_CPAL1:  return "dcache.cpal1";
      THEAD_DCACHE_CIPA:   return "dcache.cipa";
      THEAD_ICACHE_IALL:   return "icache.iall";
      THEAD_ICACHE_IALLS:  return "icache.ialls";
      THEAD_ICACHE_IVA:    return "icache.iva";
      THEAD_ICACHE_IPA:    return "icache.ipa";
      THEAD_L2CACHE_IALL:  return "l2cache.iall";
      THEAD_L2CACHE_CALL:  return "l2cache.call";
      THEAD_L2CACHE_CIALL: return "l2cache.ciall";
      THEAD_SYNC_I:        return "sync.i";
      THEAD_SYNC_S:        return "sync.s";
      THEAD_SYNC_IS:       return "sync.is";
      default: begin
        name = instr_name.name().tolower();
        return name.substr(6, name.len() - 1);
      end
    endcase
  endfunction : get_thead_mnemonic

  virtual function void set_rand_mode();
    thead_operand_format_t operand_format;
    super.set_rand_mode();
    operand_format = get_thead_format();
    has_rd = !(operand_format inside {THEAD_FMT_FP_INDEXED,
                                      THEAD_FMT_CACHE_ADDR, THEAD_FMT_NONE});
    has_rs1 = !(operand_format == THEAD_FMT_NONE);
    has_rs2 = operand_format inside {THEAD_FMT_RRRI, THEAD_FMT_RRR,
                                     THEAD_FMT_MEM_INDEXED, THEAD_FMT_MEM_PAIR,
                                     THEAD_FMT_FP_INDEXED};
    has_imm = 1'b0;
  endfunction : set_rand_mode

  function void pre_randomize();
    thead_operand_format_t operand_format;
    super.pre_randomize();
    operand_format = get_thead_format();
    thead_msb.rand_mode(operand_format == THEAD_FMT_RRII);
    thead_lsb.rand_mode(operand_format == THEAD_FMT_RRII);
    thead_imm.rand_mode(operand_format inside {THEAD_FMT_RRI, THEAD_FMT_RRRI});
    thead_scale.rand_mode(operand_format inside {THEAD_FMT_MEM_INDEXED,
                                                 THEAD_FMT_MEM_INCREMENT,
                                                 THEAD_FMT_MEM_PAIR,
                                                 THEAD_FMT_FP_INDEXED});
    thead_step.rand_mode(operand_format == THEAD_FMT_MEM_INCREMENT);
    thead_pair_imm.rand_mode(operand_format == THEAD_FMT_MEM_PAIR);
    thead_fpr.rand_mode(operand_format == THEAD_FMT_FP_INDEXED);
  endfunction : pre_randomize

  function void configure_safe_memory_operands(riscv_reg_t base_reg,
                                                riscv_reg_t data_reg,
                                                riscv_reg_t pair_reg,
                                                riscv_fpr_t float_reg);
    rd = data_reg;
    rs1 = base_reg;
    rs2 = ZERO;
    thead_scale = 0;
    thead_step = 0;
    thead_pair_imm = 0;
    thead_fpr = float_reg;
    if (get_thead_format() == THEAD_FMT_MEM_PAIR) begin
      rs2 = pair_reg;
    end
  endfunction : configure_safe_memory_operands

  // Convert the instruction to the operand syntax used by the Xuantie assembler.
  virtual function string convert2asm(string prefix = "");
    string asm_str;
    asm_str = format_string(get_thead_mnemonic(), MAX_INSTR_STR_LEN);
    case (get_thead_format())
      THEAD_FMT_RR:
        asm_str = $sformatf("%0s%0s, %0s", asm_str, rd.name(), rs1.name());
      THEAD_FMT_RRI:
        asm_str = $sformatf("%0s%0s, %0s, %0d", asm_str, rd.name(), rs1.name(), thead_imm);
      THEAD_FMT_RRRI:
        asm_str = $sformatf("%0s%0s, %0s, %0s, %0d", asm_str, rd.name(), rs1.name(),
                            rs2.name(), thead_imm);
      THEAD_FMT_RRII:
        asm_str = $sformatf("%0s%0s, %0s, %0d, %0d", asm_str, rd.name(), rs1.name(),
                            thead_msb, thead_lsb);
      THEAD_FMT_RRR:
        asm_str = $sformatf("%0s%0s, %0s, %0s", asm_str, rd.name(), rs1.name(), rs2.name());
      THEAD_FMT_MEM_INDEXED:
        asm_str = $sformatf("%0s%0s, %0s, %0s, %0d", asm_str, rd.name(), rs1.name(),
                            rs2.name(), thead_scale);
      THEAD_FMT_MEM_INCREMENT:
        asm_str = $sformatf("%0s%0s, (%0s), %0d, %0d", asm_str, rd.name(), rs1.name(),
                            $signed(thead_step), thead_scale);
      THEAD_FMT_MEM_PAIR:
        asm_str = $sformatf("%0s%0s, %0s, (%0s), %0d, %0d", asm_str, rd.name(),
                            rs2.name(), rs1.name(), thead_scale, thead_pair_imm);
      THEAD_FMT_FP_INDEXED:
        asm_str = $sformatf("%0s%0s, %0s, %0s, %0d", asm_str, thead_fpr.name(),
                            rs1.name(), rs2.name(), thead_scale);
      THEAD_FMT_CACHE_ADDR:
        asm_str = $sformatf("%0s%0s", asm_str, rs1.name());
      THEAD_FMT_NONE: ;
      default: `uvm_fatal("riscv_custom_instr", "Unsupported T-Head operand format")
    endcase

    if (comment != "") begin
      asm_str = {asm_str, " #", comment};
    end
    return asm_str.tolower();
  endfunction : convert2asm

endclass : riscv_custom_instr
