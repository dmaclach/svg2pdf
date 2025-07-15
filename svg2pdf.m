// Copyright 2025 Dave MacLachlan
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//     http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


// Converts SVG files to PDF files.
//
// This is a simple wrapper around CoreGraphics's CGSVGDocumentCreateFromData
// and CGContextDrawSVGDocument.
//
// It maintains the vectors as opposed to rasterizing the image.
//
// This is intended to be used as a tool from rules_apple/apple_genrules.bzl.
//
// Usage:
//   svg2pdf <input> <output>

#import <Foundation/Foundation.h>
#include <CoreGraphics/CoreGraphics.h>

// Some Private APIs we are borrowing
typedef CFTypeRef CGSVGDocumentRef;
extern void CGContextDrawSVGDocument(CGContextRef, CGSVGDocumentRef);
extern CGSize CGSVGDocumentGetCanvasSize(CGSVGDocumentRef);
extern CGSVGDocumentRef CGSVGDocumentCreateFromURL(CFURLRef url, CFDictionaryRef options);

int main(int argc, const char* argv[]) {
    @autoreleasepool {
        if (argc != 3) {
            fprintf(stderr, "svg2pdf <input> <output>\n");
            return 1;
        }
        const char* inputPath = argv[1];
        const char* outputPath = argv[2];

        NSURL *inputURL = [NSURL fileURLWithPath:@(inputPath)];
        if (!inputURL) {
            fprintf(stderr, "svg2pdf:%s: error: unable to parse %s as a path\n",
                    inputPath, inputPath);
            return 1;
        }
        NSURL *outputURL = [NSURL fileURLWithPath:@(outputPath)];
        if (!outputURL) {
            fprintf(stderr, "svg2pdf:%s: error: unable to parse %s as a path\n",
                    inputPath, outputPath);
            return 1;
        }
        CGSVGDocumentRef doc = CGSVGDocumentCreateFromURL((__bridge CFURLRef)inputURL, NULL);
        if (!doc) {
            fprintf(stderr, "svg2pdf:%s: error: unable to parse %s as an svg\n",
                    inputPath, inputPath);
            return 1;
        }
        CGSize size = CGSVGDocumentGetCanvasSize(doc);
        if (CGSizeEqualToSize(size, CGSizeZero))
            if (!doc) {
                fprintf(stderr, "svg2pdf:%s: error: unable to get canvas size from %s\n",
                        inputPath, inputPath);
                return 1;
            }
        CGRect mediaBox = CGRectMake(0, 0, size.width, size.height);
        CGContextRef context = CGPDFContextCreateWithURL((__bridge CFURLRef)outputURL, &mediaBox, NULL);
        if (!context) {
            fprintf(stderr, "svg2pdf:%s: error: unable to create file at %s\n",
                    inputPath, outputPath);
            return 1;
        }
        CGContextBeginPage(context, &mediaBox);
        CGContextDrawSVGDocument(context, doc);
        CGContextEndPage(context);
        CGPDFContextClose(context);
        CFRelease(context);
        CFRelease(doc);
        return 0;
    }
}

