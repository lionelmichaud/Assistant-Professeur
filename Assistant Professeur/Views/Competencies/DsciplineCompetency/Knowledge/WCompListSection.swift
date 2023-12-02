//
//  WCompListSection.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 18/06/2023.
//

import HelpersView
import SwiftUI
import TipKit

struct WCompListSection: View {
    @ObservedObject
    var dCompetency: DCompEntity

    @State
    private var isAddingObject = false

    /// Create an instance of your tip content.
    var dissociateItemTip = ActivityDisociationItemTip()

    var body: some View {
        Section {
            let workedComps = dCompetency.workedCompSortedByAcronym
            // ajouter une compétences travaillée
            Button {
                isAddingObject.toggle()
            } label: {
                Label(
                    "Associer des compétences du socle",
                    systemImage: "link.badge.plus"
                )
            }
            .buttonStyle(.borderless)
            .customizedListItemStyle(
                isSelected: false
            )

            if workedComps.isNotEmpty {
                TipView(dissociateItemTip, arrowEdge: .bottom)
                    .customizedTipKitStyle()
            }
            ForEach(workedComps) { workedComp in
                WCompBrowserRow(workedComp: workedComp)
                    .customizedListItemStyle(
                        isSelected: false
                    )
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        // supprimer le lien vers la compétence travaillée
                        Button(role: .destructive) {
                            dissociateItemTip.invalidate(reason: .actionPerformed)
                            workedComp.removeFromDisciplineCompetencies(dCompetency)
                            try? DCompEntity.saveIfContextHasChanged()
                        } label: {
                            Label("Dissocier", systemImage: "minus.circle")
                        }
                    }
            }
            .emptyListPlaceHolder(workedComps) {
                Text("Aucune compétence travaillée associée.")
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
