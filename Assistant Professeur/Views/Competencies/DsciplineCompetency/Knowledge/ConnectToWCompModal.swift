//
//  ConnectToWCompModal.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 17/06/2023.
//

import HelpersView
import SwiftUI

/// Dialogue modal de connection d'une Compétence Disciplinaire avec des Compétences Travaillées
struct ConnectToWCompModal: View {
    @ObservedObject
    var competency: DCompEntity

    @State
    private var selectedWComp: WCompEntity = .all().first!

    @State
    private var selectedWCompChapter: WCompChapterEntity = .all().first!

    @Environment(\.dismiss)
    private var dismiss

    private var cycle: Cycle? {
        competency.section?.theme?.cycleEnum
    }

    /// Filtrer les chapitres en fonction du Cycle
    private var selectedWCompChapters: [WCompChapterEntity] {
        if let cycle {
            return WCompChapterEntity
                .sortedbyCycleAcronymTitle(forCycle: cycle)
        } else {
            return []
        }
    }

    private var selectedWComps: [WCompEntity] {
        selectedWCompChapter.allWorkedCompetenciesSortedByNumber
    }

    var body: some View {
        Form {
            if cycle == nil {
                Text("Aucune compétence travaillée existante sélectionnable.")

            } else {
                if selectedWCompChapters.isNotEmpty {
                    Section("Sélectionner un Élement du socle") {
                        WCompChapterPicker(
                            selectedChapter: $selectedWCompChapter,
                            inChapters: selectedWCompChapters
                        )
                    }
                } else {
                    Text("Aucun élément existant du socle sélectionnable.")
                }

                if selectedWComps.isNotEmpty {
                    Section("Sélectionner une Compétence du socle") {
                        WCompPicker(
                            selectedCompetency: $selectedWComp,
                            inCompetencies: selectedWComps
                        )
                    }
                } else {
                    Text("Aucune compétence existante du socle sélectionnable.")
                }
            }
        }
        .onAppear {
            if let firstChapter = selectedWCompChapters.first {
                self.selectedWCompChapter = firstChapter
            }
            if let firstComp = selectedWComps.first {
                self.selectedWComp = firstComp
            }
        }
        #if os(iOS)
        .navigationTitle("Compétence travaillée associée")
        #endif
        .navigationBarTitleDisplayModeInline()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuler") {
                    DCompEntity.rollback()
                    dismiss()
                }
            }
            if selectedWCompChapters.isNotEmpty && selectedWComps.isNotEmpty {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ok") {
                        selectedWComp.addToDisciplineCompetencies(competency)
                        try? DCompEntity.saveIfContextHasChanged()
                        dismiss()
                    }
                }
            }
        }
    }
}

// struct ConnectToWCompModal_Previews: PreviewProvider {
//    static var previews: some View {
//        ConnectToWCompModal()
//    }
// }
