//
//  ActivityListSection.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 19/06/2023.
//

import HelpersView
import SwiftUI

struct ActivityListSection: View {
    @ObservedObject
    var dCompetency: DCompEntity

    @State
    private var isAddingObject = false

    var body: some View {
        Section {
            // ajouter une activité
            Button {
                isAddingObject.toggle()
            } label: {
                Label(
                    "Associer des activités pédagogiques",
                    systemImage: "plus.circle.fill"
                )
            }
            .buttonStyle(.borderless)

            ForEach(dCompetency.activitiesSortedByLevelSeqActNumber) { activity in
                AssociatedActivityBrowerRow(
                    activity: activity,
                    verticallyStacked: true
                )
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    // supprimer le lien vers l'activité
                    Button(role: .destructive) {
                        activity.removeFromCompetencies(dCompetency)
                        try? DCompEntity.saveIfContextHasChanged()
                    } label: {
                        Label("Dissocier", systemImage: "minus.circle")
                    }
                }
            }
            .emptyListPlaceHolder(dCompetency.activitiesSortedByLevelSeqActNumber) {
                EmptyListMessage(
                    title: "Aucune activité pédagogique associée.",
                    showAsGroupBox: false
                )
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
