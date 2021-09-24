//
//  ConfigurationSummary.swift
//  Broadcasting
//
//  Created by Uldis Zingis on 16/06/2021.
//

import SwiftUI
import AmazonIVSBroadcast

struct ConfigurationSummary: View {
    @ObservedObject var viewModel: BroadcastViewModel

    var body: some View {
        VStack {
            Spacer()

            Text("Configuration Summary")
                .foregroundColor(.white)
                .font(Constants.fAppBoldExtraLarge)
                .padding(.bottom, 20)

            ZStack {
                Rectangle()
                    .overlay(
                        RoundedRectangle(cornerRadius: 13)
                            .fill(Constants.backgroundGrayLight)
                            .background(Color.black)
                    )
                    .frame(height: 300)
                    .frame(maxWidth: .infinity)

                VStack(alignment: .leading, spacing: 0) {
                    Text("These are the recommended encoder settings based on current network conditions. You can edit these values manually in the App settings.")
                        .font(Constants.fAppRegular)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 20)
                        .padding(.horizontal, 8)

                    ConfigurationRow(
                        title: "Video quality",
                        value: "\(Int(viewModel.configurations.activeVideoConfiguration.size.height))p\(Int(viewModel.configurations.activeVideoConfiguration.targetFramerate))"
                    )
                    ConfigurationRow(
                        title: "Bitrate",
                        value: viewModel.formattedInitialBitrate
                    )
                    ConfigurationRow(
                        title: "Estimated data use*",
                        value: String(format: "%.1fGB/hr", viewModel.dataUsePerHour)
                    )

                    Text("*Actual data usage may be higher or lower, depending on network conditions during the livestream.")
                        .font(Constants.fAppRegularSmall)
                        .foregroundColor(Constants.lightGray)
                        .padding(.top, 10)
                        .padding(.horizontal, 16)
                }
                .frame(maxWidth: UIScreen.main.bounds.width)
            }

            Spacer()
        }
    }
}

struct ConfigurationRow: View {
    var title: String
    var value: String

    var body: some View {
        Group {
            HStack {
                Text(title)
                    .font(Constants.fAppRegularLarge)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                Spacer()
                Text(value)
                    .font(Constants.fAppRegularLarge)
                    .foregroundColor(Constants.lightGray)
                    .padding(.horizontal, 16)
            }
            .padding(.vertical, 12)
            .overlay(
                Rectangle()
                    .frame(width: nil, height: 1, alignment: .top)
                    .foregroundColor(Constants.borderColor),
                alignment: .top
            )
        }
    }
}
