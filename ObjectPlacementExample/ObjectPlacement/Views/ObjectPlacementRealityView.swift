/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The view shown inside the immersive space.
*/

import RealityKit
import SwiftUI

@MainActor
struct ObjectPlacementRealityView: View {
    var appState: AppState
    
    @State private var placementManager = PlacementManager()
    
    @State private var collisionBeganSubscription: EventSubscription? = nil
    @State private var collisionEndedSubscription: EventSubscription? = nil
    
    private enum Attachments {
        case placementTooltip
        case dragTooltip
        case deleteButton
    }

    var body: some View {
        RealityView { content, attachments in
            content.add(placementManager.rootEntity)
            placementManager.appState = appState
            
            if let placementTooltipAttachment = attachments.entity(for: Attachments.placementTooltip) {
                placementManager.addPlacementTooltip(placementTooltipAttachment)
            }
            
            if let dragTooltipAttachment = attachments.entity(for: Attachments.dragTooltip) {
                placementManager.dragTooltip = dragTooltipAttachment
            }
            
            if let deleteButtonAttachment = attachments.entity(for: Attachments.deleteButton) {
                placementManager.deleteButton = deleteButtonAttachment
            }
            
            collisionBeganSubscription = content.subscribe(to: CollisionEvents.Began.self) {  [weak placementManager] event in
                placementManager?.collisionBegan(event)
            }
            
            collisionEndedSubscription = content.subscribe(to: CollisionEvents.Ended.self) {  [weak placementManager] event in
                placementManager?.collisionEnded(event)
            }
            
            Task {
                // Run the ARKit session after the user opens the immersive space.
                await placementManager.runARKitSession()
            }
        } update: { update, attachments in
            let placementState = placementManager.placementState

            if let placementTooltip = attachments.entity(for: Attachments.placementTooltip) {
                placementTooltip.isEnabled = (placementState.selectedObject != nil && placementState.shouldShowPreview)
            }
            
            if let dragTooltip = attachments.entity(for: Attachments.dragTooltip) {
                // Dismiss the drag tooltip after the user demonstrates it.
                dragTooltip.isEnabled = !placementState.userDraggedAnObject
            }

            if let selectedObject = placementState.selectedObject {
                selectedObject.isPreviewActive = placementState.isPlacementPossible
            }
        } attachments: {
            Attachment(id: Attachments.placementTooltip) {
                PlacementTooltip(placementState: placementManager.placementState)
            }
            Attachment(id: Attachments.dragTooltip) {
                TooltipView(text: "Drag to reposition.")
            }
            Attachment(id: Attachments.deleteButton) {
                DeleteButton {
                    Task {
                        await placementManager.removeHighlightedObject()
                    }
                }
            }
        }
        .task {
            // Monitor ARKit anchor updates once the user opens the immersive space.
            //
            // Tasks attached to a view automatically receive a cancellation
            // signal when the user dismisses the view. This ensures that
            // loops that await anchor updates from the ARKit data providers
            // immediately end.
            await placementManager.processWorldAnchorUpdates()
        }
        .task {
            await placementManager.processDeviceAnchorUpdates()
        }
        .task {
            await placementManager.processPlaneDetectionUpdates()
        }
        .task {
            await placementManager.checkIfAnchoredObjectsNeedToBeDetached()
        }
        .task {
            await placementManager.checkIfMovingObjectsCanBeAnchored()
        }
        .gesture(SpatialTapGesture().targetedToAnyEntity().onEnded { event in
            // Place the currently selected object when the user looks directly at the selected object’s preview.
            if event.entity.components[CollisionComponent.self]?.filter.group == PlaceableObject.previewCollisionGroup {
                placementManager.placeSelectedObject()
            }
        })
        .gesture(DragGesture()
            .targetedToAnyEntity()
            .handActivationBehavior(.pinch) // Prevent moving objects by direct touch.
            .onChanged { value in
                if value.entity.components[CollisionComponent.self]?.filter.group == PlacedObject.collisionGroup {
                    placementManager.updateDrag(value: value)
                }
            }
            .onEnded { value in
                if value.entity.components[CollisionComponent.self]?.filter.group == PlacedObject.collisionGroup {
                    placementManager.endDrag()
                }
            }
        )
        .onAppear() {
            print("Entering immersive space.")
            appState.immersiveSpaceOpened(with: placementManager)
        }
        .onDisappear() {
            print("Leaving immersive space.")
            appState.didLeaveImmersiveSpace()
        }
    }
}
