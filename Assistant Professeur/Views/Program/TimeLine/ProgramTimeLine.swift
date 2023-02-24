//
//  ProgramTimeLine.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 23/02/2023.
//

import SwiftUI

struct ProgramTimeLine: View {
    @EnvironmentObject
    private var navig: NavigationModel

    var body: some View {
        VStack {
            if let programId = navig.selectedProgramId {
                if let program = ProgramEntity.byObjectId(id: programId) {
                    ProgramStepperView(program: program)
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
        #if os(iOS)
        .navigationTitle("Déroulement du programme")
        #endif
        .navigationBarTitleDisplayModeInline()
    }
}

//struct ProgramTimeLine_Previews: PreviewProvider {
//    static var previews: some View {
//        ProgramTimeLine()
//    }
//}
