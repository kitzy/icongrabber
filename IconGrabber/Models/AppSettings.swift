//
//  AppSettings.swift
//  IconGrabber
//
//  Created on October 30, 2025.
//

import Foundation
import SwiftUI

class AppSettings: ObservableObject {
    @AppStorage("defaultOutputFormat") var defaultOutputFormat: OutputFormat = .png
    @AppStorage("defaultIconSize") var defaultIconSize: IconSize = .size512
    
    enum OutputFormat: String, CaseIterable, Identifiable {
        case png = "PNG"
        case svg = "SVG"
        
        var id: String { self.rawValue }
        
        var fileExtension: String {
            switch self {
            case .png: return "png"
            case .svg: return "svg"
            }
        }
    }
    
    enum IconSize: Int, CaseIterable, Identifiable {
        case size16 = 16
        case size32 = 32
        case size64 = 64
        case size128 = 128
        case size256 = 256
        case size512 = 512
        case size1024 = 1024
        
        var id: Int { self.rawValue }
        
        var displayName: String {
            "\(rawValue)x\(rawValue)"
        }
    }
}
