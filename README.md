# Briefly

A clean SwiftUI iOS/macOS app for creating and managing brief content.

## Features

- Clean, minimal interface inspired by Notion
- Custom #F0F2F2 background color scheme
- Light mode only
- Multi-platform support (iOS 18.5+, macOS 15.5+, visionOS 2.5+)
- Custom Satoshi font family

## Tech Stack

- SwiftUI
- Swift Testing framework
- Pure Swift/SwiftUI (no external dependencies)

## Development

Build the project using Xcode or command line:

```bash
xcodebuild -project Briefly.xcodeproj -scheme Briefly build
```

Run tests:

```bash
xcodebuild test -project Briefly.xcodeproj -scheme Briefly -destination 'platform=iOS Simulator,name=iPhone 15'
```