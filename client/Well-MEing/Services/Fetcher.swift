import SwiftUI

func loadImage(url: URL) async -> Image? {
    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        if let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        }
    } catch {
        print("Failed to load image: \(error.localizedDescription)")
    }
    return nil
}
