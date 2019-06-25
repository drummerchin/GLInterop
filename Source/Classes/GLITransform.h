//
//  GLITransform.h
//  GLInterop
//
//  Created by Qin Hong on 5/31/19.
//

#import <Foundation/Foundation.h>
#import "GLIRenderer.h"

NS_ASSUME_NONNULL_BEGIN

@interface GLITransform : GLIRenderer

/*!
 @abstract The transform that applied to the render contents.
 */
@property (nonatomic) CATransform3D transform;

- (instancetype)init NS_DESIGNATED_INITIALIZER;

GLI_RENDERER_INITIALIZER_UNAVAILABLE

@end

NS_ASSUME_NONNULL_END
