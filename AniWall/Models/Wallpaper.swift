// Models/Wallpaper.swift
// A MODEL is just a Swift structure that describes the "shape" of your data.
// When the Wallhaven API sends us wallpaper info, it comes as JSON.
// This struct tells Swift: "here's what that JSON looks like, decode it for me."

import Foundation

// Codable = Swift can automatically convert JSON <-> this struct
// Identifiable = every Wallpaper has a unique id (needed for SwiftUI lists)
struct Wallpaper: Codable, Identifiable {

    // These property names MUST match the JSON keys from the Wallhaven API exactly.
    // The API returns something like:
    // { "id": "abc123", "path": "https://...", "resolution": "3840x2160", "thumbs": {...} }

    let id: String           // unique ID for each wallpaper, e.g. "8oxrz1"
    let path: String         // the full 4K image URL — this is what we download
    let resolution: String   // e.g. "3840x2160"
    let thumbs: Thumbs       // a nested object with preview image URLs

    // Thumbs is a nested struct — it lives inside the Wallpaper struct
    // because it only makes sense in the context of a wallpaper
    struct Thumbs: Codable {
        let original: String  // full-res thumbnail URL
        let large: String     // large preview — we use this in our popup UI
        let small: String     // smallest preview — useful for quick loading
    }
}

// This struct represents the FULL response from the Wallhaven API.
// The API wraps the wallpaper list in a "data" key, like this:
// { "data": [ {...wallpaper1...}, {...wallpaper2...} ], "meta": {...} }
struct WallhavenResponse: Codable {
    let data: [Wallpaper]   // an array of Wallpaper objects
}
