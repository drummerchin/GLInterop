//
//  GLIMetalRenderTarget.h
//  GLInterop
//
//  Created by Qin Hong on 6/26/19.
//

#import "GLIRenderTarget.h"
#import <Metal/Metal.h>

NS_ASSUME_NONNULL_BEGIN

@class GLIMetalTextureCache;

@interface GLIMetalRenderTarget : GLIRenderTarget

/*!
 @property mtlTexture
 @abstract The Metal texture that represents the render target. The pixel format is MTLPixelFormatBGRA8Unorm.
 */
@property (nonatomic, strong, readonly, nullable) id<MTLTexture> mtlTexture;

/*!
 @property mtlTextureCache
 @abstract The Metal texture cache that the render target used.
 */
@property (nonatomic, strong, readonly) GLIMetalTextureCache *mtlTextureCache;

/*!
 @method initWithWithCVPixelBuffer:glTextureCache:mtlTextureCache:
 @abstract Initialize instance from a given pixel buffer, GLITextureCache and GLIMetalTextureCache.
 */
- (instancetype)initWithWithCVPixelBuffer:(CVPixelBufferRef)pixelBuffer glTextureCache:(GLITextureCache *)glTextureCache mtlTextureCache:(GLIMetalTextureCache *)mtlTextureCache NS_DESIGNATED_INITIALIZER;

/*!
 @method initWithSize:glTextureCache:mtlTextureCache:
 @abstract Initialize instance from a given size, a shared GLITextureCache object and a shared GLIMetalTextureCache object.
 */
- (instancetype)initWithSize:(CGSize)size glTextureCache:(GLITextureCache *)glTextureCache mtlTextureCache:(GLIMetalTextureCache *)mtlTextureCache  NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
