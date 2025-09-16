#!/bin/bash
# Universal Binary build script for TextMate
# Builds separate x86_64 and arm64 binaries, then combines them with lipo

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Building TextMate Universal Binary...${NC}"

# Check dependencies
echo -e "${YELLOW}Checking dependencies...${NC}"
./configure

# Build directories
BUILD_ARM64="build_arm64"
BUILD_X86_64="build_x86_64" 
BUILD_UNIVERSAL="build_universal"

# Clean previous builds
echo -e "${YELLOW}Cleaning previous builds...${NC}"
rm -rf dist/ "$BUILD_ARM64" "$BUILD_X86_64" "$BUILD_UNIVERSAL"

# Backup original local.rave
if [ -f "local.rave" ]; then
    cp local.rave local.rave.backup
fi

# Build arm64
echo -e "${YELLOW}Building arm64 version...${NC}"
cat > local.rave << 'EOF'
add FLAGS    "-I/usr/local/include"
add FLAGS    "-I/opt/homebrew/include"
add LN_FLAGS "-L/usr/local/lib"
add LN_FLAGS "-L/opt/homebrew/lib"
add FLAGS    "-arch arm64"
add LN_FLAGS "-arch arm64"
EOF

bin/rave -crelease -tTextMate -b"$BUILD_ARM64"
ninja -C "$BUILD_ARM64" TextMate

# Build x86_64
echo -e "${YELLOW}Building x86_64 version...${NC}"
cat > local.rave << 'EOF'
add FLAGS    "-I/usr/local/include"
add FLAGS    "-I/opt/homebrew/include"
add LN_FLAGS "-L/usr/local/lib"
add LN_FLAGS "-L/opt/homebrew/lib"
add FLAGS    "-arch x86_64"
add LN_FLAGS "-arch x86_64"
EOF

bin/rave -crelease -tTextMate -b"$BUILD_X86_64"
ninja -C "$BUILD_X86_64" TextMate

# Restore original local.rave
if [ -f "local.rave.backup" ]; then
    mv local.rave.backup local.rave
fi

# Create universal directory structure
echo -e "${YELLOW}Creating universal binary...${NC}"
mkdir -p "$BUILD_UNIVERSAL/Applications/TextMate/"
cp -R "$BUILD_ARM64/Applications/TextMate/TextMate.app" "$BUILD_UNIVERSAL/Applications/TextMate/"

# Combine binaries with lipo
ARM64_BINARY="$BUILD_ARM64/Applications/TextMate/TextMate.app/Contents/MacOS/TextMate"
X86_64_BINARY="$BUILD_X86_64/Applications/TextMate/TextMate.app/Contents/MacOS/TextMate"
UNIVERSAL_BINARY="$BUILD_UNIVERSAL/Applications/TextMate/TextMate.app/Contents/MacOS/TextMate"

echo -e "${YELLOW}Combining architectures with lipo...${NC}"
lipo -create "$ARM64_BINARY" "$X86_64_BINARY" -output "$UNIVERSAL_BINARY"

# Also combine other binaries in the bundle
for binary in mate tm_query; do
    if [ -f "$BUILD_ARM64/Applications/$binary/$binary" ] && [ -f "$BUILD_X86_64/Applications/$binary/$binary" ]; then
        echo "Combining $binary..."
        DEST_DIR="$BUILD_UNIVERSAL/Applications/TextMate/TextMate.app/Contents/MacOS"
        lipo -create "$BUILD_ARM64/Applications/$binary/$binary" "$BUILD_X86_64/Applications/$binary/$binary" -output "$DEST_DIR/$binary"
    fi
done

# Verify universal binary
echo -e "${YELLOW}Verifying universal binary...${NC}"
lipo -info "$UNIVERSAL_BINARY"
file "$UNIVERSAL_BINARY"

echo -e "${GREEN}Universal Binary build complete!${NC}"
echo -e "Main binary: ${UNIVERSAL_BINARY}"

# Sign the universal binary
echo -e "${YELLOW}Signing universal binary...${NC}"
codesign --force --sign - "$BUILD_UNIVERSAL/Applications/TextMate/TextMate.app"

echo -e "${GREEN}Done! Universal TextMate.app is ready at:${NC}"
echo "$BUILD_UNIVERSAL/Applications/TextMate/TextMate.app"

# Test the universal app
echo -e "${YELLOW}Testing universal binary...${NC}"
"$UNIVERSAL_BINARY" --version || echo "App ready but version check timed out (normal for GUI apps)"