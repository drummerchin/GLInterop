//
//  GLIMetalRenderTarget.m
//  GLInterop
//
//  Created by Qin Hong on 6/26/19.
//

#import "GLIMetalRenderTarget.h"
#import <CoreVideo/CoreVideo.h>
#import "GLIMetalTextureCache.h"
#import "GLITextureCache.h"

@interface GLIMetalRenderTarget ()
{
    id _cvTexture;
    GLIMetalTextureCache *_mtlTextureCache;
}

@end

@implementation GLIMetalRenderTarget

- (instancetype)initWithWithCVPixelBuffer:(CVPixelBufferRef)pixelBuffer glTextureCache:(nonnull GLITextureCache *)glTextureCache mtlTextureCache:(nonnull GLIMetalTextureCache *)mtlTextureCache
{
    if (self = [super initWithWithCVPixelBuffer:pixelBuffer glTextureCache:glTextureCache])
    {
        NSParameterAssert(mtlTextureCache);
        if (!mtlTextureCache) return nil;
        
        _mtlTextureCache = mtlTextureCache;
        _cvTexture = (__bridge_transfer id)[_mtlTextureCache createCVTextureFromImage:self.pixelBuffer
                                                                          pixelFormat:MTLPixelFormatBGRA8Unorm
                                                                                width:self.width
                                                                               height:self.height
                                                                           planeIndex:0];
        _mtlTexture = CVMetalTextureGetTexture((__bridge CVMetalTextureRef)_cvTexture);
    }
    return self;
}

- (instancetype)initWithWithCVPixelBuffer:(CVPixelBufferRef)pixelBuffer glTextureCache:(GLITextureCache *)textureCache
{
    return [self initWithWithCVPixelBuffer:pixelBuffer glTextureCache:textureCache mtlTextureCache:[GLIMetalTextureCache sharedTextureCache]];
}

- (instancetype)initWithWithCVPixelBuffer:(CVPixelBufferRef)pixelBuffer
{
    return [self initWithWithCVPixelBuffer:pixelBuffer glTextureCache:[GLITextureCache sharedTextureCache] mtlTextureCache:[GLIMetalTextureCache sharedTextureCache]];
}

- (instancetype)initWithSize:(CGSize)size glTextureCache:(nonnull GLITextureCache *)glTextureCache mtlTextureCache:(nonnull GLIMetalTextureCache *)mtlTextureCache
{
    if (self = [super initWithSize:size glTextureCache:glTextureCache])
    {
        NSParameterAssert(mtlTextureCache);
        if (!mtlTextureCache) return nil;
        
        _mtlTextureCache = mtlTextureCache;
        _cvTexture = (__bridge_transfer id)[_mtlTextureCache createCVTextureFromImage:self.pixelBuffer
                                                                          pixelFormat:MTLPixelFormatBGRA8Unorm
                                                                                width:self.width
                                                                               height:self.height
                                                                           planeIndex:0];
        _mtlTexture = CVMetalTextureGetTexture((__bridge CVMetalTextureRef)_cvTexture);
    }
    return self;
}

- (instancetype)initWithSize:(CGSize)size glTextureCache:(GLITextureCache *)textureCache
{
    return [self initWithSize:size glTextureCache:textureCache mtlTextureCache:[GLIMetalTextureCache sharedTextureCache]];
}

- (instancetype)initWithSize:(CGSize)size
{
    return [self initWithSize:size glTextureCache:[GLITextureCache sharedTextureCache] mtlTextureCache:[GLIMetalTextureCache sharedTextureCache]];
}

@end
