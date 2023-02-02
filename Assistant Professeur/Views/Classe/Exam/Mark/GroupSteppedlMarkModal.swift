//
//  GroupSteppedlMarkModal.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 31/01/2023.
//

import CoreData
import HelpersView
import SwiftUI

struct GroupSteppedlMarkModal: View {
    @ObservedObject
    var exam: ExamEntity

    @Environment(\.dismiss)
    private var dismiss

    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    @Preference(\.nameDisplayOrder)
    private var nameDisplayOrder

    private let fontWeight: Font.Weight = .regular
    private let smallColumns = [GridItem(.adaptive(minimum: 80, maximum: 120))]

    @State
    private var selectedGroupeNb: Int = 1

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

            // Saisie de la validation des étapes de l'évaluation
            if horizontalSizeClass == .regular {
                StepsValidationView(exam: exam, width: 250)
            } else {
                StepsValidationView(exam: exam, width: 125)
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
        }
    }
}

// struct GroupSteppedlMarkModal_Previews: PreviewProvider {
//    static var previews: some View {
//        GroupSteppedlMarkModal()
//    }
// }
