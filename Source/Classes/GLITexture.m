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
    return ret;
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
    return ret;
}

@implementation GLITexture

- (instancetype)init
{
    if (self = [super init])
    {
        _minFilter = GLIMinFilter_Linear;
        _magFilter = GLIMagFilter_Linear;
        _wrapS = GLIAddressMode_ClampToEdge;
        _wrapT = GLIAddressMode_ClampToEdge;
    }
    return self;
}

- (void)upload
{
    glBindTexture(_target, _name);
    glTexParameteri(_target, GL_TEXTURE_MIN_FILTER, glValueFromMinFilter(_minFilter));
    glTexParameteri(_target, GL_TEXTURE_MAG_FILTER, glValueFromMagFilter(_magFilter));
    glTexParameteri(_target, GL_TEXTURE_WRAP_S, glValueFromAddressMode(_wrapS));
    glTexParameteri(_target, GL_TEXTURE_WRAP_T, glValueFromAddressMode(_wrapT));
    glBindTexture(_target, 0);
}

@end
