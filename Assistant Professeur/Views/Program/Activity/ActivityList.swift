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

    @EnvironmentObject
    private var navig: NavigationModel

    var body: some View {
        let filteredActivities = sequence.filteredActivitiesSortedByNumber(searchString: searchString)

        return Section {
            ForEach(filteredActivities, id: \.objectID) { activity in
                NavigationLink(value: ProgramNavigationRoute.activityDetail(activity.id)) {
                    ActivityBrowserRow(activity: activity)
                }
                .customizedListItemStyle(
                    isSelected: activity.objectID == navig.selectedActivityMngObjId
                )
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    // supprimer l'activité et tous ses descendants
                    Button(role: .destructive) {
                        withAnimation {
                            if navig.selectedActivityMngObjId == activity.objectID {
                                navig.selectedActivityMngObjId = nil
                            }
                            try? activity.delete()
                        }
                    } label: {
                        Label("Supprimer", systemImage: "trash")
                    }
                }
            }
            .onMove(perform: moveItems)
            .emptyListPlaceHolder(filteredActivities) {
                ContentUnavailableView(
                    "Aucune activitée trouvée dans cette séquence...",
                    systemImage: ActivityEntity.defaultImageName,
                    description: Text("Les activitées ajoutées apparaîtront ici.")
                )
            }
        } header: {
            HStack {
                Text("Activités de cette Séquence (\(sequence.nbOfActivities))")
                    .style(.sectionHeader)
                Spacer()
            }
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
}

// struct ActivityList_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivityList()
//    }
// }
