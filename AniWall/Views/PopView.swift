// Views/PopoverView.swift
import SwiftUI

struct PopoverView: View {

    @StateObject private var viewModel = WallpaperViewModel()

    var body: some View {
        ZStack {
            background

            VStack(spacing: 0) {
                headerView
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 14)

                categoryPicker
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)

                previewCard
                    .padding(.horizontal, 20)
                    .padding(.top, 4)  // extra breathing room so picker never overlaps

                actionButtons
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 18)

                statusArea
                    .padding(.bottom, 14)
            }
        }
        .frame(width: 420, height: 380)
        .onAppear {
            viewModel.fetchNewWallpaper()
        }
    }

    // MARK: - Background
    private var background: some View {
        ZStack {
            Color(red: 0.04, green: 0.03, blue: 0.07)

            LinearGradient(
                colors: [
                    Color(red: 0.22, green: 0.08, blue: 0.38).opacity(0.35),
                    Color.clear
                ],
                startPoint: .top,
                endPoint: .center
            )
        }
        .ignoresSafeArea()
    }

    // MARK: - Header
    private var headerView: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 3) {
                Text("AniWall")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)

                Text("4K Anime & Aesthetic")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.3))
            }

            Spacer()

            if let wallpaper = viewModel.currentWallpaper {
                Text(wallpaper.resolution)
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundColor(Color(red: 0.65, green: 0.45, blue: 0.95))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color(red: 0.65, green: 0.45, blue: 0.95).opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .strokeBorder(
                                        Color(red: 0.65, green: 0.45, blue: 0.95).opacity(0.25),
                                        lineWidth: 0.5
                                    )
                            )
                    )
            }
        }
    }

    // MARK: - Category Picker
    private var categoryPicker: some View {
        HStack(spacing: 6) {
            ForEach(WallpaperCategory.allCases, id: \.self) { category in
                let isSelected = viewModel.selectedCategory == category

                Button {
                    viewModel.selectedCategory = category
                    viewModel.fetchNewWallpaper()
                } label: {
                    Text(category.label)
                        .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                        .foregroundColor(isSelected ? .white : Color.white.opacity(0.4))
                        .frame(maxWidth: .infinity)
                        .frame(height: 28)
                        .background(
                            RoundedRectangle(cornerRadius: 7)
                                .fill(
                                    isSelected
                                    ? Color(red: 0.4, green: 0.18, blue: 0.72)
                                    : Color.white.opacity(0.05)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 7)
                                        .strokeBorder(
                                            isSelected
                                            ? Color(red: 0.6, green: 0.35, blue: 0.95).opacity(0.5)
                                            : Color.white.opacity(0.07),
                                            lineWidth: 0.5
                                        )
                                )
                        )
                }
                .buttonStyle(.plain)
                .animation(.easeInOut(duration: 0.12), value: viewModel.selectedCategory)
            }
        }
    }

    // MARK: - Preview Card
    private var previewCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.white.opacity(0.07), lineWidth: 0.5)
                )

            Group {
                if viewModel.isLoading {
                    loadingView
                } else if let image = viewModel.previewImage {
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: 160)  // hard cap the height
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    placeholderView
                }
            }
        }
        .frame(height: 160)
        .clipped()
        .shadow(
            color: Color(red: 0.4, green: 0.15, blue: 0.75).opacity(0.2),
            radius: 14,
            y: 5
        )
    }

    private var loadingView: some View {
        VStack(spacing: 10) {
            ProgressView()
                .progressViewStyle(
                    CircularProgressViewStyle(tint: Color(red: 0.6, green: 0.4, blue: 0.9))
                )
                .scaleEffect(0.9)

            Text("Fetching wallpaper...")
                .font(.system(size: 10))
                .foregroundColor(Color.white.opacity(0.25))
        }
    }

    private var placeholderView: some View {
        VStack(spacing: 8) {
            Image(systemName: "photo")
                .font(.system(size: 22))
                .foregroundColor(Color.white.opacity(0.08))

            Text("No wallpaper loaded")
                .font(.system(size: 10))
                .foregroundColor(Color.white.opacity(0.2))
        }
    }

    // MARK: - Action Buttons
    private var actionButtons: some View {
        HStack(spacing: 8) {

            Button {
                viewModel.fetchNewWallpaper()
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "shuffle")
                        .font(.system(size: 11, weight: .medium))
                    Text("Shuffle")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(Color.white.opacity(0.75))
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 9)
                        .fill(Color.white.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 9)
                                .strokeBorder(Color.white.opacity(0.09), lineWidth: 0.5)
                        )
                )
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isLoading || viewModel.isSettingWallpaper)
            .opacity(viewModel.isLoading ? 0.4 : 1.0)

            Button {
                viewModel.setCurrentAsWallpaper()
            } label: {
                HStack(spacing: 5) {
                    if viewModel.isSettingWallpaper {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.6)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 11, weight: .medium))
                    }
                    Text(viewModel.isSettingWallpaper ? "Setting..." : "Set Wallpaper")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 9)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.45, green: 0.18, blue: 0.78),
                                    Color(red: 0.32, green: 0.10, blue: 0.58)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 9)
                                .strokeBorder(
                                    Color(red: 0.6, green: 0.35, blue: 0.95).opacity(0.4),
                                    lineWidth: 0.5
                                )
                        )
                )
                .opacity(viewModel.currentWallpaper == nil ? 0.35 : 1.0)
            }
            .buttonStyle(.plain)
            .disabled(viewModel.currentWallpaper == nil || viewModel.isLoading || viewModel.isSettingWallpaper)
        }
    }

    // MARK: - Status
    private var statusArea: some View {
        Group {
            if let error = viewModel.errorMessage {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 9))
                    Text(error)
                        .font(.system(size: 10))
                        .lineLimit(1)
                }
                .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.4))

            } else if let success = viewModel.successMessage {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 9))
                    Text(success)
                        .font(.system(size: 10))
                }
                .foregroundColor(Color(red: 0.4, green: 0.85, blue: 0.6))

            } else {
                Text(" ").font(.system(size: 10))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.errorMessage)
        .animation(.easeInOut(duration: 0.2), value: viewModel.successMessage)
    }
}

#Preview {
    PopoverView()
}
