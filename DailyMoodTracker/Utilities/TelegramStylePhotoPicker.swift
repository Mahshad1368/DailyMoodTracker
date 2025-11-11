//
//  TelegramStylePhotoPicker.swift
//  DailyMoodTracker
//
//  UIImagePickerController wrapper that opens photo library with camera access
//  Mimics Telegram's photo picker behavior
//

import SwiftUI
import UIKit

struct TelegramStylePhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedImageData: Data?
    @Environment(\.dismiss) var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()

        // Use photo library source - this shows gallery with camera option on iOS
        picker.sourceType = .photoLibrary
        picker.delegate = context.coordinator
        picker.allowsEditing = false

        // Enable camera access if available
        picker.cameraCaptureMode = .photo

        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: TelegramStylePhotoPicker

        init(_ parent: TelegramStylePhotoPicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                // Compress image to max 2MB like Telegram
                if let data = compressImage(image) {
                    parent.selectedImageData = data
                }
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
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

            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.draw(in: CGRect(origin: .zero, size: newSize))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return newImage ?? image
        }
    }
}
