//
//  GLIContextSpec.m
//  GLInterop_Example
//
//  Created by Qin Hong on 5/31/19.
//  Copyright © 2019 Qin Hong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLIContext.h"

SpecBegin(GLIContext)

describe(@"GLIContext", ^{
    
    context(@"Initializing", ^{
        
        it(@"can be initialized as a singletone", ^{
            GLIContext *context = [GLIContext sharedContext];
            expect(context).notTo.beNil();
            expect(context.glContext).notTo.beNil();
        });
        
    });
});

SpecEnd
