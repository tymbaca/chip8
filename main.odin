package main

import ch "chip8"
import "core:fmt"

main :: proc() {
	cpu := ch.CPU{}
	/*
	fmt.println(cpu.pc)
	cpu.opcode = 0x0421
	ch.SYS(&cpu)
	fmt.println(cpu.pc)
    */

	a := u8(254)
	fmt.println(a)
	fmt.printf("%08b", a)
	a += 2
	// 254 2
	// 255 1
	// 0   0
	fmt.println(a)
	fmt.printf("%08b", a)
}
