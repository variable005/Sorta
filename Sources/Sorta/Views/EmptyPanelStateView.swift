import SwiftUI
import AppKit

@MainActor
public final class EmptyStateViewModel: ObservableObject {
    @Published public var currentMessage: FunnyMessage = FunnyMessagesProvider.randomMessage()
    @Published public var diceRotation: Double = 0
    @Published public var bounceScale: CGFloat = 1.0
    @Published public var isHoveringCard: Bool = false
    private var messageIndex: Int = 0

    public init() {}

    public func cycleNext(forSearch query: String, category: ClipCategory?) {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
            diceRotation += 180
            bounceScale = 0.88
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { [weak self] in
            guard let self = self else { return }
            withAnimation(.spring(response: 0.3, dampingFraction: 0.65)) {
                self.bounceScale = 1.0
                if !query.isEmpty {
                    self.currentMessage = FunnyMessagesProvider.searchMessage(for: query)
                } else if let cat = category {
                    self.currentMessage = FunnyMessagesProvider.categoryMessage(for: cat)
                } else {
                    let messages = FunnyMessagesProvider.allGeneralMessages
                    self.messageIndex = (self.messageIndex + 1) % messages.count
                    self.currentMessage = messages[self.messageIndex]
                }
            }
        }
    }

    public func updateState(forSearch query: String, category: ClipCategory?) {
        withAnimation(.easeInOut(duration: 0.18)) {
            if !query.isEmpty {
                self.currentMessage = FunnyMessagesProvider.searchMessage(for: query)
            } else if let cat = category {
                self.currentMessage = FunnyMessagesProvider.categoryMessage(for: cat)
            } else {
                self.currentMessage = FunnyMessagesProvider.randomMessage()
            }
        }
    }
}

/// Rich, interactive Liquid Glass Empty State View for Sorta HUD
public struct EmptyPanelStateView: View {
    @ObservedObject var viewModel: HUDViewModel
    @ObservedObject var watcher: PasteboardWatcher
    @StateObject private var emptyStateVM = EmptyStateViewModel()

    public init(viewModel: HUDViewModel, watcher: PasteboardWatcher) {
        self.viewModel = viewModel
        self.watcher = watcher
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Top Action Bar for Empty State (Sidebar Toggle & Clear)
            HStack(spacing: 8) {
                Button(action: {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                        viewModel.isSidebarVisible.toggle()
                    }
                }) {
                    Image(systemName: viewModel.isSidebarVisible ? "sidebar.left" : "clock.arrow.circlepath")
                        .font(.system(size: 11))
                        .foregroundColor(viewModel.isSidebarVisible ? .primary : .secondary)
                        .frame(width: 28, height: 28)
                        .background(
                            LiquidGlassLens(cornerRadius: 7, isHighlighted: viewModel.isSidebarVisible)
                        )
                }
                .buttonStyle(.plain)
                .help("Toggle Clipboard History (Tab / ⌘H)")

                Spacer()

                // "New Joke" Quick Button in Header
                Button(action: {
                    emptyStateVM.cycleNext(forSearch: viewModel.searchQuery, category: viewModel.selectedCategory)
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: "dice.fill")
                            .font(.system(size: 11))
                            .rotationEffect(.degrees(emptyStateVM.diceRotation))
                        Text("New Joke")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 10)
                    .frame(height: 28)
                    .background(
                        LiquidGlassLens(cornerRadius: 7, isHighlighted: false)
                    )
                }
                .buttonStyle(.plain)
                .help("Cycle to another funny message")
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 6)

            Spacer(minLength: 10)

            // Centered Interactive Liquid Glass Card
            VStack(spacing: 16) {
                // Animated Glowing Icon Badge
                ZStack {
                    // Soft Outer Ambient Glow
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: emptyStateVM.currentMessage.gradientColors.map { $0.opacity(0.35) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 72, height: 72)
                        .blur(radius: 12)

                    // Glass Circle Base
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: emptyStateVM.currentMessage.gradientColors.map { $0.opacity(0.20) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: emptyStateVM.currentMessage.gradientColors.map { $0.opacity(0.6) },
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.2
                                )
                        )

                    // SF Symbol Icon
                    Image(systemName: emptyStateVM.currentMessage.icon)
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, emptyStateVM.currentMessage.gradientColors.first ?? .white],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: (emptyStateVM.currentMessage.gradientColors.first ?? .blue).opacity(0.5), radius: 6, x: 0, y: 2)
                }
                .scaleEffect(emptyStateVM.bounceScale)

                // Category / Tag Badge
                HStack(spacing: 5) {
                    Circle()
                        .fill(emptyStateVM.currentMessage.gradientColors.first ?? .blue)
                        .frame(width: 5, height: 5)
                    Text(emptyStateVM.currentMessage.badge.uppercased())
                        .font(.system(size: 9.5, weight: .bold, design: .rounded))
                        .tracking(0.6)
                        .foregroundColor(.primary.opacity(0.85))
                }
                .padding(.horizontal, 9)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.08))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.14), lineWidth: 0.8)
                )

                // Headline and Subtext
                VStack(spacing: 6) {
                    Text(emptyStateVM.currentMessage.headline)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)

                    Text(emptyStateVM.currentMessage.subtext)
                        .font(.system(size: 12.5, weight: .regular))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .frame(maxWidth: 380)
                        .padding(.horizontal, 16)
                }

                // Interactive Buttons & Shortcuts Area
                HStack(spacing: 10) {
                    if !viewModel.searchQuery.isEmpty {
                        Button(action: {
                            withAnimation(.spring(response: 0.22, dampingFraction: 0.85)) {
                                viewModel.searchQuery = ""
                            }
                        }) {
                            HStack(spacing: 5) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 11))
                                Text("Clear Search")
                                    .font(.system(size: 11, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.12))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    } else if viewModel.selectedCategory != nil {
                        Button(action: {
                            withAnimation(.spring(response: 0.22, dampingFraction: 0.85)) {
                                viewModel.selectedCategory = nil
                            }
                        }) {
                            HStack(spacing: 5) {
                                Image(systemName: "tray.full")
                                    .font(.system(size: 11))
                                Text("Show All Clips")
                                    .font(.system(size: 11, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.12))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }

                    // Shuffle Joke Pill Button
                    Button(action: {
                        emptyStateVM.cycleNext(forSearch: viewModel.searchQuery, category: viewModel.selectedCategory)
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: "shuffle")
                                .font(.system(size: 10, weight: .bold))
                            Text("Tell me another")
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundColor(.primary.opacity(0.9))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white.opacity(0.15), lineWidth: 0.8)
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 4)
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(emptyStateVM.isHoveringCard ? 0.05 : 0.02))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(emptyStateVM.isHoveringCard ? 0.20 : 0.08),
                                        Color.white.opacity(0.02)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .onHover { hovering in
                withAnimation(.spring(response: 0.2, dampingFraction: 0.85)) {
                    emptyStateVM.isHoveringCard = hovering
                }
            }
            .onTapGesture {
                emptyStateVM.cycleNext(forSearch: viewModel.searchQuery, category: viewModel.selectedCategory)
            }
            .help("Click to get another funny message")
            .padding(.horizontal, 24)

            Spacer(minLength: 10)

            // Bottom Helpful Tip Bar
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)

                Text("Tip: Press")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)

                Text("⌘C")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(4)
                    .foregroundColor(.primary)

                Text("in any app to copy text, links, JSON, or images")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 14)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            emptyStateVM.updateState(forSearch: viewModel.searchQuery, category: viewModel.selectedCategory)
        }
        .onChange(of: viewModel.searchQuery) { _, newQuery in
            emptyStateVM.updateState(forSearch: newQuery, category: viewModel.selectedCategory)
        }
        .onChange(of: viewModel.selectedCategory) { _, newCat in
            emptyStateVM.updateState(forSearch: viewModel.searchQuery, category: newCat)
        }
    }
}

/// Compact humorous empty state for the Sidebar list
public struct CompactEmptyStateView: View {
    @ObservedObject var viewModel: HUDViewModel
    @ObservedObject var watcher: PasteboardWatcher
    @StateObject private var emptyStateVM = EmptyStateViewModel()

    public init(viewModel: HUDViewModel, watcher: PasteboardWatcher) {
        self.viewModel = viewModel
        self.watcher = watcher
    }

    public var body: some View {
        VStack(spacing: 10) {
            Spacer()

            // Mini Glowing Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: emptyStateVM.currentMessage.gradientColors.map { $0.opacity(0.25) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)

                Image(systemName: emptyStateVM.currentMessage.icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, emptyStateVM.currentMessage.gradientColors.first ?? .white],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }

            VStack(spacing: 4) {
                Text(emptyStateVM.currentMessage.headline)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)

                Text(emptyStateVM.currentMessage.subtext)
                    .font(.system(size: 10.5))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(.horizontal, 16)
            }

            Button(action: {
                emptyStateVM.cycleNext(forSearch: viewModel.searchQuery, category: viewModel.selectedCategory)
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "dice.fill")
                        .font(.system(size: 9))
                        .rotationEffect(.degrees(emptyStateVM.diceRotation))
                    Text("Joke")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.07))
                .cornerRadius(6)
            }
            .buttonStyle(.plain)
            .padding(.top, 4)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 16)
        .onAppear {
            emptyStateVM.updateState(forSearch: viewModel.searchQuery, category: viewModel.selectedCategory)
        }
        .onChange(of: viewModel.searchQuery) { _, newQuery in
            emptyStateVM.updateState(forSearch: newQuery, category: viewModel.selectedCategory)
        }
        .onChange(of: viewModel.selectedCategory) { _, newCat in
            emptyStateVM.updateState(forSearch: viewModel.searchQuery, category: newCat)
        }
    }
}
