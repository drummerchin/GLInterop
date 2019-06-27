//
//  GLIRenderer.h
//  GLInterop
//
//  Created by Qin Hong on 6/3/19.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/gltypes.h>
#import "GLIRenderTarget.h"
#import "GLITexture.h"

NS_ASSUME_NONNULL_BEGIN

// stringify shader source
#define GLI_SHADER(shader) #shader

/*!
 @class     GLIRenderer
 @abstract  An renderer that used to render GL contents to an interoperable render target (aka *GLIRenderTarget*).
 */
@interface GLIRenderer : NSObject

/*!
 @property clearColor
 @abstarct The clear color to be rendered.
 */
@property (nonatomic) UIColor *clearColor;

/*!
 @property inputTextures
 @abstract The input textures to be processed. The element of the array conforms GLITexture protocol.
 */
@property (nonatomic) NSArray<id<GLITexture>> *inputTextures;

/*!
 @property output
 @abstract The output of the rendering.
 */
@property (nonatomic) __kindof GLIRenderTarget *output;

/*!
 @method    initWithVertex:fragment:
 @abstract  Initializes instance from given vertex and fragment shader source.
 */
- (instancetype)initWithVertex:(NSString * _Nullable)vertex fragment:(NSString * _Nullable)fragment NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/*!
 @method    render:
 @abstract  Render contents. The default implementation considers the situation as below:
            1) Vertex shader has a `position` and a `texCoord` attribute.
            2) Vertex shader have no uniforms such as projection matrix or model matrix etc.
            3) The textures of the fragment shader named `inputTexture + N`, N represents the index of the texture. The first texture named `inputTexture`.
            If the shader not conforms these rules, subclass must override the method.
 */
- (void)render;

/*!
 @method        waitUntilCompleted
 @abstract      Blocks execution of the current thread until the rendering is completed.
 @discussion    This operation will implictly enforce the GPU to execute all the commands called before.
 */
- (void)waitUntilCompleted;

@end

@interface GLIRenderer (GLIRendererProtectedMethods)

+ (NSString *)defaultVertexString;
- (GLuint)program;
- (BOOL)prepareFramebuffer;
- (void)setViewPortWithContentMode:(UIViewContentMode)contentMode inputSize:(CGSize)inputSize;
- (void)applyVertexAttribute:(NSString *)attribName bytes:(void *)bytes;
- (void)setUniform:(NSString *)uniformName bytes:(void *)bytes;
- (void)setTexture:(NSString *)textureName texture:(GLuint)glTexture;
- (void)applyUniforms;

@end

#define GLI_RENDERER_INITIALIZER_UNAVAILABLE \
- (instancetype)initWithVertex:(NSString * _Nullable)vertex fragment:(NSString * _Nullable)fragment NS_UNAVAILABLE;

NS_ASSUME_NONNULL_END
