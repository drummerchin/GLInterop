//
//  GLITextureRenderTarget.m
//  GLInterop
//
//  Created by Qin Hong on 5/30/20.
//

#import "GLITextureRenderTarget.h"
#import "GLITexture.h"
#import <OpenGLES/ES2/gl.h>

@implementation GLITextureRenderTarget
@dynamic texture;
@synthesize glTexture, width, height;

- (id<GLITexture>)texture
{
    GLITexture *texture = [GLITexture new];
    texture.target = GL_TEXTURE_2D;
    texture.name = self.glTexture;
    texture.width = self.width;
    texture.height = self.height;
    texture.isFlipped = self.isFlipped;
    return texture;
}

@end
