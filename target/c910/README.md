# C910 target

This target generates all 101 private instruction families decoded by C910:

- 19 scalar performance instructions;
- 57 indexed, incrementing, pair, and floating-point memory instructions;
- 25 cache-maintenance and synchronization instructions.

The memory directed stream reloads a generated data-page address before every
private memory instruction. It uses zero offset, step, scale, and pair displacement
so all memory accesses remain in the allocated page. Its test configuration also
enables floating-point state before executing the private floating-point memory
instructions. Cache address operands use the same data-page address in machine-mode
bare addressing.

Generate the three deterministic tests with VCS and compile them with the Xuantie
toolchain:

```bash
export RISCV_GCC="$TOOL_EXTENSION/riscv64-unknown-elf-gcc"
export RISCV_OBJCOPY="$TOOL_EXTENSION/riscv64-unknown-elf-objcopy"

for test in \
  c910_xthead_rand_test \
  c910_xthead_memory_test \
  c910_xthead_cache_sync_test; do
  python3 run.py \
    --custom_target target/c910 \
    --test "$test" \
    --simulator vcs \
    --steps gen,gcc_compile \
    --isa rv64imafdcxtheadc \
    --mabi lp64d \
    --seed 1 \
    --output "out/$test"
done
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

Standard ISS builds do not implement these vendor instructions, so every test
sets `no_iss: 1` and does not enable ISS comparison. The cache test provides
decode/execute stimulus; architectural checking of cache state still requires
C910 RTL monitors or a cache-aware reference model.

Check that all custom instruction families were generated and that `ext`/`extu`
bit ranges are valid:

```bash
python3 target/c910/check_generated_asm.py --group scalar \
  out/c910_xthead_rand_test/asm_test/c910_xthead_rand_test_0.S
python3 target/c910/check_generated_asm.py --group memory \
  out/c910_xthead_memory_test/asm_test/c910_xthead_memory_test_0.S
python3 target/c910/check_generated_asm.py --group cache-sync \
  out/c910_xthead_cache_sync_test/asm_test/c910_xthead_cache_sync_test_0.S
```
