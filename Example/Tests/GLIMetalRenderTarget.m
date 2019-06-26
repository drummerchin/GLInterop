//
//  GLIMetalRenderTarget.m
//  GLInterop_Tests
//
//  Created by Qin Hong on 6/27/19.
//  Copyright © 2019 Qin Hong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLIMetalRenderTarget.h"

SpecBegin(GLIMetalRenderTarget)

describe(@"GLIMetalRenderTarget", ^{
    
    context(@"Initializing", ^{
        
        it(@"can be initialized with a given size", ^{
            CGSize size = CGSizeMake(100, 200);
            GLIMetalRenderTarget *renderTarget = [[GLIMetalRenderTarget alloc] initWithSize:size];
            expect(renderTarget).notTo.beNil();
            expect(renderTarget.glTexture).notTo.beNil();
            expect(renderTarget.pixelBuffer).notTo.beNil();
            expect(renderTarget.mtlTexture).notTo.beNil();
            
            NSUInteger width = CVPixelBufferGetWidth(renderTarget.pixelBuffer);
            NSUInteger height = CVPixelBufferGetHeight(renderTarget.pixelBuffer);
            expect(width).to.equal(size.width);
            expect(height).to.equal(size.height);
        });
        
    });
});

SpecEnd
