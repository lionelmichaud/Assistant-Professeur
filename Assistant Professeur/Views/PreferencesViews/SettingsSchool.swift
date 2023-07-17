//
//  SettingsSchool.swift
//  Cahier du Professeur (iOS)
//
//  Created by Lionel MICHAUD on 22/05/2022.
//

import SwiftUI

struct SettingsSchool: View {
    @ObservedObject
    private var pref = UserPrefEntity.shared

    var body: some View {
        List {
            Section {
                Toggle("Annotation", isOn: $pref.viewSchoolAnnotationEnabled)
            } header: {
                Text("Champs")
                    .style(.sectionHeader)
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
