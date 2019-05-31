//
//  GLIRenderTargetSpec.m
//  GLInterop_Example
//
//  Created by qinhong on 5/31/19.
//  Copyright © 2019 Qin Hong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLIRenderTarget.h"

SpecBegin(GLIRenderTarget)

describe(@"GLIRenderTarget", ^{
    
    context(@"Initializing", ^{
        
        it(@"can be initialized with a given size", ^{
            CGSize size = CGSizeMake(100, 200);
            GLIRenderTarget *renderTarget = [[GLIRenderTarget alloc] initWithSize:size];
            expect(renderTarget).notTo.beNil();
            expect(renderTarget.glTexture).notTo.beNil();
            expect(renderTarget.pixelBuffer).notTo.beNil();
            
            NSUInteger width = CVPixelBufferGetWidth(renderTarget.pixelBuffer);
            NSUInteger height = CVPixelBufferGetHeight(renderTarget.pixelBuffer);
            expect(width).to.equal(size.width);
            expect(height).to.equal(size.height);
        });
        
    });
});

SpecEnd
