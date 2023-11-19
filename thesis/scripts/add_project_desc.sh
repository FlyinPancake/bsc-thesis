#!/bin/bash

# This script adds the project description to the project

# Function to display script usage
show_usage() {
    echo "Usage: $0 input_pdf append_pdf output_pdf"
    echo "  input_pdf    : The input PDF file from which to remove the first page."
    echo "  append_pdf   : The PDF file to append to the modified input PDF."
    echo "  output_pdf   : The output PDF file after removing the first page and appending another PDF."
}

# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
    show_usage
    exit 1
fi

# Check for the help flag
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    show_usage
    exit 0
fi

# Set the temporary file in the /tmp directory
temp_file="/tmp/merged_pdf_temp_$(date +%s).pdf"

# Extract the first page of the input PDF
pdftk "$1" cat 2-end output "$temp_file"

# Concatenate the extracted PDF with the append PDF
pdftk "$2" "$temp_file" cat output "$3"

# Remove the temporary file
rm "$temp_file"

echo "Done. Output saved to $3"