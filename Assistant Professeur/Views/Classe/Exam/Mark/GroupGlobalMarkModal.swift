//
//  GroupMarkModal.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 31/01/2023.
//

import AppFoundation
import CoreData
import HelpersView
import SwiftUI

/// Saisie la de la note dun groupe pour une évaluation
struct GroupGlobalMarkModal: View {
    @ObservedObject
    var exam: ExamEntity

    @Environment(\.dismiss)
    private var dismiss

    @Preference(\.nameDisplayOrder)
    private var nameDisplayOrder

    private let fontWeight : Font.Weight = .semibold
    private let smallColumns = [GridItem(.adaptive(minimum: 120, maximum: 200))]

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

    // MARK: - Computed Properties

    private var oprationPickerView: some View {
        CasePicker(
            pickedCase: $operationType,
            label: "Opération"
        )
        .pickerStyle(.segmented)
    }

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

    private var groupPickerView: some View {
        Picker(selection: $selectedGroupeNb) {
            ForEach(groupsNb, id: \.self) { grp in
                Text("Groupe \(grp)")
            }
        } label: {
            Image(systemName: "person.line.dotted.person.fill")
        }
        .pickerStyle(.menu)
    }

    private var noteEditorView: some View {
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
            groupPickerView
                .frame(maxWidth: 200)

            Spacer()

            noteEditorView
                .frame(maxWidth: 300)
        }
    }

    private var compactForm: some View {
        VStack {
            groupPickerView
            noteEditorView
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
    private var listeElevesView: some View {
        LazyVGrid(
            columns: smallColumns,
            spacing: 4
        ) {
            ForEach(
                exam.classe?
                    .groupe(number: selectedGroupeNb)
                    .elevesSortedByName ?? [ ]) { eleve in
                VStack {
                    TrombineView(eleve: eleve)

                    // Nom de l'élève
                    Text(eleve.displayName2lines(nameDisplayOrder))
                        .multilineTextAlignment(.center)
                        .fontWeight(fontWeight)
                        .elevNameStyling(
                            hasTrouble: eleve.hasTrouble,
                            hasAddTime: eleve.hasAddTime
                        )
                }
            }
        }
    }

    var body: some View {
        Form {
            oprationPickerView

            ViewThatFits {
                regulartForm
                compactForm
            }
            .padding([.top, .bottom])

            listeElevesView
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

    func attribuer(note: Double, auGroupe _: Int) {
        withAnimation {
            // affecter la note à ces élèves
            if let elevesInGroupID {
                exam.allMarks
                    .forEach { mark in
                        if elevesInGroupID.contains(mark.eleve!.objectID) {
                            mark.markTypeEnum = .note
                            mark.viewMark = note
                        }
                    }
            }
        }
    }

    func modifier(note: Double, auGroupe _: Int) {
        withAnimation {
            // modifier la note de ces élèves
            if let elevesInGroupID {
                exam.allMarks
                    .forEach { mark in
                        if elevesInGroupID.contains(mark.eleve!.objectID) {
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

// struct GroupMarkModal_Previews: PreviewProvider {
//    static var previews: some View {
//        GroupMarkModal()
//    }
// }
