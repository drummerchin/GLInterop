//
//  GLIContext.h
//  GLInterop
//
//  Created by Qin Hong on 5/31/19.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLIContext : NSObject

@property (nonatomic, strong, readonly) EAGLContext *glContext;

+ (instancetype)sharedContext;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
