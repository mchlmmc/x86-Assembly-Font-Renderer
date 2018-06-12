// Copyright © 2018 Michael Mamic
// ----------------------------------------------------
// Permission is hereby granted, free of charge,
// to any person obtaining a copy of this software
// and associated documentation files (the “Software”),
// to deal in the Software without restriction,
// including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software,
// and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
// TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
// ----------------------------------------------------- 
// The anatomy of the font binary is quite simple.
// Each character is 7 lines tall, each line being 5 pixels wide.
// The five pixels are represented by the 5 most significant bits in each byte.
// There is a character for each of the first 128 ASCII characters.
// 7 x 128 = 896, so there are 896 bytes in a font binary. 
// The first 32 characters are empty.
// -----------------------------------------------------
// The anatomy of the font.txt file is also quite simple.
// Lines not starting with . or # are ignored.
// Each . is considered a 0 bit, and each # is a 1 bit.
// Each line is one line of a character.

using System;
using System.IO;

class FontGenerator
{
    static void Main(string[] args)
    {
        Console.WriteLine("# Font Creator #");
        Console.WriteLine("Press any key to generate the font.");
        Console.ReadKey(true);
        // This program will crash if it cannot locate font.txt
        string[] lns = File.ReadAllLines("font.txt");
        byte[] fl = new byte[1024];
        int e = 223;
        for (int i = 0, j = 0; i < lns.Length; i++)
        {
            // Skip lines that are not parts of characters.
            if (!lns[i].StartsWith(".") && !lns[i].StartsWith("#")) continue;
            j++;
            byte b = 0;
            if (lns[i][0] == '#')
                b += 128;
            if (lns[i][1] == '#')
                b += 64;
            if (lns[i][2] == '#')
                b += 32;
            if (lns[i][3] == '#')
                b += 16;
            if (lns[i][4] == '#')
                b += 8;
            fl[j + e] = b;

        }
        // Output font to a fontdata.bin binary font file.
        File.WriteAllBytes("fontdata.bin", fl);
    }
}
