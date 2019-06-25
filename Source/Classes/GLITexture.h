//
//  GLITexture.h
//  GLInterop
//
//  Created by Qin Hong on 6/21/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol GLITexture <NSObject>

@property (nonatomic, readonly) GLenum target;
@property (nonatomic, readonly) GLuint name;
@property (nonatomic, readonly) size_t width;
@property (nonatomic, readonly) size_t height;

@end

@interface GLITexture : NSObject <GLITexture>

@property (nonatomic) GLenum target;
@property (nonatomic) GLuint name;
@property (nonatomic) size_t width;
@property (nonatomic) size_t height;

- (instancetype)init NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
