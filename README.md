# Command-Interpreter-M68k

## Overview
The goal of the project was to build a monitor program to run on a "SANPER1" educational computer board built around a Motorola 68k microprocessor.  This program can be simulated using [EASY68k](http://www.easy68k.com/) simulator software.  The monitor recognizes which command is entered and then branches to subroutine for executing this command. And when there is no match, it displays an error message.  This monitor program is able to perform basic debugging functions:
* Memory Display
* Memory Sort
* Memory Change
* Block Fill
* Block Search
* Block Move

Along with the debugging functionalities, this program also handles exceptions.  
