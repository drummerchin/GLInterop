//
//  GLIRenderTarget.m
//  GLInterop
//
//  Created by Qin Hong on 5/31/19.
//

#import "GLIRenderTarget.h"
#import "GLIPixelBufferPool.h"
#import "GLITextureCache.h"
#import <OpenGLES/ES2/glext.h>

@interface GLIRenderTarget ()
{
    GLITextureCache *_textureCache;
    id _cvPixelBuffer;
    id _cvTexture;
}

@end

@implementation GLIRenderTarget
@dynamic pixelBuffer;

#pragma mark - life cycle

- (instancetype)initWithWithCVPixelBuffer:(CVPixelBufferRef)pixelBuffer
{
    if (self = [super init])
    {
        if (!pixelBuffer) return nil;
        NSUInteger planeCount = CVPixelBufferGetPlaneCount(pixelBuffer);
        if (planeCount > 1) return nil;

        _textureCache = [GLITextureCache sharedTextureCache];
        _cvPixelBuffer = (__bridge_transfer id)pixelBuffer;

        NSUInteger width = CVPixelBufferGetWidth(pixelBuffer);
        NSUInteger height = CVPixelBufferGetHeight(pixelBuffer);
        _cvTexture = (__bridge_transfer id)[_textureCache createCVTextureFromImage:(__bridge CVImageBufferRef _Nonnull)_cvPixelBuffer width:width height:height planeIndex:0];
        if (!_cvTexture) return nil;
        _glTexture = CVOpenGLESTextureGetName((__bridge CVOpenGLESTextureRef)_cvTexture);;

    }
    return self;
}

- (instancetype)initWithSize:(CGSize)size
{
    if (self = [super init])
    {
        NSUInteger width = size.width;
        NSUInteger height = size.height;
        NSAssert(width > 0 && height > 0, @"Invalid render target size.");
        if (!(width > 0 && height > 0)) return nil;
        
        CVPixelBufferRef pixelBuffer = NULL;
        NSDictionary *pixelBufferAttributes = @{
            (__bridge NSString*)kCVPixelBufferOpenGLCompatibilityKey : @YES,
            (__bridge NSString*)kCVPixelBufferMetalCompatibilityKey : @(YES),
        };
        CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef _Nullable)(pixelBufferAttributes), &pixelBuffer);
        if (!pixelBuffer) return nil;
        
        _textureCache = [GLITextureCache sharedTextureCache];
        _cvPixelBuffer = (__bridge_transfer id)pixelBuffer;

        _cvTexture = (__bridge_transfer id)[_textureCache createCVTextureFromImage:(__bridge CVImageBufferRef _Nonnull)_cvPixelBuffer width:width height:height planeIndex:0];
        if (!_cvTexture) return nil;
        _glTexture = CVOpenGLESTextureGetName((__bridge CVOpenGLESTextureRef)_cvTexture);;
    }
    return self;
}

- (CVPixelBufferRef)pixelBuffer
{
    return (__bridge CVPixelBufferRef)_cvPixelBuffer;
}

@end
