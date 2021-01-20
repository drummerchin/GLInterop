//
//  GLIViewRenderExampleVC.m
//  GLInterop
//
//  Created by Qin Hong on 05/29/2019.
//  Copyright (c) 2019 Qin Hong. All rights reserved.
//

#import "GLIViewRenderExampleVC.h"
#import <OpenGLES/EAGL.h>
#import <GLKit/GLKit.h>
#import <MetalKit/MetalKit.h>
#import <AVFoundation/AVFoundation.h>
#import <GLInterop/GLInterop.h>

@interface GLIViewRenderExampleVC () <AVCaptureVideoDataOutputSampleBufferDelegate>
{
    AVCaptureSession *_captureSession;
    dispatch_queue_t _videoCaptureQueue;
    
    GLIView *_glView;
    GLIViewRenderer *_viewRenderer;
    
    GLIContext *_glContext;
    GLITextureCache *_glTextureCache;
    __kindof GLIRenderer *_filter;
    
    GLIRenderTarget *_frameRenderTarget;
    dispatch_semaphore_t _frameLock;
}

@property (nonatomic, strong) UIAlertController *contentModeActionMenu;

@end

@implementation GLIViewRenderExampleVC

#pragma mark - life cycle

- (void)dealloc
{
    [_glContext runTaskWithHint:GLITaskHint_GenericTask block:^{
        [_filter removeResources];
        [_viewRenderer removeResources];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // setup GL context
    _glContext = [[GLIContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    _glTextureCache = [[GLITextureCache alloc] initWithContext:_glContext.glContext];
    
    [_glContext runTaskWithHint:GLITaskHint_GenericTask block:^{
        _filter = [[GLITransform alloc] init];
        _viewRenderer = [[GLIViewRenderer alloc] init];
        _viewRenderer.clearColor = [UIColor lightGrayColor];
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
    _glView = [[GLIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    _glView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_glView];
    [self.view addConstraints:@[
        [NSLayoutConstraint constraintWithItem:_glView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0],
        [NSLayoutConstraint constraintWithItem:_glView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0],
        [NSLayoutConstraint constraintWithItem:_glView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:300],
        [NSLayoutConstraint constraintWithItem:_glView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:300],
    ]];
    
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithTitle:@"ContentMode" style:UIBarButtonItemStylePlain target:self action:@selector(contentModeMenuAction:)],
    ];
}

- (void)contentModeMenuAction:(UIBarButtonItem *)item
{
    [self presentViewController:self.contentModeActionMenu animated:YES completion:nil];
}

- (UIAlertController *)contentModeActionMenu
{
    UIAlertController *menu = [UIAlertController alertControllerWithTitle:@"Select a contentMode" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    NSArray *contentModes = @[
        @{@"name":@"UIViewContentModeScaleToFill", @"value":@(UIViewContentModeScaleToFill)},
        @{@"name":@"UIViewContentModeScaleAspectFit", @"value":@(UIViewContentModeScaleAspectFit)},
        @{@"name":@"UIViewContentModeScaleAspectFill", @"value":@(UIViewContentModeScaleAspectFill)},
        @{@"name":@"UIViewContentModeCenter", @"value":@(UIViewContentModeCenter)},
        @{@"name":@"UIViewContentModeTop", @"value":@(UIViewContentModeTop)},
        @{@"name":@"UIViewContentModeBottom", @"value":@(UIViewContentModeBottom)},
        @{@"name":@"UIViewContentModeLeft", @"value":@(UIViewContentModeLeft)},
        @{@"name":@"UIViewContentModeRight", @"value":@(UIViewContentModeRight)},
        @{@"name":@"UIViewContentModeTopLeft", @"value":@(UIViewContentModeTopLeft)},
        @{@"name":@"UIViewContentModeTopRight", @"value":@(UIViewContentModeTopRight)},
        @{@"name":@"UIViewContentModeBottomLeft", @"value":@(UIViewContentModeBottomLeft)},
        @{@"name":@"UIViewContentModeBottomRight", @"value":@(UIViewContentModeBottomRight)},
    ];
    __weak typeof(self) weakSelf = self;
    for (int i = 0; i < contentModes.count; i++)
    {
        NSDictionary *item = contentModes[i];
        NSString *title = item[@"name"];
        UIViewContentMode value = [item[@"value"] unsignedIntegerValue];
        
        UIAlertAction *contentModeAction = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            __strong typeof(self) self = weakSelf;
            if (self)
            {
                self->_glView.contentMode = value;
            }
        }];
        contentModeAction.enabled = _glView.contentMode == value ? NO : YES;
        [menu addAction:contentModeAction];
    }
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        __strong typeof(self) self = weakSelf;
        if (self)
        {
            [menu dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    [menu addAction:cancelAction];
    return menu;
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
    
    [_glContext runTaskWithHint:GLITaskHint_GenericTask block:^{
        // convert pixel buffer to GL texture
        CVOpenGLESTextureRef inputTexture = [_glTextureCache createCVTextureFromImage:pixelBuffer width:width height:height planeIndex:0];
        GLITexture *inputTextureInfo = GLITextureNew(CVOpenGLESTextureGetTarget(inputTexture),
                                                     CVOpenGLESTextureGetName(inputTexture),
                                                     width,
                                                     height,
                                                     CVOpenGLESTextureIsFlipped(inputTexture));
        GLfloat bottomLeft[2], bottomRight[2], topLeft[2], topRight[2];
        CVOpenGLESTextureGetCleanTexCoords(inputTexture, bottomLeft, bottomRight, topRight, topLeft);
        
        // create an interoperable render target
        if (!_frameRenderTarget
            || _frameRenderTarget.width != width
            || _frameRenderTarget.height != height)
        {
            _frameRenderTarget = [[GLIRenderTarget alloc] initWithSize:CGSizeMake(width, height) glTextureCache:_glTextureCache];
        }
        
        // filter processing
        _filter.clearColor = [UIColor clearColor];
        _filter.inputTextures = @[inputTextureInfo];
        _filter.output = _frameRenderTarget;
        [_filter render];
        
        // render texture to view
        _viewRenderer.inputTextures = @[_frameRenderTarget.texture];
        [_viewRenderer renderToView:_glView];

        glFinish();
        CFRelease(inputTexture);
    }];
}

- (void)captureOutput:(AVCaptureOutput *)output didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    CMAttachmentMode mode = 0;
    CFStringRef reason = CMGetAttachment(sampleBuffer, kCMSampleBufferAttachmentKey_DroppedFrameReason, &mode);
    CFStringRef reasonInfo = CMGetAttachment(sampleBuffer, kCMSampleBufferAttachmentKey_DroppedFrameReasonInfo, &mode);
    NSLog(@"Drop frame. Reason: %@, Reason Info: %@", (__bridge NSString *)reason, (__bridge NSString *)reasonInfo);
}

@end
