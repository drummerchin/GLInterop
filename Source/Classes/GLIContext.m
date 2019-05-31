//
//  GLIContext.m
//  GLInterop
//
//  Created by Qin Hong on 5/31/19.
//

#import "GLIContext.h"

@interface GLIContext ()
{
    
}

@end

@implementation GLIContext

+ (instancetype)sharedContext
{
    static GLIContext *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GLIContext alloc] initPrivate];
    });
    return instance;
}

- (instancetype)initPrivate
{
    if (self = [super init])
    {
        _glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    }
    return self;
}

@end
