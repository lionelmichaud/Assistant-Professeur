//
//  ActivityListSection.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 19/06/2023.
//

import HelpersView
import SwiftUI
import TipKit

struct ActivityListSection: View {
    @ObservedObject
    var dCompetency: DCompEntity

    @State
    private var isAddingObject = false

    /// Create an instance of your tip content.
    var dissociateItemTip = WCompDisociationItemTip()

    var body: some View {
        Section {
            let activities = dCompetency.activitiesSortedByLevelSeqActNumber
            // ajouter une activité
            Button {
                isAddingObject.toggle()
            } label: {
                Label(
                    "Associer des activités pédagogiques",
                    systemImage: "link.badge.plus"
                )
            }
            .buttonStyle(.borderless)
            .customizedListItemStyle(
                isSelected: false
            )

            if activities.isNotEmpty {
                TipView(dissociateItemTip, arrowEdge: .bottom)
                    .customizedTipKitStyle()
            }
            ForEach(activities) { activity in
                AssociatedActivityBrowerRow(
                    activity: activity,
                    verticallyStacked: true
                )
                .customizedListItemStyle(
                    isSelected: false
                )
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    // supprimer le lien vers l'activité
                    Button(role: .destructive) {
                        dissociateItemTip.invalidate(reason: .actionPerformed)
                        activity.removeFromCompetencies(dCompetency)
                        try? DCompEntity.saveIfContextHasChanged()
                    } label: {
                        Label("Dissocier", systemImage: "minus.circle")
                    }
                }
            }
            .emptyListPlaceHolder(activities) {
                Text("Aucune activité pédagogique associée.")
            }

        } header: {
            Text("Activités pédagogiques associées")
                .style(.sectionHeader)
        }

        // Modal Sheet d'ajout d'une activité
        .sheet(
            isPresented: $isAddingObject
        ) {
            NavigationStack {
                ConnectToActivityModal(competency: dCompetency)
            }
            .interactiveDismissDisabled()
            .presentationDetents([.large])
        }
    }
}

// struct ActivityListSection_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivityListSection()
//    }
// }
