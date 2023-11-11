//
//  SettingsProgram.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 20/01/2023.
//

import SwiftUI

struct SettingsProgram: View {
    @EnvironmentObject
    private var userContext: UserContext

    var body: some View {
        List {
            Section {
                Toggle("Annotation", isOn: $userContext.prefs.viewProgramAnnotationEnabled)
            } header: {
                Text("Champs")
                    .style(.sectionHeader)
            } footer: {
                Text("Ajouter un champ de saisie d'annotation à chaque progression")
            }
        }
        #if os(iOS)
        .navigationTitle("Préférences Progressions")
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct SettingsProgram_Previews: PreviewProvider {
    static var previews: some View {
        SettingsProgram()
            .environmentObject(UserPrefEntity())
    }
}
