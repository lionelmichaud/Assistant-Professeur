//
//  SettingsSequence.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 22/01/2023.
//

import SwiftUI

struct SettingsSequence: View {
    @EnvironmentObject
    private var pref: UserPreferences

    var body: some View {
        List {
            Section {
                Toggle("Annotation", isOn: $pref.sequenceAnnotationEnabled)
            } header: {
                Text("Champs")
                    .style(.sectionHeader)
            } footer: {
                Text("Ajouter un champ de saisie d'annotation à chaque séquence")
            }

            Section {
                Stepper(value : $pref.margeInterSequence,
                        in    : 0 ... 3,
                        step  : 1) {
                    HStack {
                        Text("Nombre de séances")
                        Spacer()
                        Text("\(pref.margeInterSequence.formatted(.number))")
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
            .environmentObject(UserPreferences())
    }
}
