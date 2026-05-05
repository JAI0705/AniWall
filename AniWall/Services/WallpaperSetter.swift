// Services/WallpaperSetter.swift
import AppKit

class WallpaperSetter {

    static func set(from localFileURL: URL) throws {

        // Verify file exists before trying to set
        guard FileManager.default.fileExists(atPath: localFileURL.path) else {
            print("❌ File does not exist at: \(localFileURL.path)")
            throw SetterError.fileNotFound
        }

        print("📂 Setting wallpaper from: \(localFileURL.path)")

        let screens = NSScreen.screens
        guard !screens.isEmpty else {
            throw SetterError.noScreenFound
        }

        let options: [NSWorkspace.DesktopImageOptionKey: Any] = [
            .imageScaling: NSImageScaling.scaleProportionallyUpOrDown.rawValue,
            .allowClipping: true
        ]

        for screen in screens {
            do {
                try NSWorkspace.shared.setDesktopImageURL(
                    localFileURL,
                    for: screen,
                    options: options
                )
                print("✅ Set on screen: \(screen.localizedName)")
            } catch {
                // Print the actual error from NSWorkspace
                print("❌ NSWorkspace error: \(error)")
                throw error
            }
        }
    }

    enum SetterError: Error, LocalizedError {
        case noScreenFound
        case fileNotFound

        var errorDescription: String? {
            switch self {
            case .noScreenFound: return "No display screen was found."
            case .fileNotFound:  return "Wallpaper file could not be found on disk."
            }
        }
    }

    private static func setAcrossAllSpacesViaScript(path: String) {
        // This AppleScript tells System Events to set the wallpaper
        // on every desktop space macOS knows about
        let script = """
        tell application "System Events"
            tell every desktop
                set picture to "\(path)"
            end tell
        end tell
        """

        var error: NSDictionary?
        if let appleScript = NSAppleScript(source: script) {
            appleScript.executeAndReturnError(&error)
            if let err = error {
                print("AppleScript error: \(err)")
            } else {
                print("Wallpaper set on all desktops ✓")
            }
        }
    }

    
}
