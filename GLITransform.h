//
//  GLITransform.h
//  GLInterop
//
//  Created by qinhong on 5/31/19.
//

#import <Foundation/Foundation.h>
#import "GLIRenderTarget.h"

NS_ASSUME_NONNULL_BEGIN

@interface GLITransform : NSObject

@property (nonatomic) CATransform3D transform;
@property (nonatomic, strong, readonly) GLIRenderTarget *renderTarget;

- (instancetype)init;

@end

NS_ASSUME_NONNULL_END
