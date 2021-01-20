//
//  GLIMixingMetalExampleVC.m
//  GLInterop
//
//  Created by Qin Hong on 05/29/2019.
//  Copyright (c) 2019 Qin Hong. All rights reserved.
//

#import "GLIMixingMetalExampleVC.h"
#import <OpenGLES/EAGL.h>
#import <GLKit/GLKit.h>
#import <MetalKit/MetalKit.h>
#import <AVFoundation/AVFoundation.h>
#import "GLInterop.h"

@interface GLIMixingMetalExampleVC () <MTKViewDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>
{
    AVCaptureSession *_captureSession;
    dispatch_queue_t _videoCaptureQueue;
    
    id<MTLDevice> _device;
    id<MTLCommandQueue> _commandQueue;
    id<MTLRenderPipelineState> _renderQuadPipelineState;
    IBOutlet MTKView *_mtkView;
    id _cvMetalTexture;
    id<MTLTexture> _lastTexture;
    
    GLIContext *_glContext;
    GLITextureCache *_glTextureCache;
    GLIMetalTextureCache *_metalTextureCache;
    GLIMetalRenderTarget *_frameRenderTarget;
    __kindof GLIRenderer *_filter;
    dispatch_semaphore_t _frameLock;
}

@end

@implementation GLIMixingMetalExampleVC

#pragma mark - life cycle

- (void)dealloc
{
    [_glContext runTaskWithHint:GLITaskHint_GenericTask block:^{
        [_filter removeResources];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // setup metal pipelines
    _device = MTLCreateSystemDefaultDevice();
    _commandQueue = [_device newCommandQueue];
    _metalTextureCache = [[GLIMetalTextureCache alloc] initWithDevice:_device];

    id<MTLLibrary> library = [_device newDefaultLibrary];
    id<MTLFunction> vertexFunction = [library newFunctionWithName:@"vertexDefault"];
    id<MTLFunction> fragmentFunction = [library newFunctionWithName:@"passthrough"];
    MTLRenderPipelineDescriptor *renderPipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    renderPipelineDescriptor.vertexFunction = vertexFunction;
    renderPipelineDescriptor.fragmentFunction = fragmentFunction;
    renderPipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    renderPipelineDescriptor.depthAttachmentPixelFormat = MTLPixelFormatInvalid;
    renderPipelineDescriptor.stencilAttachmentPixelFormat = MTLPixelFormatInvalid;
    _renderQuadPipelineState = [_device newRenderPipelineStateWithDescriptor:renderPipelineDescriptor error:nil];
    NSAssert(_renderQuadPipelineState, @"Failed create pipeline state.");
    
    // setup GL context
    _glContext = [[GLIContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    _glTextureCache = [[GLITextureCache alloc] initWithContext:_glContext.glContext];
    
    [_glContext runTaskWithHint:GLITaskHint_GenericTask block:^{
        _filter = [[GLITransform alloc] init];
    }];

    // setup camera
    [self setupCamera];
    
    _frameLock = dispatch_semaphore_create(1);
    
    // setup UI
    [self setupUI];
    
    // start camera
    [_captureSession startRunning];
}

- (void)setupUI
{
    _mtkView = [[MTKView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) device:_device];
    _mtkView.delegate = self;
    _mtkView.paused = YES;
    _mtkView.framebufferOnly = YES;
    _mtkView.colorPixelFormat = MTLPixelFormatBGRA8Unorm;
    [self.view addSubview:_mtkView];
}

#pragma mark - Camera

- (void)setupCamera
{
    _captureSession = [[AVCaptureSession alloc] init];
    dispatch_queue_t videoCaptureQueue = dispatch_queue_create("capturepipeline.video", DISPATCH_QUEUE_SERIAL);
    dispatch_set_target_queue(videoCaptureQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0));
    
    AVCaptureDevice *videoDevice = nil;
    NSArray* devices = [AVCaptureDevice devices];
    for (AVCaptureDevice* device in devices)
    {
        if ([device position] == AVCaptureDevicePositionBack)
        {
            videoDevice = device;
            break;
        }
    }
    AVCaptureDeviceInput *videoDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:videoDevice error:nil];
    
    AVCaptureVideoDataOutput *videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
    [videoDataOutput setSampleBufferDelegate:self queue:videoCaptureQueue];
    [videoDataOutput setVideoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)}];

    [_captureSession beginConfiguration];
    [_captureSession setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_captureSession canAddInput:videoDeviceInput])
    {
        [_captureSession addInput:videoDeviceInput];
    }
    if ([_captureSession canAddOutput:videoDataOutput])
    {
        [_captureSession addOutput:videoDataOutput];
    }
    [_captureSession commitConfiguration];
    AVCaptureConnection *videoConnection = [videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
    videoConnection.videoOrientation = [self.class videoOrientationFromUIOrientation:[UIApplication sharedApplication].statusBarOrientation];
    videoConnection.videoMirrored = videoDevice.position == AVCaptureDevicePositionFront;
}

+ (AVCaptureVideoOrientation)videoOrientationFromUIOrientation:(UIInterfaceOrientation)uiOrientation
{
    AVCaptureVideoOrientation videoOrientation;
    switch (uiOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
            videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIInterfaceOrientationLandscapeRight:
            videoOrientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIInterfaceOrientationPortrait:
            videoOrientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            videoOrientation = AVCaptureVideoOrientationPortrait;
            break;
    }
    return videoOrientation;
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if (!CMSampleBufferIsValid(sampleBuffer)) return;
    
    // convert sample buffer to pixel buffer
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);

    [_glContext runTaskWithHint:GLITaskHint_ContextSpecificTask block:^{
        // convert pixel buffer to GL texture
        CVOpenGLESTextureRef inputTexture = [_glTextureCache createCVTextureFromImage:pixelBuffer width:width height:height planeIndex:0];
        GLITexture *inputTextureInfo = GLITextureNew(CVOpenGLESTextureGetTarget(inputTexture),
                                                     CVOpenGLESTextureGetName(inputTexture),
                                                     width,
                                                     height,
                                                     CVOpenGLESTextureIsFlipped(inputTexture));
        
        // create an interoperable render target
        if (!_frameRenderTarget
            || _frameRenderTarget.width != width
            || _frameRenderTarget.height != height)
        {
            _frameRenderTarget = [[GLIMetalRenderTarget alloc] initWithSize:CGSizeMake(width, height) glTextureCache:_glTextureCache mtlTextureCache:_metalTextureCache];
        }
        
        // render using GL
        _filter.clearColor = [UIColor clearColor];
        _filter.inputTextures = @[inputTextureInfo];
        _filter.output = _frameRenderTarget;
        [_filter render];
        
        // wait GL finish
        glFinish();
        CFRelease(inputTexture);
    }];
        
    // metal processing
    _cvMetalTexture = (__bridge_transfer id)[_metalTextureCache createCVTextureFromImage:_frameRenderTarget.pixelBuffer pixelFormat:MTLPixelFormatBGRA8Unorm width:_frameRenderTarget.width height:_frameRenderTarget.height planeIndex:0];
    _lastTexture = CVMetalTextureGetTexture((__bridge CVMetalTextureRef _Nonnull)_cvMetalTexture);
    
    // present
    [_mtkView draw];
}

- (void)captureOutput:(AVCaptureOutput *)output didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    CMAttachmentMode mode = 0;
    CFStringRef reason = CMGetAttachment(sampleBuffer, kCMSampleBufferAttachmentKey_DroppedFrameReason, &mode);
    CFStringRef reasonInfo = CMGetAttachment(sampleBuffer, kCMSampleBufferAttachmentKey_DroppedFrameReasonInfo, &mode);
    NSLog(@"Drop frame. Reason: %@, Reason Info: %@", (__bridge NSString *)reason, (__bridge NSString *)reasonInfo);
}

#pragma mark - MTKView Delegate

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size
{
    
}

- (void)drawInMTKView:(MTKView *)view
{
   if (dispatch_semaphore_wait(_frameLock, DISPATCH_TIME_NOW) != 0) return;
    
    MTLRenderPassDescriptor *renderPassDesc = _mtkView.currentRenderPassDescriptor;
    if (renderPassDesc
        && _lastTexture)
    {
        id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
        id<MTLRenderCommandEncoder> commandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDesc];
        [commandEncoder setRenderPipelineState:_renderQuadPipelineState];
        matrix_float4x4 mvpMatrix = matrix_identity_float4x4;
        [commandEncoder setVertexBytes:&mvpMatrix length:sizeof(matrix_float4x4) atIndex:1];
        [commandEncoder setFragmentTexture:_lastTexture atIndex:0];
        [commandEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
        [commandEncoder endEncoding];
        [commandBuffer presentDrawable:view.currentDrawable];
        [commandBuffer commit];
        [commandBuffer waitUntilCompleted];
    }
    
    dispatch_semaphore_signal(_frameLock);
}

@end
