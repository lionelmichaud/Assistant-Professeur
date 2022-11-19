//
//  SettingsSchool.swift
//  Cahier du Professeur (iOS)
//
//  Created by Lionel MICHAUD on 22/05/2022.
//

import SwiftUI

struct SettingsSchool: View {
    @Preference(\.schoolAnnotationEnabled)
    var schoolAnnotation

    var body: some View {
        List {
            Section {
                Toggle("Annotation", isOn: $schoolAnnotation)
            } header: {
                Text("Champs")
            } footer: {
                Text("Ajouter un champ de saisie d'annotation à chaque établissement")
            }
        }
        #if os(iOS)
        .navigationTitle("Préférences Établissement")
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct SettingsSchool_Previews: PreviewProvider {
    static var previews: some View {
        SettingsSchool()
    }
}
