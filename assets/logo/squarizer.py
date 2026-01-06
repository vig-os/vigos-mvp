#!/usr/bin/env python3
"""
Squarizer - Make images square by padding the smaller dimension symmetrically.

Supports SVG and PNG formats. For SVG files, it adjusts the viewBox and wraps 
content in a transformed group. For PNG files, it adds transparent pixels.
"""

import argparse
import os
import sys
from pathlib import Path
import xml.etree.ElementTree as ET

# PIL is optional - only needed for PNG processing
try:
    from PIL import Image
    HAS_PIL = True
except ImportError:
    HAS_PIL = False


def squarize_svg(input_path, output_path):
    """Make an SVG square by adjusting viewBox and wrapping content."""
    # Parse the SVG
    tree = ET.parse(input_path)
    root = tree.getroot()
    
    # Get the viewBox
    viewbox = root.get('viewBox')
    if not viewbox:
        print(f"Error: SVG must have a viewBox attribute", file=sys.stderr)
        return False
    
    # Parse viewBox: "min-x min-y width height"
    vb_parts = viewbox.split()
    if len(vb_parts) != 4:
        print(f"Error: Invalid viewBox format", file=sys.stderr)
        return False
    
    min_x, min_y, width, height = map(float, vb_parts)
    
    # Calculate the square size (largest dimension)
    square_size = max(width, height)
    
    # Calculate padding needed
    pad_x = (square_size - width) / 2
    pad_y = (square_size - height) / 2
    
    print(f"Original dimensions: {width} x {height}")
    print(f"Square size: {square_size} x {square_size}")
    print(f"Padding: {pad_x} (x), {pad_y} (y)")
    
    # Create a new root with square viewBox
    new_viewbox = f"{min_x} {min_y} {square_size} {square_size}"
    root.set('viewBox', new_viewbox)
    
    # Find all top-level children (excluding defs, metadata, etc. that should stay at root)
    children_to_wrap = []
    for child in list(root):
        # Keep certain elements at root level
        tag = child.tag.split('}')[-1]  # Remove namespace
        if tag not in ['defs', 'metadata', 'title', 'desc', 'style']:
            children_to_wrap.append(child)
            root.remove(child)
    
    # Create wrapper group with translation
    # Define namespace for proper SVG output
    ns = {'svg': 'http://www.w3.org/2000/svg'}
    ET.register_namespace('', ns['svg'])
    
    wrapper = ET.Element('{http://www.w3.org/2000/svg}g')
    wrapper.set('transform', f'matrix(1,0,0,1,{pad_x},{pad_y})')
    
    # Add all children to wrapper
    for child in children_to_wrap:
        wrapper.append(child)
    
    # Add wrapper to root
    root.append(wrapper)
    
    # Write output
    tree.write(output_path, encoding='utf-8', xml_declaration=True)
    print(f"Saved square SVG to: {output_path}")
    return True


def squarize_png(input_path, output_path, resolution=None):
    """Make a PNG square by adding transparent pixels symmetrically."""
    if not HAS_PIL:
        print("Error: PIL/Pillow is required for PNG processing. Install with: pip install Pillow", file=sys.stderr)
        return False
    
    # Open the image
    img = Image.open(input_path)
    width, height = img.size
    
    # Calculate the square size (largest dimension)
    square_size = max(width, height)
    
    # Calculate padding needed
    pad_x = (square_size - width) // 2
    pad_y = (square_size - height) // 2
    
    print(f"Original dimensions: {width} x {height}")
    print(f"Square size: {square_size} x {square_size}")
    print(f"Padding: {pad_x} (x), {pad_y} (y)")
    
    # Create a new square image with transparent background
    # Use RGBA mode to support transparency
    if img.mode != 'RGBA':
        img = img.convert('RGBA')
    
    square_img = Image.new('RGBA', (square_size, square_size), (0, 0, 0, 0))
    
    # Paste the original image in the center
    square_img.paste(img, (pad_x, pad_y))
    
    # Downsample if resolution is specified
    if resolution:
        print(f"Downsampling to: {resolution} x {resolution}")
        square_img = square_img.resize((resolution, resolution), Image.Resampling.LANCZOS)
    
    # Save the result
    square_img.save(output_path, 'PNG')
    print(f"Saved square PNG to: {output_path}")
    return True


def main():
    parser = argparse.ArgumentParser(
        description='Squarizer - Make images square by padding symmetrically',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s logo.svg                    # Creates logo_sq.svg
  %(prog)s logo.svg -o square.svg      # Custom output name
  %(prog)s logo.png -r 512             # Square PNG downsampled to 512x512
  %(prog)s logo.svg logo.png           # Process multiple files
        """
    )
    
    parser.add_argument('input', nargs='+', help='Input image file(s) (SVG or PNG)')
    parser.add_argument('-o', '--output', help='Output file path (only works with single input)')
    parser.add_argument('-r', '--resolution', type=int, metavar='SIZE',
                        help='Downsample to SIZE x SIZE pixels (PNG only)')
    parser.add_argument('-s', '--suffix', default='_sq',
                        help='Suffix to add to filename (default: _sq)')
    
    args = parser.parse_args()
    
    # Check if output is specified with multiple inputs
    if args.output and len(args.input) > 1:
        print("Error: --output can only be used with a single input file", file=sys.stderr)
        return 1
    
    success_count = 0
    
    for input_path in args.input:
        input_path = Path(input_path)
        
        if not input_path.exists():
            print(f"Error: File not found: {input_path}", file=sys.stderr)
            continue
        
        # Determine output path
        if args.output:
            output_path = Path(args.output)
        else:
            # Generate output name with suffix
            stem = input_path.stem
            suffix = input_path.suffix
            output_path = input_path.parent / f"{stem}{args.suffix}{suffix}"
        
        print(f"\nProcessing: {input_path}")
        
        # Process based on file type
        ext = input_path.suffix.lower()
        
        if ext == '.svg':
            if squarize_svg(input_path, output_path):
                success_count += 1
        elif ext in ['.png', '.jpg', '.jpeg']:
            if squarize_png(input_path, output_path, args.resolution):
                success_count += 1
        else:
            print(f"Error: Unsupported file format: {ext}", file=sys.stderr)
            continue
    
    print(f"\n✓ Successfully processed {success_count}/{len(args.input)} file(s)")
    return 0 if success_count == len(args.input) else 1


if __name__ == '__main__':
    sys.exit(main())

