//
//  GLIMetalTextureCache.m
//  GLInterop
//
//  Created by Qin Hong on 2018/12/3.
//

#import "GLIMetalTextureCache.h"

@interface GLIMetalTextureCache ()
{
    id<MTLDevice> _device;
    CVMetalTextureCacheRef _mtlTextureCache;
}

@end

@implementation GLIMetalTextureCache

+ (instancetype)sharedTextureCache
{
    static GLIMetalTextureCache *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        id<MTLDevice> device = MTLCreateSystemDefaultDevice();
        instance = [[GLIMetalTextureCache alloc] initWithDevice:device];
    });
    return instance;
}

- (void)dealloc
{
    [self flush];
    if (_mtlTextureCache)
    {
        CFRelease(_mtlTextureCache);
    }
}

- (instancetype)initWithDevice:(id<MTLDevice>)device
{
    if (self = [super init])
    {
        NSParameterAssert(device);
        _device = device;
        CVReturn ret = CVMetalTextureCacheCreate(kCFAllocatorDefault, NULL, _device, NULL, &_mtlTextureCache);
        if (ret != kCVReturnSuccess)
        {
            NSLog(@"Failed to create metal texture cache.");
        }
    }
    return self;
}

- (CVMetalTextureRef)createCVTextureFromImage:(CVImageBufferRef)sourceImage pixelFormat:(MTLPixelFormat)pixelFormat width:(NSUInteger)width height:(NSUInteger)height planeIndex:(NSUInteger)planeIndex
{
    if (sourceImage == NULL) return nil;
    CVMetalTextureRef mtlTexture = NULL;
    CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, _mtlTextureCache, sourceImage, NULL, pixelFormat, width, height, planeIndex, &mtlTexture);
    return mtlTexture;
}

- (void)flush
{
    CVMetalTextureCacheFlush(_mtlTextureCache, 0);
}

@end
