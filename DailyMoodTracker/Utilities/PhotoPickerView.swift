//
//  PhotoPickerView.swift
//  DailyMoodTracker
//
//  PHPickerViewController wrapper for photo gallery selection
//

import SwiftUI
import PhotosUI

struct PhotoPickerView: UIViewControllerRepresentable {
    @Binding var selectedImageData: Data?
    @Environment(\.dismiss) var dismiss

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())

        // Configure picker to show photos
        configuration.filter = .images
        configuration.selectionLimit = 1
        configuration.preferredAssetRepresentationMode = .current

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator

        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPickerView

        init(_ parent: PhotoPickerView) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()

            guard let result = results.first else { return }

            // Load image data
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                guard let self = self, let image = object as? UIImage else { return }

                // Compress image on background thread
                DispatchQueue.global(qos: .userInitiated).async {
                    let compressedData = self.compressImage(image)

                    // Update on main thread
                    DispatchQueue.main.async {
                        self.parent.selectedImageData = compressedData
                    }
                }
            }
        }

        private func compressImage(_ image: UIImage) -> Data? {
            let maxSize: Int = 2 * 1024 * 1024 // 2MB max
            var compression: CGFloat = 0.8

            // Try different compression levels
            while compression > 0.1 {
                if let data = image.jpegData(compressionQuality: compression) {
                    if data.count <= maxSize {
                        return data
                    }
                }
                compression -= 0.1
            }

            // If still too large, resize
            let resizedImage = resizeImage(image, maxDimension: 1920)
            return resizedImage.jpegData(compressionQuality: 0.7)
        }

        private func resizeImage(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
            let size = image.size
            let ratio = max(size.width, size.height) / maxDimension

            if ratio <= 1 {
                return image
            }

            let newSize = CGSize(width: size.width / ratio, height: size.height / ratio)

            // Use UIGraphicsImageRenderer instead of deprecated UIGraphics APIs
            let renderer = UIGraphicsImageRenderer(size: newSize)
            let newImage = renderer.image { context in
                image.draw(in: CGRect(origin: .zero, size: newSize))
            }

            return newImage
        }
    }
}
