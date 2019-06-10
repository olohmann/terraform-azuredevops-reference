# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

### Removed

### Changed

- More verbose error messages.

## [1.0.0] - 2019-06-10

### Added

- Added this Changelog for future reference.
- Support for terraform >=0.12.1.
- Support for downloading terraform client on the fly.

### Changed

- Switched to a `az` based deployment of the state storage account (required by terraform >=0.12.0 due to stricter behavior).
- Using standard `TF_` prefix for passing variables. That is, `__TF_` is no longer supported.

### Removed

- Dropped support for providing a tfvars file as input to `run_tf.sh`.

## <[1.0.0]

- Initial version
- **Important:** Fails for terraform >= 0.12.0 due to increased strictness.
