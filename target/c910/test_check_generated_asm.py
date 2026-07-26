import unittest
import re
from pathlib import Path

from check_generated_asm import (
    CACHE_SYNC_INSTRUCTIONS,
    INSTRUCTIONS,
    MEMORY_INSTRUCTIONS,
    SCALAR_INSTRUCTIONS,
    check_assembly,
)


EXPECTED_MEMORY_INSTRUCTIONS = {
    "lrb", "lrbu", "lrh", "lrhu", "lrw", "lrwu", "lrd",
    "srb", "srh", "srw", "srd",
    "lurb", "lurbu", "lurh", "lurhu", "lurw", "lurwu", "lurd",
    "surb", "surh", "surw", "surd",
    "lwd", "ldd", "lwud", "swd", "sdd",
    "lbia", "lbib", "lbuia", "lbuib", "lhia", "lhib", "lhuia", "lhuib",
    "lwia", "lwib", "lwuia", "lwuib", "ldia", "ldib",
    "sbia", "sbib", "shia", "shib", "swia", "swib", "sdia", "sdib",
    "flrw", "flrd", "flurw", "flurd", "fsrw", "fsrd", "fsurw", "fsurd",
}

EXPECTED_CACHE_SYNC_INSTRUCTIONS = {
    "dcache.iall", "dcache.call", "dcache.ciall",
    "dcache.isw", "dcache.csw", "dcache.cisw",
    "dcache.iva", "dcache.cva", "dcache.cval1", "dcache.civa",
    "dcache.ipa", "dcache.cpa", "dcache.cpal1", "dcache.cipa",
    "icache.iall", "icache.ialls", "icache.iva", "icache.ipa",
    "l2cache.iall", "l2cache.call", "l2cache.ciall",
    "sync", "sync.i", "sync.s", "sync.is",
}


class CheckGeneratedAssemblyTest(unittest.TestCase):
    def test_instruction_manifest_is_complete(self):
        self.assertEqual(set(MEMORY_INSTRUCTIONS), EXPECTED_MEMORY_INSTRUCTIONS)
        self.assertEqual(set(CACHE_SYNC_INSTRUCTIONS), EXPECTED_CACHE_SYNC_INSTRUCTIONS)
        self.assertEqual(len(SCALAR_INSTRUCTIONS), 19)
        self.assertEqual(len(INSTRUCTIONS), 101)
        self.assertEqual(len(set(INSTRUCTIONS)), len(INSTRUCTIONS))

    def test_systemverilog_registry_matches_manifest(self):
        root = Path(__file__).resolve().parents[2]
        expected = {f"THEAD_{name.upper().replace('.', '_')}" for name in INSTRUCTIONS}
        enum_text = (root / "src/isa/custom/riscv_custom_instr_enum.sv").read_text()
        registry_text = (root / "src/isa/custom/rv64x_instr.sv").read_text()
        enum_names = set(re.findall(r"^\s*(THEAD_[A-Z0-9_]+),", enum_text, re.MULTILINE))
        registry_names = set(
            re.findall(r"DEFINE_CUSTOM_INSTR\((THEAD_[A-Z0-9_]+),", registry_text)
        )

        self.assertEqual(enum_names, expected)
        self.assertEqual(registry_names, expected)

    def test_memory_test_enables_floating_point_state(self):
        root = Path(__file__).resolve().parents[2]
        testlist = (root / "target/c910/testlist.yaml").read_text()
        memory_test = testlist.split("- test: c910_xthead_memory_test", 1)[1]
        memory_test = memory_test.split("- test:", 1)[0]

        self.assertIn("+enable_floating_point=1", memory_test)

    def test_testlist_custom_streams_are_factory_registered(self):
        root = Path(__file__).resolve().parents[2]
        testlist = (root / "target/c910/testlist.yaml").read_text()
        stream_source = (root / "src/isa/custom/riscv_custom_instr_stream.sv").read_text()
        referenced = set(re.findall(r"\+stream_name_\d+=(riscv_c910_\w+)", testlist))
        registered = set(
            re.findall(r"`uvm_object_utils\((riscv_c910_\w+)\)", stream_source)
        )

        self.assertTrue(referenced)
        self.assertEqual(set(), referenced - registered)

    def test_counts_consecutive_no_operand_instructions(self):
        assembly = """
          sync
          sync.i
          sync.s
          sync.is
        """

        counts = check_assembly(assembly, ("sync", "sync.i", "sync.s", "sync.is"))

        self.assertEqual(set(counts.values()), {1})

    def test_accepts_all_instruction_families(self):
        assembly = """
          addsl a0, a1, a2, 3
          srri a0, a1, 3
          srriw a0, a1, 3
          tstnbz a0, a1
          rev a0, a1
          ff0 a0, a1
          ff1 a0, a1
          tst a0, a1, 3
          revw a0, a1
          ext a0, a1, 63, 0
          extu a0, a1, 9, 4
          mveqz a0, a1, a2
          mvnez a0, a1, a2
          mula a0, a1, a2
          muls a0, a1, a2
          mulaw a0, a1, a2
          mulsw a0, a1, a2
          mulah a0, a1, a2
          mulsh a0, a1, a2
        """

        counts = check_assembly(assembly, SCALAR_INSTRUCTIONS)

        self.assertEqual(set(counts.values()), {1})

    def test_rejects_invalid_ext_range(self):
        assembly = """
          addsl a0, a1, a2, 3
          srri a0, a1, 3
          srriw a0, a1, 3
          tstnbz a0, a1
          rev a0, a1
          ff0 a0, a1
          ff1 a0, a1
          tst a0, a1, 3
          revw a0, a1
          ext a0, a1, 2, 3
          extu a0, a1, 9, 4
          mveqz a0, a1, a2
          mvnez a0, a1, a2
          mula a0, a1, a2
          muls a0, a1, a2
          mulaw a0, a1, a2
          mulsw a0, a1, a2
          mulah a0, a1, a2
          mulsh a0, a1, a2
        """

        with self.assertRaisesRegex(ValueError, "invalid ext bit range"):
            check_assembly(assembly, SCALAR_INSTRUCTIONS)

    def test_rejects_missing_instruction_family(self):
        assembly = """
          addsl a0, a1, a2, 3
          srri a0, a1, 3
          srriw a0, a1, 3
          tstnbz a0, a1
          rev a0, a1
          ff0 a0, a1
          ff1 a0, a1
          tst a0, a1, 3
          revw a0, a1
          ext a0, a1, 63, 0
          extu a0, a1, 9, 4
          mveqz a0, a1, a2
          mula a0, a1, a2
          muls a0, a1, a2
          mulaw a0, a1, a2
          mulsw a0, a1, a2
          mulah a0, a1, a2
          mulsh a0, a1, a2
        """

        with self.assertRaisesRegex(ValueError, "mvnez"):
            check_assembly(assembly, SCALAR_INSTRUCTIONS)


if __name__ == "__main__":
    unittest.main()
