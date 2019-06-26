//
//  GLIRenderer.m
//  GLInterop
//
//  Created by Qin Hong on 6/3/19.
//

#import "GLIRenderer.h"
#import <OpenGLES/ES2/gl.h>
#include "GLIProgram.h"
#include "GLIMatrixUtil.h"

const char * GLIDefaultVertexString = GLI_SHADER(
    precision highp float;
    attribute vec4 position;
    attribute vec2 texCoord;
    varying vec2 vTexCoord;
    void main()
    {
        gl_Position = position;
        vTexCoord = texCoord.xy;
    }
);

struct GLIFramebuffer
{
    GLenum target; // GL_FRAMEBUFFER, GL_FRAMEBUFFER_EXT, etc.
    GLuint name;
};

@interface GLIRenderer ()
{
    GLIProgramRef _prog;
    struct GLIFramebuffer _framebuffer;    
}

@end

@implementation GLIRenderer

#pragma mark - life cycle

- (void)dealloc
{
    if (_prog)
    {
        GLIProgramDestroy(_prog);
    }
    if (_framebuffer.name)
    {
        glDeleteFramebuffers(1, &_framebuffer.name);
    }
}

- (instancetype)initWithVertex:(NSString *)vertex fragment:(NSString *)fragment
{
    if (self = [super init])
    {
        if (vertex && fragment)
        {
            const char *vertexStr = [vertex UTF8String];
            const char *fragStr = [fragment UTF8String];
            _prog = GLIProgramCreateFromSource(vertexStr, fragStr);
            int isValid = GLIProgramLinkAndValidate(_prog);
            if (!isValid)
            {
                NSLog(@"Failed to create GLIRenderer.");
            }
            
            GLIProgramParseVertexAttrib(_prog);
            GLIProgramParseUniform(_prog);

            
        }
        
        _framebuffer.target = GL_FRAMEBUFFER;
        glGenFramebuffers(1, &_framebuffer.name);
        
        glEnable(GL_TEXTURE_2D);
        glDisable(GL_DEPTH_TEST);
    }
    return self;
}

#pragma mark - rendering


- (BOOL)prepareFramebuffer
{
    if (!_output) return NO;
    glBindFramebuffer(_framebuffer.target, _framebuffer.name);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _output.glTexture);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _output.glTexture, 0);
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE)
    {
        printf("failed to make complete framebuffer object %x\n", status);
        return NO;
    }
    
    CGFloat clearColorR = 0, clearColorG = 0, clearColorB = 0, clearColorA = 0;
    [_clearColor getRed:&clearColorR green:&clearColorG blue:&clearColorB alpha:&clearColorA];
    glClearColor(clearColorR, clearColorG, clearColorB, clearColorA);
    glClear(GL_COLOR_BUFFER_BIT);
    return YES;
}

- (void)render
{
    if (![self prepareFramebuffer]) return;
    if (self.program)
    {
        id<GLITexture> firstTexture = [self.inputTextures firstObject];
        glUseProgram(self.program);
        [self setViewPortWithContentMode:UIViewContentModeCenter inputSize:CGSizeMake(firstTexture.width, firstTexture.height)];
        [self applyVertexAttribute:@"position" bytes:&(GLfloat[]){
            -1.0, -1.0, 0.0, 1.0,
             1.0, -1.0, 0.0, 1.0,
            -1.0,  1.0, 0.0, 1.0,
             1.0,  1.0, 0.0, 1.0
        }];
        [self applyVertexAttribute:@"texCoord" bytes:&(GLfloat[]){
            0.0f, 0.0f,
            1.0f, 0.0f,
            0.0f, 1.0f,
            1.0f, 1.0f
        }];
        for (int i = 0; i < self.inputTextures.count; i++)
        {
            NSString *texIndexStr = (i == 0) ? @"" : [NSString stringWithFormat:@"%d", i];
            [self setTexture:[NSString stringWithFormat:@"inputTexture%@", texIndexStr] texture:firstTexture.name];
        }
        
        [self applyUniforms];
        
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        glUseProgram(0);
        glBindTexture(GL_TEXTURE_2D, 0);
    }
}

- (void)waitUntilCompleted
{
    glFinish();
}

#pragma mark - utils for subclassing

+ (NSString *)defaultVertexString
{
    return @(GLIDefaultVertexString);
}

- (GLuint)program
{
    if (!_prog) return 0;
    return GLIProgramGetProgram(_prog);
}

- (void)setViewPortWithContentMode:(UIViewContentMode)contentMode inputSize:(CGSize)inputSize
{
    CGRect viewPort = [self.class viewPortRectForContentMode:contentMode
                                                drawableSize:CGSizeMake(self.output.width, self.output.height)
                                                 textureSize:inputSize];
    glViewport(viewPort.origin.x, viewPort.origin.y, viewPort.size.width, viewPort.size.height);
}

- (void)applyVertexAttribute:(NSString *)attribName bytes:(void *)bytes
{
    GLIProgramApplyVertexAttribute(_prog, (char *)attribName.UTF8String, bytes);
}

- (void)setUniform:(NSString *)uniformName bytes:(void *)bytes
{
    GLIProgramSetUniformBytes(_prog, (char *)uniformName.UTF8String, bytes);
}

- (void)setTexture:(NSString *)textureName texture:(GLuint)glTexture
{
    GLIProgramSetUniformBytes(_prog, (char *)textureName.UTF8String, &glTexture);
}

- (void)applyUniforms
{
    GLProgramApplyUniforms(_prog);
}

+ (CGRect)viewPortRectForContentMode:(UIViewContentMode)contentMode drawableSize:(CGSize)drawableSize textureSize:(CGSize)textureSize
{
    CGFloat dW = drawableSize.width;
    CGFloat dH = drawableSize.height;
    CGFloat tW = textureSize.width;
    CGFloat tH = textureSize.height;
    CGFloat vX = 0, vY = 0, vW = tW, vH = tH;
    int texIsWiderThanDrawable = tW / tH > dW / dH;
    switch (contentMode) {
        case UIViewContentModeScaleToFill:
            vW = dW;
            vH = dH;
            break;
        case UIViewContentModeScaleAspectFit:
            vW = texIsWiderThanDrawable ? dW : dH * tW / tH;
            vH = texIsWiderThanDrawable ? dW * tH / tW : dH;
            vX = texIsWiderThanDrawable ? 0 : (dW - vW) / 2.f;
            vY = texIsWiderThanDrawable ? (dH - vH) / 2.f : 0;
            break;
        case UIViewContentModeScaleAspectFill:
            vW = texIsWiderThanDrawable ? dH * tW / tH : dW;
            vH = texIsWiderThanDrawable ? dH : dW * tH / tW;
            vX = texIsWiderThanDrawable ? (dW - vW) / 2.f : 0;
            vY = texIsWiderThanDrawable ? 0 : (dH - vH) / 2.f;
            break;
        case UIViewContentModeCenter:
            vX = (dW - vW) / 2.f;
            vY = (dH - vH) / 2.f;
            break;
        case UIViewContentModeLeft:
            vY = (dH - vH) / 2.f;
            break;
        case UIViewContentModeRight:
            vX = dW - vW;
            vY = (dH - vH) / 2.f;
            break;
        case UIViewContentModeTop:
            vX = (dW - vW) / 2.f;
            vY = dH - vH;
            break;
        case UIViewContentModeBottom:
            vX = (dW - vW) / 2.f;
            break;
        case UIViewContentModeTopLeft:
            vY = dH - vH;
            break;
        case UIViewContentModeTopRight:
            vX = dW - vW;
            vY = dH - vH;
            break;
        case UIViewContentModeBottomLeft:
            break;
        case UIViewContentModeBottomRight:
            vX = dW - vW;
            break;
        default:
            vW = dW;
            vH = dH;
            break;
    }
    return CGRectMake(vX, vY, vW, vH);
}

@end
