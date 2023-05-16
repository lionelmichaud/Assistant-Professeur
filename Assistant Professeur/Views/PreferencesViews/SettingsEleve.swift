//
//  SettingsPage1.swift
//  Cahier du Professeur (iOS)
//
//  Created by Lionel MICHAUD on 22/05/2022.
//

import SwiftUI

struct SettingsEleve: View {
    @EnvironmentObject
    private var pref: UserPreferences

    @State private var isShowingBonusResetConfirmDialog = false

    var body: some View {
        List {
            Section {
                Toggle("Trombine", isOn: $pref.eleveTrombineEnabled)
                Toggle("Appréciation", isOn: $pref.eleveAppreciationEnabled)
                Toggle("Annotation", isOn: $pref.eleveAnnotationEnabled)
            } header: {
                Text("Champs")
            } footer: {
                Text("Inclure ces champs de saisie pour chaque élève")
            }

            Section("Bonus / Malus") {
                Toggle("Afficher", isOn: $pref.eleveBonusEnabled)
                if pref.eleveBonusEnabled {
                    Stepper(
                        value: $pref.maxBonusMalus,
                        in: 0 ... 100,
                        step: 1
                    ) {
                        HStack {
                            Text("Limite")
                            Spacer()
                            Text("+/-\(pref.maxBonusMalus.formatted(.number.precision(.fractionLength(0)))) points")
                                .foregroundColor(.secondary)
                        }
                    }

                    Stepper(
                        value: $pref.maxBonusIncrement,
                        in: 1 ... 5,
                        step: 1
                    ) {
                        HStack {
                            Text("Incrément de")
                            Spacer()
                            Text("\(pref.maxBonusIncrement.formatted(.number.precision(.fractionLength(0)))) points")
                                .foregroundColor(.secondary)
                        }
                    }

                    Button("Remettre tous les bonus à zéro", role: .destructive) {
                        isShowingBonusResetConfirmDialog.toggle()
                    }
                    // Confirmation de la remise à zéro des bonus/malus de tous les élèves
                    .confirmationDialog(
                        "Remise à zéro des bonus/malus de tous les élèves",
                        isPresented: $isShowingBonusResetConfirmDialog,
                        titleVisibility: .visible
                    ) {
                        Button("Remettre à zéro", role: .destructive) {
                            let eleves = EleveEntity.all()
                            eleves.forEach { eleve in
                                eleve.viewBonus = 0
                            }
                        }
                    } message: {
                        Text("Cette action ne peut pas être annulée.")
                    }
                }
            }
        }
        #if os(iOS)
        .navigationTitle("Préférences Élève")
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct SettingsEleve_Previews: PreviewProvider {
    static var previews: some View {
        SettingsEleve()
    }
}
