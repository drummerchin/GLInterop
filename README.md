# GLInterop

*GLInterop* is a library that supports interoperable render target between GL texture, Metal texture and CVPixelBufferRef.

## Features

### Render Target

*GLInterop* provides variety render targets to cover most business needs.

| RenderTarget                      | GL Texture | GL Framebuffer | Metal Texture | CVPixelBufferRef |
|-----------------------------------|:----------:|:--------------:|:-------------:|:----------------:|
| GLIRenderTarget                   |      o     |        x       |       x       |         o        |
| GLIMetalRenderTarget              |      o     |        x       |       o       |         o        |
| GLIFramebufferTextureRenderTarget |      o     |        o       |       x       |         x        |
| GLITextureRenderTarget            |      o     |        x       |       x       |         x        |

### GLIRenderer

*GLIRenderer* is a lightweight encapsulation of GL Program, which provides the basic ability to call GL Program.

*GLIRenderer* provides an `inputTextures` array, an` output` that supports multiple rendering target types, a `clearColor` for clearing framebuffer, and a` render` method for actual rendering operations.

For the setting of the view port, *GLIRenderer* provides the following methods:

```
- (void)setViewPortWithContentMode:(UIViewContentMode)contentMode inputSize:(CGSize)inputSize;
```

For vertex attributes, *GLIRenderer* provides the following methods:

```
- (void)applyVertexAttribute:(NSString *)attribName bytes:(void *)bytes;
```

For the above two methods, they touch GL instantly. And for uniform, the following methods will store the uniform value, and will not be passed to GL until the `applyUniforms` method is executed.

```
- (void)setUniform:(NSString *)uniformName bytes:(void *)bytes;
- (void)setTexture:(NSString *)textureName texture:(GLuint)glTexture;
```

This allows you to do some preparations for your GL Program before the actual rendering starts, such as parameter default settings, or some built-in static image texture settings.

If you override the `render` method, then you need to call this method to pass the uniform and all textures to the GL shader:

```
- (void)applyUniforms;
```

In fact, if *GLIRenderer* only provides these methods, it will still make you feel inconvenient to use. For example, `inputTextures` will assume that the texture in the shader is named "inputTexture + Number", which will reduce the readability of the shader. And, `inputTextures` is an array, which means that you must collect all the textures needed for rendering at once, even if only one of them is changed in the next rendering.

Now, this version provides a new way, you only need to define the property that begin with `uniform_` in the subclass of *GLIRenderer*, and you can get/set the uniform of texture / float / int type.

```
@property (nonatomic, strong) id <GLITexture> uniform_blurTexture;
@property (nonatomic) float uniform_intensity;
@property (nonatomic) int uniform_stride;
```

This code means that to set `blueTexture`,` intensity` and `stride` in the shader, you only need to define it without writing these implementations. Actually *GLIRenderer* will generate these uniform getters/setters at runtime.

### Utils

- GLIContext
- GLITextureCache
- GLIMetalTextureCache
- GLIPixelBufferPool
- GLITexture

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

iOS 8.0 or later.

## Installation

GLInterop is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'GLInterop'
```

## Author

Qin Hong, qinhong@face2d.com

## License

GLInterop is available under the MIT license. See the LICENSE file for more info.
