# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2026-07-03

### Added
- Re-created missing platform configuration directories (`android`, `ios`, `windows`, `macos`, `linux`) using custom organization package identifier `com.itsmeakshay0510` for App Store readiness.
- Configured iOS permissions in `Info.plist` for `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription` to support stable file picker functionality.
- Integrated `firebase_crashlytics` dependency to handle and capture runtime uncaught fatal exceptions.
- Implemented responsive grid delegates in Home, Search, and Wishlist screens to dynamically adjust viewport grid columns on wider screens, cutting layout rendering scales.
- Integrated offline Privacy Policy dialog view directly accessible via the Profile screen section.
- Added comprehensive repository documentations (`LICENSE`, `CHANGELOG.md`, `PRIVACY_POLICY.md`, `README.md`).

### Changed
- Refactored entire application color branding to use a modern, high-quality **Dark Violet & Purple** scheme.
- Forced default application startup theme state to dark theme mode.
- Optimized mock product image resolution requests to downscaled `w=225` queries, conserving ~75% network bandwidth.
- Added `memCacheWidth` limits to network image components to throttle image decoding resolution and prevent high RAM usage.

### Fixed
- Fixed the "fail-open" authentication bypass in Demo Mode. Now, the application requires local mock credentials and supports active login/logout session states in offline mode.
