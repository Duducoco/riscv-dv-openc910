import unittest

from check_generated_asm import check_assembly


class CheckGeneratedAssemblyTest(unittest.TestCase):
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

        counts = check_assembly(assembly)

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
            check_assembly(assembly)

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
            check_assembly(assembly)


if __name__ == "__main__":
    unittest.main()
