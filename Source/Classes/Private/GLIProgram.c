//
//  GLIProgram.c
//  GLInterop
//
//  Created by Qin Hong on 6/4/19.
//

#include "GLIProgram.h"
#include <OpenGLES/ES2/gl.h>
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include <string.h>

#define GLI_ATTRIB_ARRAY_MAX_SIZE 1024

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
};

struct GLIUniform
{
    GLint location;
    GLint size;
    GLenum type;
    char *name;
    GLIUniformValue value;
};

struct GLIProgram {
    GLuint prog;
    GLuint vert;
    GLuint frag;
    int hasLinkAndValidate;
    size_t addedAttribCount;
    char *attribArray;
    
    struct GLIVertexAttrib *vertexAttribs;
    int vertexAttribCount;
    
    struct GLIUniform *uniforms;
    int uniformCount;
};

GLuint GLIShaderCreate(GLenum shaderType, const char * shaderStr)
{
    GLuint shader = glCreateShader(shaderType);
    const GLchar *source = (GLchar *)shaderStr;
    glShaderSource(shader, 1, &source, NULL);
    glCompileShader(shader);
    
    GLint status;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &status);
    if (status != GL_TRUE)
    {
        GLint logLength;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &logLength);
        if (logLength > 0)
        {
            GLchar *log = (GLchar *)calloc(1, logLength);
            glGetShaderInfoLog(shader, logLength, &logLength, log);
            //printf("%s shader compile log:\n%s", shaderType==GL_VERTEX_SHADER? "Vertex":"Fragment", log);
            free(log);
        }
    }
    
    return shader;
}

GLIProgramRef GLIProgramCreateFromSource(const char *vertexString, const char *fragmentString)
{
    GLIProgramRef p = (GLIProgramRef)calloc(1, sizeof(struct GLIProgram));
    p->vert = GLIShaderCreate(GL_VERTEX_SHADER, vertexString);
    p->frag = GLIShaderCreate(GL_FRAGMENT_SHADER, fragmentString);
    p->prog = glCreateProgram();
    glAttachShader(p->prog, p->vert);
    glAttachShader(p->prog, p->frag);
    return p;
}

GLuint GLIProgramGetProgram(GLIProgramRef p)
{
    return p->prog;
}

int GLIProgramGetAttributeLocation(GLIProgramRef p, const char *attribName)
{
    return glGetAttribLocation(p->prog, attribName);
}

int GLIProgramAddAttribute(GLIProgramRef p, const char *attribName)
{
    if (p->attribArray == NULL)
    {
        p->addedAttribCount = 0;
        p->attribArray = (char *)calloc(GLI_ATTRIB_ARRAY_MAX_SIZE, sizeof(char));
    }
    int index = GLIProgramGetAttributeLocation(p, attribName);
    if (index == -1)
    {
        char *dst = p->attribArray;
        size_t len = strlen(dst);
        while (len > 0)
        {
            dst += len + 1;
            len = strlen(dst);
        }
        strcpy(dst, attribName);
        glBindAttribLocation(p->prog, (GLint)p->addedAttribCount, (GLchar *)attribName);
        return (int)p->addedAttribCount++;
    }
    else
    {
        printf("Failed to add attribute '%s'", attribName);
        return -1;
    }
}

int GLIProgramLinkAndValidate(GLIProgramRef p)
{
    assert(p);
    if (!p) return 0;
    glLinkProgram(p->prog);
    glValidateProgram(p->prog);
    
    GLint status;
    glGetProgramiv(p->prog, GL_LINK_STATUS, &status);
    if (status != GL_TRUE)
    {
        GLint logLength;
        glGetProgramiv(p->prog, GL_INFO_LOG_LENGTH, &logLength);
        if (logLength > 0)
        {
            GLchar *log = (GLchar *)calloc(1, logLength);
            glGetProgramInfoLog(p->prog, logLength, &logLength, log);
            printf("Program validate log: %s \n", log);
            free(log);
        }
        glDeleteProgram(p->prog);
        p->prog = 0;
        p->hasLinkAndValidate = 0;
        return p->hasLinkAndValidate;
    }
    glDeleteShader(p->vert);
    glDeleteShader(p->frag);
    p->vert = 0;
    p->frag = 0;
    p->hasLinkAndValidate = 1;
        
    return p->hasLinkAndValidate;
}

int GLIProgramIsValidate(GLIProgramRef p)
{
    return p->hasLinkAndValidate;
}

void GLIProgramParseVertexAttrib(GLIProgramRef p)
{
    GLint activeAttributes;
    glGetProgramiv(p->prog, GL_ACTIVE_ATTRIBUTES, &activeAttributes);
    GLint length;
    glGetProgramiv(p->prog, GL_ACTIVE_ATTRIBUTE_MAX_LENGTH, &length);
    if (activeAttributes > 0 && length > 0)
    {
        p->vertexAttribs = calloc(activeAttributes, sizeof(struct GLIVertexAttrib));
        for (int i = 0; i < activeAttributes; i++)
        {
            struct GLIVertexAttrib vertexAttrib;
            vertexAttrib.name = calloc(length, sizeof(char));
            glGetActiveAttrib(p->prog, i, length, NULL, &vertexAttrib.size, &vertexAttrib.type, vertexAttrib.name);
            vertexAttrib.index = glGetAttribLocation(p->prog, vertexAttrib.name);
            p->vertexAttribs[i] = vertexAttrib;
            //printf("[vertex attribute] index: %d, name: %s, size: %d, type: %x\n", vertexAttrib.index, vertexAttrib.name, vertexAttrib.size, vertexAttrib.type);
        }
        p->vertexAttribCount = activeAttributes;
    }
}

void GLIProgramParseUniform(GLIProgramRef p)
{
    GLint activeUniforms;
    glGetProgramiv(p->prog, GL_ACTIVE_UNIFORMS, &activeUniforms);
    GLint length;
    glGetProgramiv(p->prog, GL_ACTIVE_UNIFORM_MAX_LENGTH, &length);
    if (activeUniforms > 0 && length > 0)
    {
        p->uniforms = calloc(activeUniforms, sizeof(struct GLIUniform));
        for (int i = 0; i < activeUniforms; i++)
        {
            struct GLIUniform uniform;
            uniform.name = calloc(length, sizeof(char));
            glGetActiveUniform(p->prog, i, length, NULL, &uniform.size, &uniform.type, uniform.name);
            //TODO: uniform.name remove '[]'
            //uniform.name
            uniform.location = glGetUniformLocation(p->prog, uniform.name);
            p->uniforms[i] = uniform;
            //printf("[uniform] location: %d, name: %s, size: %d, type: %x\n", uniform.location, uniform.name, uniform.size, uniform.type);

        }
        p->uniformCount = activeUniforms;
    }
}


void GLIProgramUse(GLIProgramRef p)
{
    assert(p->prog);
    glUseProgram(p->prog);
}

int GLIProgramGetUniformLocation(GLIProgramRef p, const char *uniformName)
{
    return glGetUniformLocation(p->prog, (GLchar *)uniformName);
}

struct GLIVertexAttrib *GLIProgramGetVertexAttribute(GLIProgramRef p, char *attributeName)
{
    for (int i = 0; i < p->vertexAttribCount; i++)
    {
        struct GLIVertexAttrib *attrib = &p->vertexAttribs[i];
        if (strcmp(attributeName, attrib->name) == 0)
        {
            return attrib;
        }
    }
    return NULL;
}

struct GLIUniform *GLIProgramGetUniform(GLIProgramRef p, char *uniformName)
{
    for (int i = 0; i < p->uniformCount; i++)
    {
        struct GLIUniform *uniform = &p->uniforms[i];
        if (strcmp(uniformName, uniform->name) == 0)
        {
            return uniform;
        }
    }
    return NULL;
}

void GLIProgramApplyVertexAttribute(GLIProgramRef p, char *attributeName, void *bytes)
{
    struct GLIVertexAttrib *vertexAttrib = GLIProgramGetVertexAttribute(p, attributeName);
    if (vertexAttrib == NULL) return;
    
    glEnableVertexAttribArray(vertexAttrib->index);
    switch (vertexAttrib->type) {
        case GL_FLOAT_VEC2: glVertexAttribPointer(vertexAttrib->index, 2, GL_FLOAT, GL_FALSE, 0, bytes); break;
        case GL_FLOAT_VEC3: glVertexAttribPointer(vertexAttrib->index, 3, GL_FLOAT, GL_FALSE, 0, bytes); break;
        case GL_FLOAT_VEC4: glVertexAttribPointer(vertexAttrib->index, 4, GL_FLOAT, GL_FALSE, 0, bytes); break;
        case GL_INT_VEC2: glVertexAttribPointer(vertexAttrib->index, 2, GL_INT, GL_FALSE, 0, bytes); break;
        case GL_INT_VEC3: glVertexAttribPointer(vertexAttrib->index, 3, GL_INT, GL_FALSE, 0, bytes); break;
        case GL_INT_VEC4: glVertexAttribPointer(vertexAttrib->index, 4, GL_INT, GL_FALSE, 0, bytes); break;
        default: break;
    }
}

void GLIProgramSetUniformBytes(GLIProgramRef p, char *uniformName, void *bytes)
{
    struct GLIUniform *uniform = GLIProgramGetUniform(p, uniformName);
    if (uniform == NULL) return;

    switch (uniform->type) {
        case GL_FLOAT:      memcpy(&uniform->value.f, bytes, sizeof(float)); break;
        case GL_FLOAT_VEC2: memcpy(uniform->value.f2, bytes, sizeof(float)*2); break;
        case GL_FLOAT_VEC3: memcpy(uniform->value.f3, bytes, sizeof(float)*3); break;
        case GL_FLOAT_VEC4: memcpy(uniform->value.f4, bytes, sizeof(float)*4); break;
        case GL_BOOL:
        case GL_INT:        memcpy(&uniform->value.i, bytes, sizeof(int)); break;
        case GL_BOOL_VEC2:
        case GL_INT_VEC2:   memcpy(uniform->value.i2, bytes, sizeof(int)*2); break;
        case GL_BOOL_VEC3:
        case GL_INT_VEC3:   memcpy(uniform->value.i3, bytes, sizeof(int)*3); break;
        case GL_BOOL_VEC4:
        case GL_INT_VEC4:   memcpy(uniform->value.i4, bytes, sizeof(int)*4); break;
        case GL_FLOAT_MAT2: memcpy(uniform->value.m2x2, bytes, sizeof(float)*4); break;
        case GL_FLOAT_MAT3: memcpy(uniform->value.m3x3, bytes, sizeof(float)*9); break;
        case GL_FLOAT_MAT4: memcpy(uniform->value.m4x4, bytes, sizeof(float)*16); break;
        case GL_SAMPLER_2D: memcpy(&uniform->value.i, bytes, sizeof(int)); break;
        //case GL_SAMPLER_CUBE: break;
        default: break;
    }
}

void GLProgramApplyUniforms(GLIProgramRef p)
{
    if (p == NULL) return;
    int texLoc = 0;
    for (int i = 0; i < p->uniformCount; i++)
    {
        struct GLIUniform uniform = p->uniforms[i];
        switch (uniform.type) {
            case GL_FLOAT:      glUniform1fv(uniform.location, uniform.size, &uniform.value.f); break;
            case GL_FLOAT_VEC2: glUniform1fv(uniform.location, uniform.size, uniform.value.f2); break;
            case GL_FLOAT_VEC3: glUniform1fv(uniform.location, uniform.size, uniform.value.f3); break;
            case GL_FLOAT_VEC4: glUniform1fv(uniform.location, uniform.size, uniform.value.f4); break;
            case GL_BOOL:
            case GL_INT:        glUniform1iv(uniform.location, uniform.size, &uniform.value.i); break;
            case GL_BOOL_VEC2:
            case GL_INT_VEC2:   glUniform1iv(uniform.location, uniform.size, uniform.value.i2); break;
            case GL_BOOL_VEC3:
            case GL_INT_VEC3:   glUniform1iv(uniform.location, uniform.size, uniform.value.i3); break;
            case GL_BOOL_VEC4:
            case GL_INT_VEC4:   glUniform1iv(uniform.location, uniform.size, uniform.value.i4); break;
            case GL_FLOAT_MAT2: glUniformMatrix2fv(uniform.location, uniform.size, GL_FALSE, uniform.value.m2x2); break;
            case GL_FLOAT_MAT3: glUniformMatrix3fv(uniform.location, uniform.size, GL_FALSE, uniform.value.m3x3); break;
            case GL_FLOAT_MAT4: glUniformMatrix4fv(uniform.location, uniform.size, GL_FALSE, uniform.value.m4x4); break;
            case GL_SAMPLER_2D:
                glActiveTexture(GL_TEXTURE0 + texLoc);
                glBindTexture(GL_TEXTURE_2D, uniform.value.i);
                glUniform1i(uniform.location, texLoc);
                texLoc ++;
                break;
            //case GL_SAMPLER_CUBE: break;
            default: break;
        }
    }
}

void GLIProgramDestroy(GLIProgramRef p)
{
    if (p)
    {
        if (p->attribArray)
        {
            free(p->attribArray);
            p->attribArray = NULL;
        }
        if (p->vert)
        {
            glDeleteShader(p->vert);
            p->vert = 0;
        }
        if (p->frag)
        {
            glDeleteShader(p->frag);
            p->frag = 0;
        }
        if (p->prog)
        {
            glDeleteProgram(p->prog);
            p->prog = 0;
        }
        if (p->vertexAttribs)
        {
            free(p->vertexAttribs);
        }
        if (p->uniforms)
        {
            free(p->uniforms);
        }
        free(p);
    }
}
