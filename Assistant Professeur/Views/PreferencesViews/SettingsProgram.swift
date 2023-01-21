//
//  SettingsProgram.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 20/01/2023.
//

import SwiftUI

struct SettingsProgram: View {
    @Preference(\.margeInterSequence)
    var margeInterSequence

    var body: some View {
        List {
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
        .navigationTitle("Préférences Programmes")
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct SettingsProgram_Previews: PreviewProvider {
    static var previews: some View {
        SettingsProgram()
    }
}
