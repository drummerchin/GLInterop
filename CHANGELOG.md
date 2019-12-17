# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
