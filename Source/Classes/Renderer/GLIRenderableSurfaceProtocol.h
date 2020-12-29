//
//  GLIRenderableSurfaceProtocol.h
//  GLInterop
//
//  Created by Qin Hong on 2020/12/25.
//

#ifndef GLIRenderableSurfaceProtocol_h
#define GLIRenderableSurfaceProtocol_h

#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol GLIRenderableSurface <NSObject>

@property (nonatomic, readonly) CAEAGLLayer *eglSurface;
@property (nonatomic, readonly) UIViewContentMode drawingContentMode;

@end

NS_ASSUME_NONNULL_END

#endif /* GLIRenderableSurfaceProtocol_h */
