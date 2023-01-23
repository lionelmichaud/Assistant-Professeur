//
//  ProgramEditor.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 21/01/2023.
//

import SwiftUI
import CoreData

struct ProgramEditor: View {
    @EnvironmentObject
    private var navigationModel : NavigationModel

    // MARK: - Computed Properties

    private var selectedProgramId: NSManagedObjectID? {
        navigationModel.selectedProgramId
    }

    private var selectedProgram: ProgramEntity? {
        guard let selectedProgramId else { return nil }
        return ProgramEntity.byObjectId(id: selectedProgramId)
    }

    private var selectedProgramExists: Bool {
        selectedProgram != nil
    }

    var body: some View {
        if selectedProgramExists {
            ProgramDetailGroupBox(program: selectedProgram!)
        } else {
            VStack(alignment: .center) {
                Text("Aucun programme sélectionné.")
                Text("Sélectionner un programme.")
            }
            .foregroundStyle(.secondary)
            .font(.title2)
        }
    }
}

//struct ProgramEditor_Previews: PreviewProvider {
//    static var previews: some View {
//        ProgramEditor()
//    }
//}
