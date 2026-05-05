# AniWall 🌸

A macOS menu bar app that brings 4K anime and aesthetic wallpapers to your desktop in one click. No more jumping between websites.

![AniWall UI](screenshots/preview.png)

---

## The Story

Got a new MacBook. Spent two hours jumping between Wallhaven, Pinterest, and Reddit just trying to find a decent wallpaper. At some point I thought — why isn't there an app that does this for me?

So I built one. Inspired by the Unsplash Mac app, but made for anime and aesthetic wallpapers.

---

## Features

- **Menu bar native** — lives in your menu bar, always one click away, no Dock clutter
- **4K wallpapers** — pulls high resolution wallpapers from two sources
- **Two wallpaper sources** — Wallhaven for anime, Unsplash for aesthetic photography
- **Live preview** — see the wallpaper before setting it
- **One tap to set** — downloads and sets your wallpaper instantly
- **Three categories** — Anime, Aesthetic, or a Mix of both
- **Multi-monitor support** — sets wallpaper across all connected displays
- **Completely free** — no subscription, no account needed

---

## Screenshots

| Menu Bar | Anime Category | Aesthetic Category |
|----------|---------------|-------------------|
| ![Menu Bar](screenshots/menubar.png) | ![Anime](screenshots/anime.png) | ![Aesthetic](screenshots/aesthetic.png) |

---

## Download

**[⬇ Download AniWall v1.0](https://github.com/yourusername/AniWall/releases/latest)**

### Installation

1. Download `AniWall.zip` from the link above
2. Unzip and drag `AniWall.app` to your **Applications** folder
3. Right click → **Open** → **Open Anyway** (required first time — app is not yet notarized)
4. The ✦ sparkles icon appears in your menu bar
5. Click it and start browsing

> **Why the "Open Anyway" step?** AniWall is independently distributed and not yet on the Mac App Store. This is a standard macOS security step for indie apps — it's safe.

---

## Requirements

- macOS 13 (Ventura) or later
- Internet connection (for fetching wallpapers)
- Apple Silicon or Intel Mac

---

## How It Works

```
Click menu bar icon
        ↓
AniWall fetches a random wallpaper
from Wallhaven (anime) or Unsplash (aesthetic)
        ↓
Thumbnail loads in the preview card
        ↓
Click "Set Wallpaper"
        ↓
Full 4K image downloads to ~/Pictures/AniWall/
        ↓
macOS sets it as your desktop wallpaper
```

---

## Built With

- **Swift 5.9**
- **SwiftUI** — all UI is native SwiftUI, no AppKit views
- **MenuBarExtra** — Apple's modern menu bar API (macOS 13+)
- **Wallhaven API** — anime wallpapers
- **Unsplash API** — aesthetic wallpapers
- **NSWorkspace** — macOS wallpaper setting

---

## Project Structure

```
AniWall/
├── Models/
│   └── Wallpaper.swift          ← data shape for wallpaper objects
│
├── Services/
│   ├── WallhavenAPI.swift        ← fetches from Wallhaven + downloads images
│   ├── UnsplashAPI.swift         ← fetches from Unsplash
│   ├── WallpaperService.swift    ← router — decides which API to call
│   └── WallpaperSetter.swift     ← sets wallpaper via NSWorkspace
│
├── ViewModels/
│   └── WallpaperViewModel.swift  ← app state, actions, business logic
│
├── Views/
│   └── PopoverView.swift         ← all UI — menu bar popup
│
└── AniWallApp.swift              ← entry point, MenuBarExtra setup
```

---

## Build It Yourself

### Prerequisites
- Xcode 15 or later
- macOS 13 or later
- Free Apple Developer account (for signing)

### API Keys

You'll need two free API keys:

**Wallhaven** (anime wallpapers)
1. Sign up at [wallhaven.cc](https://wallhaven.cc)
2. Go to Account Settings → API Key
3. Paste it into `WallhavenAPI.swift`:
```swift
private let apiKey = "YOUR_WALLHAVEN_KEY"
```

**Unsplash** (aesthetic wallpapers)
1. Sign up at [unsplash.com/developers](https://unsplash.com/developers)
2. Create a new app → copy the Access Key
3. Paste it into `UnsplashAPI.swift`:
```swift
private let accessKey = "YOUR_UNSPLASH_KEY"
```

### Run

```bash
git clone https://github.com/yourusername/AniWall.git
cd AniWall
open AniWall.xcodeproj
```

Hit **▶ Run** in Xcode. The sparkles icon appears in your menu bar.

---

## Roadmap

- [ ] Favourites — save wallpapers you love
- [ ] Auto-refresh — new wallpaper every X hours automatically
- [ ] Settings panel — refresh interval, resolution filter, preferred source
- [ ] All Spaces support — set wallpaper across every virtual desktop
- [ ] Notarization — remove the "Open Anyway" step for everyone
- [ ] More wallpaper sources

---

## Contributing

This is my first macOS app — built while learning Swift from scratch. If you find a bug or want to add a feature, open an issue or pull request. All contributions welcome.

---

## License

MIT License — do whatever you want with it.

---

## Acknowledgements

- [Wallhaven](https://wallhaven.cc) — incredible anime wallpaper collection
- [Unsplash](https://unsplash.com) — beautiful aesthetic photography
- Inspired by the Unsplash Mac app

---

*Built by [Jai Tiwari](https://linkedin.com/in/yourprofile) — because I was too lazy to find wallpapers manually.*
