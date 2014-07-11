Arduino Projects
================

A collection of previous work with LED cubes and matrices from 2009-2010. Code adapted from my high-school team project of building and programming a 4x4x4 LED cube.

Further Documentation:

* [LED Cube construction, schematics, and programming](doc/LedCube.md)

Software
========
Software has been developed for Arduino IDE release 0017 and tested on an Adruino Duemilanove (ATMega328).

Libraries
---------
These library folders must be placed in the Arduino IDE folder under Hardware/Libraries (IDE restart required). If they show up in the Sketch:Include Library menu, they have been installed correctly and code referencing them should compile. Other steps may be required if a different build process (e.g. avr-gcc, avrdude) is used. I originally developed these in such a setup created from the official Arduino in Eclipse documentation [http://playground.arduino.cc/Code/Eclipse].

Rewritten:
 * LedControl was taken from http://playground.arduino.cc/Main/LedControl (The version included here is an earlier release as compatibility has not yet been tested)
 * LedCube extends LedControl and maps 3D positions in our specific cube model to the two-dimensional matrix, as well as providing some extra functionality.
 * LedDisplay extends LedControl and provides an interface for controlling 16x16 matrix built from four 8x8 matrices with daisy-chained controllers.

Legacy: This is not used in most revised example sketches anymore.
 * max7221 was my original library for controlling a matrix display which was written from near-scratch for the school project.
 * cube is similar to LedCube described above, but builds on this max7221 library instead of using third-party code.
 * effects implements several animations for the cube and was used in some of the game sketches.



Sketches
--------
These are arduino sketches (.pde files instead of full .c programs). Full C/C++ source code can be generated through the Arduino IDE's compile process.

Hardware
========
 * MAX7221/7219 LED display driver
 * Custom LED Cube design and built by Robin
 * Simple 16x16 LED matrix made from four identical sections, wired in the usual way (based on MAX7221 data sheet etc.)
