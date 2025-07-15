# svg2pdf

This is a simple wrapper around CoreSVG's CGSVGDocumentCreateFromData and CGContextDrawSVGDocument.

It maintains the vectors as opposed to rasterizing the image.

Usage:
  svg2pdf <input> <output>

## Building

Assuming you have Xcode installed, run `make.sh`.