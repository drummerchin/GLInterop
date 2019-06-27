//
//  GLIMetalTextureCacheSpec.m
//  GLInterop_Tests
//
//  Created by Qin Hong on 3/22/19.
//  Copyright © 2019 Qin Hong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLIMetalTextureCache.h"
#import <Metal/Metal.h>
#import <UIKit/UIKit.h>

SpecBegin(GLIMetalTextureCache)

describe(@"GLIMetalTextureCache", ^{
    
    context(@"Initializing", ^{
        it(@"can be initialized with a device", ^{
            id<MTLDevice> device = MTLCreateSystemDefaultDevice();
            GLIMetalTextureCache *textureCache = [[GLIMetalTextureCache alloc] initWithDevice:device];
            expect(textureCache).notTo.beNil();
        });
        it(@"can be a singleton", ^{
            GLIMetalTextureCache *textureCache = [GLIMetalTextureCache sharedTextureCache];
            GLIMetalTextureCache *textureCache2 = [GLIMetalTextureCache sharedTextureCache];
            expect(textureCache).notTo.beNil();
            expect(textureCache2).notTo.beNil();
            expect(textureCache).to.beIdenticalTo(textureCache2);
        });
    });
    
    it(@"can create a CVMetalTextureRef from image source", ^{
        GLIMetalTextureCache *textureCache = [GLIMetalTextureCache sharedTextureCache];
        
        CGImageRef image = [UIImage imageNamed:@"USC-SIPI.4.2.03.tiff"].CGImage;
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
        
        MTLPixelFormat pixelFormat = MTLPixelFormatBGRA8Unorm;
        CVMetalTextureRef cvTexture = [textureCache createCVTextureFromImage:pixelBuffer pixelFormat:pixelFormat width:w height:h planeIndex:0];
        expect(cvTexture).notTo.beNil();
        
        id<MTLTexture> texture = CVMetalTextureGetTexture(cvTexture);
        expect(texture).notTo.beNil();
        expect(texture.width).to.equal(w);
        expect(texture.height).to.equal(h);
        expect(texture.pixelFormat).to.equal(pixelFormat);
        
        CVBufferRelease(cvTexture);
    });
});

SpecEnd
