# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## Changed

- Change the type of `output` from `GLIRenderTarget *` to `__kindof GLIRenderTarget *` in *GLIRenderer* to compatible with *GLIMetalRenderTarget*.

## Added

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
