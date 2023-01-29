//
//  MarkListView.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 15/10/2022.
//

import AppFoundation
import CoreData
import HelpersView
import SwiftUI

/// Liste des notes éditables de chaque élève de la classe
struct MarkListView: View {
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

                // reset de toutes les notes de la classe
                Button(role: .destructive) {
                    isShowingResetConfirmDialog = true
                } label: {
                    Image(systemName: "eraser.fill")
                }
                // Confirmation de Suppression de toutes vos données
                .confirmationDialog(
                    "Remettre toutes les notes à \"Non noté\" ?",
                    isPresented: $isShowingResetConfirmDialog,
                    titleVisibility: .visible
                ) {
                    Button("Poursuivre", role: .destructive) {
                        withAnimation {
                            self.resetAllMarks()
                        }
                    }
                } message: {
                    Text("Cette action ne peut pas être annulée.")
                }

                // affecter la même note à tous les membres d'un même groupe
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
struct GroupMarkModal: View {
    @ObservedObject
    var exam: ExamEntity

    @Environment(\.dismiss)
    private var dismiss

    enum OperationType: PickableEnumP {
        case attribuer
        case modifier

        public var pickerString: String {
            switch self {
            case .attribuer:
                return "Atribuer une note"
            case .modifier:
                return "Modifier la note"
            }
        }
    }

    @State
    private var operationType: OperationType = .attribuer

    @State
    private var mark: Double = 0

    @State
    private var selectedGroupeNb: Int = 1

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

    private var oprationPicker: some View {
        CasePicker(
            pickedCase: $operationType,
            label: "Opération"
        )
        .pickerStyle(.segmented)
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
            switch operationType {
            case .attribuer:
                AmountEditView(
                    label: "Note",
                    amount: $mark,
                    validity: .within(range: 0.0 ... Double(exam.viewMaxMark)),
                    currency: false
                )
                Stepper(
                    "",
                    value: $mark,
                    in: 0 ... Double(exam.viewMaxMark),
                    step: 0.5
                )
            case .modifier:
                AmountEditView(
                    label: "Modifier",
                    amount: $mark,
                    validity: .within(range: Double(-exam.viewMaxMark) ... Double(exam.viewMaxMark)),
                    currency: false
                )
                Stepper(
                    "",
                    value: $mark,
                    in: Double(-exam.viewMaxMark) ... Double(exam.viewMaxMark),
                    step: 0.5
                )
            }
        }
    }

    private var regulartForm: some View {
        HStack {
            groupPicker
                .frame(maxWidth: 200)

            Spacer()

            noteEditor
                .frame(maxWidth: 300)
        }
    }

    private var compactForm: some View {
        VStack {
            groupPicker
            noteEditor
        }
    }

    private var elevesInGroupIDs: [NSManagedObjectID]? {
        exam.classe?
            .groupe(number: selectedGroupeNb)
            .allEleves
            .map { $0.objectID }
    }

    private var listeEleves: some View {
        Group {
            if let elevesInGroupIDs {
                List(elevesInGroupIDs, id: \.self) { eleveID in
                    if let eleve = EleveEntity.byObjectId(id: eleveID) {
                        Text(eleve.displayName)
                    }
                }
            } else {
                EmptyView()
            }
        }
    }

    var body: some View {
        Form {
            oprationPicker
            ViewThatFits {
                regulartForm
                compactForm
            }
            listeEleves
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
                switch operationType {
                case .attribuer:
                    Button("Attribuer") {
                        withAnimation {
                            attribuer(note: mark, auGroupe: selectedGroupeNb)
                        }
                        dismiss()
                    }
                case .modifier:
                    Button("Modifer") {
                        withAnimation {
                            modifier(note: mark, auGroupe: selectedGroupeNb)
                        }
                        dismiss()
                    }
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
                            .contains(mark.eleve!.objectID) {
                            mark.markTypeEnum = .note
                            mark.viewMark = note
                        }
                    }
            }
        }
    }

    func modifier(note: Double, auGroupe: Int) {
        withAnimation {
            // Liste des élèves du groupe
            let elevesInGroupIDs = exam.classe?
                .groupe(number: auGroupe)
                .allEleves
                .map { $0.objectID }

            // modifier la note de ces élèves
            if let elevesInGroupIDs {
                exam.allMarks
                    .forEach { mark in
                        if elevesInGroupIDs
                            .contains(mark.eleve!.objectID) {
                            if mark.markTypeEnum == .note {
                                mark.viewMark += note
                            } else {
                                mark.markTypeEnum = .note
                                mark.viewMark = note
                            }
                        }
                    }
            }
        }
    }
}

// struct MarkListView_Previews: PreviewProvider {
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
// }
