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
    private var userContext: UserContext

    var body: some View {
        List {
            // Type d'interopérabilité avec les ENT
            Text("Importation de listes d'élèves au format")
            CasePicker(
                pickedCase: $userContext.prefs.interoperabilityEnum,
                label: "Interopérabilté avec"
            )
            .pickerStyle(.segmented)
            VStack(alignment: .leading) {
                Text("Les fichiers **`\(userContext.prefs.interoperabilityEnum.pickerString)`** importés doivent être au format CSV:")
                switch userContext.prefs.interoperabilityEnum {
                    case .proNote:
                        Group {
                            Text("1) Les fichiers liste d'élèves doivent contenir 3 colonnes nommées: **'Nom'**; **'Prén.'**; **'S'**.")
                                .padding(.top, 2)
                            Text("2) La colonne **'S'** contient le sexe avec pour convention **'Masculin'** ou **'Féminin'**.")
                                .padding(.top, 2)
                        }
                        .padding(.leading)

                    case .ecoleDirecte:
                        Group {
                            Text("1) Les fichiers liste d'élèves doivent contenir 3 colonnes nommées: **'Nom'**; **'Sexe'**.")
                                .padding(.top, 2)
                            Text("2) La colonne **'Nom'** contient les nom (sans espace) et prénom séparés par un espace.")
                                .padding(.top, 2)
                            Text("3) La colonne **'Sexe'** contient le sexe avec pour convention **'M'** ou **'F'**.")
                                .padding(.top, 2)
                        }
                        .padding(.leading)
                }
            }
            .foregroundColor(.secondary)

            Section {
                // Ordre d'affichage des noms des élèves
                Text("Ordre d'affichage des noms des élèves")
                CasePicker(
                    pickedCase: $userContext.prefs.nameDisplayOrderEnum,
                    label: "Ordre d'affichage des noms"
                )
                .pickerStyle(.segmented)
                // Ordre de tri des noms des élèves
                Text("Ordre de tri des noms des élèves")
                CasePicker(
                    pickedCase: $userContext.prefs.nameSortOrderEnum,
                    label: "Ordre de tri des noms"
                )
                .pickerStyle(.segmented)
            } header: {
                Text("Affichage")
                    .style(.sectionHeader)
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
            .environmentObject(UserPrefEntity())
    }
}
