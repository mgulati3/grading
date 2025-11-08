#!/bin/bash

# iOS Submission Grader
# Interactive script to grade student submissions

# Color codes for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default download directory (change this to your Canvas download folder)
DOWNLOAD_DIR="$HOME/Downloads"

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}   iOS Submission Grader${NC}"
echo -e "${BLUE}======================================${NC}"
echo ""

# Check if a custom directory was provided
if [ -n "$1" ]; then
    DOWNLOAD_DIR="$1"
fi

echo -e "Looking for submissions in: ${GREEN}$DOWNLOAD_DIR${NC}"
echo ""

# Find all zip files (compatible with older bash versions)
ZIP_FILES=()
while IFS= read -r -d '' file; do
    ZIP_FILES+=("$file")
done < <(find "$DOWNLOAD_DIR" -maxdepth 1 -name "*.zip" -type f -print0)

if [ ${#ZIP_FILES[@]} -eq 0 ]; then
    echo -e "${RED}No zip files found in $DOWNLOAD_DIR${NC}"
    exit 1
fi

# Display menu
echo -e "${YELLOW}Found ${#ZIP_FILES[@]} submission(s):${NC}"
echo ""

for i in "${!ZIP_FILES[@]}"; do
    filename=$(basename "${ZIP_FILES[$i]}")
    echo -e "  ${GREEN}$((i+1)))${NC} $filename"
done

echo ""
echo -e "  ${GREEN}0)${NC} Exit"
echo ""

# Get user selection
while true; do
    read -p "Select a submission to grade (0-${#ZIP_FILES[@]}): " selection
    
    if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 0 ] && [ "$selection" -le ${#ZIP_FILES[@]} ]; then
        break
    else
        echo -e "${RED}Invalid selection. Please try again.${NC}"
    fi
done

# Exit if user selected 0
if [ "$selection" -eq 0 ]; then
    echo -e "${YELLOW}Exiting...${NC}"
    exit 0
fi

# Get the selected file
SELECTED_FILE="${ZIP_FILES[$((selection-1))]}"
FILENAME=$(basename "$SELECTED_FILE" .zip)

echo ""
echo -e "${BLUE}Processing: ${NC}$FILENAME"
echo ""

# Create temporary extraction directory
EXTRACT_DIR="$DOWNLOAD_DIR/${FILENAME}_extracted"

# Unzip the file
echo -e "${YELLOW}Unzipping...${NC}"
unzip -q "$SELECTED_FILE" -d "$EXTRACT_DIR"

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to unzip file${NC}"
    exit 1
fi

# Find .xcodeproj file (excluding __MACOSX folders)
XCODE_PROJECT=$(find "$EXTRACT_DIR" -name "*.xcodeproj" -type d -not -path "*/__MACOSX/*" | head -n 1)

if [ -z "$XCODE_PROJECT" ]; then
    echo -e "${RED}Error: No .xcodeproj file found${NC}"
    echo -e "${YELLOW}Contents of extracted folder:${NC}"
    find "$EXTRACT_DIR" -maxdepth 3 -type d -not -path "*/__MACOSX/*"
    read -p "Press Enter to clean up and continue..."
    rm -rf "$EXTRACT_DIR"
    rm "$SELECTED_FILE"
    exit 1
fi

# Verify the project has a project.pbxproj file
if [ ! -f "$XCODE_PROJECT/project.pbxproj" ]; then
    echo -e "${RED}Error: Project is missing project.pbxproj file${NC}"
    echo -e "${YELLOW}Looking for other .xcodeproj files...${NC}"
    find "$EXTRACT_DIR" -name "*.xcodeproj" -type d -not -path "*/__MACOSX/*"
    read -p "Press Enter to clean up and continue..."
    rm -rf "$EXTRACT_DIR"
    rm "$SELECTED_FILE"
    exit 1
fi

echo -e "${GREEN}Found project: ${NC}$(basename "$XCODE_PROJECT")"
echo ""

# Run MVVM architecture check
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Running MVVM Architecture Analysis...${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if mvvm-checker.sh exists in the same directory as this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MVVM_CHECKER="$SCRIPT_DIR/mvvm-checker.sh"

if [ -f "$MVVM_CHECKER" ]; then
    bash "$MVVM_CHECKER" "$EXTRACT_DIR"
    echo ""
    read -p "Press Enter to open project in Xcode..."
else
    echo -e "${YELLOW}Note: mvvm-checker.sh not found. Skipping MVVM analysis.${NC}"
    echo -e "${YELLOW}Place mvvm-checker.sh in the same folder as this script to enable.${NC}"
    echo ""
fi

# Open the project in Xcode
echo -e "${YELLOW}Opening in Xcode...${NC}"
open "$XCODE_PROJECT"

echo -e "${BLUE}======================================${NC}"
echo -e "${GREEN}Xcode has been launched!${NC}"
echo -e "${BLUE}======================================${NC}"
echo ""
echo "Grade the submission in Xcode."
echo ""
read -p "Press Enter when you're done grading to clean up..."

# Cleanup
echo ""
echo -e "${YELLOW}Cleaning up...${NC}"
rm -rf "$EXTRACT_DIR"
rm "$SELECTED_FILE"

echo -e "${GREEN}✓ Deleted extracted folder${NC}"
echo -e "${GREEN}✓ Deleted zip file${NC}"
echo ""
echo -e "${BLUE}Done! Ready for next submission.${NC}"
echo ""

# Ask if user wants to grade another
read -p "Grade another submission? (y/n): " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    exec "$0" "$DOWNLOAD_DIR"
fi
