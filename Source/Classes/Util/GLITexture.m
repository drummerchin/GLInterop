//
//  GLITexture.m
//  GLInterop
//
//  Created by Qin Hong on 6/25/19.
//

#import "GLITexture.h"
#import <OpenGLES/ES2/gl.h>

static const GLint glValueFromMinFilter(GLIMinFilter minFilter)
{
    GLIMinFilter ret = GL_LINEAR;
    switch (minFilter) {
        case GLIMinFilter_Linear: ret = GL_LINEAR; break;
        case GLIMinFilter_Nearest: ret = GL_NEAREST; break;
        case GLIMinFilter_NearestMipmapNearest: ret = GL_NEAREST_MIPMAP_NEAREST; break;
        case GLIMinFilter_LinearMipmapNearest: ret = GL_LINEAR_MIPMAP_NEAREST; break;
        case GLIMinFilter_NearestMipmapLinear: ret = GL_NEAREST_MIPMAP_LINEAR; break;
        case GLIMinFilter_LinearMipmapLinear: ret = GL_LINEAR_MIPMAP_LINEAR; break;
        default: break;
    }
    return (GLint)ret;
}

static const GLint glValueFromMagFilter(GLIMagFilter magFilter)
{
    return magFilter == GLIMagFilter_Linear ? GL_LINEAR : GL_NEAREST;
}

static const GLint glValueFromAddressMode(GLIAddressMode addressMode)
{
    GLIAddressMode ret = GL_CLAMP_TO_EDGE;
    switch (addressMode)
    {
        case GLIAddressMode_ClampToEdge: ret = GL_CLAMP_TO_EDGE; break;
        case GLIAddressMode_Repeat: ret = GL_REPEAT; break;
        case GLIAddressMode_MirroredRepeat: ret = GL_MIRRORED_REPEAT; break;
        default: break;
    }
    return (GLint)ret;
}

@implementation GLITexture

- (void)dealloc
{
    if (self.deleteTextureWhileDeallocating)
    {
        if (self.name)
        {
            GLuint tex = self.name;
            glDeleteTextures(1, &tex);
        }
    }
}

- (instancetype)init
{
    if (self = [super init])
    {
        self.target = GL_TEXTURE_2D;
        self.name = 0;
        self.minFilter = GLIMinFilter_Linear;
        self.magFilter = GLIMagFilter_Linear;
        self.wrapS = GLIAddressMode_ClampToEdge;
        self.wrapT = GLIAddressMode_ClampToEdge;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    GLITexture *copy = [[self.class allocWithZone:zone] init];
    copy.target = self.target;
    copy.name = self.name;
    copy.width = self.width;
    copy.height = self.height;
    copy.minFilter = self.minFilter;
    copy.magFilter = self.magFilter;
    copy.wrapS = self.wrapS;
    copy.wrapT = self.wrapT;
    return copy;
}

- (void)upload
{
    glBindTexture(self.target, self.name);
    glTexParameteri(self.target, GL_TEXTURE_MIN_FILTER, glValueFromMinFilter(self.minFilter));
    glTexParameteri(self.target, GL_TEXTURE_MAG_FILTER, glValueFromMagFilter(self.magFilter));
    glTexParameteri(self.target, GL_TEXTURE_WRAP_S, glValueFromAddressMode(self.wrapS));
    glTexParameteri(self.target, GL_TEXTURE_WRAP_T, glValueFromAddressMode(self.wrapT));
    glBindTexture(self.target, 0);
}

- (void)setTextureParameters
{
    glBindTexture(self.target, self.name);
    glTexParameteri(self.target, GL_TEXTURE_MIN_FILTER, glValueFromMinFilter(self.minFilter));
    glTexParameteri(self.target, GL_TEXTURE_MAG_FILTER, glValueFromMagFilter(self.magFilter));
    glTexParameteri(self.target, GL_TEXTURE_WRAP_S, glValueFromAddressMode(self.wrapS));
    glTexParameteri(self.target, GL_TEXTURE_WRAP_T, glValueFromAddressMode(self.wrapT));
    glBindTexture(self.target, 0);
}

- (void)setDimensions
{
    glBindTexture(self.target, self.name);
    glTexImage2D(self.target, 0, GL_RGBA, (GLsizei)self.width, (GLsizei)self.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    glBindTexture(self.target, 0);
}

GLI_OVERLOADABLE void GLITextureSetTexParameters(id<GLITexture> textureObj)
{
    GLITextureSetTexParameters(textureObj,
                               GLIMinFilter_Linear,
                               GLIMagFilter_Linear,
                               GLIAddressMode_ClampToEdge,
                               GLIAddressMode_ClampToEdge);
}

GLI_OVERLOADABLE void GLITextureSetTexParameters(id<GLITexture> textureObj, GLIMinFilter minFilter, GLIMagFilter magFilter, GLIAddressMode wrapS, GLIAddressMode wrapT)
{
    glBindTexture(textureObj.target, textureObj.name);
    glTexParameteri(textureObj.target, GL_TEXTURE_MIN_FILTER, glValueFromMinFilter(minFilter));
    glTexParameteri(textureObj.target, GL_TEXTURE_MAG_FILTER, glValueFromMagFilter(magFilter));
    glTexParameteri(textureObj.target, GL_TEXTURE_WRAP_S, glValueFromAddressMode(wrapS));
    glTexParameteri(textureObj.target, GL_TEXTURE_WRAP_T, glValueFromAddressMode(wrapT));
    glBindTexture(textureObj.target, 0);
}

GLITexture *GLITextureNew(GLenum target, GLuint name, size_t width, size_t height)
{
    GLITexture *texture = [GLITexture new];
    texture.target = target;
    texture.name = name;
    texture.width = width;
    texture.height = height;
    return texture;
}

GLITexture *GLITextureNewTexture2D(GLuint name, size_t width, size_t height)
{
    return GLITextureNew(GL_TEXTURE_2D, name, width, height);
}

@end
