//
//  GLITextureRenderTarget.h
//  GLInterop
//
//  Created by Qin Hong on 5/30/20.
//

#import <Foundation/Foundation.h>
#import "GLIRenderTargetProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface GLITextureRenderTarget : NSObject <GLIRenderTarget>

/*!
 @abstract The GL texture that represents the render target.
 */
@property (nonatomic, readwrite) GLuint glTexture;

/*!
 @abstract The width of the render target.
 */
@property (nonatomic) NSUInteger width;

/*!
 @abstract The height of the render target.
 */
@property (nonatomic) NSUInteger height;

/*!
 @abstract A boolean value that indicates whether the content of texture is vertical flipped.
 */
@property (nonatomic) BOOL isFlipped;

@end

NS_ASSUME_NONNULL_END
