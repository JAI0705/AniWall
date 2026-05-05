// ViewModels/WallpaperViewModel.swift

import SwiftUI
import Combine

// MARK: - Category Enum
// Defined here so both the ViewModel and PopoverView can access it
// Each case maps to a different API source in WallpaperService
enum WallpaperCategory: String, CaseIterable {
    case anime      // → Wallhaven
    case aesthetic  // → Unsplash
    case both       // → random mix of both

    var label: String {
        switch self {
        case .anime:      return "Anime"
        case .aesthetic:  return "Aesthetic"
        case .both:       return "Mix"
        }
    }
}

@MainActor
class WallpaperViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var currentWallpaper: Wallpaper? = nil
    @Published var isLoading: Bool = false
    @Published var isSettingWallpaper: Bool = false
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil
    @Published var previewImage: NSImage? = nil

    // NEW — tracks which category the user has selected in the picker
    // When this changes, PopoverView will trigger a new fetch automatically
    @Published var selectedCategory: WallpaperCategory = .anime

    // MARK: - Private Properties

    // ← THIS IS THE KEY CHANGE
    // We replaced WallhavenAPI() with WallpaperService()
    // The ViewModel no longer cares which API is being used — WallpaperService handles that
    private let service = WallpaperService()

    // MARK: - Actions

    func fetchNewWallpaper() {
        Task {
            isLoading = true
            errorMessage = nil
            successMessage = nil
            previewImage = nil

            do {
                // ← CHANGED: now passes selectedCategory to the service router
                let wallpaper = try await service.fetchRandom(for: selectedCategory)
                currentWallpaper = wallpaper
                await loadPreviewImage(from: wallpaper.thumbs.large)

            } catch {
                errorMessage = error.localizedDescription
            }

            isLoading = false
        }
    }

    func setCurrentAsWallpaper() {
        guard let wallpaper = currentWallpaper else {
            print("❌ No wallpaper to set")
            return
        }

        print("⬇️ Downloading from: \(wallpaper.path)")

        Task {
            isSettingWallpaper = true
            errorMessage = nil
            successMessage = nil

            do {
                let localURL = try await service.downloadImage(from: wallpaper.path)
                print("✅ Downloaded to: \(localURL.path)")

                try WallpaperSetter.set(from: localURL)
                print("✅ Wallpaper set!")

                successMessage = "Wallpaper set! 🌸"
                try await Task.sleep(nanoseconds: 3_000_000_000)
                successMessage = nil

            } catch {
                print("❌ Error: \(error)")
                errorMessage = error.localizedDescription
            }

            isSettingWallpaper = false
        }
    }
    // MARK: - Private Helpers
    // This function is completely unchanged
    private func loadPreviewImage(from urlString: String) async {
        guard let url = URL(string: urlString) else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            previewImage = NSImage(data: data)
        } catch {
            print("Preview image failed to load: \(error)")
        }
    }
}
