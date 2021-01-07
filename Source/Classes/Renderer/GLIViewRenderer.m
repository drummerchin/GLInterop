//
//  GLIViewRenderer.m
//  GLInterop
//
//  Created by Qin Hong on 2020/12/25.
//

#import "GLIViewRenderer.h"
#import <OpenGLES/ES2/gl.h>

static GLfloat const kTexCoordData[] = {
    0.0f, 0.0f,
    1.0f, 0.0f,
    0.0f, 1.0f,
    1.0f, 1.0f
};

static GLfloat const kFlippedTexCoordData[] = {
    0.0f, 1.0f,
    1.0f, 1.0f,
    0.0f, 0.0f,
    1.0f, 0.0f
};

@interface GLIViewRenderer()
{
    GLuint _renderbuffer;
    GLint _surfaceWidth;
    GLint _surfaceHeight;
    UIViewContentMode _contentMode;
}
@end

@implementation GLIViewRenderer

- (void)dealloc
{
    NSCAssert(!_renderbuffer, @"GL objects leaked.");
}

- (void)removeResources
{
    if (_renderbuffer)
    {
        glDeleteRenderbuffers(1, &_renderbuffer);
        _renderbuffer = 0;
    }
    [super removeResources];
}

- (instancetype)init
{
    NSString *fragment = @GLI_SHADER
    (
        precision mediump float;
        varying highp vec2 vTexCoord;
        uniform sampler2D inputTexture;
        void main()
        {
            vec4 color = texture2D(inputTexture, vTexCoord);
            gl_FragColor = color;
        }
    );
    if (self = [super initWithVertex:[self.class defaultVertexString] fragment:fragment])
    {
        glGenRenderbuffers(1, &_renderbuffer);
    }
    return self;
}

- (BOOL)prepareFramebuffer
{
    glBindFramebuffer(_framebuffer.target, _framebuffer.name);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderbuffer);
    glFramebufferRenderbuffer(_framebuffer.target, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderbuffer);
    GLenum status = glCheckFramebufferStatus(_framebuffer.target);
    if (status != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"failed to make complete framebuffer object %x", status);
        return NO;
    }
    [self preprocessFramebuffer];
    return YES;
}

- (void)renderToView:(id<GLIRenderableSurface>)renderableSurface isFlipped:(BOOL)isFlipped
{
    NSParameterAssert(renderableSurface);
    if (!renderableSurface) return;
    
    EAGLContext *context = [EAGLContext currentContext];
    CAEAGLLayer *surface = renderableSurface.eglSurface;
    if (!context || !surface) return;
    
    // update renderbuffer
    if (_surfaceWidth != surface.bounds.size.width * surface.contentsScale
        || _surfaceHeight != surface.bounds.size.height * surface.contentsScale)
    {
        glBindRenderbuffer(GL_RENDERBUFFER, _renderbuffer);
        [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:surface];
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_surfaceWidth);
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_surfaceHeight);
    }
    
    // render contents
    if (![self prepareFramebuffer]) return;
    if (self.program)
    {
        id<GLITexture> firstTexture = [self.inputTextures firstObject];
        glUseProgram(self.program);

        CGRect viewPort = [self.class viewPortRectForContentMode:renderableSurface.drawingContentMode
                                                    drawableSize:CGSizeMake(_surfaceWidth, _surfaceHeight)
                                                     textureSize:CGSizeMake(firstTexture.width, firstTexture.height)];
        glViewport(viewPort.origin.x, viewPort.origin.y, viewPort.size.width, viewPort.size.height);
        
        [self setVertexAttributeToBuffer:@"position" bytes:&(GLfloat[]){
            -1.0, -1.0, 0.0, 1.0,
             1.0, -1.0, 0.0, 1.0,
            -1.0,  1.0, 0.0, 1.0,
             1.0,  1.0, 0.0, 1.0
        } size:sizeof(float) * 16];
        [self setVertexAttributeToBuffer:@"texCoord" bytes:(void *)(isFlipped ? kFlippedTexCoordData : kTexCoordData) size:sizeof(float) * 8];
        [self applyVertexAttributes];
        
        GLITextureSetTexParameters(firstTexture);
        [self setTexture:@"inputTexture" texture:firstTexture.name];
        [self applyUniforms];
        
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        glUseProgram(0);
        glBindTexture(GL_TEXTURE_2D, 0);
    }

    // present to drawable
    glBindRenderbuffer(GL_RENDERBUFFER, _renderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER];
}

@end
