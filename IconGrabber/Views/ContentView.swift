//
//  ContentView.swift
//  IconGrabber
//
//  Created on October 30, 2025.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject var settings: AppSettings
    @State private var selectedApp: URL?
    @State private var extractedIcon: NSImage?
    @State private var isProcessing = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var showSuccessAlert = false
    @State private var savedFileURL: URL?
    
    // Override settings for this session
    @State private var selectedFormat: AppSettings.OutputFormat?
    @State private var selectedSize: AppSettings.IconSize?
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            Text("Icon Grabber")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 30)
            
            Text("Extract icons from macOS applications")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            // Drop zone or selected app
            if let appURL = selectedApp {
                VStack(spacing: 15) {
                    if let icon = extractedIcon {
                        Image(nsImage: icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 128, height: 128)
                            .shadow(radius: 5)
                    }
                    
                    Text(appURL.deletingPathExtension().lastPathComponent)
                        .font(.headline)
                    
                    Text(appURL.path)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .frame(maxWidth: 400)
                    
                    Button("Choose Different App") {
                        selectApp()
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.blue)
                }
                .padding()
            } else {
                VStack(spacing: 15) {
                    Image(systemName: "app.dashed")
                        .font(.system(size: 64))
                        .foregroundColor(.secondary)
                    
                    Text("Drop an app here or click to browse")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Button("Browse Applications") {
                        selectApp()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: 200)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [10]))
                        .foregroundColor(.secondary.opacity(0.5))
                )
                .padding(.horizontal, 40)
                .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                    handleDrop(providers: providers)
                }
            }
            
            Spacer()
            
            // Settings for this extraction
            VStack(alignment: .leading, spacing: 12) {
                Text("Export Options")
                    .font(.headline)
                
                HStack {
                    Text("Format:")
                        .frame(width: 80, alignment: .trailing)
                    
                    Picker("Format", selection: Binding(
                        get: { selectedFormat ?? settings.defaultOutputFormat },
                        set: { selectedFormat = $0 }
                    )) {
                        ForEach(AppSettings.OutputFormat.allCases) { format in
                            Text(format.rawValue).tag(format)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 150)
                    
                    Text("(Default: \(settings.defaultOutputFormat.rawValue))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Size:")
                        .frame(width: 80, alignment: .trailing)
                    
                    Picker("Size", selection: Binding(
                        get: { selectedSize ?? settings.defaultIconSize },
                        set: { selectedSize = $0 }
                    )) {
                        ForEach(AppSettings.IconSize.allCases) { size in
                            Text(size.displayName).tag(size)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(width: 150)
                    
                    Text("(Default: \(settings.defaultIconSize.displayName))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(8)
            .padding(.horizontal, 40)
            
            // Export button
            Button(action: exportIcon) {
                HStack {
                    if isProcessing {
                        ProgressView()
                            .scaleEffect(0.8)
                            .frame(width: 16, height: 16)
                    } else {
                        Image(systemName: "square.and.arrow.down")
                    }
                    Text(isProcessing ? "Extracting..." : "Extract & Save Icon")
                }
                .frame(width: 200)
            }
            .buttonStyle(.borderedProminent)
            .disabled(selectedApp == nil || isProcessing)
            .padding(.bottom, 30)
        }
        .frame(minWidth: 600, minHeight: 500)
        .alert("Error", isPresented: $showError, presenting: errorMessage) { _ in
            Button("OK") { }
        } message: { message in
            Text(message)
        }
        .alert("Success!", isPresented: $showSuccessAlert, presenting: savedFileURL) { url in
            Button("OK") { }
            Button("Show in Finder") {
                if let url = savedFileURL {
                    NSWorkspace.shared.activateFileViewerSelecting([url])
                }
            }
        } message: { url in
            Text("Icon saved to:\n\(url.path)")
        }
    }
    
    private func selectApp() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [UTType.application]
        panel.directoryURL = URL(fileURLWithPath: "/Applications")
        
        if panel.runModal() == .OK, let url = panel.url {
            handleSelectedApp(url)
        }
    }
    
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }
        
        _ = provider.loadObject(ofClass: URL.self) { url, _ in
            if let url = url, url.pathExtension == "app" {
                DispatchQueue.main.async {
                    handleSelectedApp(url)
                }
            }
        }
        return true
    }
    
    private func handleSelectedApp(_ url: URL) {
        selectedApp = url
        
        // Extract icon for preview
        do {
            let icon = try IconExtractor.extractIcon(
                from: url,
                size: .size128,
                format: .png
            )
            extractedIcon = icon
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    private func exportIcon() {
        guard let appURL = selectedApp else { return }
        
        let format = selectedFormat ?? settings.defaultOutputFormat
        let size = selectedSize ?? settings.defaultIconSize
        
        // Show save panel
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [UTType(filenameExtension: format.fileExtension) ?? .data]
        savePanel.nameFieldStringValue = IconExtractor.suggestedFilename(
            for: appURL,
            format: format,
            size: size
        )
        savePanel.canCreateDirectories = true
        
        if savePanel.runModal() == .OK, let saveURL = savePanel.url {
            isProcessing = true
            
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let icon = try IconExtractor.extractIcon(
                        from: appURL,
                        size: size,
                        format: format
                    )
                    
                    // Try to save
                    do {
                        try IconExtractor.saveIcon(icon, to: saveURL, format: format, size: size)
                        
                        DispatchQueue.main.async {
                            isProcessing = false
                            savedFileURL = saveURL
                            showSuccessAlert = true
                        }
                    } catch IconExtractor.ExtractionError.svgConversionNotSupported {
                        // Fallback to PNG if SVG is not supported
                        let pngURL = saveURL.deletingPathExtension().appendingPathExtension("png")
                        try IconExtractor.saveIcon(icon, to: pngURL, format: .png, size: size)
                        
                        DispatchQueue.main.async {
                            isProcessing = false
                            savedFileURL = pngURL
                            errorMessage = "SVG export not supported. Saved as PNG instead."
                            showError = true
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        isProcessing = false
                        errorMessage = error.localizedDescription
                        showError = true
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppSettings())
}
