//
//  GLITextureCache.m
//  GLInterop
//
//  Created by Qin Hong on 2018/12/3.
//

#import "GLITextureCache.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "GLIContext.h"

@interface GLITextureCache ()
{
    EAGLContext *_context;
    CVOpenGLESTextureCacheRef _glTextureCache;
}

@end

@implementation GLITextureCache
@synthesize glContext = _context;

- (void)dealloc
{
    [self flush];
}

- (instancetype)initWithContext:(EAGLContext *)context
{
    if (self = [super init])
    {
        NSParameterAssert(context);
        _context = context;
        CVReturn ret = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, _context, NULL, &_glTextureCache);
        if (ret != kCVReturnSuccess)
        {
            NSLog(@"Failed to create gl texture cache.");
        }
    }
    return self;
}

+ (instancetype)sharedTextureCache
{
    static GLITextureCache *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GLITextureCache alloc] initWithContext:[GLIContext sharedContext].glContext];
    });
    return instance;
}

- (CVOpenGLESTextureRef)createCVTextureFromImage:(CVImageBufferRef)sourceImage width:(NSUInteger)width height:(NSUInteger)height planeIndex:(NSUInteger)planeIndex
{
    if (sourceImage == NULL) return nil;
    CVOpenGLESTextureRef glTexture = NULL;
    CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                 _glTextureCache,
                                                 sourceImage,
                                                 NULL,
                                                 GL_TEXTURE_2D,
                                                 GL_RGBA,
                                                 (GLsizei)width,
                                                 (GLsizei)height,
                                                 GL_BGRA,
                                                 GL_UNSIGNED_BYTE,
                                                 planeIndex,
                                                 &glTexture);
    return glTexture;
}

- (void)flush
{
    CVOpenGLESTextureCacheFlush(_glTextureCache, 0);
}

@end
