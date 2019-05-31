//
//  GLIPixelBufferPool.m
//  GLInterop
//
//  Created by Qin Hong on 2018/12/3.
//

#import "GLIPixelBufferPool.h"

@interface GLIPixelBufferPool ()
{
    CVPixelBufferPoolRef _bufferPool;
    NSDictionary *_bufferPoolAuxAttributes;
    id _formatDesc;
}

@end

@implementation GLIPixelBufferPool
@dynamic formatDescription;

#pragma mark - life cycle

- (void)dealloc
{
    if (_bufferPool)
    {
        [self flush];
        CVPixelBufferPoolRelease(_bufferPool);
    }
}

- (instancetype)initWithPixelFormat:(FourCharCode)pixelFormat width:(NSUInteger)width height:(NSUInteger)height options:(NSDictionary *)poolAttritubes
{
    if (self = [super init])
    {
        _bufferPool = NULL;
        _width = width;
        _height = height;
        _pixelFormat = pixelFormat;
        
        NSDictionary *sourcePixelBufferOptions = @{
                                                   (id)kCVPixelBufferPixelFormatTypeKey : @(_pixelFormat),
                                                   (id)kCVPixelBufferWidthKey : @(_width),
                                                   (id)kCVPixelBufferHeightKey : @(_height),
                                                   (id)kCVPixelBufferIOSurfacePropertiesKey : @{ /*empty dictionary*/},
                                                   (id)kCVPixelBufferMetalCompatibilityKey : @(YES),
                                                   (id)kCVPixelBufferOpenGLESCompatibilityKey : @(YES)
                                                   };
        
        CVReturn err = CVPixelBufferPoolCreate(kCFAllocatorDefault,
                                               (__bridge CFDictionaryRef _Nullable)(poolAttritubes),
                                               (__bridge CFDictionaryRef _Nullable)(sourcePixelBufferOptions),
                                               &_bufferPool);
        if (!_bufferPool || err != kCVReturnSuccess) return nil;
        
        BOOL hasMaxCount = [poolAttritubes.allKeys containsObject:(id)kCVPixelBufferPoolMinimumBufferCountKey];
        if (hasMaxCount)
        {
            NSUInteger maxBufferCount = [[poolAttritubes objectForKey:(id)kCVPixelBufferPoolMinimumBufferCountKey] unsignedIntegerValue];
            if (maxBufferCount > 0)
            {
                //CVPixelBufferPoolCreatePixelBufferWithAuxAttributes() will return kCVReturnWouldExceedAllocationThreshold if we have already vended the max number of buffers
                _bufferPoolAuxAttributes = @{ (id)kCVPixelBufferPoolAllocationThresholdKey : @(maxBufferCount) };
                [self preallocatePixelBuffersInPool:_bufferPoolAuxAttributes];
            }
        }
        
        // get "Default" format description
        CMFormatDescriptionRef outputFormatDescription = NULL;
        CVPixelBufferRef testPixelBuffer = NULL;
        CVPixelBufferPoolCreatePixelBufferWithAuxAttributes(kCFAllocatorDefault,
                                                            _bufferPool,
                                                            (__bridge CFDictionaryRef _Nullable)(_bufferPoolAuxAttributes),
                                                            &testPixelBuffer);
        if (!testPixelBuffer)
        {
            NSLog(@"Problem creating a pixel buffer.");
            [self flush];
            return nil;
        }
        CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, testPixelBuffer, &outputFormatDescription);
        _formatDesc = (__bridge_transfer id)outputFormatDescription;
        CFRelease(testPixelBuffer);
    }
    return self;
}

- (instancetype)initWithSize:(CGSize)size pixelFormat:(FourCharCode)pixelFormat maxBufferCount:(NSUInteger)maxBufferCount
{
    NSUInteger width = size.width;
    NSUInteger height = size.height;
    return [self initWithPixelFormat:pixelFormat
                               width:width
                              height:height
                             options:@{ (id)kCVPixelBufferPoolMinimumBufferCountKey : @(maxBufferCount) }];
}

#pragma mark - internal

- (void)preallocatePixelBuffersInPool:(NSDictionary *)auxAttributes
{
    NSMutableArray *pixelBuffers = [[NSMutableArray alloc] init];
    while (1)
    {
        CVPixelBufferRef pixelBuffer = NULL;
        OSStatus err = CVPixelBufferPoolCreatePixelBufferWithAuxAttributes(kCFAllocatorDefault,
                                                                           _bufferPool,
                                                                           (__bridge CFDictionaryRef _Nullable)auxAttributes,
                                                                           &pixelBuffer);
        if (err == kCVReturnWouldExceedAllocationThreshold)
        {
            break;
        }
        assert(err == noErr);
        [pixelBuffers addObject:CFBridgingRelease( pixelBuffer )];
    }
    [pixelBuffers removeAllObjects];
}

#pragma mark - public

- (CMFormatDescriptionRef)formatDescription
{
    return (__bridge CMFormatDescriptionRef _Nullable)_formatDesc;
}

- (CVPixelBufferRef)createPixelBuffer
{
    CVPixelBufferRef pixelBuffer = NULL;
    /*
     CVReturn err = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, _bufferPool, &pixelBuffer );
     if (err)
     {
     NSLog( @"Cannot obtain a pixel buffer from the buffer pool (%d)", (int)err );
     }
     //*/
    CVReturn err = CVPixelBufferPoolCreatePixelBufferWithAuxAttributes(kCFAllocatorDefault,
                                                                       _bufferPool,
                                                                       (__bridge CFDictionaryRef _Nullable)_bufferPoolAuxAttributes,
                                                                       &pixelBuffer);
    if ( err ) {
        if ( err == kCVReturnWouldExceedAllocationThreshold ) {
            NSLog( @"Pool is out of buffers, dropping frame" );
        }
        else {
            NSLog( @"Error at CVPixelBufferPoolCreatePixelBuffer %d", err );
        }
    }
    return pixelBuffer;
}

- (void)flush
{
    if (_bufferPool)
    {
        CVPixelBufferPoolFlush(_bufferPool, kCVPixelBufferPoolFlushExcessBuffers);
    }
}

@end
