# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Add `removeResources` in *GLIFramebufferTextureRenderTarget*, *GLIBaseShapeRenderer*, *GLIRenderer* and *GLISyncObject* to avoid GL objects leaks while deallocating in a invalid GL context-specific thread.

### Deprecated

- Deprecate `deleteTextureWhileDeallocating` in *GLITexture* to adopt to the new management for GL objects.

# [1.5.4] - 2021-01-05

### Added

- Add `GLITextureLoadFromURL()`, `GLITextureLoadFromFilePath()` and `GLITextureLoadOptionNew()`

### Fixed

- Fix incorrect blending mode of *GLIBaseShapeRenderer*.
- Remove unneccessory disabling depth test of *GLIRenderer*.

# [1.5.3] - 2020-12-29

### Changed

- *GLIContext* is no longer a singleton and not support `sharedContext`. It has new initializers to create a GL context object, and it has a method to safely run GL rendering codes by calling `runTaskWithHint:block:`.

### Added

- Add *GLIView* and *GLIViewRenderer*.
- Add `GLITextureSetTexParameters()`, `GLITextureNew()` and `GLITextureNewTexture2D()`.

### Fixed

- Fix issue that multiple input textures can not be set correctly while rendering in *GLIRenderer*.
- Fix memory leak in *GLIBaseShapeRenderer*.
- Fix missing texture filtering parameters setttings in *GLIBaseShapeRenderer* and *GLITransform*.

# [1.5.2] - 2020-12-22

### GLIRenderer

- Add `setVertexAttributeToBuffer:bytes:size:` and `applyVertexAttributes` to support GPU buffered vertex attribute.
- Deprecate `applyVertexAttribute:bytes:` to avoid the potential rendering bug that caused by setting vertext attribute using bytes created on stack.

### Other

- Update *GLIRenderer*, *GLITransform* and *GLIBaseShapeRenderer* to avoid using above deprecated API.

# [1.5.1] - 2020-12-18

### Added

- Add *GLISyncObject*.

### Fixed

- Fix crash of *GLIProgram*.

## [1.5.0] - 2020-08-12

### Added

- Add *GLIBaseShapeRenderer*.
- Add `GLIMatrixLoadCATransform3D` in *GLIMatrixUtil.h*.
- Add `willApplyUniforms` for subclassing hooks in *GLIRenderer*.
- Add `preserveContents` in *GLIRenderer*.
- Add `deleteTextureWhileDeallocating` property in *GLITexture*.
- Add `setDimensions` method in *GLITexture*.
- Add NSCopying support in *GLITexture*.
- Add `texture`in *GLIRenderTarget* protocol and implement it.

### Fixed

- Fix issue that integer uniform can not be set via runtime method `setUniform_`.
- Fix issue that the frame buffer object should not be created until `prepareFramebuffer` is called in *GLIFramebufferTextureRenderTarget.m*
- Fix typo `GLProgramApplyUniforms()` to `GLIProgramApplyUniforms()`.
- Fix property `width` and `height` in *GLITextureRenderTarget*.
- Fix issue that vector type uniform can not be correctly applied via `GLProgramApplyUniforms()` function.

## [1.4.0] - 2020-06-02

### Changed

- *GLIRenderer* now supports to define a property with prefix 'uniform_' to get or set a texture/float/int uniform.

### Added

- Add class *GLIFramebufferTextureRenderTarget* to support the render target which contains a GL texture and a framebuffer.
- Add class *GLITextureRenderTarget* to support GL texture only render target.
- Add `applyTextureParamters` in *GLITexture*.

### Fixed

- Fix default value of `transform` issue in *GLITransform*.

## [1.3.2] - 2019-12-17

### Fixed

- Fix leaks of `GLITextureCache` and `GLIMetalTextureCache`.

## [1.3.1] - 2019-07-02

### Fixed

- Fix issue that `glContext` property is always be nil in *GLITextureCache*.

## [1.3.0] - 2019-07-01

### Added

- Add `initWithWithCVPixelBuffer:glTextureCache:` and `initWithSize:glTextureCache:` in *GLIRenderTarget*.
- Add `glTextureCache` in *GLIRenderTarget*.
- Add `initWithWithCVPixelBuffer:glTextureCache:mtlTextureCache:` and `initWithSize:glTextureCache:mtlTextureCache:` in *GLIMetalRenderTarget*.
- Add `mtlTextureCache` in *GLIMetalRenderTarget*.
- Add `setTextureParameters` in *GLITexture*.

### Deprecated

- Deprecate `upload` in *GLITexture* for incorrect API naming reason.

## [1.2.0] - 2019-06-27

### Changed

- Change the type of `output` from `GLIRenderTarget *` to `__kindof GLIRenderTarget *` in *GLIRenderer* to compatible with *GLIMetalRenderTarget*.

### Added

- Add *GLIMetalRenderTarget*.
- Add *GLIMetalTextureCache*.

## [1.1.0] - 2019-06-26

### Added

- Add `upload` method in *GLITexture*.

### Fixed

- Fix crash that occurred when initialize GLIRenderer without shaders.
- Fix typo for last version in CHANGELOG.md.

## [1.0.0] - 2019-06-25

### Added

- Add *GLIRenderer*.
- Add *GLITransform*.
- Add `width` and `height` in *GLIRenderTarget*.

## [0.1.0] - 2019-05-31

### Added

- First version.
