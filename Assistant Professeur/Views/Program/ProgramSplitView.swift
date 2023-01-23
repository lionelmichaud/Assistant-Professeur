//
//  ProgramSplitView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 20/01/2023.
//

import SwiftUI

struct ProgramSplitView: View {
    @EnvironmentObject
    private var navig : NavigationModel

    @State
    private var path = NavigationPath()

    var body: some View {
        NavigationSplitView(
            columnVisibility: $navig.columnVisibility
        ) {
            /// 1ère colonne
            ProgramSidebarView()
//                .navigationSplitViewColumnWidth(min: 200,
//                                                ideal: 250,
//                                                max: 500)
        } content: {
            /// 2nde colonne
            NavigationStack(path: $path) {
                SequenceSidebarView()
                    .navigationDestination(for: ProgramEntity.self) { program in
                        ProgramDetailGroupBox(program: program)
                    }
                    .navigationDestination(for: SequenceEntity.self) { sequence in
                        ActivitySideBar(sequence: sequence)
                    }
            }
        } detail: {
            /// Détail dans la 3ième colonne
            ActivityEditor()
        }
        .navigationSplitViewStyle(.balanced)

        // désélectionner la séquence quand on change de programme
        .onChange(of: navig.selectedProgramId) { _ in
            navig.selectedSequenceId = nil
        }

        // désélectionner l'activité quand on change de séquence
        .onChange(of: navig.selectedSequenceId) { _ in
            navig.selectedActivityId = nil
        }

        // escamoter la 1ère colonne quand une activité est sélectionnée
        .onChange(of: navig.selectedActivityId) { _ in
            if navig.selectedActivityId == nil {
                navig.columnVisibility = .all
            } else {
                navig.columnVisibility = .doubleColumn
            }
        }
   }
}

struct ProgramSplitView_Previews: PreviewProvider {
    static var previews: some View {
        ProgramSplitView()
    }
}
