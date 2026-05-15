import SwiftUI

struct ProfileImageManager {
    static let fileName = "user_profile_avatar.jpg"
    
    // Gets the secure file URL path on the local device disk
    static var fileURL: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent(fileName)
    }
    
    // Saves raw image data locally
    static func saveImage(data: Data) {
        try? data.write(to: fileURL)
    }
    
    // Removes the image file completely from disk
    static func deleteImage() {
        try? FileManager.default.removeItem(at: fileURL)
    }
    
    // Loads the image safely back as a SwiftUI Image element if it exists
    static func loadLocalImage() -> Image? {
        if let data = try? Data(contentsOf: fileURL), let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        }
        return nil
    }
}
