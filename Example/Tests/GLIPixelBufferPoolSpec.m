//
//  GLIPixelBufferPoolSpec.m
//  GLInterop_Example
//
//  Created by Qin Hong on 5/31/19.
//  Copyright © 2019 Qin Hong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLIPixelBufferPool.h"

SpecBegin(GLIPixelBufferPool)

describe(@"GLIPixelBufferPool", ^{
    
    context(@"Initializing", ^{
        
        it(@"can be initialized with a designated initializer", ^{
            GLIPixelBufferPool *pool = [[GLIPixelBufferPool alloc] initWithPixelFormat:'BGRA' width:100 height:200 options:NULL];
            expect(pool).notTo.beNil();
            expect(pool.width).to.equal(100);
            expect(pool.height).to.equal(200);
            expect(pool.pixelFormat).to.equal('BGRA');
        });
        
        it(@"can be initialized with conversion initializer", ^{
            GLIPixelBufferPool *pool = [[GLIPixelBufferPool alloc] initWithSize:CGSizeMake(100, 200) pixelFormat:'BGRA' maxBufferCount:3];
            expect(pool).notTo.beNil();
            expect(pool.width).to.equal(100);
            expect(pool.height).to.equal(200);
            expect(pool.pixelFormat).to.equal('BGRA');
        });
    });
    
    context(@"Create pixel buffer", ^{
        
        it(@"can create pixel buffer from a pixel buffer pool that give a max buffer count", ^{
            NSUInteger maxBufferCount = 3;
            GLIPixelBufferPool *pool = [[GLIPixelBufferPool alloc] initWithSize:CGSizeMake(100, 200) pixelFormat:'BGRA' maxBufferCount:maxBufferCount];
            expect(pool).notTo.beNil();
            
            CVPixelBufferRef pixelBuffer1 = [pool createPixelBuffer];
            expect(pixelBuffer1).notTo.beNil();
            CVPixelBufferRef pixelBuffer2 = [pool createPixelBuffer];
            expect(pixelBuffer2).notTo.beNil();
            CVPixelBufferRef pixelBuffer3 = [pool createPixelBuffer];
            expect(pixelBuffer3).notTo.beNil();
            
            CVPixelBufferRef pixelBuffer4 = [pool createPixelBuffer];
            expect(pixelBuffer4).to.beNil();
            
            CVPixelBufferRelease(pixelBuffer1);
            CVPixelBufferRelease(pixelBuffer2);
            CVPixelBufferRelease(pixelBuffer3);
            CVPixelBufferRelease(pixelBuffer4);
            
            CVPixelBufferRef pixelBuffer5 = [pool createPixelBuffer];
            expect(pixelBuffer5).notTo.beNil();
            CVPixelBufferRelease(pixelBuffer5);
        });
        
        it(@"can create pixel buffer from a pixel buffer pool that not give a max buffer count", ^{
            GLIPixelBufferPool *pool = [[GLIPixelBufferPool alloc] initWithPixelFormat:'BGRA' width:100 height:200 options:NULL];
            expect(pool).notTo.beNil();
            
            CVPixelBufferRef pixelBuffer1 = [pool createPixelBuffer];
            expect(pixelBuffer1).notTo.beNil();
            CVPixelBufferRef pixelBuffer2 = [pool createPixelBuffer];
            expect(pixelBuffer2).notTo.beNil();
            CVPixelBufferRef pixelBuffer3 = [pool createPixelBuffer];
            expect(pixelBuffer3).notTo.beNil();
            
            CVPixelBufferRef pixelBuffer4 = [pool createPixelBuffer];
            expect(pixelBuffer4).notTo.beNil();
            
            CVPixelBufferRelease(pixelBuffer1);
            CVPixelBufferRelease(pixelBuffer2);
            CVPixelBufferRelease(pixelBuffer3);
            CVPixelBufferRelease(pixelBuffer4);
        });
        
    });
});

SpecEnd
