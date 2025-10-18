import SwiftUI
import os.log

private let cropperLogger = Logger(subsystem: "com.homeworkhelper.app", category: "ImageCropper")

struct ImageCropperView: View {
    @Binding var image: UIImage?
    let onCrop: (UIImage) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedPreset: CropPreset = .third
    @State private var showPresetOptions = true
    @State private var verticalPosition: CGFloat = 0.1 // 0.0 (top) to max allowed (bottom)
    @State private var isImageReady = false
    @State private var displayImage: UIImage? = nil
    
    init(image: Binding<UIImage?>, onCrop: @escaping (UIImage) -> Void) {
        self._image = image
        self.onCrop = onCrop
        cropperLogger.critical("🚨 CRITICAL DEBUG: ImageCropperView init called, image is nil: \(image.wrappedValue == nil)")
    }
    
    enum CropPreset: String, CaseIterable {
        case third = "1/3"
        case half = "1/2"
        case full = "Full"
        
        var description: String {
            switch self {
            case .third: return "Focus on 1-2 problems"
            case .half: return "Focus on 2-4 problems"
            case .full: return "Analyze entire page"
            }
        }
        
        var height: CGFloat {
            switch self {
            case .third: return 0.33
            case .half: return 0.5
            case .full: return 1.0
            }
        }
        
        func cropRect(verticalPosition: CGFloat) -> CGRect {
            switch self {
            case .third, .half:
                return CGRect(x: 0, y: verticalPosition, width: 1.0, height: height)
            case .full:
                return CGRect(x: 0, y: 0, width: 1.0, height: 1.0)
            }
        }
        
        var color: Color {
            switch self {
            case .third: return .green
            case .half: return .blue
            case .full: return .orange
            }
        }
        
        var icon: String {
            switch self {
            case .third: return "rectangle.3.group"
            case .half: return "rectangle.split.2x1"
            case .full: return "rectangle.expand.vertical"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                if isImageReady, let uiImage = displayImage {
                    // Large image preview with movable crop area
                    GeometryReader { geometry in
                        ZStack {
                            // Background image
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            
                            // Preview overlay with drag
                            if selectedPreset != .full {
                                PreviewOverlayView(
                                    image: uiImage,
                                    cropRect: selectedPreset.cropRect(verticalPosition: verticalPosition),
                                    geometry: geometry,
                                    onDrag: { translation in
                                        // Calculate max Y position (can't go below bottom of image)
                                        let maxY = 1.0 - selectedPreset.height
                                        let imageAspect = uiImage.size.width / uiImage.size.height
                                        let viewAspect = geometry.size.width / geometry.size.height
                                        let displayHeight = viewAspect > imageAspect ? geometry.size.height : geometry.size.width / imageAspect
                                        
                                        let normalizedDy = translation / displayHeight
                                        verticalPosition = max(0, min(maxY, verticalPosition + normalizedDy))
                                    }
                                )
                            }
                        }
                    }
                    .background(Color.black)
                    .transition(.opacity)
                } else {
                    // Show loading state
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Preparing image...")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
                }
                
                // Compact Preset Selection at bottom
                VStack(spacing: 8) {
                    // Info message
                    HStack(spacing: 6) {
                        Image(systemName: selectedPreset == .third ? "star.fill" : selectedPreset == .half ? "checkmark.circle.fill" : "info.circle.fill")
                            .foregroundColor(selectedPreset == .third ? .green : selectedPreset == .half ? .blue : .orange)
                            .font(.caption)
                        
                        Text(selectedPreset == .third ? "Best Results - Focused Analysis" : selectedPreset == .half ? "Good Results - Multiple Problems" : "May take longer - Less accurate")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(selectedPreset == .third ? .green : selectedPreset == .half ? .blue : .orange)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(selectedPreset == .third ? Color.green.opacity(0.1) : selectedPreset == .half ? Color.blue.opacity(0.1) : Color.orange.opacity(0.1))
                    )
                    .padding(.horizontal)
                    
                    HStack(spacing: 8) {
                        ForEach(CropPreset.allCases, id: \.self) { preset in
                            Button(action: {
                                selectedPreset = preset
                                // Reset vertical position when changing presets
                                if preset != .full {
                                    verticalPosition = 0.1
                                }
                            }) {
                                VStack(spacing: 2) {
                                    Image(systemName: preset.icon)
                                        .font(.title3)
                                        .foregroundColor(selectedPreset == preset ? .white : preset.color)
                                    
                                    Text(preset.rawValue)
                                        .font(.caption2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(selectedPreset == preset ? .white : .primary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(selectedPreset == preset ? preset.color : Color.gray.opacity(0.1))
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Action Buttons
                    HStack(spacing: 8) {
                        Button("Cancel") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.gray)
                        .cornerRadius(8)
                        
                        Button(action: {
                            if let uiImage = displayImage {
                                let croppedImage = cropImage(uiImage)
                                onCrop(croppedImage)
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "sparkles")
                                Text("Analyze")
                            }
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(selectedPreset.color)
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
            }
        }
        .onAppear {
            cropperLogger.critical("🚨 CRITICAL DEBUG: ImageCropperView onAppear called, image is nil: \(image == nil)")
            loadImageAsync()
        }
    }
    
    private func loadImageAsync() {
        cropperLogger.critical("🚨 CRITICAL DEBUG: loadImageAsync called")
        // Ensure we have an image to load
        guard let sourceImage = image else {
            cropperLogger.critical("❌ CRITICAL DEBUG: No source image in loadImageAsync")
            isImageReady = false
            return
        }
        
        cropperLogger.critical("✅ CRITICAL DEBUG: Source image exists, loading... size: \(sourceImage.size.width)x\(sourceImage.size.height)")
        // Load image on background thread to prevent UI freeze
        Task.detached(priority: .userInitiated) {
            print("🔄 Background: Fixing orientation...")
            // Fix orientation on background thread
            let orientedImage = sourceImage.fixOrientation()
            print("✅ Background: Orientation fixed")
            
            // Update UI on main thread
            await MainActor.run {
                print("🎨 Main thread: Updating UI...")
                withAnimation(.easeIn(duration: 0.2)) {
                    displayImage = orientedImage
                    isImageReady = true
                }
                print("✅ Image ready and displayed")
            }
        }
    }
    
    private func cropImage(_ image: UIImage) -> UIImage {
        // For full image, just return the original
        if selectedPreset == .full {
            return image.fixOrientation()
        }
        
        let orientedImage = image.fixOrientation()
        guard let cgImage = orientedImage.cgImage else { return image }
        
        let pixelWidth = CGFloat(cgImage.width)
        let pixelHeight = CGFloat(cgImage.height)
        
        // Get the crop rect with current vertical position
        let normalizedRect = selectedPreset.cropRect(verticalPosition: verticalPosition)
        
        // Convert normalized crop rect to pixel coordinates
        let actualCropRect = CGRect(
            x: normalizedRect.origin.x * pixelWidth,
            y: normalizedRect.origin.y * pixelHeight,
            width: normalizedRect.width * pixelWidth,
            height: normalizedRect.height * pixelHeight
        )
        
        print("🔍 Preset Crop Debug:")
        print("   Preset: \(selectedPreset.rawValue)")
        print("   Vertical position: \(verticalPosition)")
        print("   Image size: \(pixelWidth) x \(pixelHeight)")
        print("   Normalized rect: \(normalizedRect)")
        print("   Actual crop rect: \(actualCropRect)")
        
        guard let croppedCGImage = cgImage.cropping(to: actualCropRect) else {
            print("❌ Failed to crop")
            return image
        }
        
        print("✅ Cropped successfully: \(croppedCGImage.width) x \(croppedCGImage.height)")
        return UIImage(cgImage: croppedCGImage, scale: 1.0, orientation: .up)
    }
}

struct PreviewOverlayView: View {
    let image: UIImage
    let cropRect: CGRect
    let geometry: GeometryProxy
    let onDrag: (CGFloat) -> Void
    
    @State private var dragStart: CGFloat = 0
    
    var body: some View {
        let imageSize = image.size
        let viewSize = geometry.size
        
        // Calculate how the image is displayed (scaled to fit)
        let imageAspect = imageSize.width / imageSize.height
        let viewAspect = viewSize.width / viewSize.height
        
        let displayWidth: CGFloat
        let displayHeight: CGFloat
        
        if viewAspect > imageAspect {
            // View is wider - image fits height
            displayHeight = viewSize.height
            displayWidth = displayHeight * imageAspect
        } else {
            // View is taller - image fits width
            displayWidth = viewSize.width
            displayHeight = displayWidth / imageAspect
        }
        
        // Center the image
        let imageOffsetX = (viewSize.width - displayWidth) / 2
        let imageOffsetY = (viewSize.height - displayHeight) / 2
        
        return ZStack {
            // Dimming overlay
            Rectangle()
                .fill(Color.black.opacity(0.3))
                .frame(width: viewSize.width, height: viewSize.height)
            
            // Clear area for crop preview
            Rectangle()
                .fill(Color.clear)
                .frame(
                    width: displayWidth * cropRect.width,
                    height: displayHeight * cropRect.height
                )
                .position(
                    x: imageOffsetX + displayWidth * (cropRect.origin.x + cropRect.width / 2),
                    y: imageOffsetY + displayHeight * (cropRect.origin.y + cropRect.height / 2)
                )
                .blendMode(.destinationOut)
            
            // Draggable overlay - covers the entire crop area for easier dragging
            Rectangle()
                .fill(Color.white.opacity(0.001)) // Nearly invisible but captures touches
                .frame(
                    width: displayWidth * cropRect.width,
                    height: displayHeight * cropRect.height
                )
                .position(
                    x: imageOffsetX + displayWidth * (cropRect.origin.x + cropRect.width / 2),
                    y: imageOffsetY + displayHeight * (cropRect.origin.y + cropRect.height / 2)
                )
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            if dragStart == 0 {
                                dragStart = value.translation.height
                            }
                            let delta = value.translation.height - dragStart
                            onDrag(delta)
                            dragStart = value.translation.height
                        }
                        .onEnded { _ in
                            dragStart = 0
                        }
                )
            
            // Preview frame (non-interactive)
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.green, lineWidth: 4)
                .frame(
                    width: displayWidth * cropRect.width,
                    height: displayHeight * cropRect.height
                )
                .position(
                    x: imageOffsetX + displayWidth * (cropRect.origin.x + cropRect.width / 2),
                    y: imageOffsetY + displayHeight * (cropRect.origin.y + cropRect.height / 2)
                )
                .shadow(color: .green.opacity(0.6), radius: 10)
                .allowsHitTesting(false)
            
            // Drag instruction label
            HStack {
                Image(systemName: "arrow.up.and.down")
                    .font(.caption)
                Text("Drag area to move")
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.green)
                    .shadow(color: .black.opacity(0.3), radius: 4)
            )
            .position(
                x: imageOffsetX + displayWidth * (cropRect.origin.x + cropRect.width / 2),
                y: imageOffsetY + displayHeight * (cropRect.origin.y + cropRect.height / 2)
            )
            .allowsHitTesting(false)
        }
        .compositingGroup()
    }
}

extension UIImage {
    func fixOrientation() -> UIImage {
        if imageOrientation == .up {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return normalizedImage ?? self
    }
}