//
//  GLIRenderTargetProtocol.h
//  GLInterop
//
//  Created by Qin Hong on 5/29/20.
//

#ifndef GLIRenderTargetProtocol_h
#define GLIRenderTargetProtocol_h

#import <CoreVideo/CoreVideo.h>

NS_ASSUME_NONNULL_BEGIN

@protocol GLIRenderTarget <NSObject>

@required

/*!
 @abstract The width of the render target.
 */
@property (nonatomic, readonly) NSUInteger width;

/*!
 @abstract The height of the render target.
 */
@property (nonatomic, readonly) NSUInteger height;

@optional

/*!
 @abstract The pixel buffer that represents the render target.
 */
@property (nonatomic, readonly) CVPixelBufferRef pixelBuffer CV_RETURNS_RETAINED_PARAMETER;

/*!
 @abstract The GL texture that represents the render target.
 */
@property (nonatomic, readonly) GLuint glTexture;

/*!
 @abstract The Metal texture that represents the render target.
 */
@property (nonatomic, strong, readonly, nullable) id<MTLTexture> mtlTexture;

@end

NS_ASSUME_NONNULL_END

#endif /* GLIRenderTargetProtocol_h */
