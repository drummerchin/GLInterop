//
//  GLIProgram.h
//  GLInterop
//
//  Created by Qin Hong on 6/4/19.
//

#ifndef GLIProgram_h
#define GLIProgram_h

#include "GLIBase.h"
#include <OpenGLES/gltypes.h>

typedef struct GLIProgram * GLIProgramRef;

GLI_EXTERN GLIProgramRef GLIProgramCreateFromSource(const char *vertexString, const char *fragmentString);

GLI_EXTERN void          GLIProgramParseVertexAttrib(GLIProgramRef p);
GLI_EXTERN void          GLIProgramParseUniform(GLIProgramRef p);

/// Apply a vertex attribute with given bytes.
/// Note that these bytes are not buffered by CPU nor GPU, so you're
/// responsible to keep these bytes until they were consumed, especially
/// pay attention to the situation of these bytes created on the stack.
GLI_EXTERN void          GLIProgramApplyVertexAttribute(GLIProgramRef p, char *attributeName, void *bytes) __deprecated;

/// Set a vertex attribute with given bytes and size. The bytes will
/// be buffered by GPU.
GLI_EXTERN void          GLIProgramSetVertexAttributeToBuffer(GLIProgramRef p, char *attributeName, void *bytes, size_t size);

/// Apply all the buffered data to vertex attributes of the program.
GLI_EXTERN void          GLIProgramApplyVertexAttributes(GLIProgramRef p);

GLI_EXTERN void          GLIProgramSetUniformBytes(GLIProgramRef p, char *uniformName, void *bytes);
GLI_EXTERN void          GLIProgramApplyUniforms(GLIProgramRef p);

GLI_EXTERN GLuint        GLIProgramGetProgram(GLIProgramRef p);
GLI_EXTERN int           GLIProgramAddAttribute(GLIProgramRef p, const char *attribName); //return attribute location, if failed return GL_INVALID_INDEX
GLI_EXTERN int           GLIProgramGetAttributeLocation(GLIProgramRef p, const char *attribName); //return GL_INVALID_INDEX if not found
GLI_EXTERN int           GLIProgramLinkAndValidate(GLIProgramRef p); // return 1 if success
GLI_EXTERN int           GLIProgramIsValidate(GLIProgramRef p);
GLI_EXTERN void          GLIProgramUse(GLIProgramRef p);
GLI_EXTERN int           GLIProgramGetUniformLocation(GLIProgramRef p, const char *uniformName);
GLI_EXTERN void          GLIProgramDestroy(GLIProgramRef p);

#endif /* GLIProgram_h */
