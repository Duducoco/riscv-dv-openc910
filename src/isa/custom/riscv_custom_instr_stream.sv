/*
 * Copyright 2026
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

class riscv_c910_data_page_instr_stream extends riscv_mem_access_stream;

  rand int unsigned data_page_id;

  constraint data_page_c {
    data_page_id < max_data_page_id;
  }

  `uvm_object_utils(riscv_c910_data_page_instr_stream)
  `uvm_object_new

  function riscv_pseudo_instr create_base_init(riscv_reg_t base_reg);
    riscv_pseudo_instr la_instr;
    la_instr = riscv_pseudo_instr::type_id::create("c910_data_page_base_init");
    la_instr.pseudo_instr_name = LA;
    la_instr.rd = base_reg;
    la_instr.imm_str = $sformatf("%0s%0s+64", hart_prefix(hart),
                                 cfg.mem_region[data_page_id].name);
    return la_instr;
  endfunction : create_base_init

  function void append_memory_instructions(riscv_instr_name_t instr_names[]);
    foreach (instr_names[i]) begin
      riscv_custom_instr instr;
      $cast(instr, riscv_instr::get_instr(instr_names[i]));
      instr.configure_safe_memory_operands(S0, A0, A1, FA0);
      instr_list.push_back(create_base_init(S0));
      instr_list.push_back(instr);
    end
  endfunction : append_memory_instructions

  function void append_sync_instructions(riscv_instr_name_t instr_names[]);
    instr_list.push_back(create_base_init(S0));
    foreach (instr_names[i]) begin
      riscv_custom_instr instr;
      $cast(instr, riscv_instr::get_instr(instr_names[i]));
      instr.rs1 = S0;
      instr_list.push_back(instr);
    end
  endfunction : append_sync_instructions

endclass : riscv_c910_data_page_instr_stream


class riscv_c910_memory_instr_stream extends riscv_c910_data_page_instr_stream;

  `uvm_object_utils(riscv_c910_memory_instr_stream)
  `uvm_object_new

  function void post_randomize();
    riscv_instr_name_t memory_instr[] = '{
      THEAD_LRB, THEAD_LRBU, THEAD_LRH, THEAD_LRHU, THEAD_LRW, THEAD_LRWU, THEAD_LRD,
      THEAD_SRB, THEAD_SRH, THEAD_SRW, THEAD_SRD,
      THEAD_LURB, THEAD_LURBU, THEAD_LURH, THEAD_LURHU,
      THEAD_LURW, THEAD_LURWU, THEAD_LURD,
      THEAD_SURB, THEAD_SURH, THEAD_SURW, THEAD_SURD,
      THEAD_LWD, THEAD_LDD, THEAD_LWUD, THEAD_SWD, THEAD_SDD,
      THEAD_LBIA, THEAD_LBIB, THEAD_LBUIA, THEAD_LBUIB,
      THEAD_LHIA, THEAD_LHIB, THEAD_LHUIA, THEAD_LHUIB,
      THEAD_LWIA, THEAD_LWIB, THEAD_LWUIA, THEAD_LWUIB,
      THEAD_LDIA, THEAD_LDIB,
      THEAD_SBIA, THEAD_SBIB, THEAD_SHIA, THEAD_SHIB,
      THEAD_SWIA, THEAD_SWIB, THEAD_SDIA, THEAD_SDIB,
      THEAD_FLRW, THEAD_FLRD, THEAD_FLURW, THEAD_FLURD,
      THEAD_FSRW, THEAD_FSRD, THEAD_FSURW, THEAD_FSURD
    };

    append_memory_instructions(memory_instr);
    super.post_randomize();
  endfunction : post_randomize

endclass : riscv_c910_memory_instr_stream


class riscv_c910_register_offset_memory_instr_stream extends riscv_c910_data_page_instr_stream;

  `uvm_object_utils(riscv_c910_register_offset_memory_instr_stream)
  `uvm_object_new

  function void post_randomize();
    riscv_instr_name_t instr_names[] = '{
      THEAD_LRB, THEAD_LRBU, THEAD_LRH, THEAD_LRHU, THEAD_LRW, THEAD_LRWU, THEAD_LRD,
      THEAD_SRB, THEAD_SRH, THEAD_SRW, THEAD_SRD,
      THEAD_LURB, THEAD_LURBU, THEAD_LURH, THEAD_LURHU,
      THEAD_LURW, THEAD_LURWU, THEAD_LURD,
      THEAD_SURB, THEAD_SURH, THEAD_SURW, THEAD_SURD
    };
    append_memory_instructions(instr_names);
    super.post_randomize();
  endfunction : post_randomize

endclass : riscv_c910_register_offset_memory_instr_stream


class riscv_c910_pair_memory_instr_stream extends riscv_c910_data_page_instr_stream;

  `uvm_object_utils(riscv_c910_pair_memory_instr_stream)
  `uvm_object_new

  function void post_randomize();
    riscv_instr_name_t instr_names[] = '{
      THEAD_LWD, THEAD_LDD, THEAD_LWUD, THEAD_SWD, THEAD_SDD
    };
    append_memory_instructions(instr_names);
    super.post_randomize();
  endfunction : post_randomize

endclass : riscv_c910_pair_memory_instr_stream


class riscv_c910_indexed_memory_instr_stream extends riscv_c910_data_page_instr_stream;

  `uvm_object_utils(riscv_c910_indexed_memory_instr_stream)
  `uvm_object_new

  function void post_randomize();
    riscv_instr_name_t instr_names[] = '{
      THEAD_LBIA, THEAD_LBIB, THEAD_LBUIA, THEAD_LBUIB,
      THEAD_LHIA, THEAD_LHIB, THEAD_LHUIA, THEAD_LHUIB,
      THEAD_LWIA, THEAD_LWIB, THEAD_LWUIA, THEAD_LWUIB,
      THEAD_LDIA, THEAD_LDIB,
      THEAD_SBIA, THEAD_SBIB, THEAD_SHIA, THEAD_SHIB,
      THEAD_SWIA, THEAD_SWIB, THEAD_SDIA, THEAD_SDIB
    };
    append_memory_instructions(instr_names);
    super.post_randomize();
  endfunction : post_randomize

endclass : riscv_c910_indexed_memory_instr_stream


class riscv_c910_floating_memory_instr_stream extends riscv_c910_data_page_instr_stream;

  `uvm_object_utils(riscv_c910_floating_memory_instr_stream)
  `uvm_object_new

  function void post_randomize();
    riscv_instr_name_t instr_names[] = '{
      THEAD_FLRW, THEAD_FLRD, THEAD_FLURW, THEAD_FLURD,
      THEAD_FSRW, THEAD_FSRD, THEAD_FSURW, THEAD_FSURD
    };
    append_memory_instructions(instr_names);
    super.post_randomize();
  endfunction : post_randomize

endclass : riscv_c910_floating_memory_instr_stream


class riscv_c910_cache_sync_instr_stream extends riscv_c910_data_page_instr_stream;

  `uvm_object_utils(riscv_c910_cache_sync_instr_stream)
  `uvm_object_new

  function void post_randomize();
    riscv_instr_name_t cache_sync_instr[] = '{
      THEAD_DCACHE_IALL, THEAD_DCACHE_CALL, THEAD_DCACHE_CIALL,
      THEAD_DCACHE_ISW, THEAD_DCACHE_CSW, THEAD_DCACHE_CISW,
      THEAD_DCACHE_IVA, THEAD_DCACHE_CVA, THEAD_DCACHE_CVAL1, THEAD_DCACHE_CIVA,
      THEAD_DCACHE_IPA, THEAD_DCACHE_CPA, THEAD_DCACHE_CPAL1, THEAD_DCACHE_CIPA,
      THEAD_ICACHE_IALL, THEAD_ICACHE_IALLS, THEAD_ICACHE_IVA, THEAD_ICACHE_IPA,
      THEAD_L2CACHE_IALL, THEAD_L2CACHE_CALL, THEAD_L2CACHE_CIALL,
      THEAD_SYNC, THEAD_SYNC_I, THEAD_SYNC_S, THEAD_SYNC_IS
    };
    append_sync_instructions(cache_sync_instr);
    super.post_randomize();
  endfunction : post_randomize

endclass : riscv_c910_cache_sync_instr_stream


class riscv_c910_dcache_instr_stream extends riscv_c910_data_page_instr_stream;

  `uvm_object_utils(riscv_c910_dcache_instr_stream)
  `uvm_object_new

  function void post_randomize();
    riscv_instr_name_t instr_names[] = '{
      THEAD_DCACHE_IALL, THEAD_DCACHE_CALL, THEAD_DCACHE_CIALL,
      THEAD_DCACHE_ISW, THEAD_DCACHE_CSW, THEAD_DCACHE_CISW,
      THEAD_DCACHE_IVA, THEAD_DCACHE_CVA, THEAD_DCACHE_CVAL1, THEAD_DCACHE_CIVA,
      THEAD_DCACHE_IPA, THEAD_DCACHE_CPA, THEAD_DCACHE_CPAL1, THEAD_DCACHE_CIPA
    };
    append_sync_instructions(instr_names);
    super.post_randomize();
  endfunction : post_randomize

endclass : riscv_c910_dcache_instr_stream


class riscv_c910_icache_instr_stream extends riscv_c910_data_page_instr_stream;

  `uvm_object_utils(riscv_c910_icache_instr_stream)
  `uvm_object_new

  function void post_randomize();
    riscv_instr_name_t instr_names[] = '{
      THEAD_ICACHE_IALL, THEAD_ICACHE_IALLS, THEAD_ICACHE_IVA, THEAD_ICACHE_IPA
    };
    append_sync_instructions(instr_names);
    super.post_randomize();
  endfunction : post_randomize

endclass : riscv_c910_icache_instr_stream


class riscv_c910_l2cache_instr_stream extends riscv_c910_data_page_instr_stream;

  `uvm_object_utils(riscv_c910_l2cache_instr_stream)
  `uvm_object_new

  function void post_randomize();
    riscv_instr_name_t instr_names[] = '{
      THEAD_L2CACHE_IALL, THEAD_L2CACHE_CALL, THEAD_L2CACHE_CIALL
    };
    append_sync_instructions(instr_names);
    super.post_randomize();
  endfunction : post_randomize

endclass : riscv_c910_l2cache_instr_stream


class riscv_c910_sync_instr_stream extends riscv_c910_data_page_instr_stream;

  `uvm_object_utils(riscv_c910_sync_instr_stream)
  `uvm_object_new

  function void post_randomize();
    riscv_instr_name_t instr_names[] = '{
      THEAD_SYNC, THEAD_SYNC_I, THEAD_SYNC_S, THEAD_SYNC_IS
    };
    append_sync_instructions(instr_names);
    super.post_randomize();
  endfunction : post_randomize

endclass : riscv_c910_sync_instr_stream
