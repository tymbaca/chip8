package chip8

import "core:fmt"

STEP :: 2

cycle :: proc(cpu: ^CPU) {
	// Join 2 bytes (u8) into 1 u16
	cpu.opcode = u16(cpu.ram[cpu.pc]) << 8 | u16(cpu.ram[cpu.pc + 1])

	op := OpcodeXYZ(cpu.opcode)
	switch op.i { 	// get first 4 bits
	case 0:
		switch {
		case op.x == 0x0 && op.y == 0xE && op.z == 0x0:
			CLS(cpu)
		case op.x == 0x0 && op.y == 0xE && op.z == 0xE:
			RET(cpu)
		case:
			// 0nnn
			SYS(cpu)
		}
	case 1:
		JP(cpu)
	case 2:
		CALL(cpu)
	case 3:
		SE_byte(cpu)
	case 4:
		SNE_byte(cpu)
	case 5:
		SE_xy(cpu)
	case 6:
		LD_byte(cpu)
	case 7:
		ADD_byte(cpu)
	case 8:
		switch op.z { 	// check the last 4 bits
		case 0:
			LD_xy(cpu) // 8xy0 
		case 1:
			OR_xy(cpu) // 8xy1
		case 2:
			AND_xy(cpu) // etc...
		case 3:
			XOR_xy(cpu)
		case 4:
			ADD_xy(cpu)
		case 5:
			SUB(cpu)
		case 6:
			SHR(cpu)
		case 7:
			SUBN(cpu)
		case 0xE:
			SHL(cpu)
		case:
			fmt.printf("unknown opcode: %x (%b)\n", cpu.opcode, cpu.opcode)
		}
	case 9:
		SNE(cpu)
	case 0xA:
		LD_I(cpu)
	case 0xB:
		JP_offset(cpu)
	case 0xC:
		RND(cpu)
	case 0xD:
		DRW(cpu)
	case 0xE:
		op := OpcodeXYZ(cpu.opcode)
		switch {
		case op.y == 0x9 && op.z == 0xE:
			SKP(cpu)
		case op.y == 0xA && op.z == 0x1:
			SKNP(cpu)
		case:
			fmt.printf("unknown opcode: %x (%b)\n", cpu.opcode, cpu.opcode)
		}
	case 0xF:
	case:
		fmt.printf("unknown opcode: %x (%b)\n", cpu.opcode, cpu.opcode)
	}

	cpu.pc += STEP
}
