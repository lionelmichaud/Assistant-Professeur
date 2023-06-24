//
//  ActivityList.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 22/01/2023.
//

import HelpersView
import SwiftUI

struct ActivityList: View {
    @ObservedObject
    var sequence: SequenceEntity

    var searchString: String = ""

    @Environment(\.managedObjectContext)
    private var managedObjectContext

    @EnvironmentObject
    private var navig: NavigationModel

    var body: some View {
        let filteredActivities = sequence.filteredActivitiesSortedByNumber(searchString: searchString)

        return Section {
            ForEach(
                filteredActivities,
                id: \.objectID
            ) { activity in
                ActivityBrowserRow(activity: activity)
            }
            .onMove(perform: moveItems)
            .onDelete(perform: deleteItems)
            .listRowSeparatorTint(.secondary)
            .emptyListPlaceHolder(filteredActivities) {
                EmptyListMessage(
                    title: "Aucune activitée trouvée dans cette séquence.",
                    message: "Les activitées ajoutées apparaîtront ici.",
                    showAsGroupBox: true
                )
            }
        } header: {
            HStack {
                Text("Activités de cette Séquence (\(sequence.nbOfActivities))")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.top)
            .padding(.leading)
        }
    }

    private func moveItems(from source: IndexSet, to destination: Int) {
        withAnimation {
            source
                .map {
                    sequence.activitiesSortedByNumber[$0]
                }
                .forEach {
                    // Permuter et renuméroter les séquences restantes
                    ProgramManager.move(
                        activity: $0,
                        de: sequence,
                        to: destination
                    )
                }

            try? EventEntity.saveIfContextHasChanged()
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

// struct ActivityList_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivityList()
//    }
// }
