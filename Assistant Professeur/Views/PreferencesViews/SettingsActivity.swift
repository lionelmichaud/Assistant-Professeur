//
//  SettingsActivity.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 22/01/2023.
//

import SwiftUI

struct SettingsActivity: View {
    @Environment(UserContext.self)
    private var userContext

    var body: some View {
        @Bindable var userContext = userContext
        List {
            Section {
                Toggle("Annotation", isOn: $userContext.prefs.viewActivityAnnotationEnabled)
            } header: {
                Text("Champs")
                    .style(.sectionHeader)
            } footer: {
                Text("Ajouter un champ de saisie d'annotation à chaque activité")
            }
        }
        #if os(iOS)
        .navigationTitle("Préférences Activités")
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct SettingsActivity_Previews: PreviewProvider {
    static var previews: some View {
        SettingsActivity()
            .environmentObject(UserPrefEntity())
    }
}
