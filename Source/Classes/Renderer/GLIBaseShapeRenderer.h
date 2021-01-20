//
//  GLIBaseShapeRenderer.h
//  GLInterop
//
//  Created by Qin Hong on 6/5/20.
//  Copyright © 2020 Qin Hong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GLITexture.h"
#import "GLIRenderTargetProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface GLIBaseShapeRenderer : NSObject

/*!
 @abstract Remove GL resources.
 */
- (void)removeResources;

/*!
 @abstract Begin render to the render target.
 */
- (void)beginRender:(id<GLIRenderTarget>)renderTarget;

/*!
 @abstract Clean the current content using clear color.
 */
- (void)cleanWithClearColor:(UIColor *)clearColor;

/*!
 @abstract End render to the render target.
 */
- (void)endRender;

/*!
 @abstract Render a quad with given texture to the render target, and specifies it's transform, anchor point and intensity.
 @note The origin of the anchorPoint is the top-left corner.
 */
- (void)renderQuadWithTexture:(id<GLITexture>)texture transform:(CATransform3D)transform anchorPoint:(CGPoint)anchorPoint intensity:(CGFloat)intensity;

/*!
 @abstract Render a quad with given color to the render target, and specifies it's size, transform, anchor point and intensity.
 @note The origin of the anchorPoint is the top-left corner.
 */
- (void)renderQuadWithColor:(UIColor *)color size:(CGSize)size transform:(CATransform3D)transform anchorPoint:(CGPoint)anchorPoint intensity:(CGFloat)intensity;

/*!
 @abstract Render points and specifies it's color and point size.
 @note The origin of the points is the bottom-left corner.
*/
- (void)renderPoint2D:(CGPoint *)points count:(NSUInteger)count color:(UIColor *)color pointSize:(CGFloat)pointSize intensity:(CGFloat)intensity;

/*!
 @abstract Render line strip and specifies it's color and whether is closure.
 @note The origin of the points is the bottom-left corner.
*/
- (void)renderLineStrip2D:(CGPoint *)points count:(NSInteger)pointCount closePath:(BOOL)isClosure color:(UIColor *)color intensity:(CGFloat)intensity;

/*!
 @abstract Render triangle strip with a given color.
 @note The origin of the points is the bottom-left corner.
*/
- (void)renderTriangleStrip2D:(CGPoint *)points count:(NSInteger)pointCount color:(UIColor *)color intensity:(CGFloat)intensity;

@end

typedef enum : NSUInteger {
    GLIFillModeScaleToFill,
    GLIFillModeAspectFit,
    GLIFillModeAspectFill,
} GLIFillMode;

@interface GLIBaseShapeRenderer (Utils)

/*!
 @abstract Get a transform by position, rotation and scaling.
 */
+ (CATransform3D)transformWithPosition:(CGPoint)position rotation:(CGFloat)rotate scale:(CGFloat)scale;

/*!
 @abstract Get a transform that the size can be fill in rect using the given fill mode.
 */
+ (CATransform3D)transformWithSize:(CGSize)size fillInRect:(CGRect)rect mode:(GLIFillMode)mode;

@end

NS_ASSUME_NONNULL_END
