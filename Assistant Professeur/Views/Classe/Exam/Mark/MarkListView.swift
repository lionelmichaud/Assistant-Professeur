//
//  MarkListView.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 15/10/2022.
//

import SwiftUI
import HelpersView

/// Liste des notes éditables de chaque élève de la classe
struct MarkListView : View {
    @ObservedObject
    var exam: ExamEntity

    var searchString: String

    @State
    private var isAddingGroupMark = false

    @State
    private var isShowingResetConfirmDialog = false

    // MARK: - Compute Properties

    var body: some View {
        Section {
            ForEach(exam.sortedMarksByEleveName(searchString: searchString)) { mark in
                MarkView(mark: mark)
            }
        } header: {
            HStack {
                Text("Notes")
                Spacer()

                /// reset de toutes les notes de la classe
                Button(role: .destructive) {
                    isShowingResetConfirmDialog = true
                } label: {
                    Image(systemName: "eraser.fill")
                }
                /// Confirmation de Suppression de toutes vos données
                .confirmationDialog("Remettre toutes les notes à \"Non noté\" ?",
                                    isPresented: $isShowingResetConfirmDialog,
                                    titleVisibility : .visible) {
                    Button("Poursuivre", role: .destructive) {
                        withAnimation {
                            self.resetAllMarks()
                        }
                    }
                } message: {
                    Text("Cette action ne peut pas être annulée.")
                }

                /// affecter la même note à tous les membres d'un même groupe
                if exam.classe!.nbOfGroups > 1 {
                    Button {
                        isAddingGroupMark = true
                    } label: {
                        Image(systemName: "person.line.dotted.person.fill")
                    }
                }
            }
        }
        .headerProminence(.increased)
        .sheet(isPresented: $isAddingGroupMark) {
            NavigationStack {
                GroupMarkModal(exam: exam)
            }
            .presentationDetents([.medium])
        }
    }

    // MARK: - Methods

    private func resetAllMarks() {
        withAnimation {
            exam.allMarks.forEach { mark in
                mark.markTypeEnum = .nonNote
            }
        }
    }
}

/// Saisie la de la note dun groupe pour une évaluation
struct GroupMarkModal : View {
    @ObservedObject
    var exam: ExamEntity

    @Environment(\.dismiss)
    private var dismiss

    @State
    private var mark: Double = 0

    @State
    private var selectedGroupeNb : Int = 1

    @State
    private var grpTable = [Int]()

    // MARK: - Computed Properties

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

    private var groupPicker: some View {
        Picker(selection: $selectedGroupeNb) {
            ForEach(groupsNb, id: \.self) { grp in
                Text("Groupe \(grp)")
            }
        } label: {
            Image(systemName: "person.line.dotted.person.fill")
        }
        .pickerStyle(.menu)
    }

    private var noteEditor: some View {
        HStack {
            AmountEditView(label    : "Note",
                           amount   : $mark,
                           validity : .within(range: 0.0 ... Double(exam.maxMark)),
                           currency : false)

            Stepper(
                "",
                value : $mark,
                in    : 0 ... Double(exam.maxMark),
                step  : 0.5
            )
        }
    }

    private var regulartForm: some View {
        HStack {
            groupPicker
                .frame(maxWidth: 200)

            Spacer()

            noteEditor
                .frame(maxWidth: 250)
        }
    }

    private var compactForm: some View {
        VStack {
            groupPicker
            noteEditor
        }
    }

    var body: some View {
        Form {
            ViewThatFits {
                regulartForm
                compactForm
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
                        attribuer(note: mark, auGroupe: selectedGroupeNb)
                    }
                    dismiss()
                }
            }
        }
    }

    // MARK: - Methods

    func attribuer(note: Double, auGroupe: Int) {
        withAnimation {
            // Liste des élèves du groupe
            let elevesInGroupIDs = exam.classe?
                .groupe(number: auGroupe)
                .allEleves
                .map { $0.objectID }

            // affecter la note à ces élèves
            if let elevesInGroupIDs {
                exam.allMarks
                    .forEach { mark in
                        if elevesInGroupIDs
                            .contains(mark.eleve!.objectID)
                        {
                            mark.markTypeEnum = .note
                            mark.viewMark = note
                        }
                    }
            }
        }
    }
}

//struct MarkListView_Previews: PreviewProvider {
//    static var previews: some View {
//        TestEnvir.createFakes()
//        return Group {
//            List {
//                MarkListView(classe       : TestEnvir.classeStore.items.first!,
//                             exam         : .constant(Exam.exemple),
//                             searchString : "")
//                .environmentObject(NavigationModel(selectedClasseId: TestEnvir.classeStore.items.first!.id))
//                .environmentObject(TestEnvir.schoolStore)
//                .environmentObject(TestEnvir.classeStore)
//                .environmentObject(TestEnvir.eleveStore)
//                .environmentObject(TestEnvir.colleStore)
//                .environmentObject(TestEnvir.observStore)
//            }
//            .previewDevice("iPad mini (6th generation)")
//
//            List {
//                MarkListView(classe       : TestEnvir.classeStore.items.first!,
//                             exam         : .constant(Exam.exemple),
//                             searchString : "")
//                    .environmentObject(NavigationModel(selectedClasseId: TestEnvir.classeStore.items.first!.id))
//                    .environmentObject(TestEnvir.schoolStore)
//                    .environmentObject(TestEnvir.classeStore)
//                    .environmentObject(TestEnvir.eleveStore)
//                    .environmentObject(TestEnvir.colleStore)
//                    .environmentObject(TestEnvir.observStore)
//            }
//            .previewDevice("iPhone 13")
//        }
//    }
//}
