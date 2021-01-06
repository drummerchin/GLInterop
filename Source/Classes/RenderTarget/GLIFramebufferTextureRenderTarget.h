//
//  GLIFramebufferTextureRenderTarget.h
//  GLInterop
//
//  Created by Qin Hong on 5/29/20.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GLIRenderTargetProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface GLIFramebufferTextureRenderTarget : NSObject <GLIRenderTarget>

/*!
 @abstract The GL texture that represents the render target.
 */
@property (nonatomic, readonly) GLuint glTexture;

/*!
 @abstarct The clear color to be rendered.
 */
@property (nonatomic) UIColor *clearColor;

- (instancetype)initWithWidth:(NSUInteger)width height:(NSUInteger)height NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/*!
 @abstract Prepare framebuffer that bind to a texture and set clear color.
 */
- (void)prepareFramebuffer;

/*!
 @abstract Remove GL resources.
 */
- (void)removeResources;

@end

NS_ASSUME_NONNULL_END
