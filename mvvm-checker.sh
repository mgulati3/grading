#!/bin/bash

# MVVM Architecture Checker for iOS Projects
# Analyzes Swift project structure and code for MVVM compliance

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Counters
SCORE=0
MAX_SCORE=0
WARNINGS=()
PASSES=()

# Function to add a check result
add_pass() {
    PASSES+=("$1")
    SCORE=$((SCORE + $2))
    MAX_SCORE=$((MAX_SCORE + $2))
}

add_warning() {
    WARNINGS+=("$1")
    MAX_SCORE=$((MAX_SCORE + $2))
}

add_info() {
    echo -e "${CYAN}ℹ $1${NC}"
}

# Check if directory provided
if [ -z "$1" ]; then
    echo -e "${RED}Usage: $0 <path-to-extracted-project>${NC}"
    echo "Example: $0 /Users/username/Desktop/Grading/StudentProject_extracted"
    exit 1
fi

PROJECT_DIR="$1"

# Check if directory exists
if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${RED}Error: Directory not found: $PROJECT_DIR${NC}"
    exit 1
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   MVVM Architecture Analysis${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "Analyzing: ${CYAN}$PROJECT_DIR${NC}"
echo ""

# Find all Swift files (excluding __MACOSX and build folders)
SWIFT_FILES=$(find "$PROJECT_DIR" -name "*.swift" -not -path "*/__MACOSX/*" -not -path "*/build/*" -not -path "*/DerivedData/*" -type f)

if [ -z "$SWIFT_FILES" ]; then
    echo -e "${RED}Error: No Swift files found${NC}"
    exit 1
fi

TOTAL_SWIFT_FILES=$(echo "$SWIFT_FILES" | wc -l | tr -d ' ')
echo -e "${CYAN}Found $TOTAL_SWIFT_FILES Swift files${NC}"
echo ""

# ============================================
# 1. Check for ViewModel files
# ============================================
echo -e "${YELLOW}[1/8] Checking for ViewModel files...${NC}"
VIEWMODEL_FILES=$(echo "$SWIFT_FILES" | grep -i "viewmodel\.swift" || true)
VIEWMODEL_COUNT=$(echo "$VIEWMODEL_FILES" | grep -c "." || echo "0")

if [ "$VIEWMODEL_COUNT" -gt 0 ]; then
    add_pass "Found $VIEWMODEL_COUNT ViewModel file(s)" 2
    echo "$VIEWMODEL_FILES" | while read -r file; do
        [ -n "$file" ] && echo -e "  ${GREEN}✓${NC} $(basename "$file")"
    done
else
    add_warning "No ViewModel files found (expected *ViewModel.swift)" 2
fi
echo ""

# ============================================
# 2. Check for Model files
# ============================================
echo -e "${YELLOW}[2/8] Checking for Model files...${NC}"
MODEL_FILES=$(echo "$SWIFT_FILES" | grep -i "model\.swift" || true)
MODEL_COUNT=$(echo "$MODEL_FILES" | grep -c "." || echo "0")

if [ "$MODEL_COUNT" -gt 0 ]; then
    add_pass "Found $MODEL_COUNT Model file(s)" 2
    echo "$MODEL_FILES" | while read -r file; do
        [ -n "$file" ] && echo -e "  ${GREEN}✓${NC} $(basename "$file")"
    done
else
    add_warning "No Model files found (expected *Model.swift)" 2
fi
echo ""

# ============================================
# 3. Check for folder structure
# ============================================
echo -e "${YELLOW}[3/8] Checking folder structure...${NC}"
HAS_MODEL_FOLDER=$(find "$PROJECT_DIR" -type d -iname "model*" -not -path "*/__MACOSX/*" | head -1)
HAS_VIEW_FOLDER=$(find "$PROJECT_DIR" -type d -iname "view*" -not -path "*/__MACOSX/*" | head -1)
HAS_VIEWMODEL_FOLDER=$(find "$PROJECT_DIR" -type d -iname "viewmodel*" -not -path "*/__MACOSX/*" | head -1)

FOLDER_SCORE=0
if [ -n "$HAS_MODEL_FOLDER" ]; then
    echo -e "  ${GREEN}✓${NC} Model folder exists"
    FOLDER_SCORE=$((FOLDER_SCORE + 1))
fi
if [ -n "$HAS_VIEW_FOLDER" ]; then
    echo -e "  ${GREEN}✓${NC} View folder exists"
    FOLDER_SCORE=$((FOLDER_SCORE + 1))
fi
if [ -n "$HAS_VIEWMODEL_FOLDER" ]; then
    echo -e "  ${GREEN}✓${NC} ViewModel folder exists"
    FOLDER_SCORE=$((FOLDER_SCORE + 1))
fi

if [ "$FOLDER_SCORE" -ge 2 ]; then
    add_pass "Good folder organization ($FOLDER_SCORE/3 MVVM folders found)" 2
else
    add_warning "Weak folder organization (only $FOLDER_SCORE/3 MVVM folders found)" 2
fi
echo ""

# ============================================
# 4. Check for ObservableObject usage
# ============================================
echo -e "${YELLOW}[4/8] Checking for ObservableObject conformance...${NC}"
OBSERVABLE_COUNT=0
while IFS= read -r file; do
    [ -z "$file" ] && continue
    if grep -q "ObservableObject" "$file" 2>/dev/null; then
        OBSERVABLE_COUNT=$((OBSERVABLE_COUNT + 1))
        echo -e "  ${GREEN}✓${NC} $(basename "$file")"
    fi
done <<< "$SWIFT_FILES"

if [ "$OBSERVABLE_COUNT" -gt 0 ]; then
    add_pass "Found $OBSERVABLE_COUNT file(s) with ObservableObject" 2
else
    add_warning "No ObservableObject conformance found (required for ViewModels)" 2
fi
echo ""

# ============================================
# 5. Check for @Published properties
# ============================================
echo -e "${YELLOW}[5/8] Checking for @Published properties...${NC}"
PUBLISHED_COUNT=0
while IFS= read -r file; do
    [ -z "$file" ] && continue
    if grep -q "@Published" "$file" 2>/dev/null; then
        PUBLISHED_COUNT=$((PUBLISHED_COUNT + 1))
        echo -e "  ${GREEN}✓${NC} $(basename "$file")"
    fi
done <<< "$SWIFT_FILES"

if [ "$PUBLISHED_COUNT" -gt 0 ]; then
    add_pass "Found @Published properties in $PUBLISHED_COUNT file(s)" 2
else
    add_warning "No @Published properties found (needed for reactive ViewModels)" 2
fi
echo ""

# ============================================
# 6. Check for @StateObject or @ObservedObject
# ============================================
echo -e "${YELLOW}[6/8] Checking for proper ViewModel binding...${NC}"
BINDING_COUNT=0
while IFS= read -r file; do
    [ -z "$file" ] && continue
    if grep -qE "@StateObject|@ObservedObject" "$file" 2>/dev/null; then
        BINDING_COUNT=$((BINDING_COUNT + 1))
        echo -e "  ${GREEN}✓${NC} $(basename "$file")"
    fi
done <<< "$SWIFT_FILES"

if [ "$BINDING_COUNT" -gt 0 ]; then
    add_pass "Found proper ViewModel binding in $BINDING_COUNT View(s)" 2
else
    add_warning "No @StateObject/@ObservedObject found (Views should observe ViewModels)" 2
fi
echo ""

# ============================================
# 7. Check for architecture violations
# ============================================
echo -e "${YELLOW}[7/8] Checking for architecture violations...${NC}"
VIOLATIONS=0

# Check for URLSession in View files
while IFS= read -r file; do
    [ -z "$file" ] && continue
    if echo "$file" | grep -qi "view\.swift"; then
        if grep -qE "URLSession|\.fetch|\.post|\.get" "$file" 2>/dev/null; then
            echo -e "  ${RED}✗${NC} Network calls in View: $(basename "$file")"
            VIOLATIONS=$((VIOLATIONS + 1))
        fi
    fi
done <<< "$SWIFT_FILES"

# Check for business logic in Views (heuristic: functions with >10 lines in View files)
VIEW_FILES=$(echo "$SWIFT_FILES" | grep -i "view\.swift" || true)
while IFS= read -r file; do
    [ -z "$file" ] && continue
    if [ -f "$file" ]; then
        # Simple heuristic: if View file is very large, might contain business logic
        LINE_COUNT=$(wc -l < "$file" | tr -d ' ')
        if [ "$LINE_COUNT" -gt 200 ]; then
            echo -e "  ${YELLOW}⚠${NC} Large View file (${LINE_COUNT} lines): $(basename "$file")"
            VIOLATIONS=$((VIOLATIONS + 1))
        fi
    fi
done <<< "$VIEW_FILES"

if [ "$VIOLATIONS" -eq 0 ]; then
    add_pass "No obvious architecture violations detected" 2
else
    add_warning "Found $VIOLATIONS potential architecture violation(s)" 2
fi
echo ""

# ============================================
# 8. Check Model purity
# ============================================
echo -e "${YELLOW}[8/8] Checking Model file purity...${NC}"
MODEL_VIOLATIONS=0

while IFS= read -r file; do
    [ -z "$file" ] && continue
    if echo "$file" | grep -qi "model\.swift"; then
        # Models should not import SwiftUI or UIKit
        if grep -qE "import SwiftUI|import UIKit" "$file" 2>/dev/null; then
            echo -e "  ${RED}✗${NC} Model imports UI framework: $(basename "$file")"
            MODEL_VIOLATIONS=$((MODEL_VIOLATIONS + 1))
        fi
        # Models should not have @Published
        if grep -q "@Published" "$file" 2>/dev/null; then
            echo -e "  ${RED}✗${NC} Model has @Published (should be in ViewModel): $(basename "$file")"
            MODEL_VIOLATIONS=$((MODEL_VIOLATIONS + 1))
        fi
    fi
done <<< "$SWIFT_FILES"

if [ "$MODEL_VIOLATIONS" -eq 0 ]; then
    add_pass "Models are pure data structures" 2
else
    add_warning "Found $MODEL_VIOLATIONS Model purity violation(s)" 2
fi
echo ""

# ============================================
# Final Report
# ============================================
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   Analysis Complete${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Display passes
if [ ${#PASSES[@]} -gt 0 ]; then
    echo -e "${GREEN}✓ Passes:${NC}"
    for pass in "${PASSES[@]}"; do
        echo -e "  ${GREEN}•${NC} $pass"
    done
    echo ""
fi

# Display warnings
if [ ${#WARNINGS[@]} -gt 0 ]; then
    echo -e "${RED}✗ Issues:${NC}"
    for warning in "${WARNINGS[@]}"; do
        echo -e "  ${RED}•${NC} $warning"
    done
    echo ""
fi

# Calculate percentage
if [ "$MAX_SCORE" -gt 0 ]; then
    PERCENTAGE=$((SCORE * 100 / MAX_SCORE))
else
    PERCENTAGE=0
fi

# Display score
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}MVVM Compliance Score: $SCORE/$MAX_SCORE ($PERCENTAGE%)${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# Grade interpretation
if [ "$PERCENTAGE" -ge 90 ]; then
    echo -e "${GREEN}Grade: Excellent MVVM implementation ✓${NC}"
elif [ "$PERCENTAGE" -ge 75 ]; then
    echo -e "${YELLOW}Grade: Good MVVM implementation with minor issues${NC}"
elif [ "$PERCENTAGE" -ge 50 ]; then
    echo -e "${YELLOW}Grade: Partial MVVM implementation${NC}"
else
    echo -e "${RED}Grade: Poor or no MVVM implementation${NC}"
fi
echo ""

# Save report to file
REPORT_FILE="$PROJECT_DIR/MVVM_Analysis_Report.txt"
{
    echo "MVVM Architecture Analysis Report"
    echo "=================================="
    echo "Date: $(date)"
    echo "Project: $PROJECT_DIR"
    echo ""
    echo "Score: $SCORE/$MAX_SCORE ($PERCENTAGE%)"
    echo ""
    echo "Passes:"
    for pass in "${PASSES[@]}"; do
        echo "  ✓ $pass"
    done
    echo ""
    echo "Issues:"
    for warning in "${WARNINGS[@]}"; do
        echo "  ✗ $warning"
    done
} > "$REPORT_FILE"

echo -e "${GREEN}Report saved to: $REPORT_FILE${NC}"
echo ""
