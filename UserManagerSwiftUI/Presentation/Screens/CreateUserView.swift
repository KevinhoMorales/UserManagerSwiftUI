//
//  CreateUserView.swift
//  UserManagerSwiftUI
//
//  Created by Kevinho Morales on 7/5/26.
//

import SwiftUI

// MARK: - CreateUserView

struct CreateUserView: View {

    // MARK: Properties

    @Bindable private var locationManager: CoreLocationManager
    private let viewModel = CreateUserViewModel()

    @State private var coordinatesAlertText: String?
    @State private var errorAlertText: String?

    // MARK: Lifecycle

    init(locationManager: CoreLocationManager) {
        self.locationManager = locationManager
    }

    // MARK: Body

    var body: some View {
        Form {
            Section {
                Text(L10n.CreateUser.intro)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .listRowBackground(Color.clear)
            }

            Section {
                Button {
                    viewModel.requestCurrentLocation(using: locationManager)
                } label: {
                    Label(L10n.CreateUser.getLocation, systemImage: "location.fill")
                }
                .disabled(locationManager.isLoading)
                .accessibilityHint(L10n.CreateUser.locationFooter)
            } footer: {
                Text(L10n.CreateUser.locationFooter)
                    .font(.footnote)
            }
        }
        .formStyle(.grouped)
        .navigationTitle(L10n.CreateUser.title)
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if locationManager.isLoading {
                ZStack {
                    Color.black.opacity(0.08)
                        .ignoresSafeArea()
                    VStack(spacing: 12) {
                        ProgressView()
                            .controlSize(.large)
                        Text(L10n.CreateUser.loading)
                            .font(.callout)
                            .multilineTextAlignment(.center)
                    }
                    .padding(AppMetrics.loadingPanelPadding)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: AppMetrics.loadingPanelCornerRadius))
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: locationManager.isLoading)
        .onChange(of: locationManager.isLoading) { _, isLoading in
            guard isLoading == false else { return }
            if let lat = locationManager.latitude,
               let lon = locationManager.longitude,
               locationManager.errorMessage == nil {
                coordinatesAlertText = viewModel.coordinatesAlertBody(latitude: lat, longitude: lon)
            } else if let message = locationManager.errorMessage {
                errorAlertText = message
            }
        }
        .onChange(of: locationManager.errorMessage) { _, message in
            guard locationManager.isLoading == false, let message else { return }
            if locationManager.latitude != nil, locationManager.longitude != nil {
                return
            }
            errorAlertText = message
        }
        .alert(L10n.CreateUser.alertCoordinates, isPresented: Binding(
            get: { coordinatesAlertText != nil },
            set: { if $0 == false { coordinatesAlertText = nil } }
        )) {
            Button(L10n.Common.ok, role: .cancel) {
                coordinatesAlertText = nil
            }
        } message: {
            Text(coordinatesAlertText ?? "")
        }
        .alert(L10n.CreateUser.alertLocation, isPresented: Binding(
            get: { errorAlertText != nil },
            set: { if $0 == false { errorAlertText = nil } }
        )) {
            Button(L10n.Common.ok, role: .cancel) {
                errorAlertText = nil
            }
        } message: {
            Text(errorAlertText ?? "")
        }
    }
}

// MARK: - Previews

#Preview {
    NavigationStack {
        CreateUserView(locationManager: CoreLocationManager())
    }
}
