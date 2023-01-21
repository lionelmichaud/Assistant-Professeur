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
        } detail: {
            ProgramEditor()
        }
    }
}

struct ProgramSplitView_Previews: PreviewProvider {
    static var previews: some View {
        ProgramSplitView()
    }
}
