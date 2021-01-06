//
//  GLIRenderer.m
//  GLInterop
//
//  Created by Qin Hong on 6/3/19.
//

#import "GLIRenderer.h"
#import <OpenGLES/ES2/gl.h>
#include "GLIProgram.h"
#include "GLIMatrixUtil.h"
#import <objc/runtime.h>

void GLIRendererAddMedhod(Class clz, SEL sel, id _Nonnull block)
{
    IMP impl = imp_implementationWithBlock(block);
    IMP originImpl = class_getMethodImplementation(clz, sel);
    if (originImpl) {
        class_replaceMethod(clz, sel, impl, NULL);
    } else {
        class_addMethod(clz, sel, impl, NULL);
    }
}

const char * GLIDefaultVertexString = GLI_SHADER(
    precision highp float;
    attribute vec4 position;
    attribute vec2 texCoord;
    varying vec2 vTexCoord;
    void main()
    {
        gl_Position = position;
        vTexCoord = texCoord.xy;
    }
);

@interface GLIRenderer ()
{
    GLIProgramRef _prog;
}

@end

@implementation GLIRenderer

#pragma mark - runtime

+ (void)initialize
{
    Class clz = self.class;
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(clz, &methodCount);
    
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:@"\\d" options:NSRegularExpressionCaseInsensitive error:nil];
    for (unsigned int i = 0; i < methodCount; i++)
    {
        Method method = methods[i];
        SEL selector = method_getName(method);
        NSString *selectorName = NSStringFromSelector(selector);
        const char *typeEncoding = method_getTypeEncoding(method);
        NSString *typeEncodingStr = [NSString stringWithCString:typeEncoding encoding:NSASCIIStringEncoding];
        NSString *typeStr = [regEx stringByReplacingMatchesInString:typeEncodingStr options:0 range:NSMakeRange(0, typeEncodingStr.length) withTemplate:@""];
        //NSLog(@"'%@' has method named '%@' of encoding '%s'", NSStringFromClass(clz), selectorName, typeEncoding);

        NSArray *components = [selectorName componentsSeparatedByString:@":"];
        NSString *firstComponent = components.count ? components[0] : selectorName;
        if ([selectorName hasPrefix:@"setUniform_"]
            && [typeStr hasPrefix:@"v@:"])
        {
            NSRange range = [firstComponent rangeOfString:@"setUniform_"];
            NSString *uniformName = [firstComponent substringFromIndex:(range.location + range.length)];

            NSRange prefixOfTypeEncodingRange = [typeStr rangeOfString:@"v@:"];
            NSString *propTypeEncodingStr = [typeStr substringFromIndex:(prefixOfTypeEncodingRange.location + prefixOfTypeEncodingRange.length)];
            if ([propTypeEncodingStr isEqualToString:@"@"])
            {
                // object type
                GLIRendererAddMedhod(clz, selector, ^(__kindof GLIRenderer *self, id<GLITexture> texture) {
                    if (!uniformName || !texture) return;
                    const void *propKey = NSSelectorFromString(uniformName);
                    id<GLITexture> propObj = objc_getAssociatedObject(self, propKey);
                    if (!propObj
                        || propObj != texture)
                    {
                        objc_setAssociatedObject(self, propKey, texture, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                        [self setTexture:uniformName texture:texture.name];
                    }
                });
            }
            else if ([propTypeEncodingStr isEqualToString:@"f"])
            {
                // float
                GLIRendererAddMedhod(clz, selector, ^(__kindof GLIRenderer *self, float value) {
                    if (!uniformName) return;
                    const void *propKey = NSSelectorFromString(uniformName);
                    NSNumber *propObj = objc_getAssociatedObject(self, propKey);
                    if (!propObj
                        || [propObj floatValue] != value)
                    {
                        objc_setAssociatedObject(self, propKey, @(value), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                        [self setUniform:uniformName bytes:&value];
                    }
                });
            }
            else if ([propTypeEncodingStr isEqualToString:@"i"])
            {
                // int
                GLIRendererAddMedhod(clz, selector, ^(__kindof GLIRenderer *self, int value) {
                    if (!uniformName) return;
                    const void *propKey = NSSelectorFromString(uniformName);
                    NSNumber *propObj = objc_getAssociatedObject(self, propKey);
                    if (!propObj
                        || [propObj intValue] != value)
                    {
                        objc_setAssociatedObject(self, propKey, @(value), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                        [self setUniform:uniformName bytes:&value];
                    }
                });
            }
        }
        else if ([selectorName hasPrefix:@"uniform_"]
                 && [typeStr hasSuffix:@"@:"])
        {
            NSRange range = [firstComponent rangeOfString:@"uniform_"];
            NSString *uniformName = [firstComponent substringFromIndex:(range.location + range.length)];
            
            NSRange suffixOfTypeEncodingRange = [typeStr rangeOfString:@"@:"];
            NSString *propTypeEncodingStr = [typeStr substringToIndex:suffixOfTypeEncodingRange.location];
            if ([propTypeEncodingStr isEqualToString:@"@"])
            {
                // object type
                GLIRendererAddMedhod(clz, selector, ^id<GLITexture> (__kindof GLIRenderer *self) {
                    const void *propKey = NSSelectorFromString(uniformName);
                    id<GLITexture> propObj = objc_getAssociatedObject(self, propKey);
                    return propObj;
                });
            }
            else if ([propTypeEncodingStr isEqualToString:@"f"])
            {
                // float
                GLIRendererAddMedhod(clz, selector, ^float (__kindof GLIRenderer *self) {
                    const void *propKey = NSSelectorFromString(uniformName);
                    NSNumber *propObj = objc_getAssociatedObject(self, propKey);
                    return [propObj floatValue];
                });
            }
            else if ([propTypeEncodingStr isEqualToString:@"i"])
            {
                // int
                GLIRendererAddMedhod(clz, selector, ^int (__kindof GLIRenderer *self) {
                    const void *propKey = NSSelectorFromString(uniformName);
                    NSNumber *propObj = objc_getAssociatedObject(self, propKey);
                    return [propObj intValue];
                });
            }
        }
    }
    free(methods);
}

#pragma mark - life cycle

- (void)dealloc
{
    NSCAssert(!_prog && !_framebuffer.name, @"GL objects leaked.");
}

- (void)removeResources
{
    if (_prog)
    {
        GLIProgramDestroy(_prog);
        _prog = NULL;
    }
    if (_framebuffer.name)
    {
        glDeleteFramebuffers(1, &_framebuffer.name);
        _framebuffer.name = 0;
    }
}

- (instancetype)initWithVertex:(NSString *)vertex fragment:(NSString *)fragment
{
    if (self = [super init])
    {
        if (vertex && fragment)
        {
            const char *vertexStr = [vertex UTF8String];
            const char *fragStr = [fragment UTF8String];
            _prog = GLIProgramCreateFromSource(vertexStr, fragStr);
            int isValid = GLIProgramLinkAndValidate(_prog);
            NSAssert(isValid, @"GLProgram error.");
            if (!isValid)
            {
                NSLog(@"Failed to create GLIRenderer.");
            }
            
            GLIProgramParseVertexAttrib(_prog);
            GLIProgramParseUniform(_prog);
        }
        
        _framebuffer.target = GL_FRAMEBUFFER;
        glGenFramebuffers(1, &_framebuffer.name);
                
        self.preserveContents = NO;
        self.clearColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark - rendering

- (BOOL)prepareFramebuffer
{
    if (!self.output) return NO;
    glBindFramebuffer(_framebuffer.target, _framebuffer.name);
    glActiveTexture(GL_TEXTURE0);
    GLenum outputTarget = GL_TEXTURE_2D;
    glBindTexture(outputTarget, self.output.glTexture);
    glFramebufferTexture2D(_framebuffer.target, GL_COLOR_ATTACHMENT0, outputTarget, self.output.glTexture, 0);
    GLenum status = glCheckFramebufferStatus(_framebuffer.target);
    if (status != GL_FRAMEBUFFER_COMPLETE)
    {
        printf("failed to make complete framebuffer object %x\n", status);
        return NO;
    }
    
    [self preprocessFramebuffer];
    
    return YES;
}

- (void)render
{
    if (![self prepareFramebuffer]) return;
    if (self.program)
    {
        id<GLITexture> firstTexture = [self.inputTextures firstObject];
        glUseProgram(self.program);
        [self setViewPortWithContentMode:UIViewContentModeScaleAspectFit inputSize:CGSizeMake(firstTexture.width, firstTexture.height)];
        
        [self setVertexAttributeToBuffer:@"position" bytes:&(GLfloat[]){
            -1.0, -1.0, 0.0, 1.0,
             1.0, -1.0, 0.0, 1.0,
            -1.0,  1.0, 0.0, 1.0,
             1.0,  1.0, 0.0, 1.0
        } size:sizeof(float) * 16];
        [self setVertexAttributeToBuffer:@"texCoord" bytes:&(GLfloat[]){
            0.0f, 0.0f,
            1.0f, 0.0f,
            0.0f, 1.0f,
            1.0f, 1.0f
        } size:sizeof(float) * 8];
        
        [self applyVertexAttributes];
        
        for (int i = 0; i < self.inputTextures.count; i++)
        {
            NSString *texIndexStr = (i == 0) ? @"" : [NSString stringWithFormat:@"%d", i];
            id<GLITexture> texture = self.inputTextures[i];
            GLITextureSetTexParameters(texture);
            [self setTexture:[NSString stringWithFormat:@"inputTexture%@", texIndexStr] texture:texture.name];
        }
        
        [self applyUniforms];
        
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        glUseProgram(0);
        glBindTexture(GL_TEXTURE_2D, 0);
    }
}

- (void)waitUntilCompleted
{
    glFinish();
}

- (void)willApplyUniforms
{
    
}

#pragma mark - utils for subclassing

+ (NSString *)defaultVertexString
{
    return @(GLIDefaultVertexString);
}

- (GLuint)program
{
    if (!_prog) return 0;
    return GLIProgramGetProgram(_prog);
}

- (void)preprocessFramebuffer
{
    if (!self.preserveContents)
    {
        CGFloat clearColorR = 0, clearColorG = 0, clearColorB = 0, clearColorA = 0;
        [self.clearColor getRed:&clearColorR green:&clearColorG blue:&clearColorB alpha:&clearColorA];
        glClearColor(clearColorR, clearColorG, clearColorB, clearColorA);
        glClear(GL_COLOR_BUFFER_BIT);
    }
}

- (void)setViewPortWithContentMode:(UIViewContentMode)contentMode inputSize:(CGSize)inputSize
{
    CGRect viewPort = [self.class viewPortRectForContentMode:contentMode
                                                drawableSize:CGSizeMake(self.output.width, self.output.height)
                                                 textureSize:inputSize];
    glViewport(viewPort.origin.x, viewPort.origin.y, viewPort.size.width, viewPort.size.height);
}

- (void)applyVertexAttribute:(NSString *)attribName bytes:(void *)bytes
{
    GLIProgramApplyVertexAttribute(_prog, (char *)attribName.UTF8String, bytes);
}

- (void)setVertexAttributeToBuffer:(NSString *)attribName bytes:(void *)bytes size:(size_t)size
{
    GLIProgramSetVertexAttributeToBuffer(_prog, (char *)attribName.UTF8String, bytes, size);
}

- (void)applyVertexAttributes
{
    GLIProgramApplyVertexAttributes(_prog);
}

- (void)setUniform:(NSString *)uniformName bytes:(void *)bytes
{
    GLIProgramSetUniformBytes(_prog, (char *)uniformName.UTF8String, bytes);
}

- (void)setTexture:(NSString *)textureName texture:(GLuint)glTexture
{
    GLIProgramSetUniformBytes(_prog, (char *)textureName.UTF8String, &glTexture);
}

- (void)applyUniforms
{
    [self willApplyUniforms];
    GLIProgramApplyUniforms(_prog);
}

+ (CGRect)viewPortRectForContentMode:(UIViewContentMode)contentMode drawableSize:(CGSize)drawableSize textureSize:(CGSize)textureSize
{
    CGFloat dW = drawableSize.width;
    CGFloat dH = drawableSize.height;
    CGFloat tW = textureSize.width;
    CGFloat tH = textureSize.height;
    CGFloat vX = 0, vY = 0, vW = tW, vH = tH;
    int texIsWiderThanDrawable = tW / tH > dW / dH;
    switch (contentMode) {
        case UIViewContentModeScaleToFill:
            vW = dW;
            vH = dH;
            break;
        case UIViewContentModeScaleAspectFit:
            vW = texIsWiderThanDrawable ? dW : dH * tW / tH;
            vH = texIsWiderThanDrawable ? dW * tH / tW : dH;
            vX = texIsWiderThanDrawable ? 0 : (dW - vW) / 2.f;
            vY = texIsWiderThanDrawable ? (dH - vH) / 2.f : 0;
            break;
        case UIViewContentModeScaleAspectFill:
            vW = texIsWiderThanDrawable ? dH * tW / tH : dW;
            vH = texIsWiderThanDrawable ? dH : dW * tH / tW;
            vX = texIsWiderThanDrawable ? (dW - vW) / 2.f : 0;
            vY = texIsWiderThanDrawable ? 0 : (dH - vH) / 2.f;
            break;
        case UIViewContentModeCenter:
            vX = (dW - vW) / 2.f;
            vY = (dH - vH) / 2.f;
            break;
        case UIViewContentModeLeft:
            vY = (dH - vH) / 2.f;
            break;
        case UIViewContentModeRight:
            vX = dW - vW;
            vY = (dH - vH) / 2.f;
            break;
        case UIViewContentModeTop:
            vX = (dW - vW) / 2.f;
            vY = dH - vH;
            break;
        case UIViewContentModeBottom:
            vX = (dW - vW) / 2.f;
            break;
        case UIViewContentModeTopLeft:
            vY = dH - vH;
            break;
        case UIViewContentModeTopRight:
            vX = dW - vW;
            vY = dH - vH;
            break;
        case UIViewContentModeBottomLeft:
            break;
        case UIViewContentModeBottomRight:
            vX = dW - vW;
            break;
        default:
            vW = dW;
            vH = dH;
            break;
    }
    return CGRectMake(vX, vY, vW, vH);
}

@end
