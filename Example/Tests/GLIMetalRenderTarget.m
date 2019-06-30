//
//  GLIMetalRenderTarget.m
//  GLInterop_Tests
//
//  Created by Qin Hong on 6/27/19.
//  Copyright © 2019 Qin Hong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLIMetalRenderTarget.h"
#import "GLITextureCache.h"
#import "GLIMetalTextureCache.h"

SpecBegin(GLIMetalRenderTarget)

describe(@"GLIMetalRenderTarget", ^{
    
    context(@"Initializing", ^{
        
        it(@"can be initialized with a given size", ^{
            CGSize size = CGSizeMake(100, 200);
            GLIMetalRenderTarget *renderTarget = [[GLIMetalRenderTarget alloc] initWithSize:size];
            expect(renderTarget).notTo.beNil();
            expect(renderTarget.mtlTexture).notTo.beNil();
            expect(renderTarget.glTexture).notTo.beNil();
            expect(renderTarget.pixelBuffer).notTo.beNil();
            expect(renderTarget.width).to.equal(size.width);
            expect(renderTarget.height).to.equal(size.height);
            GLITextureCache *glTextureCache = [GLITextureCache sharedTextureCache];
            expect(renderTarget.glTextureCache).to.equal(glTextureCache);
            GLIMetalTextureCache *mtlTextureCache = [GLIMetalTextureCache sharedTextureCache];
            expect(renderTarget.mtlTextureCache).to.equal(mtlTextureCache);
        });
        
        it(@"can be initialized with a given size and a GLITextureCache", ^{
            EAGLContext *eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
            GLITextureCache *customGLTextureCache = [[GLITextureCache alloc] initWithContext:eaglContext];
            CGSize size = CGSizeMake(100, 200);
            GLIMetalRenderTarget *renderTarget = [[GLIMetalRenderTarget alloc] initWithSize:size glTextureCache:customGLTextureCache];
            expect(renderTarget).notTo.beNil();
            expect(renderTarget.mtlTexture).notTo.beNil();
            expect(renderTarget.glTexture).notTo.beNil();
            expect(renderTarget.pixelBuffer).notTo.beNil();
            expect(renderTarget.width).to.equal(size.width);
            expect(renderTarget.height).to.equal(size.height);
            expect(renderTarget.glTextureCache).to.equal(customGLTextureCache);
            GLIMetalTextureCache *mtlTextureCache = [GLIMetalTextureCache sharedTextureCache];
            expect(renderTarget.mtlTextureCache).to.equal(mtlTextureCache);
        });

        it(@"can be initialized with a given size, GLITextureCache and GLIMetalTextureCache", ^{
            EAGLContext *eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
            GLITextureCache *customGLTextureCache = [[GLITextureCache alloc] initWithContext:eaglContext];
            id<MTLDevice> device = MTLCreateSystemDefaultDevice();
            GLIMetalTextureCache *customMTLTextureCache = [[GLIMetalTextureCache alloc] initWithDevice:device];
            
            CGSize size = CGSizeMake(100, 200);
            GLIMetalRenderTarget *renderTarget = [[GLIMetalRenderTarget alloc] initWithSize:size glTextureCache:customGLTextureCache mtlTextureCache:customMTLTextureCache];
            expect(renderTarget).notTo.beNil();
            expect(renderTarget.mtlTexture).notTo.beNil();
            expect(renderTarget.glTexture).notTo.beNil();
            expect(renderTarget.pixelBuffer).notTo.beNil();
            expect(renderTarget.width).to.equal(size.width);
            expect(renderTarget.height).to.equal(size.height);
            expect(renderTarget.glTextureCache).to.equal(customGLTextureCache);
            expect(renderTarget.mtlTextureCache).to.equal(customMTLTextureCache);
        });

        it(@"can be initialized with a given pixel buffer", ^{
            CVPixelBufferRef pixelBuffer = NULL;
            CVPixelBufferCreate(kCFAllocatorDefault, 100, 200, kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef _Nullable)@{(__bridge NSString*)kCVPixelBufferOpenGLCompatibilityKey : @(YES), (__bridge NSString*)kCVPixelBufferMetalCompatibilityKey : @(YES), }, &pixelBuffer);
            expect(pixelBuffer).notTo.beNil();
            NSUInteger width = CVPixelBufferGetWidth(pixelBuffer);
            NSUInteger height = CVPixelBufferGetHeight(pixelBuffer);
            
            GLIMetalRenderTarget *renderTarget = [[GLIMetalRenderTarget alloc] initWithWithCVPixelBuffer:pixelBuffer];
            expect(renderTarget).notTo.beNil();
            expect(renderTarget.mtlTexture).notTo.beNil();
            expect(renderTarget.glTexture).notTo.beNil();
            expect(renderTarget.pixelBuffer).notTo.beNil();
            expect(renderTarget.width).to.equal(width);
            expect(renderTarget.height).to.equal(height);
            GLITextureCache *glTextureCache = [GLITextureCache sharedTextureCache];
            expect(renderTarget.glTextureCache).to.equal(glTextureCache);
            GLIMetalTextureCache *mtlTextureCache = [GLIMetalTextureCache sharedTextureCache];
            expect(renderTarget.mtlTextureCache).to.equal(mtlTextureCache);
        });
        
        it(@"can be initialized with a given pixel buffer and a GLITextureCache", ^{
            CVPixelBufferRef pixelBuffer = NULL;
            CVPixelBufferCreate(kCFAllocatorDefault, 100, 200, kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef _Nullable)@{(__bridge NSString*)kCVPixelBufferOpenGLCompatibilityKey : @(YES), (__bridge NSString*)kCVPixelBufferMetalCompatibilityKey : @(YES), }, &pixelBuffer);
            expect(pixelBuffer).notTo.beNil();
            NSUInteger width = CVPixelBufferGetWidth(pixelBuffer);
            NSUInteger height = CVPixelBufferGetHeight(pixelBuffer);
            
            EAGLContext *eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
            GLITextureCache *customGLTextureCache = [[GLITextureCache alloc] initWithContext:eaglContext];
            
            GLIMetalRenderTarget *renderTarget = [[GLIMetalRenderTarget alloc] initWithWithCVPixelBuffer:pixelBuffer glTextureCache:customGLTextureCache];
            expect(renderTarget).notTo.beNil();
            expect(renderTarget.mtlTexture).notTo.beNil();
            expect(renderTarget.glTexture).notTo.beNil();
            expect(renderTarget.pixelBuffer).notTo.beNil();
            expect(renderTarget.width).to.equal(width);
            expect(renderTarget.height).to.equal(height);
            expect(renderTarget.glTextureCache).to.equal(customGLTextureCache);
            GLIMetalTextureCache *mtlTextureCache = [GLIMetalTextureCache sharedTextureCache];
            expect(renderTarget.mtlTextureCache).to.equal(mtlTextureCache);
        });

        it(@"can be initialized with a given pixel buffer, GLITextureCache and GLIMetalTextureCache", ^{
            CVPixelBufferRef pixelBuffer = NULL;
            CVPixelBufferCreate(kCFAllocatorDefault, 100, 200, kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef _Nullable)@{(__bridge NSString*)kCVPixelBufferOpenGLCompatibilityKey : @(YES), (__bridge NSString*)kCVPixelBufferMetalCompatibilityKey : @(YES), }, &pixelBuffer);
            expect(pixelBuffer).notTo.beNil();
            NSUInteger width = CVPixelBufferGetWidth(pixelBuffer);
            NSUInteger height = CVPixelBufferGetHeight(pixelBuffer);
            
            EAGLContext *eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
            GLITextureCache *customGLTextureCache = [[GLITextureCache alloc] initWithContext:eaglContext];
            id<MTLDevice> device = MTLCreateSystemDefaultDevice();
            GLIMetalTextureCache *customMTLTextureCache = [[GLIMetalTextureCache alloc] initWithDevice:device];

            GLIMetalRenderTarget *renderTarget = [[GLIMetalRenderTarget alloc] initWithWithCVPixelBuffer:pixelBuffer glTextureCache:customGLTextureCache mtlTextureCache:customMTLTextureCache];
            expect(renderTarget).notTo.beNil();
            expect(renderTarget.mtlTexture).notTo.beNil();
            expect(renderTarget.glTexture).notTo.beNil();
            expect(renderTarget.pixelBuffer).notTo.beNil();
            expect(renderTarget.width).to.equal(width);
            expect(renderTarget.height).to.equal(height);
            expect(renderTarget.glTextureCache).to.equal(customGLTextureCache);
            expect(renderTarget.mtlTextureCache).to.equal(customMTLTextureCache);
        });
        
    });
});

SpecEnd
