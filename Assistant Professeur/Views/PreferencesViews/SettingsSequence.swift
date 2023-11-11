//
//  SettingsSequence.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 22/01/2023.
//

import SwiftUI

struct SettingsSequence: View {
    @EnvironmentObject
    private var userContext: UserContext

    var body: some View {
        List {
            Section {
                Toggle("Annotation", isOn: $userContext.prefs.viewSequenceAnnotationEnabled)
            } header: {
                Text("Champs")
                    .style(.sectionHeader)
            } footer: {
                Text("Ajouter un champ de saisie d'annotation à chaque séquence")
            }

            Section {
                Stepper(value : $userContext.prefs.viewMargeInterSequence,
                        in    : 0 ... 3,
                        step  : 1) {
                    HStack {
                        Text("Nombre de séances")
                        Spacer()
                        Text("\(userContext.prefs.viewMargeInterSequence.formatted(.number))")
                            .foregroundColor(.secondary)
                    }
                }
            } header: {
                Text("Marge temporelle entre deux séquences pédagogiques")
                    .style(.sectionHeader)
            } footer: {
                Text("Ajouter éventuellement une marge temporelle d'une ou plusieurs séances entre deux séquences pédagogiques.")
            }
        }
        #if os(iOS)
        .navigationTitle("Préférences Séquences")
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct SettingsSequence_Previews: PreviewProvider {
    static var previews: some View {
        SettingsSequence()
            .environmentObject(UserPrefEntity())
    }
}
