//
//  SettingsActivity.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 22/01/2023.
//

import SwiftUI

struct SettingsActivity: View {
    @Preference(\.activityAnnotationEnabled)
    var activityAnnotationEnabled

    var body: some View {
        List {
            Section {
                Toggle("Annotation", isOn: $activityAnnotationEnabled)
            } header: {
                Text("Champs")
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
    }
}
