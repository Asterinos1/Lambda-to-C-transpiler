#!/bin/bash

echo "Starting the build script..."

# Run Flex
flex mylexer.l
if [ $? -ne 0 ]; then
    echo "Flex failed"
    exit 1
fi

# Run Bison
bison -d -v -r all myanalyzer.y
if [ $? -ne 0 ]; then
    echo "Bison failed"
    exit 1
fi

# Compile and link using GCC
gcc -o mycomp lex.yy.c myanalyzer.tab.c cgen.c -lfl
if [ $? -ne 0 ]; then
    echo "GCC failed"
    exit 1
fi

echo "Build successful"
