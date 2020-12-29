//
//  GLIView.m
//  GLInterop
//
//  Created by Qin Hong on 2020/12/25.
//

#import "GLIView.h"

@interface GLIView ()
{
    CGFloat _width;
    CGFloat _height;
}

@end

@implementation GLIView
@synthesize eglSurface = _eaglLayer;
@synthesize drawingContentMode = _drawingContentMode;

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"contentMode"];
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.contentMode = UIViewContentModeScaleAspectFit;
    self.contentScaleFactor = [UIScreen mainScreen].scale;
    
    _eaglLayer = (CAEAGLLayer*)self.layer;
    _eaglLayer.opaque = YES;
    _eaglLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking: @(false),
                                     kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8};
    
    [self addObserver:self forKeyPath:@"contentMode" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _width = self.bounds.size.width;
    _height = self.bounds.size.height;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (object == self
        && [keyPath isEqualToString:@"contentMode"])
    {
        _drawingContentMode = self.contentMode;
    }
}

@end
