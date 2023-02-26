//
//  SequenceTimeLine.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 22/02/2023.
//

import SwiftUI

struct SequenceTimeLine: View {
    @EnvironmentObject
    private var navig: NavigationModel

    var body: some View {
        VStack {
            if let sequenceId = navig.selectedSequenceId {
                if let sequence = SequenceEntity.byObjectId(id: sequenceId) {
                    SequenceStepperView(sequence: sequence)
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
        #if os(iOS)
        .navigationTitle("Déroulement de la séquence")
        #endif
        .navigationBarTitleDisplayModeInline()
    }
}

struct SequenceTimeLine_Previews: PreviewProvider {
    static var previews: some View {
        SequenceTimeLine()
    }
}
