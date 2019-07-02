//
//  GLITextureCacheSpec.m
//  GLInterop_Example
//
//  Created by Qin Hong on 5/31/19.
//  Copyright © 2019 Qin Hong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GLITextureCache.h"
#import <OpenGLES/EAGL.h>

SpecBegin(GLITextureCache)

describe(@"GLITextureCache", ^{
    
    context(@"Initializing", ^{
    
        it(@"can be initialized with a context", ^{
            EAGLContext *gl2Context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
            GLITextureCache *gl2TextureCache = [[GLITextureCache alloc] initWithContext:gl2Context];
            expect(gl2TextureCache).notTo.beNil();
            expect(gl2TextureCache.glContext).to.equal(gl2Context);

            EAGLContext *gl3Context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
            GLITextureCache *gl3TextureCache = [[GLITextureCache alloc] initWithContext:gl3Context];
            expect(gl3TextureCache).notTo.beNil();
            expect(gl3TextureCache.glContext).to.equal(gl3Context);
        });
        
        it(@"can be a singleton", ^{
            GLITextureCache *textureCache = [GLITextureCache sharedTextureCache];
            GLITextureCache *textureCache2 = [GLITextureCache sharedTextureCache];
            expect(textureCache).notTo.beNil();
            expect(textureCache2).notTo.beNil();
            expect(textureCache).to.beIdenticalTo(textureCache2);
        });
    });
    
    it(@"can create a CVOpenGLESTextureRef from image source", ^{
        GLITextureCache *textureCache = [GLITextureCache sharedTextureCache];
        
        CGImageRef image = [UIImage imageNamed:@"USC-SIPI.4.2.07.tiff"].CGImage;
        expect(image).notTo.beNil();
        NSUInteger w = CGImageGetWidth(image);
        NSUInteger h = CGImageGetHeight(image);
        uint8_t *rawData = (uint8_t *)calloc(w*4*h, sizeof(uint8_t));
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(rawData, w, h, 8, w*4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
        CGColorSpaceRelease(colorSpace);
        CGRect imageRect = CGRectMake(0, 0, w, h);
        CGContextDrawImage(context, imageRect, image);
        CGContextRelease(context);
        
        CVPixelBufferRef pixelBuffer = NULL;
        CVPixelBufferCreate(kCFAllocatorDefault, w, h, 'BGRA', (__bridge CFDictionaryRef _Nullable)(@{(id)kCVPixelBufferMetalCompatibilityKey: @(YES)}), &pixelBuffer);
        CVPixelBufferLockBaseAddress(pixelBuffer, 0);
        void *baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer);
        memcpy(baseAddress, rawData, w*4*h);
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
        free(rawData);
        
        CVOpenGLESTextureRef cvTexture = [textureCache createCVTextureFromImage:pixelBuffer width:w height:h planeIndex:0];
        expect(cvTexture).notTo.beNil();
        CVBufferRelease(cvTexture);
    });
    
});

SpecEnd
