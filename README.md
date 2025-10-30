# Icon Grabber

A macOS application built with Swift and SwiftUI that extracts icons from macOS applications and exports them as PNG files.

## Features

- 🎯 **Drag & Drop Support**: Simply drag an application onto the window or browse for it
- 🖼️ **Multiple Icon Sizes**: Choose from 16x16 up to 1024x1024 pixels
- 💾 **PNG Export**: High-quality PNG output with customizable sizes
- ⚙️ **Configurable Defaults**: Set your preferred output format and icon size in Settings
- 🎨 **Live Preview**: See the icon before extracting
- 📱 **Modern UI**: Clean, native macOS interface built with SwiftUI

## Requirements

- macOS 13.0 or later
- Xcode 15.0 or later (for building from source)

## Installation

1. Open `IconGrabber.xcodeproj` in Xcode
2. Build and run the project (⌘R)
3. The app will launch and be ready to use

## Usage

1. **Select an Application**:
   - Drag and drop an `.app` file onto the window, or
   - Click "Browse Applications" to select from your Applications folder

2. **Configure Export Settings**:
   - Choose your desired output format (PNG recommended)
   - Select the icon size (16x16 to 1024x1024)
   - Or use your default settings from Preferences

3. **Extract & Save**:
   - Click "Extract & Save Icon"
   - Choose where to save the exported icon
   - Done! You can optionally open the file in Finder

## Settings

Access Settings from the menu (IconGrabber → Settings... or ⌘,) to configure:
- **Default Output Format**: PNG or SVG (PNG recommended)
- **Default Icon Size**: Your preferred icon dimensions

These defaults will be used each time you extract an icon, but can be overridden for individual extractions.

## Note about SVG Export

macOS app icons are stored as raster images (PNG/ICNS format internally). True SVG export would require vectorization, which is not currently supported. PNG format is recommended for best quality results.

## Project Structure

```
IconGrabber/
├── IconGrabberApp.swift      # Main app entry point
├── Models/
│   ├── AppSettings.swift     # User preferences and settings
│   └── IconExtractor.swift   # Core icon extraction logic
├── Views/
│   ├── ContentView.swift     # Main application window
│   └── SettingsView.swift    # Settings/Preferences window
└── Assets.xcassets/          # App icons and assets
```

## Technical Details

- **Framework**: SwiftUI + AppKit
- **Language**: Swift 5.0
- **Minimum Deployment**: macOS 13.0
- **Sandboxing**: Enabled with user-selected file access

## License

MIT License - feel free to use and modify as needed.

## Contributing

Contributions are welcome! Feel free to submit issues or pull requests.