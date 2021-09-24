//
//  Permissions.swift
//  Broadcasting
//
//  Created by Uldis Zingis on 15/06/2021.
//

import SwiftUI
import AmazonIVSBroadcast

struct Permissions: View {
    @Environment(\.openURL) var openURL
    @State var cameraPermissionGranted: Bool = false
    @State var microphonePermissionGranted: Bool = false
    @State var allPermissionsGranted: Bool = false
    var continueAction: () -> Void

    private func checkPermissionsGranted() {
        checkPermission(for: .video) { (granted) in
            cameraPermissionGranted = granted
            checkPermission(for: .audio) { (granted) in
                microphonePermissionGranted = granted
                allPermissionsGranted = cameraPermissionGranted && microphonePermissionGranted
            }
        }
    }

    private func checkPermission(for mediaType: AVMediaType, _ result: @escaping (Bool) -> Void) {
        func mainThreadResult(_ success: Bool) {
            DispatchQueue.main.async {
                result(success)
            }
        }
        switch AVCaptureDevice.authorizationStatus(for: mediaType) {
        case .authorized:
            mainThreadResult(true)
        case .notDetermined, .denied, .restricted:
            mainThreadResult(false)
        @unknown default:
            mainThreadResult(false)
        }
    }

    private func getPermission(for mediaType: AVMediaType, _ result: @escaping () -> Void) {
        func mainThreadResult() {
            DispatchQueue.main.async {
                result()
            }
        }
        AVCaptureDevice.requestAccess(for: mediaType) { _ in
            mainThreadResult()
        }
    }

    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)

            VStack {
                Text("To continue, provide the following permissions")
                    .foregroundColor(.white)
                    .font(Constants.fAppBoldExtraLarge)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 20)

                VStack(alignment: .leading) {
                    PermissionItem(title: "Camera Access", description: "Lets the demo capture video using the camera", isOn: $cameraPermissionGranted) {
                        getPermission(for: .video) {
                            checkPermissionsGranted()
                        }
                    }
                    .padding(.top, 10)

                    PermissionItem(title: "Microphone Access", description: "Lets the demo capture audio using the camera", isOn: $microphonePermissionGranted) {
                        getPermission(for: .audio) {
                            checkPermissionsGranted()
                        }
                    }

                    PrimaryButton(title: "Continue", isEnabled: $allPermissionsGranted) {
                        continueAction()
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal, 19)
                }
                .background(
                    RoundedRectangle(cornerRadius: 13)
                        .fill(Constants.backgroundGrayLight)
                )

                TextWithHyperlink(
                    leadingText: "This application does not store any data captured from your phone.",
                    urlLabel: " AWS Privacy Policy.",
                    url: "https://aws.amazon.com/privacy",
                    urlColor: Constants.lightGray,
                    textAlignment: .center,
                    underlineStyle: NSUnderlineStyle.single
                )
                .modifier(FooterText())
                .frame(height: 80)
                .onTapGesture {
                    openURL(URL(string: "https://aws.amazon.com/privacy")!)
                }
            }
        }
        .onAppear {
            checkPermissionsGranted()
        }
    }
}
