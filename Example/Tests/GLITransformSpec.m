//
//  GLITransformSpec.m
//  GLInterop_Tests
//
//  Created by Qin Hong on 6/25/19.
//  Copyright © 2019 Qin Hong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>
#import <GLKit/GLKit.h>
#import "GLIContext.h"
#import "GLIRenderer.h"
#import "GLITransform.h"

SpecBegin(GLITransform)

describe(@"GLITransform", ^{
    it(@"can be render correctly", ^{
        [EAGLContext setCurrentContext:[GLIContext sharedContext].glContext];
        
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"USC-SIPI.4.2.07" ofType:@"tiff"];
        NSError *error;
        NSDictionary *loadOptions = @{GLKTextureLoaderGenerateMipmaps: @NO,
                                      GLKTextureLoaderSRGB: @NO,
                                      GLKTextureLoaderApplyPremultiplication: @YES
                                      };
        GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:imagePath options:loadOptions error:&error];
        textureInfo = [GLKTextureLoader textureWithContentsOfFile:imagePath options:loadOptions error:&error];
        
        GLITexture *texture = [GLITexture new];
        texture.target = textureInfo.target;
        texture.name = textureInfo.name;
        texture.width = textureInfo.width;
        texture.height = textureInfo.height;
        
        GLIRenderTarget *renderTarget = [[GLIRenderTarget alloc] initWithSize:CGSizeMake(256, 512)];
        
        GLITransform *transform = [[GLITransform alloc] init];
        transform.clearColor = [UIColor redColor];
        CATransform3D t = CATransform3DIdentity;
        t = CATransform3DScale(t, 0.5, 0.5, 1.0);
        transform.transform = t;
        transform.inputTextures = @[texture];
        transform.output = renderTarget;
        [transform render];
        [transform waitUntilCompleted];
        
        CVPixelBufferRef pixelBuffer = renderTarget.pixelBuffer;
        expect(renderTarget.glTexture).to.beGreaterThan(0);
        expect(renderTarget.pixelBuffer).to.beTruthy();
    });
});

SpecEnd
