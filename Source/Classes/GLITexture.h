//
//  GLITexture.h
//  GLInterop
//
//  Created by Qin Hong on 6/21/19.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>

NS_ASSUME_NONNULL_BEGIN

@protocol GLITexture <NSObject>

@property (nonatomic, readonly) GLenum target;
@property (nonatomic, readonly) GLuint name;
@property (nonatomic, readonly) size_t width;
@property (nonatomic, readonly) size_t height;

@end

typedef enum : NSUInteger {
    GLIAddressMode_ClampToEdge,
    GLIAddressMode_Repeat,
    GLIAddressMode_MirroredRepeat,
} GLIAddressMode;

typedef enum : NSUInteger {
    GLIMinFilter_Linear,
    GLIMinFilter_Nearest,
    GLIMinFilter_NearestMipmapNearest,
    GLIMinFilter_LinearMipmapNearest,
    GLIMinFilter_NearestMipmapLinear,
    GLIMinFilter_LinearMipmapLinear,
} GLIMinFilter;

typedef enum : NSUInteger {
    GLIMagFilter_Linear,
    GLIMagFilter_Nearest,
} GLIMagFilter;

@interface GLITexture : NSObject <GLITexture>

/*!
 @abstract The target of the texture.
 */
@property (nonatomic) GLenum target;

/*!
 @abstract The name of the texture.
 */
@property (nonatomic) GLuint name;

/*!
 @abstract The width of the texture.
 */
@property (nonatomic) size_t width;

/*!
 @abstract The height of the texture.
 */
@property (nonatomic) size_t height;

/*!
 @abstract Default is GLIMinFilter_Linear.
 */
@property (nonatomic) GLIMinFilter minFilter;

/*!
 @abstract Default is GLIMinFilter_Linear.
 */
@property (nonatomic) GLIMagFilter magFilter;

/*!
 @abstract Default is GLIAddressMode_ClampToEdge.
 */
@property (nonatomic) GLIAddressMode wrapS;

/*!
 @abstract Default is GLIAddressMode_ClampToEdge.
 */
@property (nonatomic) GLIAddressMode wrapT;

- (instancetype)init NS_DESIGNATED_INITIALIZER;

/*!
 @method        upload
 @abstract      Upload texture to GPU with the given min/mag filter and adress mode.
 */
- (void)upload;

@end

NS_ASSUME_NONNULL_END
