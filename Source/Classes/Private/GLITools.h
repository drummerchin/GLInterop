//
//  GLITools.h
//  GLInterop
//
//  Created by Qin Hong on 5/29/19.
//

#include <OpenGLES/gltypes.h>

#pragma mark - texture

struct CETexture
{
    GLenum target; // GL_TEXTURE_2D, GL_TEXTURE_EXTERNAL_OES, etc.
    GLuint name;
    size_t width;
    size_t height;
};

typedef struct CETexture *CETextureRef;

CE_EXTERN CETextureRef CETextureCreate(GLenum target, GLuint name, size_t width, size_t height);

#pragma mark - program

typedef struct _CEGLProgram * _CEGLProgramRef;

CE_EXTERN _CEGLProgramRef _CEGLProgramCreateFromSource(const char *vertexString, const char *fragmentString);
CE_EXTERN GLuint          _CEGLProgramGetProgram(_CEGLProgramRef p);
CE_EXTERN int             _CEGLProgramAddAttribute(_CEGLProgramRef p, const char *attribName); //return attribute location, if failed return GL_INVALID_INDEX
CE_EXTERN int             _CEGLProgramGetAttributeLocation(_CEGLProgramRef p, const char *attribName); //return GL_INVALID_INDEX if not found
CE_EXTERN int             _CEGLProgramLinkAndValidate(_CEGLProgramRef p); // return 1 if success
CE_EXTERN int             _CEGLProgramIsValidate(_CEGLProgramRef p);
CE_EXTERN void            _CEGLProgramUse(_CEGLProgramRef p);
CE_EXTERN int             _CEGLProgramGetUniformLocation(_CEGLProgramRef p, const char *uniformName);
CE_EXTERN void            _CEGLProgramDestroy(_CEGLProgramRef p);


struct CEFramebuffer
{
    GLenum target; // GL_FRAMEBUFFER, GL_FRAMEBUFFER_EXT, etc.
    GLuint name;
};

struct CEFilter
{
    // base
    CEFilterType type;
    uint8_t repeatCount;
    size_t outputWidth;
    size_t outputHeight;
    
    struct CEFramebuffer framebuffer;
    
    _CEGLProgramRef prog;
    int positionAttribLocation;
    int texCoordAttribLocation;
    
    GLuint positionVertexBuffer;
    GLuint texCoordVertexBuffer;
    
    GLint  mvpMatrixUniformLocation;
    GLint  inputTextureUniformLocation;
    GLint  inputTexture2UniformLocation;
    
    struct CETexture input;
    struct CETexture input2;
    struct CETexture output;
    
    int isExtOutput;
    
    // action support
    int isActionPaused;
    struct CEFilterAction action;
    
    // callbacks
    void (* willApplyCallback)(struct CEFilter *f, time_t currentTime);
    void (* shouldSetUniformsCallback)(struct CEFilter *f);
    void (* didApplyCallback)(struct CEFilter *f, time_t currentTime);
};


#pragma mark - program

typedef struct _CEGLProgram * _CEGLProgramRef;

CE_EXTERN _CEGLProgramRef _CEGLProgramCreateFromSource(const char *vertexString, const char *fragmentString);
CE_EXTERN GLuint          _CEGLProgramGetProgram(_CEGLProgramRef p);
CE_EXTERN int             _CEGLProgramAddAttribute(_CEGLProgramRef p, const char *attribName); //return attribute location, if failed return GL_INVALID_INDEX
CE_EXTERN int             _CEGLProgramGetAttributeLocation(_CEGLProgramRef p, const char *attribName); //return GL_INVALID_INDEX if not found
CE_EXTERN int             _CEGLProgramLinkAndValidate(_CEGLProgramRef p); // return 1 if success
CE_EXTERN int             _CEGLProgramIsValidate(_CEGLProgramRef p);
CE_EXTERN void            _CEGLProgramUse(_CEGLProgramRef p);
CE_EXTERN int             _CEGLProgramGetUniformLocation(_CEGLProgramRef p, const char *uniformName);
CE_EXTERN void            _CEGLProgramDestroy(_CEGLProgramRef p);


