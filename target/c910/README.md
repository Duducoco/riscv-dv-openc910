# C910 target

This target generates all 19 scalar instructions in the C910 performance-extension
decoder: `addsl`, `srri`, `srriw`, `tstnbz`, `rev`, `ff0`, `ff1`, `tst`, `revw`,
`ext`, `extu`, `mveqz`, `mvnez`, `mula`, `muls`, `mulaw`, `mulsw`, `mulah`, and
`mulsh`.

Generate one deterministic test with VCS and compile it with the Xuantie
toolchain:

```bash
export RISCV_GCC="$TOOL_EXTENSION/riscv64-unknown-elf-gcc"
export RISCV_OBJCOPY="$TOOL_EXTENSION/riscv64-unknown-elf-objcopy"

python3 run.py \
  --custom_target target/c910 \
  --test c910_xthead_rand_test \
  --simulator vcs \
  --steps gen,gcc_compile \
  --isa rv64imafdcxtheadc \
  --mabi lp64d \
  --seed 1 \
  --output out/c910
```

The custom target directory is placed first on the assembly include path, so
the C910-specific `user_init.s` enables `MXSTATUS.THEADISAEE`. To compile a
previously generated test manually:

```bash
$TOOL_EXTENSION/riscv64-unknown-elf-gcc \
  -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles \
  -Itarget/c910 -Iuser_extension -T scripts/link.ld \
  -march=rv64imafdcxtheadc -mabi=lp64d \
  out/c910/asm_test/c910_xthead_rand_test_0.S \
  -o out/c910/asm_test/c910_xthead_rand_test_0.o
```

Standard ISS builds do not implement these vendor instructions, so this target
sets `no_iss: 1` and does not enable ISS comparison. Custom load/store, cache,
and barrier instructions are intentionally excluded because random generation
needs a dedicated memory and privilege-state model for their side effects.

Check that all custom instruction families were generated and that `ext`/`extu`
bit ranges are valid:

```bash
python3 target/c910/check_generated_asm.py \
  out/c910/asm_test/c910_xthead_rand_test_0.S
```
