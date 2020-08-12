//
//  GLIProgramDefines.h
//  GLInterop
//
//  Created by Qin Hong on 6/11/20.
//  Copyright © 2020 Qin Hong. All rights reserved.
//

#ifndef GLIProgramDefines_h
#define GLIProgramDefines_h

typedef union
{
    float f;
    float f2[2];
    float f3[3];
    float f4[4];
    int   i;
    int   i2[2];
    int   i3[3];
    int   i4[4];
    float m2x2[4];
    float m3x3[9];
    float m4x4[16];
} GLIUniformValue;

struct GLIVertexAttrib
{
    GLuint index;
    GLint size;
    GLenum type;
    char *name;
    void *external;
};

struct GLIUniform
{
    GLint location;
    GLint size;
    GLenum type;
    char *name;
    GLIUniformValue value;
};

#endif /* GLIProgramDefines_h */
