//
//  SettingsProgram.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 20/01/2023.
//

import SwiftUI

struct SettingsProgram: View {
    @Preference(\.programAnnotationEnabled)
    var programAnnotationEnabled

    var body: some View {
        List {
            Section {
                Toggle("Annotation", isOn: $programAnnotationEnabled)
            } header: {
                Text("Champs")
            } footer: {
                Text("Ajouter un champ de saisie d'annotation à chaque programme")
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
