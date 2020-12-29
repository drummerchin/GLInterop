//
//  GLIContext.h
//  GLInterop
//
//  Created by Qin Hong on 5/31/19.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    GLITaskHint_GenericTask = 0,
    GLITaskHint_ContextSpecificTask,
} GLITaskHint;

@interface GLIContext : NSObject

@property (nonatomic, strong, readonly) EAGLContext *glContext;
@property (nonatomic) int debugLevel;

+ (instancetype)sharedContext __deprecated;

- (instancetype)initWithAPI:(EAGLRenderingAPI)api NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithAPI:(EAGLRenderingAPI)api sharegroup:(EAGLSharegroup*)sharegroup NS_DESIGNATED_INITIALIZER;

+ (instancetype)new NS_UNAVAILABLE;

- (void)runTaskWithHint:(GLITaskHint)hint block:(void(^NS_NOESCAPE)(void))block;

@end

NS_ASSUME_NONNULL_END
