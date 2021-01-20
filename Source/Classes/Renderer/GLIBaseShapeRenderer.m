//
//  GLIBaseShapeRenderer.m
//  GLInterop
//
//  Created by Qin Hong on 6/5/20.
//  Copyright © 2020 Qin Hong. All rights reserved.
//

#import "GLIBaseShapeRenderer.h"
#import "GLIProgram.h"
#import "GLIRenderer.h"
#import "GLIMatrixUtil.h"
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>

@import simd;

#define GLI_LOCK_TYPE                dispatch_semaphore_t
#define GLI_LOCK_DEF(LOCK)           dispatch_semaphore_t LOCK
#define GLI_LOCK_INIT(LOCK)          LOCK = dispatch_semaphore_create(1)
#define GLI_LOCK(LOCK)               dispatch_semaphore_wait(LOCK, DISPATCH_TIME_FOREVER)
#define GLI_TRYLOCK(LOCK)            (dispatch_semaphore_wait(LOCK, DISPATCH_TIME_NOW) == 0 ? YES : NO)
#define GLI_UNLOCK(LOCK)             dispatch_semaphore_signal(LOCK)

__attribute__((__overloadable__)) matrix_float4x4 TransformMakeTranslate(vector_float3 t)
{
    matrix_float4x4 M = matrix_identity_float4x4;
    M.columns[3].xyz = t;
    return M;
}

__attribute__((__overloadable__)) matrix_float4x4 TransformMakeTranslate(float x, float y, float z)
{
    return TransformMakeTranslate((vector_float3){x, y, z});
}

matrix_float4x4 TransformMake(CATransform3D t)
{
    return (matrix_float4x4){
        (vector_float4){t.m11, t.m12, t.m13, t.m14},
        (vector_float4){t.m21, t.m22, t.m23, t.m24},
        (vector_float4){t.m31, t.m32, t.m33, t.m34},
        (vector_float4){t.m41, t.m42, t.m43, t.m44},
    };
}

matrix_float4x4 Orthographic(float left, float right, float bottom, float top, float near, float far)
{
    float sLength = 1.0f / (right - left);
    float sHeight = 1.0f / (top   - bottom);
    float sDepth  = 1.0f / (far   - near);
    
    vector_float4 P, Q, R, S;
    
    P.x = 2.0f * sLength;
    P.y = 0.0f;
    P.z = 0.0f;
    P.w = 0.0f;
    
    Q.x = 0.0f;
    Q.y = 2.0f * sHeight;
    Q.z = 0.0f;
    Q.w = 0.0f;
    
    R.x = 0.0f;
    R.y = 0.0f;
    R.z = sDepth;
    R.w = 0.0f;
    
    S.x = -sLength * (left + right);
    S.y = -sHeight * (top + bottom);
    S.z = -sDepth  * near;
    S.w =  1.0f;
    
    return (matrix_float4x4){P, Q, R, S};
}

@interface GLIBaseShapeRenderer ()
{
    GLI_LOCK_DEF(_drawLock);
    id<GLIRenderTarget> _renderTarget;
    BOOL _preverseFramebuffer;
    
    struct GLIFramebuffer _framebuffer;
}

@property (nonatomic) GLIProgramRef textureQuadProgram;
@property (nonatomic) GLIProgramRef colorQuadProgram;
@property (nonatomic) GLIProgramRef pointProgram;

@end

@implementation GLIBaseShapeRenderer

- (void)dealloc
{
    NSCAssert(!_textureQuadProgram
              && !_colorQuadProgram
              && !_pointProgram,
              @"GL objects leaked.");
}

- (void)removeResources
{
    if (_textureQuadProgram)
    {
        GLIProgramDestroy(_textureQuadProgram);
        _textureQuadProgram = NULL;
    }
    if (_colorQuadProgram)
    {
        GLIProgramDestroy(_colorQuadProgram);
        _colorQuadProgram = NULL;
    }
    if (_pointProgram)
    {
        GLIProgramDestroy(_pointProgram);
        _pointProgram = NULL;
    }
}

- (instancetype)init
{
    if (self = [super init])
    {
        GLI_LOCK_INIT(_drawLock);
    }
    return self;
}

- (void)beginRender:(id<GLIRenderTarget>)renderTarget
{
    NSParameterAssert(renderTarget);
    GLI_LOCK(_drawLock);
    
    _renderTarget = renderTarget;
    _preverseFramebuffer = YES;
    
    [self prepareFramebuffer];
    
    glEnable(GL_BLEND);
    glBlendEquationSeparate(GL_FUNC_ADD, GL_FUNC_ADD);
    glBlendFuncSeparate(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_ONE, GL_ONE_MINUS_SRC_ALPHA);

    glViewport(0, 0, (GLsizei)_renderTarget.width, (GLsizei)_renderTarget.height);
}

- (void)prepareFramebuffer
{
    if (!_framebuffer.name)
    {
        _framebuffer.target = GL_FRAMEBUFFER;
        glGenFramebuffers(1, &_framebuffer.name);
    }
    
    glBindFramebuffer(_framebuffer.target, _framebuffer.name);
    glFramebufferTexture2D(_framebuffer.target, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _renderTarget.glTexture, 0);
    GLenum status = glCheckFramebufferStatus(_framebuffer.target);
    if (status != GL_FRAMEBUFFER_COMPLETE)
    {
        printf("failed to make complete framebuffer object %x\n", status);
    }
}
    
- (void)cleanWithClearColor:(UIColor *)clearColor
{
    CGFloat clearColorR = 0, clearColorG = 0, clearColorB = 0, clearColorA = 0;
    [clearColor getRed:&clearColorR green:&clearColorG blue:&clearColorB alpha:&clearColorA];
    glClearColor(clearColorR, clearColorG, clearColorB, clearColorA);
    glClear(GL_COLOR_BUFFER_BIT);
}

- (void)endRender
{
    glDisable(GL_BLEND);
    _renderTarget = nil;
    GLI_UNLOCK(_drawLock);
}

#pragma mark - lazy loading

- (GLIProgramRef)textureQuadProgram
{
    if (!_textureQuadProgram)
    {
        NSString *vertexString = @GLI_SHADER(
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
        NSString *fragmentString = @GLI_SHADER(
            precision mediump float;
            varying highp vec2 vTexCoord;
            uniform sampler2D inputTexture;
            uniform float intensity;
            void main()
            {
                lowp vec4 srcColor = texture2D(inputTexture, vTexCoord);
                gl_FragColor = vec4(srcColor.rgb, srcColor.a * intensity);
            }
        );
        const char *vertex = [vertexString cStringUsingEncoding:NSASCIIStringEncoding];
        const char *fragment = [fragmentString cStringUsingEncoding:NSASCIIStringEncoding];
        _textureQuadProgram = GLIProgramCreateFromSource(vertex, fragment);
        int isValid = GLIProgramLinkAndValidate(_textureQuadProgram);
        NSAssert(isValid, @"GLProgram error.");
        if (!isValid)
        {
            _textureQuadProgram = nil;
        }
        
        GLIProgramParseVertexAttrib(_textureQuadProgram);
        GLIProgramParseUniform(_textureQuadProgram);
    }
    return _textureQuadProgram;
}

- (GLIProgramRef)colorQuadProgram
{
    if (!_colorQuadProgram)
    {
        NSString *vertexString = @GLI_SHADER(
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
        NSString *fragmentString = @GLI_SHADER(
            precision mediump float;
            varying highp vec2 vTexCoord;
            uniform lowp vec4 color;
            uniform float intensity;
            void main()
            {
                gl_FragColor = vec4(color.rgb, color.a * intensity);
            }
        );
        const char *vertex = [vertexString cStringUsingEncoding:NSASCIIStringEncoding];
        const char *fragment = [fragmentString cStringUsingEncoding:NSASCIIStringEncoding];
        _colorQuadProgram = GLIProgramCreateFromSource(vertex, fragment);
        int isValid = GLIProgramLinkAndValidate(_colorQuadProgram);
        NSAssert(isValid, @"GLProgram error.");
        if (!isValid)
        {
            _colorQuadProgram = nil;
        }
        
        GLIProgramParseVertexAttrib(_colorQuadProgram);
        GLIProgramParseUniform(_colorQuadProgram);
    }
    return _colorQuadProgram;
}

- (GLIProgramRef)pointProgram
{
    if (!_pointProgram)
    {
        NSString *vertexString = @GLI_SHADER(
            precision highp float;
            attribute vec2 position;
            uniform mat4 mvpMatrix;
            uniform lowp float pointSize;
            void main()
            {
                gl_Position = mvpMatrix * vec4(position, 0, 1);
                gl_PointSize = pointSize;
            }
        );
        NSString *fragmentString = @GLI_SHADER(
            precision mediump float;
            uniform lowp vec4 color;
            uniform float intensity;
            void main()
            {
                gl_FragColor = vec4(color.rgb, color.a * intensity);
            }
        );
        const char *vertex = [vertexString cStringUsingEncoding:NSASCIIStringEncoding];
        const char *fragment = [fragmentString cStringUsingEncoding:NSASCIIStringEncoding];
        _pointProgram = GLIProgramCreateFromSource(vertex, fragment);
        int isValid = GLIProgramLinkAndValidate(_pointProgram);
        NSAssert(isValid, @"GLProgram error.");
        if (!isValid)
        {
            _pointProgram = nil;
        }
        
        GLIProgramParseVertexAttrib(_pointProgram);
        GLIProgramParseUniform(_pointProgram);
    }
    return _pointProgram;
}

#pragma mark - render texture quad

- (void)renderQuadWithTexture:(id<GLITexture>)texture
{
    [self renderQuadWithTexture:texture transform:CATransform3DIdentity anchorPoint:CGPointMake(0.5, 0.5) intensity:1.0];
}

- (void)renderQuadWithTexture:(id<GLITexture>)texture transform:(CATransform3D)transform
{
    [self renderQuadWithTexture:texture transform:transform anchorPoint:CGPointMake(0.5, 0.5) intensity:1.0];
}

- (void)renderQuadWithTexture:(id<GLITexture>)texture transform:(CATransform3D)transform anchorPoint:(CGPoint)anchorPoint
{
    [self renderQuadWithTexture:texture transform:transform anchorPoint:anchorPoint intensity:1.0];
}

- (void)renderQuadWithTexture:(id<GLITexture>)texture transform:(CATransform3D)transform anchorPoint:(CGPoint)anchorPoint intensity:(CGFloat)intensity
{
    // adjust coordinate
    anchorPoint.y = 1.0 - anchorPoint.y;
    
    GLIProgramUse(self.textureQuadProgram);
    
    float halfW = texture.width / 2.f;
    float halfH = texture.height / 2.f;
    GLfloat positions[] = {
        -1.0 * halfW, -1.0 * halfH, 0.0, 1.0,
         1.0 * halfW, -1.0 * halfH, 0.0, 1.0,
        -1.0 * halfW,  1.0 * halfH, 0.0, 1.0,
         1.0 * halfW,  1.0 * halfH, 0.0, 1.0
    };
    
    float targetWidth = _renderTarget.width;
    float targetHeight = _renderTarget.height;
    
    vector_float2 mixPos = vector_mix((vector_float2){-halfW, -halfH},
                                      (vector_float2){halfW, halfH},
                                      (vector_float2){anchorPoint.x, anchorPoint.y});
    matrix_float4x4 moveFromCenter = TransformMakeTranslate(mixPos.x, mixPos.y, 0.f);
    matrix_float4x4 moveToCenter = TransformMakeTranslate(-mixPos.x, -mixPos.y, 0.f);
    matrix_float4x4 transformMatrix = TransformMake(transform);
    matrix_float4x4 transformOp = matrix_multiply(moveFromCenter, matrix_multiply(transformMatrix, moveToCenter));
    float top = _renderTarget.texture.isFlipped ? 0 : targetHeight;
    float bottom = _renderTarget.texture.isFlipped ? targetHeight : 0;
    matrix_float4x4 projectionMatrix = Orthographic(0, targetWidth, bottom, top, -targetWidth, targetWidth);
    matrix_float4x4 m = matrix_multiply(projectionMatrix, transformOp);
    float mvpMatrix[16];
    GLIMatrixLoadFromColumns(mvpMatrix,
                          m.columns[0].x, m.columns[1].x, m.columns[2].x, m.columns[3].x,
                          m.columns[0].y, m.columns[1].y, m.columns[2].y, m.columns[3].y,
                          m.columns[0].z, m.columns[1].z, m.columns[2].z, m.columns[3].z,
                          m.columns[0].w, m.columns[1].w, m.columns[2].w, m.columns[3].w);
        
    GLIProgramSetVertexAttributeToBuffer(self.textureQuadProgram, "position", positions, sizeof(float) * 16);
    GLIProgramSetVertexAttributeToBuffer(self.textureQuadProgram, "texCoord", (void *)(texture.isFlipped ? kGLIQuad_TexCoordFlipped : kGLIQuad_TexCoord), sizeof(float) * 8);
    GLIProgramApplyVertexAttributes(self.textureQuadProgram);
    
    GLIProgramSetUniformBytes(self.textureQuadProgram, "mvpMatrix", mvpMatrix);
    GLuint tex = texture.name;
    GLITextureSetTexParameters(texture);
    GLIProgramSetUniformBytes(self.textureQuadProgram, "inputTexture", &tex);
    float uniformIntensity = (float)intensity;
    GLIProgramSetUniformBytes(self.textureQuadProgram, "intensity", &uniformIntensity);
    GLIProgramApplyUniforms(self.textureQuadProgram);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glBindTexture(GL_TEXTURE_2D, 0);
    glUseProgram(0);
}

#pragma mark - color quad

- (void)renderQuadWithColor:(UIColor *)color size:(CGSize)size transform:(CATransform3D)transform anchorPoint:(CGPoint)anchorPoint intensity:(CGFloat)intensity
{
    // adjust coordinate
    anchorPoint.y = 1.0 - anchorPoint.y;
    
    GLIProgramUse(self.colorQuadProgram);
    
    float halfW = size.width / 2.f;
    float halfH = size.height / 2.f;
    GLfloat positions[] = {
        -1.0 * halfW, -1.0 * halfH, 0.0, 1.0,
         1.0 * halfW, -1.0 * halfH, 0.0, 1.0,
        -1.0 * halfW,  1.0 * halfH, 0.0, 1.0,
         1.0 * halfW,  1.0 * halfH, 0.0, 1.0
    };
    
    float targetWidth = _renderTarget.width;
    float targetHeight = _renderTarget.height;
    
    vector_float2 mixPos = vector_mix((vector_float2){-halfW, -halfH},
                                      (vector_float2){halfW, halfH},
                                      (vector_float2){anchorPoint.x, anchorPoint.y});
    matrix_float4x4 moveFromCenter = TransformMakeTranslate(mixPos.x, mixPos.y, 0.f);
    matrix_float4x4 moveToCenter = TransformMakeTranslate(-mixPos.x, -mixPos.y, 0.f);
    matrix_float4x4 transformMatrix = TransformMake(transform);
    matrix_float4x4 transformOp = matrix_multiply(moveFromCenter, matrix_multiply(transformMatrix, moveToCenter));
    float top = _renderTarget.texture.isFlipped ? 0 : targetHeight;
    float bottom = _renderTarget.texture.isFlipped ? targetHeight : 0;
    matrix_float4x4 projectionMatrix = Orthographic(0, targetWidth, bottom, top, -targetWidth, targetWidth);
    matrix_float4x4 m = matrix_multiply(projectionMatrix, transformOp);
    float mvpMatrix[16];
    GLIMatrixLoadFromColumns(mvpMatrix,
                          m.columns[0].x, m.columns[1].x, m.columns[2].x, m.columns[3].x,
                          m.columns[0].y, m.columns[1].y, m.columns[2].y, m.columns[3].y,
                          m.columns[0].z, m.columns[1].z, m.columns[2].z, m.columns[3].z,
                          m.columns[0].w, m.columns[1].w, m.columns[2].w, m.columns[3].w);
        
    GLIProgramSetVertexAttributeToBuffer(self.colorQuadProgram, "position", positions, sizeof(float) * 16);
    GLIProgramSetVertexAttributeToBuffer(self.colorQuadProgram, "texCoord", (void *)kGLIQuad_TexCoord, sizeof(float) * 8);
    GLIProgramApplyVertexAttributes(self.colorQuadProgram);

    GLIProgramSetUniformBytes(self.colorQuadProgram, "mvpMatrix", mvpMatrix);
    
    CGFloat r, g, b, a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    float colorUniform[] = {r, g, b, a};
    GLIProgramSetUniformBytes(self.colorQuadProgram, "color", colorUniform);

    float uniformIntensity = (float)intensity;
    GLIProgramSetUniformBytes(self.colorQuadProgram, "intensity", &uniformIntensity);
    GLIProgramApplyUniforms(self.colorQuadProgram);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glUseProgram(0);
}

#pragma mark - render point 2d

- (void)renderPoint2D:(CGPoint *)points count:(NSUInteger)count color:(UIColor *)color pointSize:(CGFloat)pointSize intensity:(CGFloat)intensity
{
    [self renderPrimitive:GL_POINTS vertices:points count:count color:color pointSize:pointSize intensity:intensity];
}

#pragma mark - render line strip 2d

- (void)renderLineStrip2D:(CGPoint *)points count:(NSInteger)count closePath:(BOOL)isClosure color:(UIColor *)color intensity:(CGFloat)intensity
{
    [self renderPrimitive:(isClosure ? GL_LINE_LOOP : GL_LINE_STRIP) vertices:points count:count color:color pointSize:0.0 intensity:intensity];
}

#pragma mark - render triangle strip 2d

- (void)renderTriangleStrip2D:(CGPoint *)points count:(NSInteger)pointCount color:(UIColor *)color intensity:(CGFloat)intensity
{
    [self renderPrimitive:GL_TRIANGLE_STRIP vertices:points count:pointCount color:color pointSize:0.0 intensity:intensity];
}

#pragma mark - draw primitives

- (void)renderPrimitive:(GLuint)primitive vertices:(CGPoint *)points count:(NSUInteger)count color:(UIColor *)color pointSize:(CGFloat)pointSize intensity:(CGFloat)intensity
{
    GLIProgramUse(self.pointProgram);

    vector_float2 *vertices2d = calloc(count, sizeof(vector_float2));
    for (int i = 0; i < count; i++)
    {
        CGPoint p = points[i];
        vertices2d[i] = (vector_float2){p.x, p.y};
    }
    
    float targetWidth = _renderTarget.width;
    float targetHeight = _renderTarget.height;

    float top = _renderTarget.texture.isFlipped ? 0 : targetHeight;
    float bottom = _renderTarget.texture.isFlipped ? targetHeight : 0;
    matrix_float4x4 m = Orthographic(0, targetWidth, bottom, top, -targetWidth, targetWidth);
    float mvpMatrix[16];
    GLIMatrixLoadFromColumns(mvpMatrix,
                          m.columns[0].x, m.columns[1].x, m.columns[2].x, m.columns[3].x,
                          m.columns[0].y, m.columns[1].y, m.columns[2].y, m.columns[3].y,
                          m.columns[0].z, m.columns[1].z, m.columns[2].z, m.columns[3].z,
                          m.columns[0].w, m.columns[1].w, m.columns[2].w, m.columns[3].w);

    GLIProgramSetVertexAttributeToBuffer(self.pointProgram, "position", vertices2d, sizeof(vector_float2) * count);
    GLIProgramApplyVertexAttributes(self.pointProgram);

    GLIProgramSetUniformBytes(self.pointProgram, "mvpMatrix", mvpMatrix);

    CGFloat r, g, b, a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    float colorUniform[] = {r, g, b, a};
    GLIProgramSetUniformBytes(self.pointProgram, "color", colorUniform);

    float pointSizeUniform = pointSize;
    GLIProgramSetUniformBytes(self.pointProgram, "pointSize", &pointSizeUniform);
    float intensityUniform = intensity;
    GLIProgramSetUniformBytes(self.pointProgram, "intensity", &intensityUniform);

    GLIProgramApplyUniforms(self.pointProgram);

    glDrawArrays(primitive, 0, (GLsizei)count);
    glUseProgram(0);
    free(vertices2d);
}

#pragma mark - utils

+ (CATransform3D)transformWithPosition:(CGPoint)position rotation:(CGFloat)rotate scale:(CGFloat)scale
{
    CATransform3D t = CATransform3DMakeTranslation(position.x, position.y, 0);
    t = CATransform3DRotate(t, rotate / 180.f * M_PI, 0, 0, 1);
    t = CATransform3DScale(t, scale, scale, 0);
    return t;
}

+ (CATransform3D)transformWithSize:(CGSize)size fillInRect:(CGRect)rect mode:(GLIFillMode)mode
{
    CGFloat w = size.width;
    CGFloat h = size.height;
    CGFloat rw = CGRectGetWidth(rect);
    CGFloat rh = CGRectGetHeight(rect);
    if (mode == GLIFillModeScaleToFill)
    {
        CATransform3D t = CATransform3DMakeTranslation(rw/2.f, rh/2.f, 0);
        t = CATransform3DScale(t, rw/w, rh/h, 1);
        return t;
    }
    else
    {
        CGFloat scale = 1.f;
        if (mode == GLIFillModeAspectFit)
        {
            scale = rw/rh < w/h ? (rw / w) : (rh / h);
        }
        else if (mode == GLIFillModeAspectFill)
        {
            scale = rw/rh < w/h ? (rh / h ) : (rw / w);
        }
        CGPoint position = CGPointMake(rw/2.f, rh/2.f);
        return [self.class transformWithPosition:position rotation:0 scale:scale];
    }
}

@end
