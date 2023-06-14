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
            if let programId = navig.selectedProgramMngObjId {
                if let program = ProgramEntity.byObjectId(MngObjID: programId) {
                    ProgramStepperView(program: program)
                } else {
                    Text("Programme introuvable")
                        .foregroundStyle(.secondary)
                        .font(.title2)
                }

            } else {
                EmptyListMessage(
                    symbolName: ProgramEntity.defaultImageName,
                    title: "Aucun programme sélectionné.",
                    message: "Sélectionner un programme pour en visualiser les séquences.",
                    showAsGroupBox: true
                )
                .padding(.horizontal)
            }
        }
        #if os(iOS)
        .navigationTitle("Déroulement du programme")
        #endif
        .navigationBarTitleDisplayModeInline()
    }
}

// struct ProgramTimeLine_Previews: PreviewProvider {
//    static var previews: some View {
//        ProgramTimeLine()
//    }
// }
