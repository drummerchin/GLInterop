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
    //pthread_mutex_t _lock;
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
//        pthread_mutexattr_t attr;
//        pthread_mutexattr_init(&attr);
//        pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE);
//        pthread_mutex_init(&_lock, &attr);

        _glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];

    }
    return self;
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    //[self lock];
    glFinish();
    //[self unlock];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    //[self lock];
    glFinish();
    //[self unlock];
}

/*
- (void)lock
{
    pthread_mutex_lock(&_lock);
}

- (int)tryLock
{
    return pthread_mutex_trylock(&_lock);
}

- (void)unlock
{
    pthread_mutex_unlock(&_lock);
}
//*/

@end
