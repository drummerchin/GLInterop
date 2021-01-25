//
//  GLITexture.h
//  GLInterop
//
//  Created by Qin Hong on 6/21/19.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreGraphics/CoreGraphics.h>
#import <GLInterop/GLIBase.h>
#import <OpenGLES/ES2/gl.h>

NS_ASSUME_NONNULL_BEGIN

@protocol GLITexture <NSObject>

@property (nonatomic, readonly) GLenum target;
@property (nonatomic, readonly) GLuint name;
@property (nonatomic, readonly) size_t width;
@property (nonatomic, readonly) size_t height;
@property (nonatomic, readonly) BOOL isFlipped;

@end

/*!
 @note For npot(non-power-of-two) dimensions texture, the only valid enum is ClampToEdge.
 */
typedef enum : NSUInteger {
    GLIAddressMode_ClampToEdge,
    GLIAddressMode_Repeat,
    GLIAddressMode_MirroredRepeat,
} GLIAddressMode;

/*!
 @note For npot(non-power-of-two) dimensions texture, the valid enum is Linear and Nearest.
 */
typedef enum : NSUInteger {
    GLIMinFilter_Linear,
    GLIMinFilter_Nearest,
    GLIMinFilter_NearestMipmapNearest,
    GLIMinFilter_LinearMipmapNearest,
    GLIMinFilter_NearestMipmapLinear,
    GLIMinFilter_LinearMipmapLinear,
} GLIMinFilter;

typedef enum : NSUInteger {
    GLIMagFilter_Linear,
    GLIMagFilter_Nearest,
} GLIMagFilter;

@class GLITexture;

/// Convenience method to set texture filtering parameters using default value (linear/linear/clampToEdge/clampToEdge).
GLI_EXPORT GLI_OVERLOADABLE void GLITextureSetTexParameters(id<GLITexture> textureObj);

/// Convenience method to set texture filtering parameters.
GLI_EXPORT GLI_OVERLOADABLE void GLITextureSetTexParameters(id<GLITexture> textureObj, GLIMinFilter minFilter, GLIMagFilter magFilter, GLIAddressMode wrapS, GLIAddressMode wrapT);

/// Convenience method to create a GLITexture.
GLI_EXPORT GLI_OVERLOADABLE GLITexture *GLITextureNew(GLenum target, GLuint name, size_t width, size_t height);
GLI_EXPORT GLI_OVERLOADABLE GLITexture *GLITextureNew(GLenum target, GLuint name, size_t width, size_t height, BOOL flipped);

/// Convenience method to create a texture 2d GLITexture.
GLI_EXPORT GLI_OVERLOADABLE GLITexture *GLITextureNewTexture2D(GLuint name, size_t width, size_t height);
GLI_EXPORT GLI_OVERLOADABLE GLITexture *GLITextureNewTexture2D(GLuint name, size_t width, size_t height, BOOL flipped);

/// New a dictionary with given options.
GLI_EXPORT NSDictionary<NSString*, NSNumber*> *GLITextureLoadOptionNew(BOOL premultiplyAlpha, BOOL mipmap, BOOL bottomLeftOrigin, BOOL grayScaleAsAlpha, BOOL sRGB);
GLI_EXPORT NSDictionary<NSString*, NSNumber*> * const GLITextureLoadOptionPremultiply(void);
GLI_EXPORT NSDictionary<NSString*, NSNumber*> * const GLITextureLoadOptionPremultiplyFlipped(void);
GLI_EXPORT NSDictionary<NSString*, NSNumber*> * const GLITextureLoadOptionNonPremultiplyFlipped(void);

/// Synchronously load an image from URL into GLITexture.
GLI_EXPORT GLI_OVERLOADABLE id<GLITexture> GLITextureLoadFromURL(NSURL *URL, NSDictionary<NSString*, NSNumber*> * __nullable options, NSError * __nullable * __nullable outError);
GLI_EXPORT GLI_OVERLOADABLE id<GLITexture> GLITextureLoadFromURL(NSURL *URL, NSDictionary<NSString*, NSNumber*> * __nullable options, NSError * __nullable * __nullable outError, BOOL isFlipped);

/// Synchronously load an image form file path into GLITexture.
GLI_EXPORT GLI_OVERLOADABLE id<GLITexture> GLITextureLoadFromFilePath(NSString *filePath, NSDictionary<NSString*, NSNumber*> * __nullable options, NSError * __nullable * __nullable outError);
GLI_EXPORT GLI_OVERLOADABLE id<GLITexture> GLITextureLoadFromFilePath(NSString *filePath, NSDictionary<NSString*, NSNumber*> * __nullable options, NSError * __nullable * __nullable outError, BOOL isFlipped);

/// Synchronously load an image form data.
GLI_EXPORT GLI_OVERLOADABLE id<GLITexture> GLITextureLoadFromData(NSData *data, NSDictionary<NSString*, NSNumber*> * __nullable options, NSError * __nullable * __nullable outError);
GLI_EXPORT GLI_OVERLOADABLE id<GLITexture> GLITextureLoadFromData(NSData *data, NSDictionary<NSString*, NSNumber*> * __nullable options, NSError * __nullable * __nullable outError, BOOL isFlipped);

/// Synchronously load an image form data.
GLI_EXPORT GLI_OVERLOADABLE id<GLITexture> GLITextureLoadFromCGImage(CGImageRef image, NSDictionary<NSString*, NSNumber*> * __nullable options, NSError * __nullable * __nullable outError);
GLI_EXPORT GLI_OVERLOADABLE id<GLITexture> GLITextureLoadFromCGImage(CGImageRef image, NSDictionary<NSString*, NSNumber*> * __nullable options, NSError * __nullable * __nullable outError, BOOL isFlipped);

@interface GLITexture : NSObject <GLITexture, NSCopying>

/*!
 @abstract The target of the texture.
 */
@property (nonatomic) GLenum target;

/*!
 @abstract The name of the texture.
 */
@property (nonatomic) GLuint name;

/*!
 @abstract The width of the texture.
 */
@property (nonatomic) size_t width;

/*!
 @abstract The height of the texture.
 */
@property (nonatomic) size_t height;

/*!
 @abstract A boolean value that indicates whether the content of texture is vertical flipped.
 */
@property (nonatomic) BOOL isFlipped;

/*!
 @abstract Default is GLIMinFilter_Linear.
 @discussion To avoid performance loss, the value is not from param query of texture.
 */
@property (nonatomic) GLIMinFilter minFilter;

/*!
 @abstract Default is GLIMinFilter_Linear.
 @discussion To avoid performance loss, the value is not from param query of texture.
 */
@property (nonatomic) GLIMagFilter magFilter;

/*!
 @abstract Default is GLIAddressMode_ClampToEdge.
 @discussion To avoid performance loss, the value is not from param query of texture.
 */
@property (nonatomic) GLIAddressMode wrapS;

/*!
 @abstract Default is GLIAddressMode_ClampToEdge.
 @discussion To avoid performance loss, the value is not from param query of texture.
 */
@property (nonatomic) GLIAddressMode wrapT;

/*!
 @abstract A boolean value that indicate whether delete the texture when the receiver is deallocating. Default is NO.
 */
@property (nonatomic) BOOL deleteTextureWhileDeallocating __deprecated;

- (instancetype)init NS_DESIGNATED_INITIALIZER;

/*!
 @method        upload
 @abstract      Upload texture to GPU with the given min/mag filter and adress mode.
 */
- (void)upload __attribute__((deprecated("Use 'setTextureParameters' instead.")));

/*!
 @method        setTextureParameters
 @abstract      Set texture parameters using minFilter, magFilter, wrapS and wrapT.
 */
- (void)setTextureParameters;

/*!
 @abstract For new created texture, set the texture's width, height and pixel format (GL_RGBA).
 */
- (void)setDimensions;

@end

NS_ASSUME_NONNULL_END
