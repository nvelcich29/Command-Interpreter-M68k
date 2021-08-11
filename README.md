# Command-Interpreter-M68k

## Overview
The goal of the project was to build a monitor program to run on a "SANPER1" educational computer board built around a Motorola 68k microprocessor.  This program can be simulated using [EASY68k](http://www.easy68k.com/) simulator software.  The monitor recognizes which command is entered and then branches to subroutine for executing this command.  If there is no match, it displays an error message. 
![Command Interpreter Flowchart](https://user-images.githubusercontent.com/46805337/129077550-f0ad7cb2-144d-4640-b21a-b87b14be6263.png)

This monitor program is able to perform basic debugging functions:
  * Memory Display
  * Memory Sort
  * Memory Change
  * Block Fill
  * Block Search
  * Block Move

Along with the debugging functionalities, this program also handles exceptions.  

## Simulation using EASY68k
To simulate using EASY68k, first open the FINALPROJECT.X68 source code in EASY68k.  Then press F9 or click Project->Compile Source Code.  Once the source code is compiled click execute in the pop up window.  This will open the compiled code in the simulator.  Pressing F9 again or clicking Run->Run will start the simulation and present the Sim68k I/O window in the foreground.  In this window you will be able to interact with the monitor program as intended.  

## Usage
The monitor program offers 14 built in commands:
  * Help - Opens the user manual program that lists the commands and their functionality.  ```HELP```
  * Addition - Adds two hexidecimal numbers together. ```ADD <num1> <num2>```
  * And - Ands two hexidecimal numbers together. ```AND <num1> <num2>```
  * Recall Command - Perform the last correct command. ```<```
  * Memory Display - Displays memory in address range or can display 16 bytes from a single address: ```MDSP <addr1> <addr2>``` or ```MDSP <addr1>```
  * Memory Modify - Allows modification of memory one byte at a time.  It will display the current memory location then waits for user to input a 2 digit hexidecimal number.  Typing "." will end the modifications.  ```MM <addr>```
  * Memory Set - Sets memory in given location.  Input can be in hexidecimal or ASCII format.  Hexidecimal input must start with a "$" and can be written as: byte, word, or long.  ```MS <addr> <input to be stored>```
  * Block Fill - Fills a block of memory from one address through the ending address with a hexidecimal number in word format.  Input can not be larger than a word.  ```BF <addr1> <addr2> <input>```
  * Block Move - Copies a block of memory between a given range to another location.  ```BMOV <addr1> <addr2> <addr to move to>```
  * Block Test - A destructive test of a block of memory between addr1 and addr2.  ```BT <addr1> <addr2>```
  * Block Search - Search for a specific pattern (Input as a string of ASCII charecters) within a memory range.  If it is found the memory location is printed or notify if the search failed. ```BSCH <addr1> <addr2> <string>```
  * Go - Runs a program starting from memory location addr1.  ```GO <addr1>```
  * Display - Displays formated registers including: PC, SR, US, SS, and D and A Registers.  ```DF```
  * Exit - Exits the monitor program.  ```EXIT```
