//
//  WCompListSection.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 18/06/2023.
//

import HelpersView
import SwiftUI

struct WCompListSection: View {
    @ObservedObject
    var dCompetency: DCompEntity

    @State
    private var isAddingObject = false

    var body: some View {
        Section {
            // ajouter une compétences travaillée
            Button {
                isAddingObject.toggle()
            } label: {
                Label(
                    "Associer une compétence du socle",
                    systemImage: "plus.circle.fill"
                )
            }
            .buttonStyle(.borderless)

            ForEach(
                dCompetency.workedCompSortedByAcronym
            ) { workedComp in
                WCompBrowserRow(workedComp: workedComp)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        // supprimer le lien vers la compétence travaillée
                        Button(role: .destructive) {
                            workedComp.removeFromDisciplineCompetencies(dCompetency)
                            try? DCompEntity.saveIfContextHasChanged()
                        } label: {
                            Label("Dissocier", systemImage: "minus.circle")
                        }
                    }
            }
            .emptyListPlaceHolder(dCompetency.workedCompSortedByAcronym) {
                EmptyListMessage(
                    title: "Aucune compétence travaillée associée.",
                    showAsGroupBox: false
                )
            }

        } header: {
            Text("Compétences du scole travaillées")
                .style(.sectionHeader)
        }

        // Modal Sheet d'ajout d'une compétence travaillée
        .sheet(
            isPresented: $isAddingObject
        ) {
            NavigationStack {
                ConnectToWCompModal(competency: dCompetency)
            }
            .interactiveDismissDisabled()
            .presentationDetents([.large])
        }
    }
}

// struct WCompListSection_Previews: PreviewProvider {
//    static var previews: some View {
//        WCompListSection()
//    }
// }
