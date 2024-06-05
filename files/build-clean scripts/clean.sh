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
