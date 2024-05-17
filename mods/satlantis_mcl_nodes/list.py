import os

# List all files in the current directory
files = os.listdir('./textures/')

# Filter files to find those that end with '.png'
png_files = [file for file in files if file.endswith('.png')]

# Open a text file to write
with open('filenames.txt', 'w') as f:
    # Write each PNG file name followed by a newline
    for png_file in png_files:
        f.write(png_file + '\n')
