//
//  GLITextureCache.h
//  GLInterop
//
//  Created by Qin Hong on 2018/12/3.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>
#import <OpenGLES/EAGL.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLITextureCache : NSObject

@property (nonatomic, strong, readonly) EAGLContext *glContext;

/*!
 @method    initWithContext:
 @abstract  Initialize instance with a EAGLContext.
 */
- (instancetype)initWithContext:(EAGLContext *)context NS_DESIGNATED_INITIALIZER;

/*!
 @method    sharedTextureCache
 @abstract  Returns a singleton instance that initialized from a shared context.
 */
+ (instancetype)sharedTextureCache;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/*!
 @method    createCVTextureFromImage:width:height:planeIndex:
 @abstract  Creates a CVMetalTextureRef object from an existing CVImageBuffer
 @param     sourceImage The CVImageBuffer that you want to create a CVMetalTexture from.
 @param     width Specifies the width of the texture image.
 @param     height Specifies the height of the texture image.
 @param     planeIndex Specifies the plane of the CVImageBuffer to map bind.  Ignored for non-planar CVImageBuffers.
 @result    Returns a CVMetalTextureRef object on success
 */
- (nullable CVOpenGLESTextureRef)createCVTextureFromImage:(CVImageBufferRef)sourceImage width:(NSUInteger)width height:(NSUInteger)height planeIndex:(NSUInteger)planeIndex CF_RETURNS_RETAINED;

/*!
 @method    flush
 @abstract  Performs internal housekeeping/recycling operations
 @discussion This call must be made periodically to give the texture cache a chance to do internal housekeeping operations.
 */
- (void)flush;

@end

NS_ASSUME_NONNULL_END
