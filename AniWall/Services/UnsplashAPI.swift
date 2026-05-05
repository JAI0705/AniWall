// Services/UnsplashAPI.swift
// Handles all communication with the Unsplash API.
// Unsplash returns a very different JSON structure than Wallhaven,
// but we convert it into our existing Wallpaper model at the end —
// so the rest of the app doesn't need to care which API was used.

import Foundation

class UnsplashAPI {

    private let accessKey = "6ben6xsx94_SbFlQCo8n1S2CeQFqqxWYDBITFoS95_U"  // ← paste your key here
    private let baseURL = "https://api.unsplash.com"

    func fetchRandomWallpaper() async throws -> Wallpaper {

        var components = URLComponents(string: "\(baseURL)/photos/random")!
        components.queryItems = [
            // Search terms for aesthetic wallpapers — feel free to customise these
            URLQueryItem(name: "query", value: "aesthetic lofi anime landscape"),

            // orientation=landscape ensures we get wallpaper-shaped images
            URLQueryItem(name: "orientation", value: "landscape"),

            // content_filter=high = safe content only
            URLQueryItem(name: "content_filter", value: "high"),
        ]

        guard let url = components.url else {
            throw UnsplashError.invalidURL
        }

        // Unsplash requires you to send your Access Key as a header, not a query param
        var request = URLRequest(url: url)
        request.setValue("Client-ID \(accessKey)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw UnsplashError.badResponse
        }

        // Decode Unsplash's own JSON format
        let unsplashPhoto = try JSONDecoder().decode(UnsplashPhoto.self, from: data)

        // Convert Unsplash's format into our app's Wallpaper model
        // This is the key step — the rest of the app only knows about Wallpaper,
        // not about Unsplash or Wallhaven specifically
        return unsplashPhoto.toWallpaper()
    }

    // MARK: - Unsplash JSON Model
    // This mirrors what the Unsplash API actually returns.
    // We only decode the fields we care about — Swift ignores the rest automatically.

    struct UnsplashPhoto: Codable {
        let id: String
        let urls: URLs
        let width: Int
        let height: Int

        struct URLs: Codable {
            let raw: String      // original file — we use this as the "path" to download
            let full: String     // full resolution (slightly compressed)
            let regular: String  // ~1080px — good for thumbnail preview
            let small: String    // ~400px — fast loading
        }

        // Convert UnsplashPhoto → our Wallpaper model
        func toWallpaper() -> Wallpaper {
            // Build a resolution string like "3840x2160" from the actual dimensions
            let resolution = "\(width)x\(height)"

            // Append ?w=3840&q=85 to the raw URL to request a 4K version from Unsplash's CDN
            // Unsplash's CDN (imgix) supports URL-based resizing — this is the correct way to get 4K
            let fullResURL = "\(urls.raw)&w=3840&q=85&fm=jpg"

            return Wallpaper(
                id: id,
                path: fullResURL,       // full res for downloading and setting as wallpaper
                resolution: resolution,
                thumbs: Wallpaper.Thumbs(
                    original: urls.full,
                    large: urls.regular,  // shown in the popup preview
                    small: urls.small
                )
            )
        }
    }

    enum UnsplashError: Error, LocalizedError {
        case invalidURL
        case badResponse

        var errorDescription: String? {
            switch self {
            case .invalidURL:   return "Unsplash URL was invalid."
            case .badResponse:  return "Unsplash returned an error. Check your Access Key."
            }
        }
    }
}
