# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Briefly is a SwiftUI iOS/macOS application with support for multiple platforms including iPhone, iPad, Mac, and Apple Vision Pro. The project follows Apple's modern app development patterns and uses the new Swift Testing framework.

## Architecture

- **Main App**: `Briefly/BrieflyApp.swift` - Entry point using `@main` App protocol
- **UI**: `Briefly/ContentView.swift` - Primary SwiftUI view
- **Testing**: Uses Swift Testing framework (not XCTest) with `@Test` annotations
- **Multi-platform**: Supports iOS 18.5+, macOS 15.5+, and visionOS 2.5+
- **Bundle ID**: `briefly.Briefly`

## Development Commands

### Build and Run
```bash
# Build the project
xcodebuild -project Briefly.xcodeproj -scheme Briefly build

# Build for specific platform
xcodebuild -project Briefly.xcodeproj -scheme Briefly -destination 'platform=iOS Simulator,name=iPhone 15' build

# Clean build folder
xcodebuild -project Briefly.xcodeproj clean
```

### Testing
```bash
# Run unit tests
xcodebuild test -project Briefly.xcodeproj -scheme Briefly -destination 'platform=iOS Simulator,name=iPhone 15'

# Run UI tests
xcodebuild test -project Briefly.xcodeproj -scheme Briefly -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:BrieflyUITests

# Run specific test
xcodebuild test -project Briefly.xcodeproj -scheme Briefly -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:BrieflyTests/BrieflyTests/example
```

## Code Structure

- `/Briefly/` - Main app source code
- `/BrieflyTests/` - Unit tests using Swift Testing framework
- `/BrieflyUITests/` - UI tests
- `/Briefly/Assets.xcassets/` - App icons and assets
- `/Briefly/Briefly.entitlements` - App capabilities and permissions

## Key Development Notes

- Uses Swift 5.0 and modern SwiftUI patterns
- Development team ID: 38L2SVS3BN
- Hardened runtime enabled for security
- SwiftUI previews enabled
- Uses new Swift Testing framework (import Testing, @Test annotations)
- No external dependencies - pure SwiftUI/Swift project

## Code Cleanup Best Practices

When removing or changing features:
1. **Remove all related code**: When removing a feature, also remove all associated state variables, functions, imports, and UI elements if not needed elsewhere
2. **Clean up unused imports**: Remove any import statements that are no longer needed
3. **Remove dead code**: Delete any functions, variables, or components that are no longer used
4. **Update related functionality**: If removing a feature affects other parts of the code, update those parts accordingly
5. **Remove unused state**: Delete @State, @Binding, and other property wrappers that are no longer needed
6. **Clean up navigation**: Remove unused NavigationLink destinations, sheet presentations, and modal presentations
7. **Context preservation**: Always clean up unused code to save on context and keep the codebase maintainable