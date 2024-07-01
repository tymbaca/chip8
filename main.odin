package main

import ch "chip8"
import "core:fmt"
import "core:os"
import "core:time"
import rl "vendor:raylib"

main :: proc() {
	fmt.println("waiting a key")

	keycode := ch.wait_and_get_key()

	fmt.printf("got key: %c\n", keycode)
	/*
	cpu := ch.CPU{}
	for b, i in test_program {
		cpu.ram[i] = b
	}

	for {
		fmt.printf("\n-----------------------\n")
		fmt.printf("ram [:10]: %v\n", cpu.ram[:10])
		fmt.printf("program counter: %d\n", cpu.pc)
		fmt.printf("regs: %v\n", cpu.regs)
		ch.cycle(&cpu)
		time.sleep(1 * time.Second)
	}
    */
}
