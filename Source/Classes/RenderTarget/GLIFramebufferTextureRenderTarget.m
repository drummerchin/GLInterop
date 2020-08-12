//
//  GLIFramebufferTextureRenderTarget.m
//  GLInterop
//
//  Created by Qin Hong on 5/29/20.
//

#import "GLIFramebufferTextureRenderTarget.h"
#import <OpenGLES/ES2/gl.h>
#import "GLITexture.h"
#import "GLIRenderer.h"

@interface GLIFramebufferTextureRenderTarget ()
{
    GLITexture *_texture;
    struct GLIFramebuffer _framebuffer;
}

@property (nonatomic) NSUInteger width;
@property (nonatomic) NSUInteger height;
@property (nonatomic) GLuint glTexture;

@end

@implementation GLIFramebufferTextureRenderTarget
@dynamic texture;
@synthesize width, height, glTexture;

- (void)dealloc
{
    if (_framebuffer.name)
    {
        glDeleteFramebuffers(1, &_framebuffer.name);
        _framebuffer.name = 0;
    }
}

- (instancetype)initWithWidth:(NSUInteger)width height:(NSUInteger)height
{
    if (self = [super init])
    {
        self.clearColor = [UIColor clearColor];
        self.width = width;
        self.height = height;
        
        _texture = [GLITexture new];
        _texture.deleteTextureWhileDeallocating = YES;
        _texture.target = GL_TEXTURE_2D;
        GLuint tex = 0;
        glGenTextures(1, &tex);
        _texture.name = tex;
        _texture.width = self.width;
        _texture.height = self.height;
        
        self.glTexture = _texture.name;

        [_texture setTextureParameters];
        [_texture setDimensions];
    }
    return self;
}

- (void)prepareFramebuffer
{
    if (!_framebuffer.name)
    {
        _framebuffer.target = GL_FRAMEBUFFER;
        glGenFramebuffers(1, &_framebuffer.name);
    }

    glBindFramebuffer(_framebuffer.target, _framebuffer.name);
    glFramebufferTexture2D(_framebuffer.target, GL_COLOR_ATTACHMENT0, _texture.target, _texture.name, 0);
    GLenum status = glCheckFramebufferStatus(_framebuffer.target);
    if (status != GL_FRAMEBUFFER_COMPLETE)
    {
        printf("Failed to make complete framebuffer object %x\n", status);
    }
    
    CGFloat clearColorR = 0, clearColorG = 0, clearColorB = 0, clearColorA = 0;
    [self.clearColor getRed:&clearColorR green:&clearColorG blue:&clearColorB alpha:&clearColorA];
    glClearColor(clearColorR, clearColorG, clearColorB, clearColorA);
    glClear(GL_COLOR_BUFFER_BIT);
}

- (id<GLITexture>)texture
{
    return [_texture copy];
}

@end
