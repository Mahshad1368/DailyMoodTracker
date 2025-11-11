//
//  ImagePicker.swift
//  DailyMoodTracker
//
//  UIImagePickerController wrapper for camera and photo library access
//

import SwiftUI
import UIKit

struct ImagePicker: UIViewControllerRepresentable {
    enum SourceType {
        case camera
        case photoLibrary
    }

    let sourceType: SourceType
    @Binding var selectedImageData: Data?
    @Environment(\.dismiss) var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()

        // Set source type
        switch sourceType {
        case .camera:
            picker.sourceType = .camera
        case .photoLibrary:
            picker.sourceType = .photoLibrary
        }

        picker.delegate = context.coordinator
        picker.allowsEditing = false

        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                // Compress image to reasonable size (max 2MB)
                if let data = compressImage(image) {
                    parent.selectedImageData = data
                }
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }

        // Compress image to save storage space
        private func compressImage(_ image: UIImage) -> Data? {
            // Try different compression qualities until under 2MB
            let maxSize: Int = 2 * 1024 * 1024 // 2MB
            var compression: CGFloat = 0.8

            while compression > 0.1 {
                if let data = image.jpegData(compressionQuality: compression) {
                    if data.count <= maxSize {
                        return data
                    }
                }
                compression -= 0.1
            }

            // If still too large, resize the image
            let resizedImage = resizeImage(image, maxDimension: 1920)
            return resizedImage.jpegData(compressionQuality: 0.7)
        }

        // Resize image if too large
        private func resizeImage(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
            let size = image.size
            let ratio = max(size.width, size.height) / maxDimension

            if ratio <= 1 {
                return image // Already small enough
            }

            let newSize = CGSize(width: size.width / ratio, height: size.height / ratio)

            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.draw(in: CGRect(origin: .zero, size: newSize))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return newImage ?? image
        }
    }
}
