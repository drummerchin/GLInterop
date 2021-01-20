//
//  GLIBaseShapeRendererTexQuadVC.m
//  GLInterop_Example
//
//  Created by Qin Hong on 2021/1/14.
//  Copyright © 2021 Qin Hong. All rights reserved.
//

#import "GLIBaseShapeRendererTexQuadVC.h"
#import <GLInterop/GLInterop.h>

#define RANDOM(FROM,TO) (arc4random()%((TO) - (FROM)) + (FROM))

@interface GLIBaseShapeRendererTexQuadVC ()
{
    GLIContext *_glContext;
    GLITextureCache *_glTextureCache;
    GLIBaseShapeRenderer *_baseShapeRenderer;
    GLIRenderTarget *_renderTarget;
    GLIView *_glView;
    GLIViewRenderer *_viewRenderer;
}

@end

@implementation GLIBaseShapeRendererTexQuadVC

- (void)dealloc
{
    [_glContext runTaskWithHint:GLITaskHint_ContextSpecificTask block:^{
        [_baseShapeRenderer removeResources];
        [_viewRenderer removeResources];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupUI];
    
    _glContext = [[GLIContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    _glTextureCache = [[GLITextureCache alloc] initWithContext:_glContext.glContext];
    [_glContext runTaskWithHint:GLITaskHint_GenericTask block:^{
        _baseShapeRenderer = [[GLIBaseShapeRenderer alloc] init];
        _viewRenderer = [[GLIViewRenderer alloc] init];
        _renderTarget = [[GLIRenderTarget alloc] initWithSize:CGSizeMake(1280, 720) glTextureCache:_glTextureCache];
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self test];
    });
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
}

- (void)test
{
    [_glContext runTaskWithHint:GLITaskHint_ContextSpecificTask block:^{
        
        // load textures
        NSArray<NSString *> *texturePaths = @[[[NSBundle mainBundle] pathForResource:@"USC-SIPI.4.2.03" ofType:@"tiff"],
                                             [[NSBundle mainBundle] pathForResource:@"USC-SIPI.4.2.06" ofType:@"tiff"],
                                             [[NSBundle mainBundle] pathForResource:@"USC-SIPI.4.2.07" ofType:@"tiff"]];
        NSMutableArray<id<GLITexture>> *textures = [NSMutableArray new];
        for (int i = 0; i < texturePaths.count; i++)
        {
            id<GLITexture> texture = GLITextureLoadFromFilePath(texturePaths[i], GLITextureLoadOptionPremultiply(), nil);
            if (texture)
            {
                [textures addObject:texture];
            }
        }

        // render content to _renderTarget
        [_baseShapeRenderer beginRender:_renderTarget];
        [_baseShapeRenderer cleanWithClearColor:[UIColor lightGrayColor]];
        
        for (int i = 0; i < 100; i++)
        {
            int texIndex = RANDOM(0, textures.count);
            id<GLITexture> texture = textures[texIndex];
            float x = RANDOM(0, _renderTarget.width);
            float y = RANDOM(0, _renderTarget.height);
            float r = RANDOM(70, 130) - 100.0;
            float s = RANDOM(10, 50) / 100.0;
            float intensity = 1.0;//RANDOM(20, 100) / 100.0;
            CATransform3D transform = [GLIBaseShapeRenderer transformWithPosition:CGPointMake(x, y) rotation:r scale:s];
            [_baseShapeRenderer renderQuadWithTexture:texture
                                            transform:transform
                                          anchorPoint:CGPointMake(0.5, 0.5)
                                            intensity:intensity];
        }
        
        [_baseShapeRenderer endRender];
        
        // present to view
        _viewRenderer.inputTextures = @[_renderTarget.texture];
        [_viewRenderer renderToView:_glView];
    }];
}

@end
