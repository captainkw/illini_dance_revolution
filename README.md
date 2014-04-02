illini_dance_revolution
=======================

When I don't code in Python, JS, PHP, or C/C++, I code in Assembly

## History

A Dance Dance Revolution (DDR) is a reverse-engineering game project I did back in school, written in x86 Assembly (manually coded DMA/IRQ drivers), probably not as complex as my master's project or my senior design project, but definitely the most flashy.  =P

The text scrolling down on the left side is the actual code of the game scrolling down in an alpha-blended fashion.

It integrates a keyboard driver, file IO, writing graphics to the screen, as well as playing music by using DMA to write contents of a WAV file to the sound card, synchronizing using IRQs.  This is some of the most low level machine code I had written, and have to say it was quite fun.

To see this game in action, you can watch it on YouTube here:
https://www.youtube.com/watch?v=qjNcTIRGyQ0
