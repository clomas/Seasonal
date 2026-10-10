//
//  InfoScreen.swift
//  Seasonal
//
//  Created by Clint Thomas on 15/6/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI

@available(iOS 26, *)
struct InfoScreen: View {

    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.dismiss) private var dismiss

    @Bindable private var themeStore = ThemeStore.shared

    @State private var selectedState = Self.savedState

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text(introText)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }

                Section(Strings.Info.locationSection) {
                    Picker(Strings.Info.produceLocation, selection: $selectedState) {
                        if selectedState == .noState {
                            Text(StateLocation.noState.fullName).tag(StateLocation.noState)
                        }
                        ForEach(StateLocation.selectable, id: \.self) { state in
                            Text(state.fullName).tag(state)
                        }
                    }
                    // Menu pickers keep the tint they were created with, so rebuild them when it changes.
                    .id(themeStore.theme)
                }

                Section {
                    Picker(Strings.Info.themePicker, selection: $themeStore.theme) {
                        ForEach(Theme.allCases) { theme in
                            Text(theme.title).tag(theme)
                        }
                    }
                    .id(themeStore.theme)
                    Picker(Strings.Info.appearancePicker, selection: $themeStore.appearance) {
                        ForEach(Appearance.allCases) { appearance in
                            Text(appearance.title).tag(appearance)
                        }
                    }
                    .id(themeStore.theme)
                } header: {
                    Text(Strings.Info.appearanceSection)
                } footer: {
                    Text(Strings.Info.themeFooter)
                }

                Section(Strings.Info.aboutSection) {
                    if let url = ExternalLink.sourceCode {
                        Link(destination: url) {
                            Label(Strings.Info.viewSource, systemImage: Symbol.sourceCode)
                        }
                    }
                    if let url = ExternalLink.privacyPolicy {
                        Link(destination: url) {
                            Label(Strings.Info.privacyPolicy, systemImage: Symbol.privacy)
                        }
                    }
                    if let url = ExternalLink.contactEmail {
                        Link(destination: url) {
                            Label(Strings.Info.getInTouch, systemImage: Symbol.email)
                        }
                    }
                }

                if let version = Bundle.main.shortVersion {
                    Section {
                        Text(Strings.Info.version(version))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle(Strings.Info.title)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close, action: dismiss.callAsFunction)
                        .accessibilityIdentifier("closeInfoButton")
                }
            }
            .tint(Colour.inSeason)
            .onChange(of: selectedState) { _, newState in
                guard newState != Self.savedState else { return }
                dismiss()
                coordinator.changeLocation(to: newState)
            }
        }
    }

    private static var savedState: StateLocation {
        StateLocation(rawValue: GlobalSettings.location.state) ?? .noState
    }

    private var introText: String {
        Strings.Info.intro(location: Self.savedState.fullName)
    }
}

@available(iOS 26, *)
#Preview {
    InfoScreen()
        .environment(previewCoordinator)
}
