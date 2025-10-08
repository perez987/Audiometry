#!/bin/bash

# Script to create the swiftui branch with SwiftUI-only storage
# Run this script from the root of the Audiometry repository

set -e  # Exit on error

echo "Creating swiftui branch..."

# Ensure we're in a git repository
if [ ! -d .git ]; then
    echo "Error: Not in a git repository root"
    exit 1
fi

# Fetch latest changes
echo "Fetching latest changes from origin..."
git fetch origin

# Ensure we're on main branch
echo "Checking out main branch..."
git checkout main
git pull origin main

# Create swiftui branch
echo "Creating swiftui branch from main..."
git checkout -b swiftui

# Apply the patch
echo "Applying changes..."
PATCH_FILE="Create-swiftui-branch-with-SwiftUI-only-storage.patch"

if [ ! -f "$PATCH_FILE" ]; then
    echo "Error: Patch file $PATCH_FILE not found"
    echo "Please ensure the patch file is in the current directory"
    exit 1
fi

git am "$PATCH_FILE"

echo ""
echo "✅ SwiftUI branch created successfully!"
echo ""
echo "To push the branch to origin, run:"
echo "  git push origin swiftui"
echo ""
echo "To verify the changes, run:"
echo "  git diff main swiftui --stat"
