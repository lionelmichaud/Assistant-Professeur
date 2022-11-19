//
//  SettingsPage1.swift
//  Cahier du Professeur (iOS)
//
//  Created by Lionel MICHAUD on 22/05/2022.
//

import SwiftUI

struct SettingsEleve: View {
    @EnvironmentObject var eleveStore: EleveStore
    @Preference(\.eleveAppreciationEnabled)
    var eleveAppreciationEnabled
    @Preference(\.eleveAnnotationEnabled)
    var eleveAnnotationEnabled
    @Preference(\.eleveBonusEnabled)
    var eleveBonusEnabled
    @Preference(\.maxBonusMalus)
    var maxBonusMalus
    @Preference(\.maxBonusIncrement)
    var maxBonusIncrement
    @Preference(\.eleveTrombineEnabled)
    var eleveTrombineEnabled

    var body: some View {
        List {
            Section {
                Toggle("Trombine", isOn: $eleveTrombineEnabled)
                Toggle("Appréciation", isOn: $eleveAppreciationEnabled)
                Toggle("Annotation", isOn: $eleveAnnotationEnabled)
            } header: {
                Text("Champs")
            } footer: {
                Text("Inclure des champs de saisie pour chaque classe")
            }

            Section("Bonus / Malus") {
                Toggle("Afficher", isOn: $eleveBonusEnabled)
                if eleveBonusEnabled {
                    Stepper(value : $maxBonusMalus,
                            in    : 0 ... 100,
                            step  : 1) {
                        HStack {
                            Text("Limite")
                            Spacer()
                            Text("+/-\(maxBonusMalus.formatted(.number.precision(.fractionLength(0))))")
                                .foregroundColor(.secondary)
                        }
                    }

                    Stepper(value : $maxBonusIncrement,
                            in    : 0.25 ... 1,
                            step  : 0.25) {
                        HStack {
                            Text("Par incrément de")
                            Spacer()
                            Text("\(maxBonusIncrement.formatted(.number.precision(.fractionLength(2))))")
                                .foregroundColor(.secondary)
                        }
                    }

                    Button("Remettre tous les bonus à zéro", role: .destructive) {
                        for idx in eleveStore.items.indices {
                            eleveStore.items[idx].bonus = 0
                        }
                        eleveStore.saveAsJSON()
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
