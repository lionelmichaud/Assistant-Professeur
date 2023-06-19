//
//  ConnectToActivityModal.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 19/06/2023.
//

import HelpersView
import SwiftUI

struct ConnectToActivityModal: View {
    @ObservedObject
    var competency: DCompEntity

    @State
    private var selectedLevel: LevelClasse = .nbCP

    @State
    private var selectedSequence: SequenceEntity = .all().first!

    @State
    private var selectedActivity: ActivityEntity = .all().first!

    @Environment(\.dismiss)

    private var dismiss

    private var discipline: Discipline? {
        competency.section?.theme?.disciplineEnum
    }

    private var cycle: Cycle? {
        competency.section?.theme?.cycleEnum
    }

    /// Filtrer les séquences en fonction des Discipline, Cycle et Niveau de classe sélectionnés
    private var selectedSequences: [SequenceEntity] {
        if let cycle, let discipline {
            return SequenceEntity.sortedByDisciplineLevelSeq(
                discipline: discipline,
                cycle: cycle,
                level: selectedLevel
            )
        } else {
            return []
        }
    }

    private var selectedActivities: [ActivityEntity] {
        selectedSequence.activitiesSortedByNumber
    }

    var body: some View {
        Form {
            if cycle == nil || discipline == nil {
                Text("Aucune activité existante sélectionnable.")

            } else {
                Section("Sélectionner un niveau") {
                    LevelInCyclePicker(
                        selectedLevel: $selectedLevel,
                        inCycle: cycle!
                    )
                }

                if selectedSequences.isNotEmpty {
                    Section("Sélectionner une séquence") {
                        SequencePicker(
                            selectedSequence: $selectedSequence,
                            inSequences: selectedSequences
                        )
                        .padding(.horizontal)
                    }
                } else {
                    Text("Aucune séquence existante sélectionnable.")
                }

                if selectedActivities.isNotEmpty {
                    Section("Sélectionner une activité") {
                        ActivityPicker(
                            selectedActivity: $selectedActivity,
                            inActivities: selectedActivities
                        )
                        .padding(.horizontal)
                    }
                } else {
                    Text("Aucune activité existante sélectionnable.")
                }
            }
        }
        .onAppear {
            if let firstLevelInCycle = cycle?.associatedLevels.first {
                self.selectedLevel = firstLevelInCycle
            }
            if let firstSequence = selectedSequences.first {
                self.selectedSequence = firstSequence
            }
            if let firstActivity = selectedActivities.first {
                self.selectedActivity = firstActivity
            }
        }
        .onChange(of: selectedLevel) { _ in
            if let firstSequence = selectedSequences.first {
                self.selectedSequence = firstSequence
            }
            if let firstActivity = selectedActivities.first {
                self.selectedActivity = firstActivity
            }
        }
        #if os(iOS)
        .navigationTitle("Activité pédagogique associée")
        #endif
        .navigationBarTitleDisplayModeInline()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuler") {
                    DCompEntity.rollback()
                    dismiss()
                }
            }
            if selectedActivities.isNotEmpty && selectedSequences.isNotEmpty {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ok") {
                        selectedActivity.addToCompetencies(competency)
                        try? DCompEntity.saveIfContextHasChanged()
                        dismiss()
                    }
                }
            }
        }
    }
}

// struct ConnectToActivityModal_Previews: PreviewProvider {
//    static var previews: some View {
//        ConnectToActivityModal()
//    }
// }
