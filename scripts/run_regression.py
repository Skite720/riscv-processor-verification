import re
import shutil
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]

RTL = ROOT / "rtl"
TB = ROOT / "tb"

PROGRAMS = ROOT / "programs"
SIM = ROOT / "sim"

PROGRAMS.mkdir(exist_ok=True)
SIM.mkdir(exist_ok=True)


# --------------------------------------------------
# Check required tools
# --------------------------------------------------

for tool in ["iverilog", "vvp"]:

    if shutil.which(tool) is None:

        print(f"[ERROR] {tool} was not found.")

        print(
            "Make sure Icarus Verilog is installed "
            "and its bin directory is in PATH."
        )

        sys.exit(1)


# --------------------------------------------------
# Import instruction encoder
# --------------------------------------------------

sys.path.insert(0, str(ROOT / "scripts"))

from rv32i_encoding import (
    addi,
    add,
    sub,
    and_,
    or_,
    xor_,
    slt,
    sw,
    lw,
    beq,
    write_hex
)


# --------------------------------------------------
# Generate regression program
# --------------------------------------------------

program = [

    addi(5, 0, 10),        # x5 = 10
    addi(6, 0, 20),        # x6 = 20

    add(7, 5, 6),          # x7 = 30
    sub(8, 7, 5),          # x8 = 20

    and_(9, 5, 6),         # x9 = 0
    or_(10, 5, 6),         # x10 = 30
    xor_(11, 5, 6),        # x11 = 30

    slt(12, 5, 6),         # x12 = 1

    addi(13, 0, 100),      # x13 = 100

    sw(13, 0, 0),          # memory[0] = 100
    lw(14, 0, 0),          # x14 = 100

    beq(7, 10, 8),         # skip next instruction

    addi(15, 0, 99),       # MUST NOT execute

    addi(16, 0, 42),       # branch target
]


program_file = PROGRAMS / "program.hex"

write_hex(program_file, program)


print()
print("========================================")
print("RISC-V PYTHON RTL REGRESSION")
print("========================================")

print()
print("Generated program:")

for index, instruction in enumerate(program):

    print(
        f"  {index:02d}: "
        f"0x{instruction:08x}"
    )


# --------------------------------------------------
# SystemVerilog source files
# --------------------------------------------------

sources = [

    RTL / "alu.sv",
    RTL / "control_unit.sv",
    RTL / "cpu.sv",
    RTL / "data_memory.sv",
    RTL / "decoder.sv",
    RTL / "immediate_generator.sv",
    RTL / "instruction_memory.sv",
    RTL / "program_counter.sv",
    RTL / "register.sv",

    TB / "cpu_tb.sv",
]


output_vvp = SIM / "cpu_regression.vvp"


# --------------------------------------------------
# Compile
# --------------------------------------------------

print()
print("[1/3] Compiling SystemVerilog...")

compile_command = [

    "iverilog",

    "-g2012",

    "-Wall",

    "-o",
    str(output_vvp),

    "-s",
    "cpu_tb",

    *map(str, sources),
]


compile_result = subprocess.run(

    compile_command,

    cwd=ROOT,

    text=True,

    capture_output=True,
)


if compile_result.returncode != 0:

    print(compile_result.stdout)

    print(compile_result.stderr)

    print()
    print("[FAIL] Compilation failed.")

    sys.exit(1)


print("[PASS] Compilation successful.")


# --------------------------------------------------
# Run simulation
# --------------------------------------------------

print()
print("[2/3] Running simulation...")

run_result = subprocess.run(

    [
        "vvp",
        str(output_vvp)
    ],

    cwd=ROOT,

    text=True,

    capture_output=True,
)


print(run_result.stdout)


if run_result.returncode != 0:

    print(run_result.stderr)

    print()
    print("[FAIL] Simulation failed.")

    sys.exit(1)


# --------------------------------------------------
# Check PASS marker
# --------------------------------------------------

if "TEST_PASS CPU integration regression" not in run_result.stdout:

    print()
    print("[FAIL] CPU testbench did not report PASS.")

    sys.exit(1)


# --------------------------------------------------
# Expected architectural state
# --------------------------------------------------

expected_registers = {

    5: 10,
    6: 20,
    7: 30,
    8: 20,

    9: 0,
    10: 30,
    11: 30,

    12: 1,

    13: 100,
    14: 100,

    # BEQ must skip x15
    15: 0,

    # Branch target
    16: 42,
}


# --------------------------------------------------
# Verify registers
# --------------------------------------------------

print()
print("[3/3] Checking architectural state...")


for register, expected in expected_registers.items():

    match = re.search(
        rf"REG x{register}\s+(-?\d+)",
        run_result.stdout
    )

    if not match:

        print(
            f"[FAIL] x{register} was not reported."
        )

        sys.exit(1)


    actual = int(match.group(1))


    if actual != expected:

        print(
            f"[FAIL] x{register}: "
            f"expected {expected}, "
            f"got {actual}"
        )

        sys.exit(1)


    print(
        f"  PASS x{register}: {actual}"
    )


# --------------------------------------------------
# Verify memory
# --------------------------------------------------

memory_match = re.search(
    r"MEM 0\s+(-?\d+)",
    run_result.stdout
)


if not memory_match:

    print("[FAIL] Memory result missing.")

    sys.exit(1)


memory_value = int(memory_match.group(1))


if memory_value != 100:

    print(
        f"[FAIL] memory[0]: "
        f"expected 100, "
        f"got {memory_value}"
    )

    sys.exit(1)


print("  PASS memory[0]: 100")


# --------------------------------------------------
# Final result
# --------------------------------------------------

print()
print("========================================")
print("ALL PYTHON-DRIVEN TESTS PASSED")
print("========================================")

print()
print("Verified:")
print("  ADDI")
print("  ADD")
print("  SUB")
print("  AND")
print("  OR")
print("  XOR")
print("  SLT")
print("  LW")
print("  SW")
print("  BEQ")
print("  x0 hardwired to zero")
print("  register results")
print("  memory results")
print("  branch control flow")

print()