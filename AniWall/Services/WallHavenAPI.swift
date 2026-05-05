// Services/WallhavenAPI.swift
// This file handles ALL communication with the Wallhaven API.
// Keeping networking in its own file is good practice — it means if the API changes,
// you only need to update ONE file, not hunt through your entire project.

import Foundation

// A class marked as "actor" is thread-safe — important for async network calls.
// But for simplicity as a beginner, we'll use a regular class.
class WallhavenAPI {

    // MARK: - Configuration
    // MARK: is just a comment marker that helps Xcode organize your code with jump bar sections.

    // Your Wallhaven API key — get this from wallhaven.cc → Account Settings → API Key
    // For SFW anime content you don't strictly need it, but it gives you higher rate limits.
    private let apiKey = "Zwt9DA6y2kdmf2LZTMYaXGN74C4CcHXv"

    // The base URL for all Wallhaven API requests
    private let baseURL = "https://wallhaven.cc/api/v1"

    // MARK: - Fetch Random Wallpaper

    // "async throws" means:
    //   - async: this function might take time (network request), don't freeze the UI
    //   - throws: this function might fail (no internet, bad API key, etc.)
    // The -> Wallpaper means it returns a single Wallpaper object when done
    func fetchRandomWallpaper(categoryCode: String = "010") async throws -> Wallpaper {

        // Build the URL with query parameters
        // Let's break down each parameter:
        var components = URLComponents(string: "\(baseURL)/search")!

        components.queryItems = [
            // categories: 3 digits for General / Anime / People
            // "010" = only Anime, "110" = General + Anime (recommended)
            URLQueryItem(name: "categories", value: categoryCode),

            // purity: 3 digits for SFW / Sketchy / NSFW
            // "100" = SFW only (always use this!)
            URLQueryItem(name: "purity", value: "100"),

            // resolutions: filter to only 4K wallpapers
            // You can also try "2560x1440" for 1440p
            URLQueryItem(name: "resolutions", value: "3840x2160"),

            // sorting: "random" gives a different wallpaper each time
            // Other options: "toplist", "latest", "hot"
            URLQueryItem(name: "sorting", value: "random"),

            // atleast: minimum resolution — catches slightly different 4K sizes
            URLQueryItem(name: "atleast", value: "2560x1440"),

            // Your API key
            URLQueryItem(name: "apikey", value: apiKey)
        ]

        // Make sure our URL is valid — if not, something is very wrong
        guard let url = components.url else {
            throw APIError.invalidURL
        }

        // URLSession is Apple's built-in networking tool.
        // .shared is the default session — fine for our use case.
        // data(from:) fetches the URL and gives us back raw data + response info.
        let (data, response) = try await URLSession.shared.data(from: url)

        // Check that we got a valid HTTP response (status code 200 = success)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.badResponse
        }

        // JSONDecoder converts raw JSON bytes into our WallhavenResponse struct.
        // If the JSON doesn't match our struct, it will throw an error here.
        let decoded = try JSONDecoder().decode(WallhavenResponse.self, from: data)

        // The API returns multiple results — we just want one random one.
        // .randomElement() picks a random item from the array.
        // If the array is empty (no results for our filters), throw an error.
        guard let wallpaper = decoded.data.randomElement() else {
            throw APIError.noResults
        }

        return wallpaper
    }

    // MARK: - Download Image to Disk

    // Before we can set a wallpaper on macOS, we need to save it as a local file.
    // This function downloads the image and saves it to a temp folder.
    // It returns the local file URL (like /tmp/aniwall/current.jpg)
    func downloadImage(from urlString: String) async throws -> URL {

        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }

        let (data, _) = try await URLSession.shared.data(from: url)

        // Use Pictures folder instead of temp — more accessible to macOS wallpaper system
        let picturesURL = FileManager.default.urls(
            for: .picturesDirectory,
            in: .userDomainMask
        ).first!

        let aniWallDir = picturesURL.appendingPathComponent("AniWall", isDirectory: true)

        try FileManager.default.createDirectory(
            at: aniWallDir,
            withIntermediateDirectories: true
        )

        // Unique filename using timestamp — prevents macOS caching the same file
        let timestamp = Int(Date().timeIntervalSince1970)
        let fileURL = aniWallDir.appendingPathComponent("wallpaper_\(timestamp).jpg")
        try data.write(to: fileURL)
        // Clean up old wallpaper files — keep only the latest one
        let oldFiles = try? FileManager.default.contentsOfDirectory(
            at: aniWallDir,
            includingPropertiesForKeys: nil
        ).filter { $0.pathExtension == "jpg" && $0.lastPathComponent != fileURL.lastPathComponent }

        oldFiles?.forEach { try? FileManager.default.removeItem(at: $0) }

        print("📁 Saved to: \(fileURL.path)")
        
        return fileURL
    }

    // MARK: - Error Types

    // It's good practice to define your own error types — it makes debugging much easier.
    // Each case represents a different thing that can go wrong.
    enum APIError: Error, LocalizedError {
        case invalidURL
        case badResponse
        case noResults

        // errorDescription lets you show a human-readable message
        var errorDescription: String? {
            switch self {
            case .invalidURL:    return "The URL was invalid."
            case .badResponse:   return "The server returned an error. Check your API key."
            case .noResults:     return "No wallpapers found. Try changing filters."
            }
        }
    }
}
