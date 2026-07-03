# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2026-07-03

### Added
- **Core Mobile Support**: Regenerated native `android/` and `ios/` platform folders to enable deployment on Android and iOS devices.
- **Responsive Layout**: Wrapped pages in responsive wrappers to constrain layouts when running on desktop web views.
- **Authentication System**: Splash, onboarding, login, and signup screens with integrated Riverpod state management. Supports Google, Apple, and Email/Password sign-ins, with a fail-safe Demo Mode bypass.
- **Home & Explore**: Interactive category carousel, product grid lists, and instant Search/Explore views.
- **Wishlist & Cart**: Persistent local shopping cart storage using Hive and product bookmarking features.
- **Checkout & Shipping**: Multi-address management, dynamic shipping fee calculators, Cash on Delivery support, and payment integration skeleton (Razorpay).
- **Security & Infrastructure**: Native internet permissions configured for Android release builds, ready for API/Firebase integration.
