//
//  GLIRenderTargetSpec.m
//  GLInterop_Example
//
//  Created by Qin Hong on 5/31/19.
//  Copyright © 2019 Qin Hong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLIRenderTarget.h"
#import "GLITextureCache.h"

SpecBegin(GLIRenderTarget)

describe(@"GLIRenderTarget", ^{
    
    context(@"Initializing", ^{
        
        it(@"can be initialized with a given size", ^{
            CGSize size = CGSizeMake(100, 200);
            GLIRenderTarget *renderTarget = [[GLIRenderTarget alloc] initWithSize:size];
            expect(renderTarget).notTo.beNil();
            expect(renderTarget.glTexture).notTo.beNil();
            expect(renderTarget.pixelBuffer).notTo.beNil();
            expect(renderTarget.width).to.equal(size.width);
            expect(renderTarget.height).to.equal(size.height);
            GLITextureCache *glTextureCache = [GLITextureCache sharedTextureCache];
            expect(renderTarget.glTextureCache).to.equal(glTextureCache);
        });

        it(@"can be initialized with a given size and a GLITextureCache", ^{
            EAGLContext *eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
            GLITextureCache *customGLTextureCache = [[GLITextureCache alloc] initWithContext:eaglContext];
            CGSize size = CGSizeMake(100, 200);
            GLIRenderTarget *renderTarget = [[GLIRenderTarget alloc] initWithSize:size glTextureCache:customGLTextureCache];
            expect(renderTarget).notTo.beNil();
            expect(renderTarget.glTexture).notTo.beNil();
            expect(renderTarget.pixelBuffer).notTo.beNil();
            expect(renderTarget.width).to.equal(size.width);
            expect(renderTarget.height).to.equal(size.height);
            expect(renderTarget.glTextureCache).to.equal(customGLTextureCache);
        });

        it(@"can be initialized with a given pixel buffer", ^{
            CVPixelBufferRef pixelBuffer = NULL;
            CVPixelBufferCreate(kCFAllocatorDefault, 100, 200, kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef _Nullable)@{(__bridge NSString*)kCVPixelBufferOpenGLCompatibilityKey : @(YES), (__bridge NSString*)kCVPixelBufferMetalCompatibilityKey : @(YES), }, &pixelBuffer);
            expect(pixelBuffer).notTo.beNil();
            NSUInteger width = CVPixelBufferGetWidth(pixelBuffer);
            NSUInteger height = CVPixelBufferGetHeight(pixelBuffer);

            GLIRenderTarget *renderTarget = [[GLIRenderTarget alloc] initWithWithCVPixelBuffer:pixelBuffer];
            expect(renderTarget).notTo.beNil();
            expect(renderTarget.glTexture).notTo.beNil();
            expect(renderTarget.pixelBuffer).notTo.beNil();
            expect(renderTarget.width).to.equal(width);
            expect(renderTarget.height).to.equal(height);
            GLITextureCache *glTextureCache = [GLITextureCache sharedTextureCache];
            expect(renderTarget.glTextureCache).to.equal(glTextureCache);
        });
        
        it(@"can be initialized with a given pixel buffer and a GLITextureCache", ^{
            CVPixelBufferRef pixelBuffer = NULL;
            CVPixelBufferCreate(kCFAllocatorDefault, 100, 200, kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef _Nullable)@{(__bridge NSString*)kCVPixelBufferOpenGLCompatibilityKey : @(YES), (__bridge NSString*)kCVPixelBufferMetalCompatibilityKey : @(YES), }, &pixelBuffer);
            expect(pixelBuffer).notTo.beNil();
            NSUInteger width = CVPixelBufferGetWidth(pixelBuffer);
            NSUInteger height = CVPixelBufferGetHeight(pixelBuffer);

            EAGLContext *eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
            GLITextureCache *customGLTextureCache = [[GLITextureCache alloc] initWithContext:eaglContext];

            GLIRenderTarget *renderTarget = [[GLIRenderTarget alloc] initWithWithCVPixelBuffer:pixelBuffer glTextureCache:customGLTextureCache];
            expect(renderTarget).notTo.beNil();
            expect(renderTarget.glTexture).notTo.beNil();
            expect(renderTarget.pixelBuffer).notTo.beNil();
            expect(renderTarget.width).to.equal(width);
            expect(renderTarget.height).to.equal(height);
            expect(renderTarget.glTextureCache).to.equal(customGLTextureCache);
        });

    });
});

SpecEnd
