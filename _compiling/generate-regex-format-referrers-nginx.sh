#!/bin/bash

#### Ensure are on dev branch
git checkout dev
####

# Input and output file paths
input_file="_generator_lists/bad-referrers.list"
output_file="_compiling/referrers-regex-format-nginx.txt"

# Create or clear the output file
> "$output_file"

# Read the input file, sort it, and process each line
sort "$input_file" | while IFS= read -r line
do
    # Replace dots with escaped dots for regex
    escaped_line=${line//./\\.}
    # Format the line and append to the output file
    echo "\"~*(?:\\b)$escaped_line(?:\\b)\" 1;" >> "$output_file"
done

echo "Converted referrers have been saved to $output_file"
