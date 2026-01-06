#!/bin/bash
# Make multiple square icon sizes from a source image

set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <input_image> [sizes...]"
    echo ""
    echo "Creates square versions of an image at multiple resolutions."
    echo ""
    echo "Examples:"
    echo "  $0 logo.svg                    # Creates logo_sq.svg"
    echo "  $0 logo.png 512 256 128        # Creates square PNGs at specified sizes"
    echo "  $0 logo.svg 1024 512 256       # Creates square SVGs then PNGs at sizes"
    echo ""
    echo "Default sizes: 1024, 512, 256, 128, 64"
    exit 1
fi

INPUT="$1"
shift

# Default sizes if none specified
if [ $# -eq 0 ]; then
    SIZES=(1024 512 256 128 64)
else
    SIZES=("$@")
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SQUARIZER="$SCRIPT_DIR/squarizer.py"

if [ ! -f "$SQUARIZER" ]; then
    echo "Error: squarizer.py not found at $SQUARIZER"
    exit 1
fi

if [ ! -f "$INPUT" ]; then
    echo "Error: Input file not found: $INPUT"
    exit 1
fi

# Get file info
FILENAME=$(basename "$INPUT")
BASENAME="${FILENAME%.*}"
EXT="${FILENAME##*.}"

echo "Creating square icons from: $INPUT"
echo "Sizes: ${SIZES[*]}"
echo ""

# First create the square version
SQUARE="${BASENAME}_sq.${EXT}"
if [ ! -f "$SQUARE" ] || [ "$INPUT" -nt "$SQUARE" ]; then
    echo "Creating square base: $SQUARE"
    python3 "$SQUARIZER" "$INPUT" -o "$SQUARE"
else
    echo "Square base exists: $SQUARE"
fi

# Create PNG versions at specified sizes
if [ ${#SIZES[@]} -gt 0 ]; then
    echo ""
    echo "Creating PNG versions at specified sizes..."
    
    # Determine source for PNG conversion
    if [[ "$EXT" == "svg" ]] || [[ "$EXT" == "SVG" ]]; then
        # For SVG, we need to convert to PNG using rsvg-convert
        if ! command -v rsvg-convert &> /dev/null; then
            echo "Warning: rsvg-convert not found. Cannot create PNG versions from SVG."
            echo "Install with: brew install librsvg"
        else
            # Use the square SVG as source
            for SIZE in "${SIZES[@]}"; do
                OUTPUT="${BASENAME}_sq_${SIZE}.png"
                echo "Creating ${SIZE}x${SIZE}: $OUTPUT"
                rsvg-convert -w "$SIZE" -h "$SIZE" "$SQUARE" -o "$OUTPUT"
            done
        fi
    elif [[ "$EXT" == "png" ]] || [[ "$EXT" == "PNG" ]] || [[ "$EXT" == "jpg" ]] || [[ "$EXT" == "jpeg" ]]; then
        # For raster images, use squarizer with resolution option
        for SIZE in "${SIZES[@]}"; do
            OUTPUT="${BASENAME}_sq_${SIZE}.png"
            echo "Creating ${SIZE}x${SIZE}: $OUTPUT"
            python3 "$SQUARIZER" "$INPUT" -r "$SIZE" -o "$OUTPUT"
        done
    fi
fi

echo ""
FILES=$(ls -1 ${BASENAME}_sq* 2>/dev/null | wc -l | tr -d ' ')
echo "✓ Done! Total square files: $FILES"
ls -lh ${BASENAME}_sq* 2>/dev/null | head -20

