# Bondwell 12/14 Space Invaders Clone

This project is a port of the classic Kaypro `ALIENS.COM` Space Invaders-style game for the Bondwell 12 and Bondwell 14 computers running CP/M 3.0.

The new assembly-language source file was reconstructed from a disassembly of the original Kaypro `ALIENS.COM` executable. The code has been documented and modified to support the Bondwell 12/14 hardware.

The Bondwell version uses the computer’s character set to draw the invaders, player turret, barriers, projectiles and explosion effects. Sound effects have also been added using the Bondwell’s MC1408 digital-to-analogue converter.

https://youtu.be/S6bz4kci5cQ

## Source Reference

This port is derived from:

* The original Kaypro `ALIENS.COM` Space Invaders clone.
* A disassembly of the original Kaypro executable.
* The original Kaypro hardware-specific routines contained in the disassembled program.

The reconstructed assembly source retains comments identifying code and data derived from the original Kaypro version. Bondwell-specific changes, including display characters, sound routines and hardware port addresses, are documented separately within the source code.

## Bondwell-Specific Changes

* Adapted the program for the Bondwell 12/14 under CP/M 3.0.
* Replaced Kaypro-specific display characters with suitable Bondwell character-ROM symbols.
* Added sound effects for firing, explosions and other game events.
* Added support for the Bondwell MC1408 DAC at I/O address range `50H–5FH`.
* Produced a documented assembly source file.
* Produced CP/M executable and Intel HEX versions of the program.
