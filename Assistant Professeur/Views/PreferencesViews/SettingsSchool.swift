//
//  SettingsSchool.swift
//  Cahier du Professeur (iOS)
//
//  Created by Lionel MICHAUD on 22/05/2022.
//

import SwiftUI

struct SettingsSchool: View {
    @Environment(UserContext.self)
    private var userContext

    var body: some View {
        @Bindable var userContext = userContext
        List {
            Section {
                Toggle("Annotation", isOn: $userContext.prefs.viewSchoolAnnotationEnabled)
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
