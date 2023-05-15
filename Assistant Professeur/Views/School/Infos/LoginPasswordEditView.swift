//
//  LoginPasswordEditView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 15/05/2023.
//

import SwiftUI

public struct LoginPasswordEditView: View {
    private let title: String
    @Binding
    private var id: String
    @Binding
    private var pwd: String

    // MARK: - Initializer

    public init(
        title: String,
        id: Binding<String>,
        pwd: Binding<String>
    ) {
        self.title = title
        self._id = id
        self._pwd = pwd
    }

    // MARK: - Computed properties

    public var body: some View {
        Section {
            // Identifiant
            LabeledContent {
                TextField("Identifiant", text: $id)
                #if os(iOS) || os(tvOS)
                    .textInputAutocapitalization(.never)
                #endif
            } label: {
                Image(systemName: "person.fill.questionmark")
                    .imageScale(.large)
            }

            // Mot de passe
            LabeledContent {
                TextField("Mot de passe", text: $pwd)
                #if os(iOS) || os(tvOS)
                    .textInputAutocapitalization(.never)
                #endif
            } label: {
                Image(systemName: "key.horizontal")
                    .imageScale(.large)
            }
        } header: {
            Label(title, systemImage: "tray.full.fill")
                .bold()
                .padding(.top)
        }
        .autocorrectionDisabled()
    }
}

struct LoginPasswordEditView_Previews: PreviewProvider {
    static var previews: some View {
        LoginPasswordEditView(
            title: "Titre",
            id: .constant("identifiant"),
            pwd: .constant("motdepasse")
        )
    }
}
