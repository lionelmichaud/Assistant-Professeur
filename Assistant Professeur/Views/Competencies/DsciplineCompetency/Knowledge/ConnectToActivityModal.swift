//
//  ConnectToActivityModal.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 19/06/2023.
//

import CoreData
import HelpersView
import SwiftUI

/// Dialogue modal de connection d'une Compétence Disciplinaire avec des Activités pédagogiques
struct ConnectToActivityModal: View {
    @ObservedObject
    var competency: DCompEntity

    @State
    private var selectedLevel: LevelClasse = .nbCP

    @Environment(\.dismiss)
    private var dismiss

    @State
    private var sequences = [SequenceEntity]()

    @State
    private var selectedActivitiesObjId = Set<NSManagedObjectID>()

    private var discipline: Discipline? {
        competency.section?.theme?.disciplineEnum
    }

    private var cycle: Cycle? {
        competency.section?.theme?.cycleEnum
    }

    var body: some View {
        Group {
            if let discipline, let cycle {
                VStack(alignment: .leading) {
                    Section("Sélectionner un niveau") {
                        LevelInCyclePicker(
                            selectedLevel: $selectedLevel,
                            inCycle: cycle
                        )
                    }

                    Section("Sélectionner une activité") {
                        List(selection: $selectedActivitiesObjId) {
                            ForEach(sequences) { sequence in
                                SequenceDisclosure(sequence: sequence)
                            }
                            .emptyListPlaceHolder(sequences) {
                                EmptyListMessage(
                                    symbolName: nil,
                                    title: "Aucun séquence actuellement.",
                                    message: "Les séquences ajoutées apparaîtront ici.",
                                    showAsGroupBox: true
                                )
                            }
                        }
                        .listStyle(.sidebar)
                    }
                }
                .padding(.horizontal)
                .task(id: selectedLevel) {
                    sequences = SequenceEntity.allSortedByDisciplineLevelNumber(
                        discipline: discipline,
                        cycle: cycle,
                        level: selectedLevel
                    )
                }
            } else {
                EmptyView()
            }
        }
        #if os(iOS)
        .navigationTitle("Activités pédagogiques associées")
        #endif
        .navigationBarTitleDisplayModeInline()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuler") {
                    DCompEntity.rollback()
                    dismiss()
                }
            }
            if selectedActivitiesObjId.isNotEmpty {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Associer") {
                        let activities = selectedActivitiesObjId.compactMap { activityObjectId in
                            ActivityEntity.byObjectId(MngObjID: activityObjectId)
                        }
                        let setOfActivities = NSSet(array: activities)
                        competency.addToActivities(setOfActivities)

                        try? DCompEntity.saveIfContextHasChanged()
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SequenceDisclosure: View {
    @ObservedObject
    var sequence: SequenceEntity

    @State
    private var isExpanded: Bool = true

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded.animation()) {
            ForEach(sequence.activitiesSortedByNumber, id: \.objectID) { activity in
                AssociatedActivityBrowerRow(
                    activity: activity,
                    verticallyStacked: false
                )
                // .horizontallyAligned(.leading)
            }
        } label: {
            SequencePickerRow(sequence: sequence)
        }
    }
}

// struct ConnectToActivityModal_Previews: PreviewProvider {
//    static var previews: some View {
//        ConnectToActivityModal()
//    }
// }
