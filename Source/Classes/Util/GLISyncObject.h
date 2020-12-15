//
//  GLISyncObject.h
//  GLInterop
//
//  Created by Qin Hong on 2020/10/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLISyncObject : NSObject

/// GPU waits for fence.
- (void)wait;

/// CPU wait for fence.
- (void)clientWait;

/// CPU wait for fence.
/// return YES if GPU has finished command in time, otherwise return NO.
- (BOOL)clientWaitWithTimeout:(uint64_t)timeout;

/// Update fence for next rendering.
- (void)update;

@end

NS_ASSUME_NONNULL_END
