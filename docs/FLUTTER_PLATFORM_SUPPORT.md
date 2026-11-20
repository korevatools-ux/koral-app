# Koral Flutter platform support

Koral is the reference Flutter app in this portfolio.

## Required targets
- Android
- iOS
- Web
- Windows desktop

## Platform requirements
- Keep one Flutter/Dart application and shared feature/domain layers.
- Use platform-aware export and file-save adapters for DOCX/PPTX and generated assets.
- Keep Supabase URL and publishable/anon key as build-time configuration; never include service-role or AI provider secrets.
- Validate auth, private project access and generation flows against a configured test Supabase project.
- Run Flutter analyze, unit/widget tests and a release build for each target in CI.

## Current verified scope
Office Open XML DOCX/PPTX generation and package-level tests are implemented. Web and unsigned iOS builds have passed; Android build is in progress. Windows target still needs its own CI build and artifact verification. Builds without Supabase build-time values intentionally show the setup-required screen and are packaging checks, not configured installs.

## Release acceptance
A platform is only marked supported after its release build, startup/configuration path, authentication and file export behavior have been verified on that platform.