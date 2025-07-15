# svg2pdf

This is a simple wrapper around CoreSVG's `CGSVGDocumentCreateFromData` and `CGContextDrawSVGDocument`.

It maintains the vectors as opposed to rasterizing the image.

> [!CAUTION]
> This uses private APIs (at least as of macOS 26) so please don't attempt to distribute this without giving users appropriate caveats.

Usage:
```
  svg2pdf <input> <output>
```

## Building

Assuming you have Xcode installed, run `make.sh`.