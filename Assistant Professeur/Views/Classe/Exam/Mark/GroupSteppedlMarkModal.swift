//
//  GroupSteppedlMarkModal.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 31/01/2023.
//

import CoreData
import HelpersView
import os
import SwiftUI

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Cahier-du-Professeur",
    category: "GroupSteppedlMarkModal"
)

struct GroupSteppedlMarkModal: View {
    // MARK: - Initializer

    init(exam: ExamEntity) {
        self.exam = exam

        // Initializer les notes échelonnées à partir des
        // notes actuelles des membres du groupe
        self._stepsMarks = State(
            initialValue: GroupSteppedlMarkModal.initializedStepsMarks(
                pourExam: exam,
                aPartirDuGroupe: GroupSteppedlMarkModal.initialGroupNumber
            )
        )
    }

    // MARK: - Type Properties

    static let initialGroupNumber = 1

    // MARK: - Properties

    @ObservedObject
    private var exam: ExamEntity

    @Environment(\.dismiss)
    private var dismiss

    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    @Preference(\.nameDisplayOrder)
    private var nameDisplayOrder

    private let fontWeight: Font.Weight = .regular
    private let smallColumns = [GridItem(.adaptive(minimum: 80, maximum: 120))]

    @State
    private var selectedGroupeNb: Int = initialGroupNumber

    @State
    private var stepsMarks: [Double]

    /// Liste des numéros de groupe d'élèves non vides
    private var groupsNb: [Int] {
        var array = [Int]()
        exam.classe?.allGroupsSortedByNumber
            .forEach { group in
                if group.viewNumber != 0 && !group.isEmpty {
                    array.append(group.viewNumber)
                }
            }
        return array
    }

    /// Choix du groupe d'élèves
    private var groupPickerView: some View {
        Picker(selection: $selectedGroupeNb) {
            ForEach(groupsNb, id: \.self) { grp in
                Text("Groupe \(grp)")
            }
        } label: {
            Image(systemName: "person.line.dotted.person.fill")
        }
        .pickerStyle(.menu)
        .onChange(of: selectedGroupeNb) { newGroupe in
            stepsMarks = GroupSteppedlMarkModal.initializedStepsMarks(
                pourExam: exam,
                aPartirDuGroupe: newGroupe
            )
        }
    }

    /// Liste des élèves appartenant au groupe
    private var elevesInGroupID: [NSManagedObjectID]? {
        exam.classe?
            .groupe(number: selectedGroupeNb)
            .allEleves
            .map { $0.objectID }
    }

    /// Vue des trombines des élèves appartenant au groupe
    private var listeTrombinesElevesView: some View {
        LazyVGrid(
            columns: smallColumns,
            spacing: 4
        ) {
            ForEach(
                exam.classe?
                    .groupe(number: selectedGroupeNb)
                    .elevesSortedByName ?? []) { eleve in
                VStack {
                    TrombineView(eleve: eleve)

                    // Nom de l'élève
                    Text(eleve.displayName2lines(nameDisplayOrder))
                        .multilineTextAlignment(.center)
                        .fontWeight(fontWeight)
                        .font(.body)
                        .elevNameStyling(
                            hasTrouble: eleve.hasTrouble,
                            hasAddTime: eleve.hasAddTime
                        )
                }
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            // Sélection du groupe d'élèves à noter
            VStack(alignment: .center) {
                groupPickerView
                    .frame(maxWidth: 300)
                    .padding(.bottom)
                listeTrombinesElevesView
            }.padding(.horizontal)

            Divider()

            // Saisie de la notation des étapes de l'évaluation
            if horizontalSizeClass == .regular {
                StepsNotationView(
                    exam: exam,
                    width: 250,
                    stepsMarks: $stepsMarks
                )
            } else {
                StepsNotationView(
                    exam: exam,
                    width: 125,
                    stepsMarks: $stepsMarks
                )
            }
        }
        #if os(iOS)
        .navigationTitle("Note de groupe")
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuler") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Attribuer") {
                    withAnimation {
                        attribuer(stepsMarks: stepsMarks)
                    }
                    dismiss()
                }
            }
        }
    }

    // MARK: - Methods

    /// Initializer les notes échelonnées à partir des notes actuelles
    /// des membres du groupe `aPartirDuGroupe`
    private static func initializedStepsMarks(
        pourExam exam: ExamEntity,
        aPartirDuGroupe groupe: Int
    ) -> [Double] {
        guard let elevesInGroup = exam.classe?
            .groupe(number: groupe)
            .allEleves else {
            return []
        }

        var highestStepsMarks = [Double].init(
            repeating: 0.0,
            count: exam.nbOfSteps
        )

        exam.allMarks
            .forEach { eleveMark in
                if elevesInGroup.contains(eleveMark.eleve!) {
                    // l'élève associé à la note est membre du groupe sélectionné
                    for idx in eleveMark.viewStepsMarks.indices {
                        highestStepsMarks[idx] = max(
                            highestStepsMarks[idx],
                            eleveMark.viewStepsMarks[idx]
                        )
                    }
                }
            }

        return highestStepsMarks
    }

    /// Affecter les notes échelonnées à chaque élève du groupe sélectionné
    private func attribuer(stepsMarks: [Double]) {
        if let elevesInGroupID {
            exam.allMarks
                .forEach { mark in
                    if elevesInGroupID.contains(mark.eleve!.objectID) {
                        guard mark.nbOfSteps == stepsMarks.count else {
                            customLog.log(
                                level: .fault,
                                "Nombre de notes différent du nombre d'étapes de l'évaluation."
                            )
                            fatalError()
                        }

                        mark.setMarkType(.note)
                        mark.setStepsMarks(stepsMarks)
                    }
                }
            try? MarkEntity.saveIfContextHasChanged()
        }
    }
}

// struct GroupSteppedlMarkModal_Previews: PreviewProvider {
//    static var previews: some View {
//        GroupSteppedlMarkModal()
//    }
// }
