//
//  GLIPixelBufferPool.h
//  GLInterop
//
//  Created by Qin Hong on 2018/12/3.
//

#include <Foundation/Foundation.h>
#include <CoreVideo/CoreVideo.h>
#include <CoreMedia/CoreMedia.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLIPixelBufferPool : NSObject

/*!
 @abstract The format description of the pixel buffer that this pixel buffer pool can create.
 */
@property (nonatomic, readonly, nullable) CMFormatDescriptionRef formatDescription;

/*!
 @abstarct The pixel format that represented by four char code of pixel buffer pool.
 */
@property (nonatomic, readonly) FourCharCode pixelFormat;

/*!
 @abstract The width of the pixel buffer pool.
 */
@property (nonatomic, readonly) NSUInteger width;

/*!
 @abstract The height of the pixel buffer pool.
 */
@property (nonatomic, readonly) NSUInteger height;

/*!
 @abstract  Initializes pixel buffer pool with given params.
 @param     pixelFormat     The pixel format of the pixel buffer pool.
 @param     width           The width of the pixel buffer pool.
 @param     height          The width of the pixel buffer pool.
 @param     poolAttritubes  A dictionary of auxiliary attributes describing this pixel buffer pool. This parameter may be NULL. For a list of possible keys, see Pixel Buffer Pool Auxiliary Attribute Keys.
 */
- (nullable instancetype)initWithPixelFormat:(FourCharCode)pixelFormat width:(NSUInteger)width height:(NSUInteger)height options:(NSDictionary * _Nullable)poolAttritubes NS_DESIGNATED_INITIALIZER;

/*!
 @abstract      Initializes pixel buffer pool with given size, pixel format and max buffer count.
 @param         maxBufferCount The maximium number of pixel buffers that allowed in pool.
 @discussion    Preallocating is ocurred when maxBufferCount greater then 1.
 */
- (nullable instancetype)initWithSize:(CGSize)size pixelFormat:(FourCharCode)pixelFormat maxBufferCount:(NSUInteger)maxBufferCount;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/*!
 @abstract Creates a new pixel buffer from the pool.
 */
- (CVPixelBufferRef)createPixelBuffer CF_RETURNS_RETAINED;

/*!
 @abstract Frees all unused buffers regardless of age.
 */
- (void)flush;

@end

NS_ASSUME_NONNULL_END
