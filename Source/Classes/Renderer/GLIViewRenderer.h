//
//  GLIViewRenderer.h
//  GLInterop
//
//  Created by Qin Hong on 2020/12/25.
//

#import "GLIRenderer.h"
#import "GLIRenderableSurfaceProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface GLIViewRenderer : GLIRenderer

@property (nonatomic) id<GLIRenderTarget> output NS_UNAVAILABLE;

- (instancetype)init NS_DESIGNATED_INITIALIZER;

- (void)renderToView:(id<GLIRenderableSurface>)renderableSurface isFlipped:(BOOL)isFlipped __deprecated;
- (void)renderToView:(id<GLIRenderableSurface>)renderableSurface;

GLI_RENDERER_INITIALIZER_UNAVAILABLE

@end

NS_ASSUME_NONNULL_END
