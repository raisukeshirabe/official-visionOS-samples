/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The top level tab navigation for the app.
*/

import SwiftUI
import SwiftData

/// The top level tab navigation for the app.
struct DestinationTabs: View {
    /// Keep track of tab view customizations in app storage.
    #if !os(macOS) && !os(tvOS)
    @AppStorage("sidebarCustomizations") var tabViewCustomization: TabViewCustomization
    #endif
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @Query(filter: #Predicate<Video> { $0.isFeatured }, sort: \.id)
    private var videos: [Video]
    
    @Namespace private var namespace
    @State private var selectedTab: Tabs = .watchNow

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(Tabs.watchNow.name, systemImage: Tabs.watchNow.symbol, value: .watchNow) {
                WatchNowView()
            }
            .customizationID(Tabs.watchNow.customizationID)
            // Disable customization behavior on the watchNow tab to ensure that the tab remains visible.
            #if !os(macOS) && !os(tvOS)
            .customizationBehavior(.disabled, for: .sidebar, .tabBar)
            #endif
            
            Tab(Tabs.library.name, systemImage: Tabs.library.symbol, value: .library) {
                LibraryView()
            }
            .customizationID(Tabs.library.customizationID)
            // Disable customization behavior on the library tab to ensure that the tab remains visible.
            #if !os(macOS) && !os(tvOS)
            .customizationBehavior(.disabled, for: .sidebar, .tabBar)
            #endif
            
            Tab(Tabs.new.name, systemImage: Tabs.new.symbol, value: .new) {
                Text("This view is intentionally blank")
            }
            .customizationID(Tabs.new.customizationID)
            
            Tab(Tabs.favorites.name, systemImage: Tabs.favorites.symbol, value: .favorites) {
                Text("This view is intentionally blank")
            }
            .customizationID(Tabs.favorites.customizationID)
            
            Tab(value: .search, role: .search) {
                Text("This view is intentionally blank")
            }
            .customizationID(Tabs.search.customizationID)
            #if !os(macOS) && !os(tvOS)
            .customizationBehavior(.disabled, for: .sidebar, .tabBar)
            #endif

            #if !os(visionOS)
            TabSection {
                ForEach(Category.collectionsList) { category in
                    Tab(category.name, systemImage: category.icon, value: Tabs.collections(category)) {
                        CategoryView(
                            category: category,
                            namespace: namespace
                        )
                    }
                    .customizationID(category.customizationID)
                }
            } header: {
                Label("Collections", systemImage: "folder")
            }
            .customizationID(Tabs.collections(.forest).name)
            #if !os(macOS) && !os(tvOS)
            // Prevent the tab from appearing in the tab bar by default.
            .defaultVisibility(.hidden, for: .tabBar)
            .hidden(horizontalSizeClass == .compact)
            #endif
            
            TabSection {
                ForEach(Category.animationsList) { category in
                    Tab(category.name, systemImage: category.icon, value: Tabs.animations(category)) {
                        CategoryView(
                            category: category,
                            namespace: namespace
                        )
                    }
                    .customizationID(category.customizationID)
                }
            } header: {
                Label("Animations", systemImage: "folder")
            }
            .customizationID(Tabs.animations(.amazing).name)
            #if !os(macOS) && !os(tvOS)
            // Prevent tab from appearing in the tab bar by default.
            .defaultVisibility(.hidden, for: .tabBar)
            .hidden(horizontalSizeClass == .compact)
            #endif
            #endif
        }
        .tabViewStyle(.sidebarAdaptable)
        #if !os(macOS) && !os(tvOS)
        .tabViewCustomization($tabViewCustomization)
        #endif
    }
}

#Preview(traits: .previewData) {
    DestinationTabs()
}

