//
//  SettingsGeneral.swift
//  Cahier du Professeur (iOS)
//
//  Created by Lionel MICHAUD on 18/09/2022.
//

import HelpersView
import SwiftUI

struct SettingsGeneral: View {
    @EnvironmentObject
    private var pref: UserPreferences

    var body: some View {
        List {
            // Type d'interopérabilité avec les ENT
            Text("Type d'interopérabilité avec les ENT")
            CasePicker(
                pickedCase: $pref.interoperability,
                label: "Interopérabilté avec"
            )
            .pickerStyle(.segmented)

            Section {
                // Ordre d'affichage des noms des élèves
                Text("Ordre d'affichage des noms des élèves")
                CasePicker(
                    pickedCase: $pref.nameDisplayOrder,
                    label: "Ordre d'affichage des noms"
                )
                .pickerStyle(.segmented)
                // Ordre de tri des noms des élèves
                Text("Ordre de tri des noms des élèves")
                CasePicker(
                    pickedCase: $pref.nameSortOrder,
                    label: "Ordre de tri des noms"
                )
                .pickerStyle(.segmented)
            } header: {
                Text("Affichage")
            }
            // .listRowSeparator(.hidden)
        }
        #if os(iOS)
        .navigationTitle("Préférences Générales")
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct SettingsGeneral_Previews: PreviewProvider {
    static var previews: some View {
        SettingsGeneral()
            .environmentObject(UserPreferences())
    }
}
