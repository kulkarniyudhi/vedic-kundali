#!/bin/bash
# Build script for Linux
gcc -O3 astroengine.c astronomy.c -lm -o ../astroengine
echo "Compiled ../astroengine successfully."

