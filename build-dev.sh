#!/bin/bash
# Development build script for TextMate
# Fast single-architecture build for development and debugging

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Building TextMate for Development...${NC}"

# Check dependencies
echo -e "${YELLOW}Checking dependencies...${NC}"
./configure

# Build for development (debug config)
echo -e "${YELLOW}Building debug version...${NC}"
bin/rave -cdebug -tTextMate

# Build the application
ninja TextMate

echo -e "${GREEN}Development build complete!${NC}"
echo -e "Binary location: dist/debug/Applications/TextMate/TextMate.app"

# Check binary info
BINARY="dist/debug/Applications/TextMate/TextMate.app/Contents/MacOS/TextMate"
if [ -f "$BINARY" ]; then
    echo -e "${YELLOW}Binary info:${NC}"
    file "$BINARY"
    lipo -info "$BINARY" 2>/dev/null || echo "Single architecture binary"
    
    echo -e "${YELLOW}Code signing info:${NC}"
    codesign -dv "$BINARY" 2>&1 | head -5
fi

# Option to run the app
echo -e "${YELLOW}Run TextMate? (y/n):${NC}"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    open "dist/debug/Applications/TextMate/TextMate.app"
fi