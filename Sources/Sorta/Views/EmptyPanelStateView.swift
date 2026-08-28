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
        withAnimation(.spring(response: 0.22, dampingFraction: 0.75)) {
            diceRotation += 180
            bounceScale = 0.92
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) { [weak self] in
            guard let self = self else { return }
            withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
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
        withAnimation(.easeInOut(duration: 0.15)) {
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

/// Sleek, native macOS Liquid Glass Empty State View for Sorta HUD
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
            // Top Action Bar for Empty State (Sidebar Toggle & New Joke)
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

                // "New Joke" Button in Header
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

            // Centered Clean Glass Card
            VStack(spacing: 14) {
                // Subtle Frosted Icon Container
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white.opacity(0.06))
                        .frame(width: 50, height: 50)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )

                    Image(systemName: emptyStateVM.currentMessage.icon)
                        .font(.system(size: 22, weight: .regular))
                        .foregroundColor(.primary.opacity(0.85))
                }
                .scaleEffect(emptyStateVM.bounceScale)

                // Category / Tag Badge (Clean monochrome)
                Text(emptyStateVM.currentMessage.badge.uppercased())
                    .font(.system(size: 9.5, weight: .semibold, design: .monospaced))
                    .tracking(0.8)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.white.opacity(0.09), lineWidth: 0.8)
                    )

                // Headline and Subtext
                VStack(spacing: 5) {
                    Text(emptyStateVM.currentMessage.headline)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)

                    Text(emptyStateVM.currentMessage.subtext)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .frame(maxWidth: 380)
                        .padding(.horizontal, 16)
                }

                // Interactive Action Buttons
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
                            .padding(.vertical, 5)
                            .background(Color.white.opacity(0.10))
                            .cornerRadius(7)
                            .overlay(
                                RoundedRectangle(cornerRadius: 7)
                                    .stroke(Color.white.opacity(0.20), lineWidth: 1)
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
                            .padding(.vertical, 5)
                            .background(Color.white.opacity(0.10))
                            .cornerRadius(7)
                            .overlay(
                                RoundedRectangle(cornerRadius: 7)
                                    .stroke(Color.white.opacity(0.20), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }

                    // "Tell me another" pill
                    Button(action: {
                        emptyStateVM.cycleNext(forSearch: viewModel.searchQuery, category: viewModel.selectedCategory)
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: "shuffle")
                                .font(.system(size: 10, weight: .semibold))
                            Text("Tell me another")
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(Color.white.opacity(0.06))
                        .cornerRadius(7)
                        .overlay(
                            RoundedRectangle(cornerRadius: 7)
                                .stroke(Color.white.opacity(0.12), lineWidth: 0.8)
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 2)
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(emptyStateVM.isHoveringCard ? 0.04 : 0.02))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                Color.white.opacity(emptyStateVM.isHoveringCard ? 0.14 : 0.07),
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
            .help("Click to cycle funny messages")
            .padding(.horizontal, 24)

            Spacer(minLength: 10)

            // Bottom Tip Bar
            HStack(spacing: 5) {
                Image(systemName: "sparkles")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary.opacity(0.8))

                Text("Tip: Press")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary.opacity(0.8))

                Text("⌘C")
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .padding(.horizontal, 5)
                    .padding(.vertical, 1.5)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(4)
                    .foregroundColor(.primary.opacity(0.85))

                Text("in any app to copy text, links, JSON, or images")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary.opacity(0.8))
            }
            .padding(.bottom, 12)
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

/// Compact empty state for Sidebar
public struct CompactEmptyStateView: View {
    @ObservedObject var viewModel: HUDViewModel
    @ObservedObject var watcher: PasteboardWatcher
    @StateObject private var emptyStateVM = EmptyStateViewModel()

    public init(viewModel: HUDViewModel, watcher: PasteboardWatcher) {
        self.viewModel = viewModel
        self.watcher = watcher
    }

    public var body: some View {
        VStack(spacing: 8) {
            Spacer()

            Image(systemName: emptyStateVM.currentMessage.icon)
                .font(.system(size: 20, weight: .regular))
                .foregroundColor(.secondary.opacity(0.7))

            VStack(spacing: 3) {
                Text(emptyStateVM.currentMessage.headline)
                    .font(.system(size: 11.5, weight: .semibold))
                    .foregroundColor(.primary.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)

                Text(emptyStateVM.currentMessage.subtext)
                    .font(.system(size: 10))
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
                .padding(.vertical, 3)
                .background(Color.white.opacity(0.06))
                .cornerRadius(5)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.white.opacity(0.10), lineWidth: 0.8)
                )
            }
            .buttonStyle(.plain)
            .padding(.top, 2)

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
