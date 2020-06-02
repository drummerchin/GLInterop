//
//  GLIMetalTextureCache.h
//  GLInterop
//
//  Created by Qin Hong on 2018/12/3.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <CoreVideo/CoreVideo.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLIMetalTextureCache : NSObject

@property (nonatomic, strong, readonly) id<MTLDevice> device;

/*!
 @abstract Initialize instance with a metal device.
 */
- (instancetype)initWithDevice:(id<MTLDevice>)device NS_DESIGNATED_INITIALIZER;

/*!
 @abstract Return a singleton instance with a shared device.
 */
+ (instancetype)sharedTextureCache;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/*!
 @abstract   Creates a CVMetalTextureRef object from an existing CVImageBuffer
 @param      sourceImage The CVImageBuffer that you want to create a CVMetalTexture from.
 @param      pixelFormat Specifies the Metal pixel format.
 @param      width Specifies the width of the texture image.
 @param      height Specifies the height of the texture image.
 @param      planeIndex Specifies the plane of the CVImageBuffer to map bind.  Ignored for non-planar CVImageBuffers.
 @result     Returns a CVMetalTextureRef object on success
 */
- (nullable CVMetalTextureRef)createCVTextureFromImage:(CVImageBufferRef)sourceImage pixelFormat:(MTLPixelFormat)pixelFormat width:(NSUInteger)width height:(NSUInteger)height planeIndex:(NSUInteger)planeIndex CF_RETURNS_RETAINED;

/*!
@abstract   Performs internal housekeeping/recycling operations
@discussion This call must be made periodically to give the texture cache a chance to do internal housekeeping operations.
 */
- (void)flush;

@end

NS_ASSUME_NONNULL_END
