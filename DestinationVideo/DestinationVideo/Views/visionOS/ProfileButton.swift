/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view that presents an expanding profile button.
*/

import SwiftUI

/// A view that presents an expanding profile button.
struct ProfileButtonView: View {
    var action: () -> Void = {}
    var body: some View {
        Button(action: action) {
            ProfileDetailView()
        }
        .buttonStyle(ExpandingProfileButtonStyle())
        .padding(Constants.outerPadding)
    }
}

/// A view that displays the icon of the profile button.
private struct ProfileIconView: View {
    var body: some View {
        Image(systemName: "person.crop.circle")
            .resizable()
            .scaledToFit()
            .frame(
                width: Constants.profileIconSize.width,
                height: Constants.profileIconSize.height
            )
    }
}

/// A view that displays the expanded profile button.
private struct ProfileDetailView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Anne Johnson")
                .font(.body)
                .foregroundStyle(.primary)
            Text("Switch profiles")
                .font(.footnote)
                .foregroundStyle(.tertiary)
        }
    }
}

private struct ExpandingProfileButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 0) {
            // Reserve space for the icon. The icon appears in an overlay
            // so it doesn't scale with the background.
            Color.clear
                .frame(
                    width: Constants.collapsedSize.width,
                    height: Constants.collapsedSize.height
                )

            configuration.label
                .padding(.trailing, 24)
                .hoverEffect(FadeEffect())
        }
        .hoverEffect(reduceMotion ? HoverEffect(.empty) : HoverEffect(ExpandEffect()))
        .overlay(alignment: .leading) {
            // Center the icon over the collapsed button area.
            ZStack {
                ProfileIconView().offset(x: 0.5, y: 0.5)
            }
            .frame(
                width: Constants.collapsedSize.width,
                height: Constants.collapsedSize.height
            )
        }
        .background {
            if reduceMotion {
                // When reduceMotion is enabled, cross-fade between the
                // collapsed and expanded backgrounds.
                ZStack(alignment: .leading) {
                    Circle()
                        .fill(.thinMaterial)
                        .hoverEffect(.highlight)
                        .hoverEffect(FadeEffect(opacityFrom: 1, opacityTo: 0))
                    Capsule()
                        .fill(.thinMaterial)
                        .hoverEffect(.highlight)
                        .hoverEffect(FadeEffect())
                }
            } else {
                // Otherwise, scale and expand the background. Use a Rectangle
                // because the expand effect applies a clipShape.
                Rectangle()
                    .fill(.thinMaterial)
                    .hoverEffect(.highlight)
                    .hoverEffect(ExpandEffect())
            }
        }
        // Group all effects so they activate together.
        .hoverEffectGroup()
        // Scale the button down to provide feedback when a
        // person presses the button.
        .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

/// Expands and scales content on hover.
private struct ExpandEffect: CustomHoverEffect {
    func body(content: Content) -> some CustomHoverEffect {
        content.hoverEffect { effect, isActive, proxy in
            // Reveal content after a delay.
            effect.animation(.default.delay(isActive ? 0.8 : 0.2)) {
                $0.clipShape(
                    .capsule.size(
                        width: isActive ? proxy.size.width : proxy.size.height,
                        height: proxy.size.height,
                        anchor: .leading
                    )
                )
            }
            // Immediately scale the content on hover.
            .animation(isActive ? .easeOut(duration: 0.8) : .easeIn(duration: 0.2).delay(0.4)) {
                $0.scaleEffect(
                    isActive ? 1.1 : 1,
                    // Anchor the scale in the center of the collapsed
                    // button frame.
                    anchor: UnitPoint(x: (proxy.size.height / 2) / proxy.size.width, y: 0.5)
                )
            }
        }
    }
}

/// Fades content between the `from` and `to` properties on hover.
private struct FadeEffect: CustomHoverEffect {
    var opacityFrom: Double = 0
    var opacityTo: Double = 1

    func body(content: Content) -> some CustomHoverEffect {
        content.hoverEffect { effect, isActive, _ in
            effect.animation(.default.delay(isActive ? 0.8 : 0.2)) {
                $0.opacity(isActive ? opacityTo : opacityFrom)
            }
        }
    }
}

extension Constants {
    fileprivate static let profileIconSize = CGSize(width: 44, height: 44)

    fileprivate static let profileIconPadding: CGFloat = 6

    fileprivate static let collapsedSize = CGSize(
        width: profileIconPadding + profileIconSize.width + profileIconPadding,
        height: profileIconPadding + profileIconSize.height + profileIconPadding
    )
}
