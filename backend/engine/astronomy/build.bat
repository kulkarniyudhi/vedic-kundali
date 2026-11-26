@echo off
rem Build script for Windows using MinGW / GCC
gcc -O3 astroengine.c astronomy.c -lm -o ..\astroengine.exe
echo Compiled ..\astroengine.exe successfully.
pause

