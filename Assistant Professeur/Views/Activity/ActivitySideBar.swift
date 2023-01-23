//
//  ActivitySideBar.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 22/01/2023.
//

import SwiftUI

struct ActivitySideBar: View {
    @ObservedObject
    var sequence: SequenceEntity

    @EnvironmentObject
    private var navigationModel : NavigationModel

    @State
    private var isAddingNewActivity = false

    var body: some View {
        VStack {
            if let sequenceId = navigationModel.selectedSequenceId {
                if let sequence = SequenceEntity.byObjectId(id: sequenceId) {
                    if let program = sequence.program {
                        ProgramDetailGroupBox(program: program)
                    } else {
                        Text("Programme introuvable")
                    }
                    ActivityList(sequence: sequence)
                } else {
                    Text("Séquence introuvable")
                        .foregroundStyle(.secondary)
                        .font(.title2)
                }
            } else {
                VStack(alignment: .center) {
                    Text("Aucune séquence sélectionnée.")
                    Text("Sélectionner une séquence.")
                }
                .foregroundStyle(.secondary)
                .font(.title2)
            }
        }
        .navigationTitle("Séquence")
        .toolbar(content: myToolBarContent)
    }
}


// MARK: Toolbar Content

extension ActivitySideBar {
    @ToolbarContentBuilder
    private func myToolBarContent() -> some ToolbarContent {
        if let sequenceId = navigationModel.selectedSequenceId,
           SequenceEntity.byObjectId(id: sequenceId) != nil {
            /// Ajouter une Activité
            ToolbarItemGroup(placement: .status) {
                Button {
                    isAddingNewActivity = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Ajouter une activité")
                        Spacer()
                    }
                }
            }
        }
    }
}

//struct ActivitySideBar_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivitySideBar()
//    }
//}
