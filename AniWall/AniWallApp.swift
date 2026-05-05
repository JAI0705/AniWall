// AniWallApp.swift
// This is the ENTRY POINT of your app — the first file Swift looks at when your app launches.
// Think of it like the "main door" of your app.

import SwiftUI

// @main tells Swift: "this struct is where everything begins"
@main
struct AniWallApp: App {
    
    init() {
        print("✅ App launched successfully")
    }

    // Every app in SwiftUI has a "body" — it describes what your app contains.
    var body: some Scene {

        // MenuBarExtra creates the little icon that lives in your Mac's top menu bar.
        // "systemImage" uses Apple's built-in SF Symbols icon library.
        // Try different icons: "photo.fill", "sparkles", "wand.and.stars", "moon.stars.fill"
        MenuBarExtra("AniWall", systemImage: "sparkles") {

            // This is what appears when the user clicks the menu bar icon.
            // PopoverView is a SwiftUI view we'll build in the Views/ folder.
            PopoverView()
        }
        // .window style makes it appear as a floating panel (popover style)
        // The alternative is .menu which shows a dropdown list — we don't want that
        .menuBarExtraStyle(.window)
    }
}


// TODO: 1. Complete the app
// TODO: 2. MAke the UI better
// TODO: 3. To set wallpaper on every desktop in system
// TODO: 4. Find a way to make wallpaper selection better
