# cal-cpm

A Unix-like cal(endar) utility for CP/M

Version 0.1c, May 2023

## What is this?

This is my first attempt in nearly 40 years to write something reasonably
substantial, entirely in Z80 assembly language. It's a (somewhat cut down)
implementation of the Unix `cal` utility, for CP/M. The usage is
straightforward:

    A> cal {month} {year}

For example

    A> cal 2 2022
    February 2022
    Mo Tu We Th Fr Sa Su
        1  2  3  4  5  6 
     7  8  9 10 11 12 13 
    14 15 16 17 18 19 20 
    21 22 23 24 25 26 27 
    28 

I wrote a C version of this utility for the Manx Aztec C compiler, 
which results in an 11kB `.com` file.  This assembly-language version is 
about 2kB. 

CP/M does not have any standard system call to read a real-time clock, even if
one is fitted. In fact, most CP/M machines never had one. The ROMWBW firmware does
have a way to read an RTC so, if this program is run on a CP/M machine with 
this firmware, the current date will be used if none is given on the command
line. Of course, this date can be overridden on the command line.

## Building

I wrote this utility to be built on CP/M using the Microsoft
Macro80 assembler and Link80 linker. These are available from here:

http://www.retroarchive.org/cpm/lang/m80.com
http://www.retroarchive.org/cpm/lang/l80.com

Assemble all the `.asm` files to produce `.rel` files, then feed all
the `.rel` files into the linker. See the Makefile (for Linux) for
the syntax for these commands. There is no `make` for CP/M, so far as I
know, so building is a bit of a tedious process.

## Limitations 

The most obvious limitation is that CP/M systems typically don't have a 
real-time clock, so the utility can't display the calendar for the
current month if it is invoked without command-line arguments. It will use 
the RTC date on a z80 machine with ROMWBW firmware. Sometimes the RTC hardware
will provide broken results, and there isn't much that can be done about this. 

Unlike the Linux version, this `cal` only supports the Gregorian calendar, and
can only display a single month.

## Technical notes

Although `cal` is a simple utility by modern standards, it still has
some technical complexity. It requires

- Conversion of integers to strings, and vice versa
- Integer multiplication and division in 16 bits
- A rudimentary command-line parser
- Date calculation routines

In case I should start feeling pleased with myself for fitting this all
into 2k, I remind myself that the entire _assembler_ 
is only 20k. 
 
## Revisions

0.1e Aug 2023

- Fixed up the entry point
- Centred display of month and year

0.1d July 2023

- Fixed some bugs in command-line parsing
- Tidied up linker invocation

0.1c May 2023

- Added support for ROMWBW real-time clock

0.1b April 2023

- Fixed some bugs

0.1a February 2022

- First release


