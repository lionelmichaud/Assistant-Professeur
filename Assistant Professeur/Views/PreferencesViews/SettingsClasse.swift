//
//  SettingsClasse.swift
//  Cahier du Professeur (iOS)
//
//  Created by Lionel MICHAUD on 22/05/2022.
//

import SwiftUI

struct SettingsClasse: View {
    @EnvironmentObject
    private var userContext: UserContext

    var body: some View {
        List {
            Section {
                Toggle("Appréciation", isOn: $userContext.prefs.viewClasseAppreciationEnabled)
                Toggle("Annotation", isOn: $userContext.prefs.viewClasseAnnotationEnabled)
            } header: {
                Text("Champs")
                    .style(.sectionHeader)
            } footer: {
                Text("Inclure ces champs de saisie pour chaque classe")
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
