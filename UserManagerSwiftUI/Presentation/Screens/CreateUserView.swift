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
                Text("Add a new team member. Location helps pre-fill coordinates when you create a profile.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .listRowBackground(Color.clear)
            }

            Section {
                Button {
                    viewModel.requestCurrentLocation(using: locationManager)
                } label: {
                    Label("Get Current Location", systemImage: "location.fill")
                }
                .disabled(locationManager.isLoading)
            } footer: {
                Text("Uses your location once to read latitude and longitude. You can deny access at any time in Settings.")
            }
        }
        .navigationTitle("Create User")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if locationManager.isLoading {
                ZStack {
                    Color.black.opacity(0.08)
                        .ignoresSafeArea()
                    ProgressView("Getting location…")
                        .padding(20)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                }
            }
        }
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
        .alert("Current coordinates", isPresented: Binding(
            get: { coordinatesAlertText != nil },
            set: { if $0 == false { coordinatesAlertText = nil } }
        )) {
            Button("OK", role: .cancel) {
                coordinatesAlertText = nil
            }
        } message: {
            Text(coordinatesAlertText ?? "")
        }
        .alert("Location", isPresented: Binding(
            get: { errorAlertText != nil },
            set: { if $0 == false { errorAlertText = nil } }
        )) {
            Button("OK", role: .cancel) {
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
