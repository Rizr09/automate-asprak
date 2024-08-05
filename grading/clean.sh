#!/bin/bash

parent_directory=$(pwd)

if [ ! -d "$parent_directory" ]; then
    echo "Error: Directory $parent_directory does not exist." >&2
    exit 1
fi

cd "$parent_directory" || exit

for dir in */; do
    if [ -d "$dir" ]; then
        cd "$dir" || continue
        
        if [ -f "Makefile" ] || [ -f "makefile" ]; then
            make clean >/dev/null 2>&1
        fi
        
        cd ..
    fi
done

echo "Cleanup process completed."