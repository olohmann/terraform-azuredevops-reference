# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

### Removed

### Changed

----------------
## [1.1.0] - 2019-06-14

### Added

### Removed

### Changed

- Automatically detect (sub-)deployments. No need to change contents in the `run_tf.sh` file.
- Changed min version to terraform 0.12.2.


## [1.0.8] - 2019-06-12

### Added

### Removed

### Changed

- Bug: env vars in AzureDevOps not picked up

## [1.0.7] - 2019-06-12

### Added

### Removed

### Changed

- Fix __TF_backend_ vars for AzureDevOps capitalization

## [1.0.6] - 2019-06-12

### Added

### Removed

### Changed

- Tagging

## [1.0.5] - 2019-06-12

### Added

### Removed

### Changed

- Updates to terraform sample deployment.
- Fixed AzureDevops Environment Variable Capitalization Issue

## [1.0.4] - 2019-06-11

### Added

### Removed

### Changed

- Fix: TF_VAR_ usage and export

## [1.0.3] - 2019-06-11

### Added

### Removed

### Changed

- Fix: Custom network rules for state storage account

## [1.0.2] - 2019-06-11

### Added

### Removed

### Changed

- Updated `az` client storage container creation to new API (`auth-mode key`).

## [1.0.1] - 2019-06-11

### Added

### Removed

### Changed

- More verbose error messages.
- Fixed openssl dgst output (remove '(stdin)' prefix).
- Added `-no-color` to all terraform outputs

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
