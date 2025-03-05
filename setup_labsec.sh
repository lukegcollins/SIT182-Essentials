#!/bin/bash

# Ensure script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root (use sudo)"
  exit 1
fi

# Define Google Drive file ID and output file name
FILE_ID="18_o7qIZ0H7Y93-adOLxlh9IMi_uBATxN"
FILE_NAME="labsec2.zip"

# Install required dependencies
echo "Installing required tools..."
sudo apt update && sudo apt install -y curl unzip docker-ce docker-ce-cli containerd.io

# Download LabSec from Google Drive
echo "Downloading LabSec files..."
curl -L -o "$FILE_NAME" "https://drive.google.com/uc?export=download&id=${FILE_ID}"

# Extract the zip file
echo "Extracting LabSec files..."
unzip -o "$FILE_NAME"

# Find the extracted directory
LAB_DIR=$(find . -type d -name "LAB2_access_control" | head -n 1)
if [ -z "$LAB_DIR" ]; then
  echo "Error: Could not find LAB2_access_control directory."
  exit 1
fi

# Navigate into the lab folder
cd "$LAB_DIR" || exit

# Build the Docker image
echo "Building the LabSec Docker image..."
docker build -t labsec2 .

# Check if the image was built successfully
if ! docker images | grep -q labsec2; then
  echo "Error: Docker image build failed!"
  exit 1
fi

echo "Running the LabSec container..."
docker run -it labsec2 bash

echo "LabSec setup complete!"
