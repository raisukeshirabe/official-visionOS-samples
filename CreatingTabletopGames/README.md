# Creating tabletop games

Develop a spatial board game where multiple players interact with pieces on a table.

## Overview

You can run this sample code in Simulator to see the game layout, but to experience multiplayer, you need two or more Apple Vision Pro devices. This sample uses Group Activities for multiplayer, which doesn't support Simulator.

- Note: This sample code project is associated with WWDC24 session 10091: [Meet TabletopKit for visionOS](https://developer.apple.com/wwdc24/10091/).

## Configure the sample code project

To configure the sample code project, do the following in Xcode:

1. Choose Xcode > Settings > Accounts. Then, click the Add button (+), and add your Apple ID account.
2. Select the target in the Project navigator, click the Signing & Capabilities pane, and choose your team from the Team menu.
3. Optionally, enter a unique identifier in the Bundle Identifier text field. Otherwise, use the existing bundle ID that ends in your team ID.
4. For multiplayer, verify that the target contains the Group Activities capability below Signing.

## Run the sample code in Simulator

If you don't have an Apple Vision Pro device, you can run the sample code in Simulator and interact with some equipment.

1. Choose the Apple Vision Pro visionOS Simulator from the run destination menu.
2. Build and run the sample.

For example, you can drag pawns to various spots on the conveyor belt, pick up cards and place them in front of you, and toss the die.

## Start a multiplayer game on devices

To experience the game with multiple players, run the sample on multiple Apple Vision Pro devices using the same developer Team ID and bundle ID for each player.

1. Connect two Apple Vision Pro devices to your Mac.
2. If necessary, click Register Device in the Signing & Capabilities pane to create the provisioning profile.
3. Sign in using a different Apple ID on each device.
4. Build and run the sample on the two devices.
5. Join a FaceTime call with all participants.
6. On one device, tap the SharePlay button in the toolbar.
7. On the other devices, tap Accept in the SharePlay dialog. 
8. Ensure that the SharePlay badge turns green.

Players who join the FaceTime call can drag the pawns, pick up cards, and toss the die.
