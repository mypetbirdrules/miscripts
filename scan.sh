#!/bin/bash

# Display gaudy logo
echo "  _____                   "
echo " / ___/_________ _____    "
echo " \__ \/ ___/ __ \`/ __ \  "
echo " __/ / /__/ /_/ / / / /   "
echo "/____/\___/\__\,_/_/ /_/  "
echo
echo "--------------------------"
echo
echo

# Prompt user to scan for devices on network
echo -n "Scan for devices (y/n)? "
read DONETWORKSCAN

if [ $DONETWORKSCAN = "y" ]; then
    # List all detected devices
    echo "Scanning network for devices..."
    echo
    scanimage --formatted-device-list "* %d%n"
    echo
fi

# Prompt for device name
echo -n "Device name for scanning: "
read DEVICE

# Prompt scan source
echo
echo "----------------------------"
echo "1. Flatbed"
echo "2. Automatic Document Feeder"
echo "----------------------------"
echo -n "Please select scan source: "
read SOURCE_SELECTION
echo

# Set source from selection
SOURCE=""
OPTS="  "
if [ $SOURCE_SELECTION = "1" ]; then
    SOURCE="Flatbed"
    OPTS="--batch --batch-prompt"
else
    SOURCE="Automatic Document Feeder"
    OPTS="--batch"
fi

# Create temp directory
TMP_DIR="$(mktemp -d tmpXXXXX | tr -d '\n')"
echo "Created tmp dir $TMP_DIR"
echo

# Change dir
cd "$TMP_DIR"

# Scan batch images
echo "Starting batch scan from $SOURCE..."
scanimage --device "$DEVICE" --resolution 300 --mode "Color" $OPTS --source "$SOURCE" -y 279.4 -x 215.9 --format=tiff --progress

# Prompt user for name of output file
echo -n "Enter the name of the output file (without .pdf): "
read OUTPUTFILENAME

# Convert all TIFF images to PDFs
for file in out*.tif; do
    echo "Converting $file to $file.pdf..."
    tiff2pdf "$file" -j -o "$file.pdf"
done

# Merge pdf files
echo "Merging PDF files to final.pdf"
pdftk out*.tif.pdf cat output final.pdf

# Move final.pdf out of tmpdir
mv -v final.pdf "../$OUTPUTFILENAME.pdf"

# Remove temporary files
rm -v out*.tif
rm -v out*.tif.pdf

# Back out of dir
cd ..
rmdir -v "$TMP_DIR"
