package chip8

// 0xIaaa
OpcodeAddr :: bit_field u16 {
	a: u16 | 12, // Address
	i: u8  | 4, // Instruction
}

// 0xIxyz
OpcodeXYZ :: bit_field u16 {
	z: u8 | 4,
	y: u8 | 4,
	x: u8 | 4,
	i: u8 | 4, // Instruction
}

// 0xIXkk
OpcodeXKK :: bit_field u16 {
	kk: u8 | 8,
	x:  u8 | 4,
	i:  u8 | 4, // Instruction
}
