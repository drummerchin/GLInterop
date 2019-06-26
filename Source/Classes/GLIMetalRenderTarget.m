//
//  GLIMetalRenderTarget.m
//  GLInterop
//
//  Created by Qin Hong on 6/26/19.
//

#import "GLIMetalRenderTarget.h"
#import <CoreVideo/CoreVideo.h>
#import "GLIMetalTextureCache.h"

@interface GLIMetalRenderTarget ()
{
    id _cvTexture;
    GLIMetalTextureCache *_textureCache;
}

@end

@implementation GLIMetalRenderTarget

- (instancetype)initWithWithCVPixelBuffer:(CVPixelBufferRef)pixelBuffer
{
    if (self = [super initWithWithCVPixelBuffer:pixelBuffer])
    {
        _cvTexture = (__bridge_transfer id)[[GLIMetalTextureCache sharedTextureCache] createCVTextureFromImage:self.pixelBuffer pixelFormat:MTLPixelFormatBGRA8Unorm width:self.width height:self.height planeIndex:0];
        _mtlTexture = CVMetalTextureGetTexture((__bridge CVMetalTextureRef)_cvTexture);
    }
    return self;
}

- (instancetype)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        _cvTexture = (__bridge_transfer id)[[GLIMetalTextureCache sharedTextureCache] createCVTextureFromImage:self.pixelBuffer pixelFormat:MTLPixelFormatBGRA8Unorm width:self.width height:self.height planeIndex:0];
        _mtlTexture = CVMetalTextureGetTexture((__bridge CVMetalTextureRef)_cvTexture);
    }
    return self;
}

@end
