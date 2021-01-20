//
//  GLITransform.m
//  GLInterop
//
//  Created by Qin Hong on 5/31/19.
//

#import "GLITransform.h"
#import <OpenGLES/ES2/gl.h>
#include "GLIMatrixUtil.h"

const char * GLITransformVertexString = GLI_SHADER(
    precision highp float;
    attribute vec4 position;
    attribute vec2 texCoord;
    uniform mat4 mvpMatrix;
    varying vec2 vTexCoord;
    void main()
    {
        gl_Position = mvpMatrix * position;
        vTexCoord = texCoord.xy;
    }
);

const char * GLITransformFragmentString = GLI_SHADER(
    precision mediump float;
    varying highp vec2 vTexCoord;
    uniform sampler2D inputTexture;
    void main()
    {
        gl_FragColor = texture2D(inputTexture, vTexCoord);
    }
);

@implementation GLITransform

- (instancetype)init
{
    if (self = [super initWithVertex:@(GLITransformVertexString) fragment:@(GLITransformFragmentString)])
    {
        self.transform = CATransform3DIdentity;
    }
    return self;
}

- (void)render
{
    if (![self prepareFramebuffer]) return;
    if (self.program)
    {
        id<GLITexture> firstTexture = [self.inputTextures firstObject];
        
        glUseProgram(self.program);
        
        [self setViewPortWithContentMode:UIViewContentModeCenter inputSize:CGSizeMake(firstTexture.width, firstTexture.height)];
        
        float halfWidth = firstTexture.width / 2.f;
        float halfHeight = firstTexture.height / 2.f;
        [self setVertexAttributeToBuffer:@"position" bytes:&(GLfloat[]){
            -1.0 * halfWidth, -1.0 * halfHeight, 0.0, 1.0,
            1.0 * halfWidth,  -1.0 * halfHeight, 0.0, 1.0,
            -1.0 * halfWidth,  1.0 * halfHeight, 0.0, 1.0,
            1.0 * halfWidth,   1.0 * halfHeight, 0.0, 1.0
        } size:sizeof(float) * 16];
        
        const GLfloat * texCoord = firstTexture.isFlipped ? kGLIQuad_TexCoordFlipped : kGLIQuad_TexCoord;
        [self setVertexAttributeToBuffer:@"texCoord" bytes:(void *)texCoord size:sizeof(float) * 8];
        
        [self applyVertexAttributes];
        
        float transformMatrix[16];
        GLIMatrixLoadIdentity(transformMatrix);
        float orthoMatrix[16];
        float mvpMatrix[16];
        GLIMatrixLoadFromColumns(transformMatrix,
                                 _transform.m11, _transform.m21, _transform.m31, _transform.m41,
                                 _transform.m12, _transform.m22, _transform.m32, _transform.m42,
                                 _transform.m13, _transform.m23, _transform.m33, _transform.m43,
                                 _transform.m14, _transform.m24, _transform.m34, _transform.m44);
        float top = self.output.texture.isFlipped ? -halfHeight : halfHeight;
        float bottom = self.output.texture.isFlipped ? halfHeight : -halfHeight;
        GLIMatrixLoadOrthographic(orthoMatrix, -halfWidth, halfWidth, bottom, top, -halfWidth, halfWidth);
        GLIMatrixMultiply(mvpMatrix, orthoMatrix, transformMatrix);
        [self setUniform:@"mvpMatrix" bytes:mvpMatrix];
        
        GLITextureSetTexParameters(firstTexture);
        [self setTexture:@"inputTexture" texture:firstTexture.name];
        [self applyUniforms];
        
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        glUseProgram(0);
        glBindTexture(GL_TEXTURE_2D, 0);
    }
}

@end
