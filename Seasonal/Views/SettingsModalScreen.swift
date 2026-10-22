//
//  SettingsModalScreen.swift
//  Seasonal
//
//  Created by Clint Thomas on 15/6/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import CloudKit
import SwiftUI

@available(iOS 26, *)
struct SettingsModalScreen: View {

    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var contrast

    @Bindable private var themeStore = ThemeStore.shared

    @State private var selectedState = Self.savedState
    @State private var isChangingLocation = false
    @State private var locationError: CKError?
    @State private var isShowingLocationError = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text(introText)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }

                Section(Strings.Settings.locationSection) {
                    Picker(selection: $selectedState) {
                        if selectedState == .noState {
                            Text(StateLocation.noState.fullName).tag(StateLocation.noState)
                        }
                        ForEach(StateLocation.selectable, id: \.self) { state in
                            Text(state.fullName).tag(state)
                        }
                    } label: {
                        HStack(spacing: .space2) {
                            Text(Strings.Settings.produceLocation)
                            if isChangingLocation {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(isChangingLocation)
                    // Menu pickers keep the tint they were created with, so rebuild them when it changes.
                    .id(themeStore.theme)
                }

                Section {
                    Picker(Strings.Settings.themePicker, selection: $themeStore.theme) {
                        ForEach(Theme.allCases) { theme in
                            Label {
                                Text(theme.title)
                            } icon: {
                                Image(swatch: theme.accentResource, scheme: colorScheme, contrast: contrast)
                            }
                            .tag(theme)
                        }
                    }
                    .id(themeStore.theme)
                    Picker(Strings.Settings.appearancePicker, selection: $themeStore.appearance) {
                        ForEach(Appearance.allCases) { appearance in
                            Text(appearance.title).tag(appearance)
                        }
                    }
                    .id(themeStore.theme)
                } header: {
                    Text(Strings.Settings.appearanceSection)
                } footer: {
                    Text(Strings.Settings.themeFooter)
                }

                Section(Strings.Settings.aboutSection) {
                    if let url = ExternalLink.sourceCode {
                        Link(destination: url) {
                            Label(Strings.Settings.viewSource, systemImage: Symbol.sourceCode)
                        }
                    }
                    if let url = ExternalLink.privacyPolicy {
                        Link(destination: url) {
                            Label(Strings.Settings.privacyPolicy, systemImage: Symbol.privacy)
                        }
                    }
                    if let url = ExternalLink.contactEmail {
                        Link(destination: url) {
                            Label(Strings.Settings.getInTouch, systemImage: Symbol.email)
                        }
                    }
                }

                if let version = Bundle.main.shortVersion {
                    Section {
                        Text(Strings.Settings.version(version))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle(Strings.Settings.title)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close, action: dismiss.callAsFunction)
                        .accessibilityIdentifier("closeSettingsButton")
                }
            }
            .tint(Colour.inSeason)
            .task(id: selectedState) {
                await changeLocation(to: selectedState)
            }
            .alert(locationError?.errorTitle ?? "", isPresented: $isShowingLocationError) {
            } message: {
                Text(locationError?.errorMessage ?? "")
            }
        }
    }

    private static var savedState: StateLocation {
        StateLocation(rawValue: GlobalSettings.location.state) ?? .noState
    }

    private var introText: String {
        Strings.Settings.intro(location: Self.savedState.fullName)
    }

    private func changeLocation(to newState: StateLocation) async {
        guard newState != Self.savedState else { return }

        isChangingLocation = true
        locationError = await coordinator.changeLocation(to: newState)
        isChangingLocation = false

        if locationError != nil {
            isShowingLocationError = true
            selectedState = Self.savedState
        }
    }
}

#if DEBUG
@available(iOS 26, *)
#Preview {
    SettingsModalScreen()
        .environment(previewCoordinator)
}
#endif
