// Services/WallpaperService.swift
// This is the ROUTER — it looks at the selected category and decides
// which API to call. Your ViewModel doesn't need to know or care
// which API is being used — it just asks WallpaperService for a wallpaper.
//
// This pattern is called a "Service Layer" — it keeps your ViewModel clean
// and makes it easy to add more APIs in the future.

import Foundation

class WallpaperService {

    // One instance of each API service
    private let wallhaven = WallhavenAPI()
    private let unsplash = UnsplashAPI()

    // The single function the ViewModel calls — it handles routing internally
    func fetchRandom(for category: WallpaperCategory) async throws -> Wallpaper {
        switch category {

        case .anime:
            // Anime → always Wallhaven (best anime source)
            return try await wallhaven.fetchRandomWallpaper(categoryCode: "010")

        case .aesthetic:
            // Aesthetic → always Unsplash (best aesthetic source)
            return try await unsplash.fetchRandomWallpaper()

        case .both:
            // Both → randomly pick one of the two APIs each time
            // Bool.random() returns true or false with 50/50 chance
            if Bool.random() {
                return try await wallhaven.fetchRandomWallpaper(categoryCode: "110")
            } else {
                return try await unsplash.fetchRandomWallpaper()
            }
        }
    }

    // Download still lives in WallhavenAPI but we expose it here
    // so the ViewModel only ever talks to WallpaperService
    func downloadImage(from urlString: String) async throws -> URL {
        return try await wallhaven.downloadImage(from: urlString)
    }
}
