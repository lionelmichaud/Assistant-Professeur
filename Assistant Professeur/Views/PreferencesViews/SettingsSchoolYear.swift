//
//  SettingsSchoolYear.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 16/05/2023.
//

import HelpersView
import SwiftUI

struct SettingsSchoolYear: View {
    @EnvironmentObject
    private var pref: UserPreferences

    var body: some View {
        Form {
            // Zone scolaire
            Section {
                CasePicker(
                    pickedCase: $pref.schoolYear.zone,
                    label: "Zone scolaire"
                )
                .pickerStyle(.segmented)
                Text("\(pref.schoolYear.zone.academy)")
                    .foregroundColor(.secondary)
            } header: {
                Text("Zone scolaire")
            }

            Section {
                HStack {
                    Text("du")
                    DatePicker(
                        "Début",
                        selection: $pref.schoolYear.interval.start,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    Text("au")
                    DatePicker(
                        "Fin",
                        selection: $pref.schoolYear.interval.end,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                }
            } header: {
                Text("Année scolaire")
            }

            Section {
                HStack {
                    Text("du")
                    DatePicker(
                        "Début",
                        selection: $pref.schoolYear.autumnVacation.start,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    Text("au")
                    DatePicker(
                        "Fin",
                        selection: $pref.schoolYear.autumnVacation.end,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                }
            } header: {
                Text("Vacances de Toussaint")
            }

            Section {
                HStack {
                    Text("du")
                    DatePicker(
                        "Début",
                        selection: $pref.schoolYear.noelVacation.start,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    Text("au")
                    DatePicker(
                        "Fin",
                        selection: $pref.schoolYear.noelVacation.end,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                }
            } header: {
                Text("Vacances de Noël")
            }

            Section {
                HStack {
                    Text("du")
                    DatePicker(
                        "Début",
                        selection: $pref.schoolYear.winterVacation.start,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    Text("au")
                    DatePicker(
                        "Fin",
                        selection: $pref.schoolYear.winterVacation.end,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                }
            } header: {
                Text("Vacances d'hiver")
            }

            Section {
                HStack {
                    Text("du")
                    DatePicker(
                        "Début",
                        selection: $pref.schoolYear.paqueVacation.start,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    Text("au")
                    DatePicker(
                        "Fin",
                        selection: $pref.schoolYear.paqueVacation.end,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                }
            } header: {
                Text("Vacances de printemps")
            }
        }
        .padding(.bottom, 34)
        #if os(iOS)
            .navigationTitle("Année scolaire")
            .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct SettingsSchoolYear_Previews: PreviewProvider {
    static var previews: some View {
        SettingsSchoolYear()
            .environmentObject(UserPreferences())
    }
}
