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

    @Preference(\.nameDisplayOrder)
    private var nameDisplayOrder

    private let fontWeight: Font.Weight = .regular
    private let smallColumns = [GridItem(.adaptive(minimum: 80, maximum: 120))]

    @State
    private var selectedGroupeNb: Int = 1

    @State
    private var tog: Bool = false

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
    private var listeElevesView: some View {
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
                        .elevNameStyling(
                            hasTrouble: eleve.hasTrouble,
                            hasAddTime: eleve.hasAddTime
                        )
                }
            }
        }
    }

    private var regulartForm: some View {
        HStack(alignment: .top) {
            VStack(alignment: .center) {
                groupPickerView
                    .frame(maxWidth: 300)
                    .padding(.bottom)
                listeElevesView
            }.padding(.trailing)

            Divider()

            VStack(alignment: .center) {
                Text("Étapes")
                    .font(.headline)
                Text("Note totale: 10")
                    .font(.body)
                    .padding(.top, 8)
                List(exam.viewSteps) { step in
                    HStack {
                        Image(systemName: "figure.stair.stepper")
                            .sfSymbolStyling()
                            .foregroundColor(.accentColor)
                        Toggle(isOn: $tog) {
                            Text(step.name)
                        }
                    }
                }
            }
        }
    }

    private var compactForm: some View {
        VStack {
            groupPickerView
                .frame(maxWidth: 200)
                .padding(.bottom)
            listeElevesView
            Text("éditeur csdac sadcasdcde notes")
        }
    }

    var body: some View {
        ViewThatFits(in: .horizontal) {
            regulartForm
            compactForm
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
