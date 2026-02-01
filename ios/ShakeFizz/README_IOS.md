# ShakeFizz iOS App

This folder contains the native iOS source code for the ShakeFizz MVP.

## Requirements
- macOS with Xcode 15+ installed.
- iPhone for testing motion sensors (Simulator cannot verify shaking).

## How to Build

1. **Create a new Xcode Project**:
   - Open Xcode > Create New Project.
   - Select **iOS > App**.
   - Product Name: `ShakeFizzApp` (Internal naming can remain, or you can match the folder).
   - Interface: **SwiftUI**.
   - Language: **Swift**.
   - Use Core Data: Unchecked.
   - Include Tests: Optional.

2. **Import Files**:
   - Copy the folders (`App`, `Models`, `ViewModels`, `Views`) from this `ios` directory into your Xcode project's main group.
   - Allow Xcode to "Copy items if needed".
   - **Delete** the default `ShakeFizzAppApp.swift` or `ContentView.swift` created by Xcode if they conflict (or replace their contents with ours).
   - Ensure `App/ShakeFizzApp.swift` is the main entry point (@main).

3. **Info.plist Settings**:
   - You must add the **Privacy - Motion Usage Description** key to `Info.plist` to access the accelerometer.
     - Key: `NSMotionUsageDescription`
     - Value: "ShakeFizz uses device motion to detect how hard you shake the can!"

4. **Run**:
   - Select your connected iPhone from the device list.
   - Press Cmd+R to build and run.

## Troubleshooting
- **Missing Entitlement**: If the app crashes on shake start, check `NSMotionUsageDescription`.
- **Simulator**: The Simulator cannot simulate CMMotionManager device motion updates perfectly for this game loop. Use a real device.
