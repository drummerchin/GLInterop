//
//  GLISyncObject.m
//  GLInterop
//
//  Created by Qin Hong on 2020/10/23.
//

#import "GLISyncObject.h"
#import <OpenGLES/ES2/glext.h>

@interface GLISyncObject ()
{
    GLsync _sync;
}

@end

@implementation GLISyncObject

- (void)dealloc
{
    NSCAssert(!_sync, @"GL objects leaked.");
}

- (void)removeResources
{
    if (_sync)
    {
        glDeleteSyncAPPLE(_sync);
        _sync = 0;
    }
}

- (instancetype)init
{
    if (self = [super init])
    {
        _sync = glFenceSyncAPPLE(GL_SYNC_GPU_COMMANDS_COMPLETE_APPLE, 0);
    }
    return self;
}

- (void)wait
{
    glFlush();
    glWaitSyncAPPLE(_sync, 0, GL_TIMEOUT_IGNORED_APPLE);
}

- (void)clientWait
{
    glClientWaitSyncAPPLE(_sync, GL_SYNC_FLUSH_COMMANDS_BIT_APPLE, GL_TIMEOUT_IGNORED_APPLE);
}

- (BOOL)clientWaitWithTimeout:(uint64_t)timeout
{
    GLenum ret = glClientWaitSyncAPPLE(_sync, GL_SYNC_FLUSH_COMMANDS_BIT_APPLE, timeout);
    return (ret == GL_ALREADY_SIGNALED_APPLE
             || ret == GL_CONDITION_SATISFIED_APPLE) ? YES : NO;
}

- (void)update
{
    if (_sync)
    {
        glDeleteSyncAPPLE(_sync);
    }
    _sync = glFenceSyncAPPLE(GL_SYNC_GPU_COMMANDS_COMPLETE_APPLE, 0);
}

@end
