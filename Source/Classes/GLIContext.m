//
//  GLIContext.m
//  GLInterop
//
//  Created by Qin Hong on 5/31/19.
//

#import "GLIContext.h"
#import <pthread/pthread.h>
#include <OpenGLES/ES2/gl.h>

@interface GLIContext ()
{
    EAGLContext *_glContext;
}

@end

@implementation GLIContext

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

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

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];

    }
    return self;
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    glFinish();
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    glFinish();
}

@end
