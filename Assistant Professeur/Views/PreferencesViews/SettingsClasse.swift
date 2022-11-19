//
//  SettingsClasse.swift
//  Cahier du Professeur (iOS)
//
//  Created by Lionel MICHAUD on 22/05/2022.
//

import SwiftUI

struct SettingsClasse: View {
    @Preference(\.classeAppreciationEnabled)
    var classeAppreciation
    @Preference(\.classeAnnotationEnabled)
    var classeAnnotation

    var body: some View {
        List {
            Section {
                Toggle("Appréciation", isOn: $classeAppreciation)
                Toggle("Annotation", isOn: $classeAnnotation)
            } header: {
                Text("Champs")
            } footer: {
                Text("Inclure des champs de saisie pour chaque classe")
            }
        }
        #if os(iOS)
        .navigationTitle("Préférences Classe")
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct SettingsClasse_Previews: PreviewProvider {
    static var previews: some View {
        SettingsClasse()
    }
}
