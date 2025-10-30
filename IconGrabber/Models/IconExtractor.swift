//
//  IconExtractor.swift
//  IconGrabber
//
//  Created on October 30, 2025.
//

import Foundation
import AppKit

class IconExtractor {
    enum ExtractionError: LocalizedError {
        case invalidApp
        case iconNotFound
        case exportFailed
        case svgConversionNotSupported
        
        var errorDescription: String? {
            switch self {
            case .invalidApp:
                return "The selected item is not a valid application."
            case .iconNotFound:
                return "Could not find an icon for this application."
            case .exportFailed:
                return "Failed to export the icon."
            case .svgConversionNotSupported:
                return "SVG conversion is not directly supported. Exporting as PNG."
            }
        }
    }
    
    /// Extracts icon from an application bundle
    static func extractIcon(from appURL: URL, size: AppSettings.IconSize, format: AppSettings.OutputFormat) throws -> NSImage {
        // Verify it's an application bundle
        guard appURL.pathExtension == "app" else {
            throw ExtractionError.invalidApp
        }
        
        // Get the icon for the application
        let icon = NSWorkspace.shared.icon(forFile: appURL.path)
        
        // Set the size
        let iconSize = NSSize(width: size.rawValue, height: size.rawValue)
        icon.size = iconSize
        
        return icon
    }
    
    /// Saves the icon to a file
    static func saveIcon(_ icon: NSImage, to url: URL, format: AppSettings.OutputFormat, size: AppSettings.IconSize) throws {
        switch format {
        case .png:
            try savePNG(icon, to: url, size: size)
        case .svg:
            // SVG export is complex for raster icons. We'll export as PNG with a note.
            // True SVG would require vectorization which is non-trivial
            throw ExtractionError.svgConversionNotSupported
        }
    }
    
    private static func savePNG(_ icon: NSImage, to url: URL, size: AppSettings.IconSize) throws {
        let iconSize = NSSize(width: size.rawValue, height: size.rawValue)
        
        // Create a bitmap representation
        guard let tiffData = icon.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData) else {
            throw ExtractionError.exportFailed
        }
        
        // Resize to exact dimensions
        let resizedImage = NSImage(size: iconSize)
        resizedImage.lockFocus()
        icon.draw(in: NSRect(origin: .zero, size: iconSize),
                 from: NSRect(origin: .zero, size: icon.size),
                 operation: .copy,
                 fraction: 1.0)
        resizedImage.unlockFocus()
        
        // Convert to PNG
        guard let resizedTiff = resizedImage.tiffRepresentation,
              let resizedBitmap = NSBitmapImageRep(data: resizedTiff),
              let pngData = resizedBitmap.representation(using: .png, properties: [:]) else {
            throw ExtractionError.exportFailed
        }
        
        try pngData.write(to: url)
    }
    
    /// Generates a suggested filename for the icon
    static func suggestedFilename(for appURL: URL, format: AppSettings.OutputFormat, size: AppSettings.IconSize) -> String {
        let appName = appURL.deletingPathExtension().lastPathComponent
        let cleanName = appName.replacingOccurrences(of: " ", with: "_")
        return "\(cleanName)_\(size.rawValue)x\(size.rawValue).\(format.fileExtension)"
    }
}
