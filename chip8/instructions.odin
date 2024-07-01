package chip8

Exec :: proc(cpu: ^CPU)

/* 0nnn - SYS addr
Jump to a machine code routine at nnn.

This instruction is only used on the old computers on which Chip-8 was 
originally implemented. It is ignored by modern interpreters.*/
SYS :: proc(cpu: ^CPU) {
	using cpu
	op := OpcodeAddr(opcode)
	cpu.pc = op.a
}

/* 00E0 - CLS
Clear the display. */
CLS :: proc(cpu: ^CPU) {
	for &row in cpu.display {
		for &pix in row {
			pix = false
		}
	}
}

/* 00EE - RET
Return from a subroutine.

The interpreter sets the program counter to the address 
at the top of the stack, then subtracts 1 from the stack pointer. */
RET :: proc(cpu: ^CPU) {
	using cpu
	pc = stack[sp]
	sp -= 1
}

/* 1nnn - JP addr
Jump to location nnn.

The interpreter sets the program counter to nnn.*/
JP :: proc(cpu: ^CPU) {
	using cpu
	op := OpcodeAddr(opcode)
	cpu.pc = op.a
}

/* 2nnn - CALL addr
Call subroutine at nnn.

The interpreter increments the stack pointer, then puts the 
current PC on the top of the stack. The PC is then set to nnn.*/
CALL :: proc(cpu: ^CPU) {
	op := OpcodeAddr(cpu.opcode)

	cpu.sp += 1
	cpu.stack[cpu.sp] = cpu.pc
	cpu.pc = op.a
}

/* 3xkk - SE Vx, byte
Skip next instruction if Vx = kk.

The interpreter compares register Vx to kk, and if they are equal, 
increments the program counter by 2.*/
SE_byte :: proc(cpu: ^CPU) {
	op := OpcodeXKK(cpu.opcode)

	if cpu.regs[op.x] == op.kk {
		cpu.pc += STEP
	}
}

/* 4xkk - SNE Vx, byte
Skip next instruction if Vx != kk.

The interpreter compares register Vx to kk, and if they are not equal, 
increments the program counter by 2.*/
SNE_byte :: proc(cpu: ^CPU) {
	op := OpcodeXKK(cpu.opcode)

	if cpu.regs[op.x] != op.kk {
		cpu.pc += STEP
	}
}

/* 5xy0 - SE Vx, Vy
Skip next instruction if Vx = Vy.

The interpreter compares register Vx to register Vy, and if they are equal, 
increments the program counter by 2.*/
SE_xy :: proc(cpu: ^CPU) {
	op := OpcodeXYZ(cpu.opcode)

	if cpu.regs[op.x] == cpu.regs[op.y] {
		cpu.pc += STEP
	}
}

/* 6xkk - LD Vx, byte
Set Vx = kk.

The interpreter puts the value kk into register Vx.*/
LD_byte :: proc(cpu: ^CPU) {
	op := OpcodeXKK(cpu.opcode)

	cpu.regs[op.x] = op.kk
}

/* 7xkk - ADD Vx, byte
Set Vx = Vx + kk.

Adds the value kk to the value of register Vx, then stores the result in Vx.*/
ADD_byte :: proc(cpu: ^CPU) {
	op := OpcodeXKK(cpu.opcode)

	cpu.regs[op.x] += op.kk
}

/* 8xy0 - LD Vx, Vy
Set Vx = Vy.

Stores the value of register Vy in register Vx.*/
LD_xy :: proc(cpu: ^CPU) {
	op := OpcodeXYZ(cpu.opcode)

	cpu.regs[op.x] = cpu.regs[op.y]
}

/* 8xy1 - OR Vx, Vy
Set Vx = Vx OR Vy.

Performs a bitwise OR on the values of Vx and Vy, then stores the result in Vx. 
A bitwise OR compares the corrseponding bits from two values, and if either 
bit is 1, then the same bit in the result is also 1. Otherwise, it is 0.*/
OR_xy :: proc(cpu: ^CPU) {
	op := OpcodeXYZ(cpu.opcode)

	cpu.regs[op.x] |= cpu.regs[op.y]
}

/* 8xy2 - AND Vx, Vy
Set Vx = Vx AND Vy.

Performs a bitwise AND on the values of Vx and Vy, then stores the result in Vx. 
A bitwise AND compares the corrseponding bits from two values, and if both 
bits are 1, then the same bit in the result is also 1. Otherwise, it is 0.*/
AND_xy :: proc(cpu: ^CPU) {
	op := OpcodeXYZ(cpu.opcode)

	cpu.regs[op.x] &= cpu.regs[op.y]
}

/* 8xy3 - XOR Vx, Vy
Set Vx = Vx XOR Vy.

Performs a bitwise exclusive OR on the values of Vx and Vy, then stores the result 
in Vx. An exclusive OR compares the corrseponding bits from two values, and 
if the bits are not both the same, then the corresponding bit in the result is set to 1. 
Otherwise, it is 0.*/
XOR_xy :: proc(cpu: ^CPU) {
	op := OpcodeXYZ(cpu.opcode)

	cpu.regs[op.x] ~= cpu.regs[op.y]
}

/* 8xy4 - ADD Vx, Vy
Set Vx = Vx + Vy, set VF = carry.

The values of Vx and Vy are added together. If the result is greater than 
8 bits (i.e., > 255,) VF is set to 1, otherwise 0. Only the lowest 8 bits 
of the result are kept, and stored in Vx.*/
ADD_xy :: proc(cpu: ^CPU) {
	op := OpcodeXYZ(cpu.opcode)

	sum := cpu.regs[op.x] + cpu.regs[op.y]
	if sum > 255 {
		cpu.regs[0xF] = 1
	} else {
		cpu.regs[0xF] = 0
	}

	cpu.regs[op.x] = sum
}

/* 8xy5 - SUB Vx, Vy
Set Vx = Vx - Vy, set VF = NOT borrow.

If Vx > Vy, then VF is set to 1, otherwise 0. Then Vy is subtracted from 
Vx, and the results stored in Vx.*/
SUB :: proc(cpu: ^CPU) {
	op := OpcodeXYZ(cpu.opcode)
	using cpu

	if regs[op.x] > regs[op.y] {
		regs[0xF] = 1
	} else {
		regs[0xF] = 0
	}

	regs[op.x] -= regs[op.y]
}


/* 8xy6 - SHR Vx {, Vy}
Set Vx = Vx SHR 1.

If the least-significant bit of Vx is 1, then VF is set to 1, otherwise 
0. Then Vx is divided by 2.*/
SHR :: proc(cpu: ^CPU) {
	op := OpcodeXYZ(cpu.opcode)
	using cpu

	if op.x & 0b0001 == 1 {
		regs[0xF] = 1
	} else {
		regs[0xF] = 0
	}

	regs[op.x] /= 2
}


/* 8xy7 - SUBN Vx, Vy
Set Vx = Vy - Vx, set VF = NOT borrow.

If Vy > Vx, then VF is set to 1, otherwise 0. Then Vx is subtracted from 
Vy, and the results stored in Vx.*/
SUBN :: proc(cpu: ^CPU) {
	op := OpcodeXYZ(cpu.opcode)
	using cpu

	if regs[op.y] > regs[op.x] {
		regs[0xF] = 1
	} else {
		regs[0xF] = 0
	}

	regs[op.x] = regs[op.y] - regs[op.x]
}


/* 8xyE - SHL Vx {, Vy}
Set Vx = Vx SHL 1.

If the most-significant bit of Vx is 1, then VF is set to 1, otherwise 
to 0. Then Vx is multiplied by 2.*/
SHL :: proc(cpu: ^CPU) {
	op := OpcodeXYZ(cpu.opcode)
	using cpu

	left_bit := regs[op.x] >> 7
	regs[0xF] = left_bit
	regs[op.x] *= 2
}


/* 9xy0 - SNE Vx, Vy
Skip next instruction if Vx != Vy.

The values of Vx and Vy are compared, and if they are not equal, the program 
counter is increased by 2.*/
SNE :: proc(cpu: ^CPU) {
	op := OpcodeXYZ(cpu.opcode)

	if cpu.regs[op.x] != cpu.regs[op.y] {
		cpu.pc += STEP
	}
}


/* Annn - LD I, addr
Set I = nnn.

The value of register I is set to nnn.*/
LD_I :: proc(cpu: ^CPU) {
	op := OpcodeAddr(cpu.opcode)
	cpu.reg_i = op.a
}


/* Bnnn - JP V0, addr
Jump to location nnn + V0.

The program counter is set to nnn plus the value of V0.*/
JP_offset :: proc(cpu: ^CPU) {
	using cpu
	op := OpcodeAddr(opcode)
	cpu.pc = op.a + u16(regs[0x0])
}


/* Cxkk - RND Vx, byte
Set Vx = random byte AND kk.

The interpreter generates a random number from 0 to 255, which is then 
ANDed with the value kk. The results are stored in Vx. See instruction 
8xy2 for more information on AND.*/
RND :: proc(cpu: ^CPU) {
	op := OpcodeXKK(cpu.opcode)
	using cpu

	regs[op.x] = random_byte() & op.kk
}


/* Dxyn - DRW Vx, Vy, nibble
Display n-byte sprite starting at memory location I at (Vx, Vy), set VF = collision.

The interpreter reads n bytes from memory, starting at the address stored 
in I. These bytes are then displayed as sprites on screen at coordinates 
(Vx, Vy). Sprites are XORed onto the existing screen. If this causes any 
pixels to be erased, VF is set to 1, otherwise it is set to 0. If the sprite 
is positioned so part of it is outside the coordinates of the display, 
it wraps around to the opposite side of the screen. See instruction 8xy3 
for more information on XOR, and section 2.4, Display, for more information 
on the Chip-8 screen and sprites.*/
DRW :: proc(cpu: ^CPU) {
	op := OpcodeXYZ(cpu.opcode)
	// TODO:
}


/* Ex9E - SKP Vx
Skip next instruction if key with the value of Vx is pressed.

Checks the keyboard, and if the key corresponding to the value of Vx is 
currently in the down position, PC is increased by 2.*/
SKP :: proc(cpu: ^CPU) {
	op := OpcodeXYZ(cpu.opcode)

	if is_key_pressed(op.x) {
		cpu.pc += 1
	}
}


/* ExA1 - SKNP Vx
Skip next instruction if key with the value of Vx is not pressed.

Checks the keyboard, and if the key corresponding to the value of Vx is 
currently in the up position, PC is increased by 2.*/
SKNP :: proc(cpu: ^CPU) {
	op := OpcodeXYZ(cpu.opcode)

	if !is_key_pressed(op.x) {
		cpu.pc += 1
	}
}


/* Fx07 - LD Vx, DT
Set Vx = delay timer value.

The value of DT is placed into Vx.*/
LD_Vx_DT :: proc(cpu: ^CPU) {
	op := OpcodeXYZ(cpu.opcode)
	cpu.regs[op.x] = cpu.delay_timer
}


/* Fx0A - LD Vx, K
Wait for a key press, store the value of the key in Vx.

All execution stops until a key is pressed, then the value of that key 
is stored in Vx.*/
LD_Vx_K :: proc(cpu: ^CPU) {
	op := OpcodeXYZ(cpu.opcode)
	key := wait_and_get_key()
	// TODO:
}


/* Fx15 - LD DT, Vx
Set delay timer = Vx.

DT is set equal to the value of Vx.*/
LD_DT :: proc(cpu: ^CPU) {
	op := OpcodeXYZ(cpu.opcode)

	cpu.delay_timer = cpu.regs[op.x]
}


/* Fx18 - LD ST, Vx
Set sound timer = Vx.

ST is set equal to the value of Vx.*/
LD_ST :: proc(cpu: ^CPU) {
	op := OpcodeXYZ(cpu.opcode)

	cpu.sound_timer = cpu.regs[op.x]
}


/* Fx1E - ADD I, Vx
Set I = I + Vx.

The values of I and Vx are added, and the results are stored in I.*/
ADD_I :: proc(cpu: ^CPU) {
	op := OpcodeXYZ(cpu.opcode)

	cpu.reg_i = cpu.reg_i + u16(cpu.regs[op.x])
}


/* Fx29 - LD F, Vx
Set I = location of sprite for digit Vx.

The value of I is set to the location for the hexadecimal sprite corresponding 
to the value of Vx. See section 2.4, Display, for more information on the 
Chip-8 hexadecimal font.*/
LD_F_Vx :: proc(cpu: ^CPU) {
	op := OpcodeXYZ(cpu.opcode)
	// TODO:
}


/* Fx33 - LD B, Vx
Store BCD representation of Vx in memory locations I, I+1, and I+2.

The interpreter takes the decimal value of Vx, and places the hundreds 
digit in memory at location in I, the tens digit at location I+1, and the 
ones digit at location I+2.*/
LD_B :: proc(cpu: ^CPU) {
	op := OpcodeXYZ(cpu.opcode)

	vx := cpu.regs[op.x]

	// 243  51  99  10   6
	// 2__ 0__ 0__ 0__ 0__
	// _4_ _5_ _9_ _1_ _0_
	// __3 __1 __9 __0 __6
	hundreds := vx / 100 % 10
	tens := vx / 10 % 10
	ones := vx / 1 % 10

	cpu.ram[cpu.reg_i] = hundreds
	cpu.ram[cpu.reg_i + 1] = tens
	cpu.ram[cpu.reg_i + 2] = ones
}


/* Fx55 - LD [I], Vx
Store registers V0 through Vx in memory starting at location I.

The interpreter copies the values of registers V0 through Vx into memory, 
starting at the address in I.*/
LD_I_Vx :: proc(cpu: ^CPU) {
	op := OpcodeXYZ(cpu.opcode)

	for idx in 0 ..= op.x {
		cpu.ram[cpu.reg_i + u16(idx)] = cpu.regs[idx]
	}
}


/* Fx65 - LD Vx, [I]
Read registers V0 through Vx from memory starting at location I.

The interpreter reads values from memory starting at location I into registers 
V0 through Vx.*/
LD_Vx_I :: proc(cpu: ^CPU) {
	op := OpcodeXYZ(cpu.opcode)

	for idx in 0 ..= op.x {
		cpu.regs[idx] = cpu.regs[cpu.reg_i + u16(idx)]
	}
}
