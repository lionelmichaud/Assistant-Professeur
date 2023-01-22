//
//  SequenceSidebarView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 22/01/2023.
//

import SwiftUI

struct SequenceSidebarView: View {
    @EnvironmentObject
    private var navigationModel : NavigationModel

    @State
    private var isAddingNewSequence = false

    var body: some View {
        Group {
            if let programId = navigationModel.selectedProgramId {
                if let program = ProgramEntity.byObjectId(id: programId) {
                    SequenceList(program: program)
                } else {
                    Text("Programme introuvable")
                        .foregroundStyle(.secondary)
                        .font(.title2)
                }
            } else {
                VStack(alignment: .center) {
                    Text("Aucun programme sélectionné.")
                    Text("Sélectionner un programme.")
                }
                .foregroundStyle(.secondary)
                .font(.title2)
            }
        }
        .navigationTitle("Séquences")
        .toolbar(content: myToolBarContent)
    }
}

// MARK: Toolbar Content

extension SequenceSidebarView {
    @ToolbarContentBuilder
    private func myToolBarContent() -> some ToolbarContent {
        if let programId = navigationModel.selectedProgramId,
            let _ = ProgramEntity.byObjectId(id: programId) {
        /// Ajouter un établissement
            ToolbarItemGroup(placement: .status) {
                Button {
                    isAddingNewSequence = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Ajouter une séquence")
                        Spacer()
                    }
                }
            }
        }

    }
}

struct SequenceSidebarView_Previews: PreviewProvider {
    static var previews: some View {
        SequenceSidebarView()
    }
}
