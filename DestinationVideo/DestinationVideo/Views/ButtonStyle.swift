/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Custom button styles that the app defines.
*/

import SwiftUI

///  A custom button style.
struct CustomButtonStyle: PrimitiveButtonStyle {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    func makeBody(configuration: Configuration) -> some View {
        Button(configuration)
            .buttonStyle(.bordered)
            .buttonBorderShape(.capsule)
            .fontWeight(.medium)
            #if !os(tvOS)
            .controlSize(horizontalSizeClass == .compact ? .small : .regular)
            #endif
    }
}

/// A custom button style for buttons in the app library.
struct PickerButtonStyle: PrimitiveButtonStyle {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        if isSelected {
            Button(configuration)
                #if os(macOS)
                .buttonStyle(MacOSButtonStyle(isSelected: isSelected))
                #else
                .buttonStyle(.borderedProminent)
                .foregroundStyle(.black)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.white)
                }
                #endif
                .modifier(PickerButtonModifier(isSelected: false))
        } else {
            Button(configuration)
                #if os(macOS)
                .buttonStyle(MacOSButtonStyle(isSelected: isSelected))
                #else
                .buttonStyle(.bordered)
                #endif
                .modifier(PickerButtonModifier(isSelected: true))
        }

    }

    struct PickerButtonModifier: ViewModifier {
        @Environment(\.horizontalSizeClass) var horizontalSizeClass
        var isSelected: Bool

        func body(content: Content) -> some View {
            content
                .fontWeight(.medium)
                .buttonBorderShape(.roundedRectangle)
                #if !os(tvOS)
                .controlSize(horizontalSizeClass == .compact ? .small : .regular)
                #endif
        }
    }
    private struct MacOSButtonStyle: ButtonStyle {
        var isSelected: Bool
        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .foregroundColor(isSelected ? .black : .white)
                .background(isSelected ? .white : .black)
                .cornerRadius(5)
        }
    }
}
