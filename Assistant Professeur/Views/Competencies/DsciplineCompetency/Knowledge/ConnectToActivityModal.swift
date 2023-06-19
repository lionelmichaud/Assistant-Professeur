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
    private var selectedActivity: ActivityEntity = .all().first!

    @Environment(\.dismiss)

    private var dismiss

    private var discipline: Discipline? {
        competency.section?.theme?.disciplineEnum
    }

    private var cycle: Cycle? {
        competency.section?.theme?.cycleEnum
    }

    /// Filtrer les activitées en fonction des Discipline, Cycle et Niveau de classe sélectionnés
    private var selectedActivities: [ActivityEntity] {
        if let cycle, let discipline {
            return ActivityEntity.allSortedByProgSeqAct(
                discipline: discipline,
                cycle: cycle,
                level: selectedLevel
            )
        } else {
            return []
        }
    }

    /// Choisir l'activité
    private var activityPicker: some View {
        Picker(
            "Activité",
            selection: $selectedActivity
        ) {
            ForEach(selectedActivities) { activity in
                CompActivityBrowerRow(
                    activity: activity,
                    verticallyStacked: false
                )
                .horizontallyAligned(.leading)
                .tag(activity)
            }
        }
        .pickerStyle(.wheel)
    }

    var body: some View {
        VStack(alignment: .leading) {
            if cycle == nil || discipline == nil {
                Text("Aucune activité existante sélectionnable.")
            } else {
                Text("Choisir une activité associée:")
                    .font(.headline)
                    .padding([.leading, .top])

                LevelInCyclePicker(
                    selectedLevel: $selectedLevel,
                    inCycle: cycle!
                )
                .padding(.horizontal)

                if selectedActivities.isNotEmpty {
                    ActivityPicker(
                        selectedActivity: $selectedActivity,
                        inActivities: selectedActivities
                    )
                    .padding(.horizontal)
                } else {
                    Text("Aucune activité existante sélectionnable.")
                }
            }
        }
        .verticallyAligned(.top)
        .onAppear {
            if let firstLevelInCycle = cycle?.associatedLevels.first {
                self.selectedLevel = firstLevelInCycle
            }
            if let firstActivity = selectedActivities.first {
                self.selectedActivity = firstActivity
            }
        }
        #if os(iOS)
        .navigationTitle("Activité Pédagogique")
        #endif
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuler") {
                    DCompEntity.rollback()
                    dismiss()
                }
            }
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

// struct ConnectToActivityModal_Previews: PreviewProvider {
//    static var previews: some View {
//        ConnectToActivityModal()
//    }
// }
