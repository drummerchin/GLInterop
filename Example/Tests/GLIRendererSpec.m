//
//  GLIRendererSpec.m
//  GLInterop_Tests
//
//  Created by Qin Hong on 6/19/19.
//  Copyright © 2019 Qin Hong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>
#import <GLKit/GLKit.h>
#import "GLIContext.h"
#import "GLIRenderer.h"
#import "GLITransform.h"

SpecBegin(GLIRenderer)

describe(@"GLIRender", ^{
    
    context(@"Initializing", ^{
        it(@"can be initialized with shaders", ^{
            [EAGLContext setCurrentContext:[GLIContext sharedContext].glContext];
            
            const char * GLIDefaultVertexString = GLI_SHADER(
                precision highp float;
                attribute vec4 position;
                attribute vec2 texCoord;
                uniform mat4 mvpMatrix;
                varying vec2 vTexCoord;
                void main()
                {
                    gl_Position = mvpMatrix * position;
                    vTexCoord = texCoord.xy;
                }
            );
            
            const char * GLIPassthroughFragmentString = GLI_SHADER(
                precision mediump float;
                varying highp vec2 vTexCoord;
                uniform sampler2D inputTexture;
                void main()
                {
                    gl_FragColor = texture2D(inputTexture, vTexCoord);
                }
            );

            GLIRenderer *renderer = [[GLIRenderer alloc] initWithVertex:@(GLIDefaultVertexString) fragment:@(GLIPassthroughFragmentString)];
            expect(renderer).notTo.beNil();
        });
    });
    
    it(@"can be initialized without shaders", ^{
        [EAGLContext setCurrentContext:[GLIContext sharedContext].glContext];
        
        GLIRenderTarget *output = [[GLIRenderTarget alloc] initWithSize:CGSizeMake(100, 200)];
        GLIRenderer *renderer = [[GLIRenderer alloc] initWithVertex:nil fragment:nil];
        expect(renderer).notTo.beNil();
        renderer.clearColor = [UIColor greenColor];
        renderer.output = output;
        [renderer render];
        [renderer waitUntilCompleted];

        expect(output.pixelBuffer).notTo.beNil();
        expect(output.glTexture).to.beGreaterThan(0);
    });

});

SpecEnd
