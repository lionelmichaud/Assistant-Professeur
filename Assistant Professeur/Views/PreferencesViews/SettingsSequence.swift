//
//  SettingsSequence.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 22/01/2023.
//

import SwiftUI

struct SettingsSequence: View {
    @Preference(\.sequenceAnnotationEnabled)
    var sequenceAnnotationEnabled

    @Preference(\.margeInterSequence)
    var margeInterSequence

    var body: some View {
        List {
            Section {
                Toggle("Annotation", isOn: $sequenceAnnotationEnabled)
            } header: {
                Text("Champs")
            } footer: {
                Text("Ajouter un champ de saisie d'annotation à chaque séquence")
            }
            Section {
                Stepper(value : $margeInterSequence,
                        in    : 0 ... 3,
                        step  : 1) {
                    HStack {
                        Text("Nombre de séances")
                        Spacer()
                        Text("\(margeInterSequence.formatted(.number))")
                            .foregroundColor(.secondary)
                    }
                }

            } header: {
                Text("Marge temporelle entre deux séquences pédagogiques")
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
    }
}
