//
//  ActivityDCompListSection.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 24/07/2023.
//

import SwiftUI
import HelpersView

struct ActivityDCompListSection: View {

    @ObservedObject
    var activity: ActivityEntity

    @State
    private var isAddingObject = false

    var body: some View {
        Section {
            // ajouter une activité
            Button {
                isAddingObject.toggle()
            } label: {
                Label(
                    "Associer des compétences disciplinaires",
                    systemImage: "plus.circle.fill"
                )
            }
            .buttonStyle(.borderless)

            ForEach(activity.disciplineCompSortedByAcronym) { dCompetency in
                DCompBrowserRow(
                    competency: dCompetency,
                    showIcon: true
                )
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    // supprimer le lien vers la compétence disciplinaire
                    Button(role: .destructive) {
                        activity.removeFromCompetencies(dCompetency)
                    } label: {
                        Label("Dissocier", systemImage: "minus.circle")
                    }
                }
            }
            .emptyListPlaceHolder(activity.disciplineCompSortedByAcronym) {
                Text("Aucune compétence disciplinaire associée.")
            }

        } header: {
            Text("Compétences disciplinaires associées")
                .style(.sectionHeader)
        }

        // Modal Sheet d'ajout d'une compétence disciplinaire
        .sheet(
            isPresented: $isAddingObject
        ) {
            NavigationStack {
                ConnectToDCompModal(activity: activity)
            }
            .interactiveDismissDisabled()
            .presentationDetents([.large])
        }
    }
}

//struct ActivityDCompListSection_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivityDCompListSection()
//    }
//}
