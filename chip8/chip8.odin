package chip8

CPU :: struct {
	opcode:      u16, // Current operation code
	pc:          u16, // Program Counter

	// The stack is an array of 16 16-bit values, used to store the address that 
	// the interpreter shoud return to when finished with a subroutine. 
	// Chip-8 allows for up to 16 levels of nested subroutines.
	stack:       [16]u16,
	sp:          u8, // Stack Pointer

	// 16 general purpose 8-bit registers, usually referred to as Vx, 
	// where x is a hexadecimal digit (0 through F)
	regs:        [16]u8,
	// There is also a 16-bit register called I. This register is generally 
	// used to store memory addresses, so only the lowest (rightmost) 12 bits are usually used.
	reg_i:       u16, // holds address

	// When these registers are non-zero, they are automatically decremented at a rate of 60Hz.
	delay_timer: u8,
	sound_timer: u8,

	// Fields below must be injected and used externaly
	keyboard:    Keyboard,
	display:     Display,
	ram:         RAM,
}

RAM :: [4096]u8
Keyboard :: [16]bool
Display :: [64][32]bool

main :: proc() {
	cpu: CPU
}
