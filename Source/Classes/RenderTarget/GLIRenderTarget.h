//
//  GLIRenderTarget.h
//  GLInterop
//
//  Created by Qin Hong on 5/31/19.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import <OpenGLES/gltypes.h>
#import "GLIRenderTargetProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class GLITextureCache;

@interface GLIRenderTarget : NSObject <GLIRenderTarget>

/*!
 @abstract The GL texture that represents the render target.
 */
@property (nonatomic, readonly) GLuint glTexture;

/*!
 @abstract The pixel buffer that represents the render target.
 */
@property (nonatomic, readonly) CVPixelBufferRef pixelBuffer CV_RETURNS_RETAINED_PARAMETER;

/*!
 @abstract The GL texture cache that the render target used.
 */
@property (nonatomic, strong, readonly) GLITextureCache *glTextureCache;

/*!
 @method initWithWithCVPixelBuffer:glTextureCache:
 @abstract Initialize instance from a given pixel buffer and a given GLITextureCache.
 */
- (instancetype)initWithWithCVPixelBuffer:(CVPixelBufferRef)pixelBuffer glTextureCache:(GLITextureCache *)textureCache NS_DESIGNATED_INITIALIZER;

/*!
 @method initWithWithCVPixelBuffer:
 @abstract Initialize instance from a given pixel buffer and a shared GLITextureCache.
 */
- (instancetype)initWithWithCVPixelBuffer:(CVPixelBufferRef)pixelBuffer __attribute__((deprecated("Use 'initWithWithCVPixelBuffer:glTextureCache:' instead.")));

/*!
 @method initWithSize:glTextureCache:
 @abstract Initialize instance from a given size and a given GLITextureCache.
 */
- (instancetype)initWithSize:(CGSize)size glTextureCache:(GLITextureCache *)textureCache NS_DESIGNATED_INITIALIZER;

/*!
 @method initWithSize:
 @abstract Initialize instance from a given size a shared GLITextureCache.
 */
- (instancetype)initWithSize:(CGSize)size __attribute__((deprecated("Use 'initWithSize:glTextureCache:' instead.")));

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
