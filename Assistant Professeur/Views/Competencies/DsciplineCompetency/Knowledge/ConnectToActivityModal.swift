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
    private var selectedActivity: ActivityEntity = .all().first!

    @State
    private var levelEnum: LevelClasse = .n4ieme

    @Environment(\.dismiss)
    private var dismiss

    /// Filtrer les activitées en fonction des Discipline, Cycle et Niveau de classe sélectionnés
    private var selectedActivities: [ActivityEntity] {
        if let cycle = competency.section?.theme?.cycleEnum,
           let discipline = competency.section?.theme?.disciplineEnum {
            return ActivityEntity.allSortedByProgSeqAct(
                discipline: discipline,
                cycle: cycle,
                level: levelEnum
            )
        } else {
            return []
        }
    }

    /// Choisir le niveau de classe
    private var levelPicker: some View {
        Picker(
            "Niveau",
            selection: $levelEnum
        ) {
            if let cycle = competency.section?.theme?.cycleEnum {
                ForEach(cycle.associatedLevels, id: \.self) { level in
                    Text(level.pickerString)
                }
            }
        }
        .pickerStyle(.segmented)
    }

    /// Choisir l'activité
    private var activityPicker: some View {
        Picker(
            "Activité",
            selection: $selectedActivity
        ) {
            if selectedActivities.isNotEmpty {
                ForEach(selectedActivities) { activity in
                    CompActivityBrowerRow(
                        activity: activity,
                        verticallyStacked: false
                    )
                    .horizontallyAligned(.leading)
                    .tag(activity)
                }
            } else {
                Text("Aucune activité existante sélectionnable.")
            }
        }
        .pickerStyle(.wheel)
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Choisir une activité associée:")
                .font(.headline)
                .padding([.leading, .top])

            levelPicker
                .padding(.horizontal)

            activityPicker
                .padding(.horizontal)
        }
        .verticallyAligned(.top)
        .onAppear {
            if let firstLevelInCycle = competency.section?.theme?.cycleEnum.associatedLevels.first {
                levelEnum = firstLevelInCycle
            }
            if let firstActivity = selectedActivities.first {
                selectedActivity = firstActivity
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
