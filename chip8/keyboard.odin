package chip8

import "core:c/libc"
import rl "vendor:raylib"

Key :: enum {
	k1,
	k2,
	k3,
	k4,
	k5,
	k6,
	k7,
	k8,
	k9,
	kA,
	kB,
	kC,
	kE,
	kD,
	kF,
}

KeyToCode := map[rl.KeyboardKey]u8 {
	.ZERO  = 0x0,
	.ONE   = 0x1,
	.TWO   = 0x2,
	.THREE = 0x3,
	.FOUR  = 0x4,
	.FIVE  = 0x5,
	.SIX   = 0x6,
	.SEVEN = 0x7,
	.EIGHT = 0x8,
	.NINE  = 0x9,
	.A     = 0xA,
	.B     = 0xB,
	.C     = 0xC,
	.D     = 0xE,
	.E     = 0xD,
	.F     = 0xF,
}

CodeToKey := map[u8]rl.KeyboardKey {
	0x0 = .ZERO, // TODO: figure out layout
	0x1 = .ONE,
	0x2 = .TWO,
	0x3 = .THREE,
	0x4 = .FOUR,
	0x5 = .FIVE,
	0x6 = .SIX,
	0x7 = .SEVEN,
	0x8 = .EIGHT,
	0x9 = .NINE,
	0xA = .A,
	0xB = .B,
	0xC = .C,
	0xE = .D,
	0xD = .E,
	0xF = .F,
}

is_key_pressed :: proc(wait: u8) -> bool {
	got := u8(libc.getchar())
	return wait == got
}

wait_and_get_key :: proc() -> u8 {
	return u8(libc.getchar())
}
