//
//  ProgramSplitView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 20/01/2023.
//

import SwiftUI

struct ProgramSplitView: View {
    @EnvironmentObject
    private var navigationModel : NavigationModel

    var body: some View {
        NavigationSplitView(
            columnVisibility: $navigationModel.columnVisibility
        ) {
            ProgramSidebarView()
                .navigationSplitViewColumnWidth(250)
        } content: {
            SequenceSidebarView()
                .navigationSplitViewColumnWidth(min: 250,
                                                ideal: 350,
                                                max: 500)
        } detail: {
            ProgramEditor()
        }
        .navigationSplitViewStyle(.balanced)
        .onChange(of: navigationModel.selectedProgramId) { _ in
            navigationModel.selectedSequenceId = nil
        }
        .onChange(of: navigationModel.selectedSequenceId) { _ in
            if navigationModel.selectedSequenceId == nil {
                navigationModel.columnVisibility = .all
            } else {
                navigationModel.columnVisibility = .doubleColumn
            }
        }
    }
}

struct ProgramSplitView_Previews: PreviewProvider {
    static var previews: some View {
        ProgramSplitView()
    }
}
