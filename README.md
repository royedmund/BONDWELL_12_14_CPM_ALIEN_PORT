# Bondwell 12/14 Space Invaders Clone

This project is a port of the classic Kaypro `ALIENS.COM` Space Invaders-style game for the Bondwell 12 and Bondwell 14 computers running CP/M 3.0.

The assembly file documents a reconstruction of the original Kaypro `ALIENS.COM` executable. Much of the original program is retained as byte-exact `DB` data, with identified patches and appended Bondwell sound routines labelled separately; it is not a fully symbolic reconstruction of every original routine.

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

## Run on the Bondwell

Copy [ALIENS.COM](ALIENS.COM) to a CP/M disk and enter:

```text
A>ALIENS
```

Use the game's on-screen controls; the patched menu uses `1` to start. The port targets the Bondwell 12/14 display hardware and MC1408 DAC, rather than a generic CP/M terminal.

## Repository layout and rebuilding

| File | Purpose |
| --- | --- |
| [ALIENS.ASM](ALIENS.ASM) | Documented reconstruction, byte data and Bondwell patches |
| [ALIENS.COM](ALIENS.COM) | Supplied CP/M executable, loaded at `0100H` |
| [ALIENS.HEX](ALIENS.HEX) | Supplied HEX image |

The flat layout is appropriate for these three related files. A pinned assembler and reproducible build procedure are not included. Before replacing the supplied executable, verify the assembler syntax and compare the resulting bytes with the existing `.COM`. No standalone licence file is included; retain the original Kaypro/Yahoo Software provenance and source comments.
