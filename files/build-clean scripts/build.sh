#!/bin/bash

# List of files to remove
files=("myanalyzer.tab.c" "myanalyzer.tab.h" "lex.yy.c" "mycomp" "myanalyzer.output")

# Loop through the files and remove each one
for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "Removing $file..."
        rm "$file"
        if [ $? -ne 0 ]; then
            echo "Failed to remove $file"
            exit 1
        fi
    else
        echo "$file does not exist."
    fi
done

echo "Cleanup completed successfully."

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
