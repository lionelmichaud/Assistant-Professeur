//
//  ActivityList.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 22/01/2023.
//

import SwiftUI

struct ActivityList: View {
    @ObservedObject
    var sequence: SequenceEntity

    @Environment(\.managedObjectContext)
    private var managedObjectContext

    @EnvironmentObject
    private var navig : NavigationModel

    var body: some View {
        Section {
            if sequence.activitiesSortedByNumber.isNotEmpty {
                List(selection: $navig.selectedActivityId) {
                    ForEach(sequence.activitiesSortedByNumber, id: \.objectID) { activity in
//                        NavigationLink(value: sequence) {
                            ActivityBrowserRow(activity: activity)
//                        }
                    }
                    .onDelete(perform: deleteItems)
                }

            } else {
                GroupBox {
                    Text("Aucune activité")
                        .bold()
                    Text("Les activités ajoutées apparaîtront ici.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.top, 2)
                }
            }
        } header: {
            HStack {
                Text("Activités (\(sequence.nbOfActivities))")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.top)
            .padding(.leading)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets
                .map {
                    sequence.activitiesSortedByNumber[$0]
                }
                .forEach {
                    // Supprimer et renuméroter les séquences restantes
                    ProgramManager.delete(
                        activity: $0,
                        de: sequence
                    )
                }

            try? EventEntity.saveIfContextHasChanged()
        }
    }
}

//struct ActivityList_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivityList()
//    }
//}
