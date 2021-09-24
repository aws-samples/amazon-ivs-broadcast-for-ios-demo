//
//  DebugInfo.swift
//  Broadcasting
//
//  Created by Uldis Zingis on 16/06/2021.
//

import SwiftUI
import AmazonIVSBroadcast

struct DebugInfo: View {
    @ObservedObject private var viewModel: BroadcastViewModel
    @ObservedObject private var deviceStats = DeviceStats()
    @Binding private var isPresent: Bool
    private var debugInfoString: NSAttributedString {
        return getDebugInfo()
    }

    init(viewModel: BroadcastViewModel, isPresent: Binding<Bool>) {
        self.viewModel = viewModel
        self._isPresent = isPresent
    }

    private func getDebugInfo() -> NSAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont(name: "SFMono-Bold", size: 12) ?? UIFont.systemFont(ofSize: 12)
        ]
        let spacing = "\t\t\t\t\t\t\t\t"
        let configSpacing = "\t\t\t\t"
        let text = NSMutableAttributedString(string: "", attributes: [:])

        let cpuTitle = NSMutableAttributedString(string: "CPU", attributes: attributes)
        let cpu = NSMutableAttributedString(string: "\(spacing)\t \(deviceStats.cpu) %\n", attributes: attributes)
        cpuTitle.append(cpu)

        let memoryTitle = NSMutableAttributedString(string: "MEM", attributes: attributes)
        let memory = NSMutableAttributedString(string: "\(spacing) \(deviceStats.memory) MB\n", attributes: attributes)
        memoryTitle.append(memory)

        let temperatureTitle = NSMutableAttributedString(string: "TEMP", attributes: attributes)
        let temp = NSMutableAttributedString(string: "\(spacing) \(deviceStats.temperature)\n", attributes: attributes)
        temperatureTitle.append(temp)

        text.append(cpuTitle)
        text.append(memoryTitle)
        text.append(temperatureTitle)

        let videoConfigTitle = NSMutableAttributedString(string: "VideoConfig\n", attributes: attributes)

        let initialBitrateTitle = NSMutableAttributedString(string: "\tinitialBitrate", attributes: attributes)
        let initialBitrate = NSMutableAttributedString(
            string: "\(configSpacing)\t\t \(viewModel.configurations.activeVideoConfiguration.initialBitrate)\n",
            attributes: attributes)
        initialBitrateTitle.append(initialBitrate)

        let maxBitrateTitle = NSMutableAttributedString(string: "\tmaxBitrate", attributes: attributes)
        let maxBitrate = NSMutableAttributedString(
            string: "\(configSpacing)\t\t \(viewModel.configurations.activeVideoConfiguration.maxBitrate)\n",
            attributes: attributes)
        maxBitrateTitle.append(maxBitrate)

        let minBitrateTitle = NSMutableAttributedString(string: "\tminBitrate", attributes: attributes)
        let minBitrate = NSMutableAttributedString(
            string: "\(configSpacing)\t\t \(viewModel.configurations.activeVideoConfiguration.minBitrate)\n",
            attributes: attributes)
        minBitrateTitle.append(minBitrate)

        let targetFramerateTitle = NSMutableAttributedString(string: "\ttargetFramerate", attributes: attributes)
        let targetFramerate = NSMutableAttributedString(
            string: "\(configSpacing)\t \(viewModel.configurations.activeVideoConfiguration.targetFramerate)\n",
            attributes: attributes)
        targetFramerateTitle.append(targetFramerate)

        let keyframeIntervalTitle = NSMutableAttributedString(string: "\tkeyframeInterval", attributes: attributes)
        let keyframeInterval = NSMutableAttributedString(
            string: "\(configSpacing)\t \(viewModel.configurations.activeVideoConfiguration.keyframeInterval)\n",
            attributes: attributes)
        keyframeIntervalTitle.append(keyframeInterval)

        let sizeTitle = NSMutableAttributedString(string: "\tsize", attributes: attributes)
        let size = NSMutableAttributedString(
            string: "\(configSpacing)\t\t\t\t \(viewModel.configurations.activeVideoConfiguration.size)\n",
            attributes: attributes)
        sizeTitle.append(size)

        let enableTransparencyTitle = NSMutableAttributedString(string: "\tenableTransparency", attributes: attributes)
        let enableTransparency = NSMutableAttributedString(
            string: "\(configSpacing) \(viewModel.configurations.activeVideoConfiguration.enableTransparency)\n",
            attributes: attributes)
        enableTransparencyTitle.append(enableTransparency)

        let usesBFramesTitle = NSMutableAttributedString(string: "\tusesBFrames", attributes: attributes)
        let usesBFrames = NSMutableAttributedString(
            string: "\(configSpacing)\t\t \(viewModel.configurations.activeVideoConfiguration.usesBFrames)\n",
            attributes: attributes)
        usesBFramesTitle.append(usesBFrames)

        let useAutoBitrateTitle = NSMutableAttributedString(string: "\tuseAutoBitrate", attributes: attributes)
        let useAutoBitrate = NSMutableAttributedString(
            string: "\(configSpacing)\t\t \(viewModel.configurations.activeVideoConfiguration.useAutoBitrate)\n",
            attributes: attributes)
        useAutoBitrateTitle.append(useAutoBitrate)

        text.append(videoConfigTitle)
        text.append(initialBitrateTitle)
        text.append(maxBitrateTitle)
        text.append(minBitrateTitle)
        text.append(targetFramerateTitle)
        text.append(keyframeIntervalTitle)
        text.append(sizeTitle)
        text.append(enableTransparencyTitle)
        text.append(usesBFramesTitle)
        text.append(useAutoBitrateTitle)

        return text
    }

    var body: some View {
        ZStack {
            Rectangle()
                .overlay(
                    Rectangle()
                        .fill(Constants.background)
                        .opacity(0.9)
                )

            VStack() {
                AttributedText(debugInfoString)
                    .frame(maxWidth: .infinity)

                Spacer()

                HStack {
                    DebugButton(title: "Copy") {
                        UIPasteboard.general.string = debugInfoString.string
                    }

                    DebugButton(title: "Hide debug info") {
                        isPresent.toggle()
                    }
                }
            }
            .padding(16)
        }
        .cornerRadius(10)
    }
}

struct AttributedText: View {
    var attributedString: NSAttributedString
    @State private var size: CGSize = .zero

    init(_ attributedString: NSAttributedString) {
        self.attributedString = attributedString
    }

    var body: some View {
        AttributedTextRepresentable(attributedString: attributedString, size: $size)
            .frame(width: size.width, height: size.height)
    }

    struct AttributedTextRepresentable: UIViewRepresentable {
        let attributedString: NSAttributedString
        @Binding var size: CGSize

        func makeUIView(context: Context) -> UILabel {
            let label = UILabel()

            label.lineBreakMode = .byCharWrapping
            label.numberOfLines = 0

            return label
        }

        func updateUIView(_ uiView: UILabel, context: Context) {
            uiView.attributedText = attributedString

            DispatchQueue.main.async {
                size = uiView.sizeThatFits(uiView.superview?.bounds.size ?? .zero)
            }
        }
    }
}
