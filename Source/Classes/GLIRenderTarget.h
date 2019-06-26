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
#import <OpenGLES/EAGL.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLIRenderTarget : NSObject

/*!
 @abstract The width of the render target.
 */
@property (nonatomic) NSUInteger width;

/*!
 @abstract The height of the render target.
 */
@property (nonatomic) NSUInteger height;

/*!
 @abstract The GL texture that represents the render target.
 */
@property (nonatomic, readonly) GLuint glTexture;

/*!
 @abstract The pixel buffer that represents the render target.
 */
@property (nonatomic, readonly) CVPixelBufferRef pixelBuffer;

/*!
 @method initWithWithCVPixelBuffer:
 @abstract Initialize instance from a given pixel buffer.
 */
- (instancetype)initWithWithCVPixelBuffer:(CVPixelBufferRef)pixelBuffer NS_DESIGNATED_INITIALIZER;

/*!
 @method initWithSize:
 @abstract Initialize instance with a given size.
 */
- (instancetype)initWithSize:(CGSize)size NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
