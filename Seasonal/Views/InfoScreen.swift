//
//  InfoScreen.swift
//  Seasonal
//
//  Created by Clint Thomas on 15/6/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI

/// The in-app information screen — the SwiftUI equivalent of the legacy
/// `InfoViewController`. Shows the app spiel, a state picker that re-fetches
/// produce data, source/privacy links and an email contact.
@available(iOS 26, *)
struct InfoScreen: View {

    @EnvironmentObject private var coordinator: AppCoordinator

    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    /// States the user can pick from — excludes `.noState` (and `.act`, which has
    /// no `fullName`), matching the initial location picker.
    private let selectableStates: [StateLocation] = StateLocation.allCases.filter {
        $0.fullName != StateLocation.noState.fullName
    }

    @State private var selectedState: StateLocation = Self.currentState

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text(infoText)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }

                Section("Location") {
                    Picker("Produce location", selection: $selectedState) {
                        ForEach(selectableStates, id: \.self) { state in
                            Text(state.fullName).tag(state)
                        }
                    }
                }

                Section("About") {
                    if let url = URL(string: "https://github.com/clomas/Seasonal") {
                        Link(destination: url) {
                            Label("View source on GitHub", systemImage: "chevron.left.forwardslash.chevron.right")
                        }
                    }
                    // TODO: Privacy policy link here
                    if let url = URL(string: "https://github.com/clomas/Seasonal") {
                        Link(destination: url) {
                            Label("Privacy policy", systemImage: "hand.raised")
                        }
                    }
                    Button {
                        if let url = URL(string: "mailto:clint.thomas@me.com") {
                            openURL(url)
                        }
                    } label: {
                        Label("Get in touch", systemImage: "envelope")
                    }
                }

                if let version = appVersion {
                    Section {
                        Text("Seasonal \(version)")
                            .font(.footnote)
                            .foregroundStyle(.tertiary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("Seasonal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .tint(Colour.inSeason)
            .onChange(of: selectedState) { _, newState in
                guard newState != Self.currentState else { return }
                dismiss()
                coordinator.changeLocation(to: newState)
            }
        }
    }

    // MARK: - Helpers

    /// The currently persisted state, or `.noState` if none is set.
    private static var currentState: StateLocation {
        StateLocation(rawValue: GlobalSettings.location.state) ?? .noState
    }

    /// The info spiel, with "Australia" replaced by the user's state when one is set.
    private var infoText: String {
        let state = Self.currentState
        guard state.fullName != StateLocation.noState.fullName else {
            return Constants.infoPageSpiel
        }
        return Constants.infoPageSpiel.replacingOccurrences(of: Constants.straya, with: state.fullName)
    }

    private var appVersion: String? {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
}

@available(iOS 26, *)
#Preview {
    InfoScreen()
        .environmentObject(previewCoordinator)
}
