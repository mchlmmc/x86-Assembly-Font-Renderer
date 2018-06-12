# Raster font renderer written entirely in Assembly
FASM-Enabled Intel x86 Assembly code, intended for usage in real-mode operating systems.

**This code has only been tested on VirtualBox, not a physical computer. USE AT YOUR OWN DISCRETION!**

## Compiling
I assembled the `font.asm` file with Flat Assembler (https://flatassembler.net/ ) on Windows 10 with no Makefile. The programs that I used were:

* flat assembler 1.71.39
* HxD 1.7.7.0
* VirtualBox 5.2.2

Instead of writing a linker script, for some reason I manually copied the assembled version of font.asm into the first sector of a file I created called font.img with HxD upon each build. Then, I ran it in VirtualBox to see the result. No debugging tools were used.

While this code should work in Protected and Long Mode, I have not tested it under such running conditions yet.

## Output
If you run font.img in VirtualBox you can expect to see very something similar to below:

![Demonstration Screenshot](https://github.com/Mikestylz/x86-Assembly-Font-Renderer/blob/master/demo.png)


**WARNING: This bootloader ends in a busy loop, so your computer fan might go crazy if you leave it running for too long.**

## Making your own font
Run the tool FontGenerator.cs in Visual Studio, Visual Studio Code, MonoDevelop etc to generate a new fontdata.bin from a font.txt file in the same running directory. Then, copy the contents of fontdata.bin to the first and second sectors of font.img. The format for font.txt should be rather intuitive, but if you do not understand it then there is a full outline in the FontGenerator.cs file.

Use the following ASCII Table for reference if you are unfamiliar with the standard:

![ASCII Table](http://www.asciitable.com/index/asciifull.gif)
