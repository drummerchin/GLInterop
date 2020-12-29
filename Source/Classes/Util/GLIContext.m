//
//  GLIContext.m
//  GLInterop
//
//  Created by Qin Hong on 5/31/19.
//

#import "GLIContext.h"
#import <pthread/pthread.h>
#include <OpenGLES/ES2/gl.h>
#import <UIKit/UIKit.h>

@interface GLIContext ()
{
    EAGLContext *_glContext;
    pthread_mutexattr_t _attr;
    pthread_mutex_t _lock;
}

@end

@implementation GLIContext

- (void)dealloc
{
    pthread_mutexattr_destroy(&_attr);
    pthread_mutex_destroy(&_lock);
    
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

/*
- (void)applicationWillResignActive:(NSNotification *)notification
{
    glFinish();
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    glFinish();
}
//*/

- (instancetype)initWithAPI:(EAGLRenderingAPI)api
{
    if (self = [super init])
    {
        _glContext = [[EAGLContext alloc] initWithAPI:api];
        
        pthread_mutexattr_init(&_attr);
        pthread_mutexattr_settype(&_attr, PTHREAD_MUTEX_RECURSIVE);
        pthread_mutex_init(&_lock, &_attr);
    }
    return self;
}

- (instancetype)initWithAPI:(EAGLRenderingAPI)api sharegroup:(EAGLSharegroup *)sharegroup
{
    if (self = [super init])
    {
        _glContext = [[EAGLContext alloc] initWithAPI:api sharegroup:sharegroup];
        
        pthread_mutexattr_init(&_attr);
        pthread_mutexattr_settype(&_attr, PTHREAD_MUTEX_RECURSIVE);
        pthread_mutex_init(&_lock, &_attr);
    }
    return self;
}

- (void)runTaskWithHint:(GLITaskHint)hint block:(void (^NS_NOESCAPE)(void))block
{
    if (hint == GLITaskHint_GenericTask)
    {
        pthread_mutex_lock(&_lock);
        EAGLContext *currentContext = [EAGLContext currentContext];
        if (currentContext != _glContext)
        {
            [EAGLContext setCurrentContext:_glContext];
        }
        if (block)
        {
            block();
        }
        [EAGLContext setCurrentContext:currentContext];
        pthread_mutex_unlock(&_lock);
    }
    else if (hint == GLITaskHint_ContextSpecificTask)
    {
        BOOL isGetLock = pthread_mutex_trylock(&_lock) == 0 ? YES : NO;
        NSAssert(isGetLock, @"Error: task is not context specific.");
        if (isGetLock)
        {
            if ([EAGLContext currentContext] != _glContext)
            {
                [EAGLContext setCurrentContext:_glContext];
            }
            if (block)
            {
                block();
            }
            pthread_mutex_unlock(&_lock);
        }
    }
}


@end
