//
//  GLIMetalRenderTarget.h
//  GLInterop
//
//  Created by Qin Hong on 6/26/19.
//

#import "GLIRenderTarget.h"
#import <Metal/Metal.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLIMetalRenderTarget : GLIRenderTarget

/*!
 @property mtlTexture
 @abstract The Metal texture that represents the render target. The pixel format is MTLPixelFormatBGRA8Unorm.
 */
@property (nonatomic, strong, nullable) id<MTLTexture> mtlTexture;

@end

NS_ASSUME_NONNULL_END
