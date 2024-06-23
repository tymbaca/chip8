package chip8

import "core:math/rand"

random_byte :: proc() -> u8 {
	return u8(rand.uint32())
}
