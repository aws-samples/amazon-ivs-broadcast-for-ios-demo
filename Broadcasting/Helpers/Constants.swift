//
//  File.swift
//  Broadcasting
//
//  Created by Uldis Zingis on 15/06/2021.
//

import SwiftUI

enum Constants {
    // For screen sharing to work, this must match actual App Group container name
    // This is used to share user defaults between app and extension
    static let appGroupName = "group.amazon.ivs.broadcasting"

    // Default values (ingestServer and streamKey can be set also later in the app)
    static let ingestServer = ""
    static let streamKey = ""
    static let playbackUrl = ""

    // Persistence keys
    static let kWasLaunchedBefore = "was_launched_before"
    static let kIngestServer = "ingest_server"
    static let kStreamKey = "stream_key"
    static let kPlaybackUrl = "playback_url"
    static let kManualBitrateLimits = "manual_bitrate_limits"
    static let kManualFramerate = "manual_framerate"
    static let kManualResolution = "manual_resolution"
    static let kAudioConfigurationBitrate = "audio_configuration_bitrate"
    static let kVideoConfigurationOrientation = "video_configuration_orientation"
    static let kVideoConfigurationBitrate = "video_configuration_bitrate"
    static let kVideoConfigurationUseCustomResolution = "video_configuration_use_custom_resolution"
    static let kVideoConfigurationKeyframeInterval = "video_configuration_keyframe_interval"
    static let kVideoConfigurationMaxBitrate = "video_configuration_max_bitrate"
    static let kVideoConfigurationMinBitrate = "video_configuration_min_bitrate"
    static let kVideoConfigurationSizeWidth = "video_configuration_size_width"
    static let kVideoConfigurationSizeHeight = "video_configuration_size_height"
    static let kVideoConfigurationFramerate = "video_configuration_framerate"
    static let kVideoConfigurationTransparency = "video_configuration_transparency_enabed"
    static let kVideoConfigurationBFrames = "video_configuration_uses_b_frames"
    static let kVideoConfigurationAutoBitrate = "video_configuration_use_auto_bitrate"
    static let kDefaultCamera = "default_camera"
    static let kReplayKitSessionHasBeenStarted = "replay_kit_session_has_been_started"

    // Colors
    static let yellow = Color(.sRGB, red: 0.973, green: 0.843, blue: 0.29)
    static let red = Color(.sRGB, red: 0.92, green: 0.31, blue: 0.24, opacity: 1)
    static let gray = Color(.sRGB, red: 0.922, green: 0.922, blue: 0.961)
    static let lightGray = Color(.sRGB, red: 0.692, green: 0.692, blue: 0.692)
    static let backgroundGrayLight = Color(.sRGB, red: 0.167, green: 0.167, blue: 0.167)
    static let backgroundGrayDark = Color(.sRGB, red: 0.087, green: 0.087, blue: 0.087)
    static let background = Color(.sRGB, red: 0.13, green: 0.13, blue: 0.13)
    static let backgroundButton = Color(.sRGB, red: 0.46, green: 0.46, blue: 0.46, opacity: 0.45)
    static let secondaryText = Color(.sRGB, red: 0.47, green: 0.47, blue: 0.47, opacity: 0.45)
    static let borderColor = Color(.sRGB, red: 0.22, green: 0.22, blue: 0.23)
    static let error = Color(.sRGB, red: 0.8, green: 0.257, blue: 0.183)
    static let warning = Color(.sRGB, red: 1, green: 0.814, blue: 0.337)
    static let success = Color(.sRGB, red: 0.206, green: 0.554, blue: 0.261)

    // Other
    static let cameraOffSlotName = "camera_off"
    static let cameraSlotName = "camera"

    // Fonts
    static let defaultFontName = "AmazonEmber-Regular"
    static let fAppRegular = Font.custom("AmazonEmber-Regular", size: 15)
    static let fAppRegularSmall = Font.custom("AmazonEmber-Regular", size: 12)
    static let fAppRegularLarge = Font.custom("AmazonEmber-Regular", size: 17)
    static let fAppMedium = Font.custom("AmazonEmber-Medium", size: 15)
    static let fAppMediumSmall = Font.custom("AmazonEmber-Medium", size: 12)
    static let fAppBold = Font.custom("AmazonEmber-Bold", size: 15)
    static let fAppBoldLarge = Font.custom("AmazonEmber-Bold", size: 17)
    static let fAppBoldExtraLarge = Font.custom("AmazonEmber-Bold", size: 22)
    static let fAppHeavy = Font.custom("AmazonEmber-Heavy", size: 15)
    static let fStatusBarLabels = Font.custom("JetBrainsMono-Medium", size: 15)
    static let fMetadata = Font.custom("JetBrainsMono-Regular", size: 13)
}

enum Resolution: Int, CaseIterable {
    case fullHd
    case hd
    case sd

    var width: Int {
        switch self {
        case .fullHd:
            return 1920
        case .hd:
            return 1280
        case .sd:
            return 768
        }
    }

    var height: Int {
        switch self {
        case .fullHd:
            return 1080
        case .hd:
            return 720
        case .sd:
            return 480
        }
    }

    static func sizeFor(_ orientation: Orientation, a: Int, b: Int) -> CGSize {
        var width = a
        var height = b

        switch orientation {
        case .portrait:
            width = min(a, b)
            height = max(a, b)
        case .auto, .landscape:
            width = max(a, b)
            height = min(a, b)
        case .square:
            width = min(a, b)
            height = width
        }

        return CGSize(width: width, height: height)
    }
}

enum Framerate: Int {
    case max = 60
    case mid = 30
    case low = 15
}

enum Orientation: String, CaseIterable {
    case auto, portrait, landscape, square
}
