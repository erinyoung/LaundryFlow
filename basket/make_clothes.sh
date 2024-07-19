#!/bin/bash

# Check if clothing.txt exists
if [[ ! -f clothing.txt ]]; then
  echo "clothing.txt not found!"
  exit 1
fi

# Read the clothing.txt line by line
while IFS= read -r line
do
  # Check if the line starts with '#'
  if [[ $line == \#* ]]; then
    # Remove the '#' and store the filename
    filename="${line:1}"
  else
    # Write the content to the filename
    echo "$line" > "$filename"
  fi
done < clothing.txt

echo "Files created successfully."
