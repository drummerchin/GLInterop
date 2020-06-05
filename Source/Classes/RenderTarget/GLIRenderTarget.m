//
//  GLIRenderTarget.m
//  GLInterop
//
//  Created by Qin Hong on 5/31/19.
//

#import "GLIRenderTarget.h"
#import "GLIPixelBufferPool.h"
#import "GLITextureCache.h"
#import "GLIContext.h"
#import <OpenGLES/ES2/glext.h>

@interface GLIRenderTarget ()
{
    id _cvPixelBuffer;
    id _cvTexture;
    
    GLITexture *_texture;
}

@property (nonatomic) NSUInteger width;
@property (nonatomic) NSUInteger height;
@property (nonatomic) GLuint glTexture;
@property (nonatomic, strong) GLITextureCache *glTextureCache;

@end

@implementation GLIRenderTarget
@synthesize width, height, glTexture;
@dynamic texture;
@dynamic pixelBuffer, mtlTexture;

#pragma mark - life cycle

- (instancetype)initWithWithCVPixelBuffer:(CVPixelBufferRef)pixelBuffer glTextureCache:(nonnull GLITextureCache *)textureCache
{
    if (self = [super init])
    {
        NSParameterAssert(pixelBuffer);
        NSParameterAssert(textureCache);
        if (!pixelBuffer || !textureCache) return nil;
        
        NSUInteger planeCount = CVPixelBufferGetPlaneCount(pixelBuffer);
        if (planeCount > 1) return nil;
        
        self.glTextureCache = textureCache;
        _cvPixelBuffer = (__bridge_transfer id)pixelBuffer;

        self.width = CVPixelBufferGetWidth(pixelBuffer);
        self.height = CVPixelBufferGetHeight(pixelBuffer);
        _cvTexture = (__bridge_transfer id)[self.glTextureCache createCVTextureFromImage:(__bridge CVImageBufferRef _Nonnull)_cvPixelBuffer width:self.width height:self.height planeIndex:0];
        if (_cvTexture)
        {
            self.glTexture = CVOpenGLESTextureGetName((__bridge CVOpenGLESTextureRef)_cvTexture);
        }
    }
    return self;
}

- (instancetype)initWithWithCVPixelBuffer:(CVPixelBufferRef)pixelBuffer
{
    return [self initWithWithCVPixelBuffer:pixelBuffer glTextureCache:[GLITextureCache sharedTextureCache]];
}

- (instancetype)initWithSize:(CGSize)size glTextureCache:(nonnull GLITextureCache *)textureCache
{
    if (self = [super init])
    {
        NSParameterAssert(textureCache);
        if (!textureCache) return nil;
        
        self.width = size.width;
        self.height = size.height;
        NSAssert(self.width > 0 && self.height > 0, @"Invalid render target size.");
        if (!(self.width > 0 && self.height > 0)) return nil;
        
        CVPixelBufferRef pixelBuffer = NULL;
        NSDictionary *pixelBufferAttributes = @{
            (__bridge NSString*)kCVPixelBufferOpenGLCompatibilityKey : @(YES),
            (__bridge NSString*)kCVPixelBufferMetalCompatibilityKey : @(YES),
        };
        CVPixelBufferCreate(kCFAllocatorDefault, self.width, self.height, kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef _Nullable)(pixelBufferAttributes), &pixelBuffer);
        if (!pixelBuffer) return nil;
        
        self.glTextureCache = textureCache;
        _cvPixelBuffer = (__bridge_transfer id)pixelBuffer;

        _cvTexture = (__bridge_transfer id)[self.glTextureCache createCVTextureFromImage:(__bridge CVImageBufferRef _Nonnull)_cvPixelBuffer width:self.width height:self.height planeIndex:0];
        if (!_cvTexture) return nil;
        self.glTexture = CVOpenGLESTextureGetName((__bridge CVOpenGLESTextureRef)_cvTexture);;
    }
    return self;
}

- (instancetype)initWithSize:(CGSize)size
{
    return [self initWithSize:size glTextureCache:[GLITextureCache sharedTextureCache]];
}

#pragma mark -

- (CVPixelBufferRef)pixelBuffer
{
    return (__bridge CVPixelBufferRef)_cvPixelBuffer;
}

- (id<GLITexture>)texture
{
    if (!_texture)
    {
        _texture = [GLITexture new];
        _texture.target = GL_TEXTURE_2D;
        _texture.name = self.glTexture;
        _texture.width = self.width;
        _texture.height = self.height;
    }
    return _texture;
}

@end
