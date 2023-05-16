//
//  SettingsSchoolYear.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 16/05/2023.
//

import SwiftUI

struct SettingsSchoolYear: View {
    @EnvironmentObject
    private var pref: UserPreferences

    var body: some View {
        List {
            Section {
                DatePicker(
                    "Début",
                    selection: $pref.scolarYear.start,
                    displayedComponents: .date
                )
                DatePicker(
                    "Fin",
                    selection: $pref.scolarYear.end,
                    displayedComponents: .date
                )
            } header: {
                Text("Année scolaire")
            }

            Section {
                DatePicker(
                    "Début",
                    selection: $pref.autumnVacation.start,
                    displayedComponents: .date
                )
                DatePicker(
                    "Fin",
                    selection: $pref.autumnVacation.end,
                    displayedComponents: .date
                )
            } header: {
                Text("Vacances d'automne")
            }

            Section {
                DatePicker(
                    "Début",
                    selection: $pref.noelVacation.start,
                    displayedComponents: .date
                )
                DatePicker(
                    "Fin",
                    selection: $pref.noelVacation.end,
                    displayedComponents: .date
                )
            } header: {
                Text("Vacances de Noël")
            }

            Section {
                DatePicker(
                    "Début",
                    selection: $pref.winterVacation.start,
                    displayedComponents: .date
                )
                DatePicker(
                    "Fin",
                    selection: $pref.winterVacation.end,
                    displayedComponents: .date
                )
            } header: {
                Text("Vacances d'hiver")
            }

            Section {
                DatePicker(
                    "Début",
                    selection: $pref.paqueVacation.start,
                    displayedComponents: .date
                )
                DatePicker(
                    "Fin",
                    selection: $pref.paqueVacation.end,
                    displayedComponents: .date
                )
            } header: {
                Text("Vacances de Pâques")
            }

        }
        #if os(iOS)
        .navigationTitle("Préférences Année")
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct SettingsSchoolYear_Previews: PreviewProvider {
    static var previews: some View {
        SettingsSchoolYear()
    }
}
