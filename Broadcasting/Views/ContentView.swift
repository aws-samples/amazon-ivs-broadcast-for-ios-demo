//
//  ContentView.swift
//  Broadcasting
//
//  Created by Uldis Zingis on 10/06/2021.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var viewModel = BroadcastViewModel()
    @State private var isStartScreenPresent: Bool

    init() {
        isStartScreenPresent = !BroadcastConfiguration.shared.userDefaults.bool(forKey: Constants.kWasLaunchedBefore)
    }

    var body: some View {
        if isStartScreenPresent {
            StartScreen(viewModel: viewModel, isPresented: $isStartScreenPresent)
        } else {
            BroadcastView(viewModel: viewModel)
        }
    }
}
