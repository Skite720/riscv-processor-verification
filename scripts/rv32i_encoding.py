from __future__ import annotations


def check_signed(value: int, bits: int) -> None:
    minimum = -(1 << (bits - 1))
    maximum = (1 << (bits - 1)) - 1

    if not minimum <= value <= maximum:
        raise ValueError(
            f"{value} does not fit in signed {bits}-bit immediate"
        )


def check_reg(reg: int) -> None:
    if not 0 <= reg <= 31:
        raise ValueError(f"Register x{reg} is invalid")


def r_type(
    funct7: int,
    rs2: int,
    rs1: int,
    funct3: int,
    rd: int,
    opcode: int = 0x33
) -> int:

    check_reg(rs1)
    check_reg(rs2)
    check_reg(rd)

    return (
        ((funct7 & 0x7F) << 25)
        | ((rs2 & 0x1F) << 20)
        | ((rs1 & 0x1F) << 15)
        | ((funct3 & 0x7) << 12)
        | ((rd & 0x1F) << 7)
        | (opcode & 0x7F)
    )


def i_type(
    imm: int,
    rs1: int,
    funct3: int,
    rd: int,
    opcode: int = 0x13
) -> int:

    check_signed(imm, 12)
    check_reg(rs1)
    check_reg(rd)

    return (
        ((imm & 0xFFF) << 20)
        | ((rs1 & 0x1F) << 15)
        | ((funct3 & 0x7) << 12)
        | ((rd & 0x1F) << 7)
        | (opcode & 0x7F)
    )


def s_type(
    imm: int,
    rs2: int,
    rs1: int,
    funct3: int = 0b010,
    opcode: int = 0x23
) -> int:

    check_signed(imm, 12)
    check_reg(rs1)
    check_reg(rs2)

    value = imm & 0xFFF

    return (
        (((value >> 5) & 0x7F) << 25)
        | ((rs2 & 0x1F) << 20)
        | ((rs1 & 0x1F) << 15)
        | ((funct3 & 0x7) << 12)
        | ((value & 0x1F) << 7)
        | (opcode & 0x7F)
    )


def b_type(
    imm: int,
    rs2: int,
    rs1: int,
    funct3: int = 0b000,
    opcode: int = 0x63
) -> int:

    check_signed(imm, 13)

    if imm % 2 != 0:
        raise ValueError("Branch immediate must be 2-byte aligned")

    check_reg(rs1)
    check_reg(rs2)

    value = imm & 0x1FFF

    bit12 = (value >> 12) & 1
    bit11 = (value >> 11) & 1
    bits10_5 = (value >> 5) & 0x3F
    bits4_1 = (value >> 1) & 0xF

    return (
        (bit12 << 31)
        | (bits10_5 << 25)
        | ((rs2 & 0x1F) << 20)
        | ((rs1 & 0x1F) << 15)
        | ((funct3 & 0x7) << 12)
        | (bits4_1 << 8)
        | (bit11 << 7)
        | (opcode & 0x7F)
    )


# -------------------------
# I-Type instructions
# -------------------------

def addi(rd, rs1, imm):
    return i_type(imm, rs1, 0b000, rd)


def andi(rd, rs1, imm):
    return i_type(imm, rs1, 0b111, rd)


def ori(rd, rs1, imm):
    return i_type(imm, rs1, 0b110, rd)


def xori(rd, rs1, imm):
    return i_type(imm, rs1, 0b100, rd)


def slti(rd, rs1, imm):
    return i_type(imm, rs1, 0b010, rd)


# -------------------------
# R-Type instructions
# -------------------------

def add(rd, rs1, rs2):
    return r_type(0x00, rs2, rs1, 0b000, rd)


def sub(rd, rs1, rs2):
    return r_type(0x20, rs2, rs1, 0b000, rd)


def and_(rd, rs1, rs2):
    return r_type(0x00, rs2, rs1, 0b111, rd)


def or_(rd, rs1, rs2):
    return r_type(0x00, rs2, rs1, 0b110, rd)


def xor_(rd, rs1, rs2):
    return r_type(0x00, rs2, rs1, 0b100, rd)


def slt(rd, rs1, rs2):
    return r_type(0x00, rs2, rs1, 0b010, rd)


# -------------------------
# Memory instructions
# -------------------------

def lw(rd, rs1, imm):
    return i_type(imm, rs1, 0b010, rd, opcode=0x03)


def sw(rs2, rs1, imm):
    return s_type(imm, rs2, rs1)


# -------------------------
# Branch
# -------------------------

def beq(rs1, rs2, imm):
    return b_type(imm, rs2, rs1, funct3=0b000)


# -------------------------
# Write machine code
# -------------------------

def write_hex(path, instructions):

    with open(path, "w", encoding="utf-8") as file:

        for instruction in instructions:
            file.write(f"{instruction:08x}\n")