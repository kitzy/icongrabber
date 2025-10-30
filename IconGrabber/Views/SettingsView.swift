//
//  SettingsView.swift
//  IconGrabber
//
//  Created on October 30, 2025.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: AppSettings
    
    var body: some View {
        Form {
            Section {
                Picker("Default Output Format:", selection: $settings.defaultOutputFormat) {
                    ForEach(AppSettings.OutputFormat.allCases) { format in
                        Text(format.rawValue).tag(format)
                    }
                }
                .pickerStyle(.segmented)
                
                Picker("Default Icon Size:", selection: $settings.defaultIconSize) {
                    ForEach(AppSettings.IconSize.allCases) { size in
                        Text(size.displayName).tag(size)
                    }
                }
                .pickerStyle(.menu)
            } header: {
                Text("Default Export Settings")
            } footer: {
                Text("These settings will be used as defaults when extracting icons. You can override them for individual extractions.")
                    .font(.caption)
            }
            
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Note about SVG Export")
                        .font(.headline)
                    Text("macOS app icons are raster images (PNG/ICNS format). True SVG export requires vectorization, which is not currently supported. PNG format is recommended for best results.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 500, height: 300)
        .padding()
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppSettings())
}
