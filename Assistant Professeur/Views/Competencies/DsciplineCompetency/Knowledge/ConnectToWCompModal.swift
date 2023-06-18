//
//  ConnectToWCompModal.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 17/06/2023.
//

import HelpersView
import SwiftUI

struct ConnectToWCompModal: View {
    @ObservedObject
    var competency: DCompEntity

    @State
    private var selectedWComp: WCompEntity = .all().first!

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        VStack(alignment: .leading) {
            Text("Associer une compétence travaillée")
                .padding([.leading, .top])
            Picker(
                "Compétence",
                selection: $selectedWComp
            ) {
                ForEach(WCompEntity.allSortedbyAcronym()) { wComp in
                    HStack {
                        Text(wComp.viewAcronym)
                        Text(wComp.viewDescription)
                        Spacer()
                    }
                    .tag(wComp)
                }
            }
        }
        .verticallyAligned(.top)
        .pickerStyle(.wheel)
        #if os(iOS)
            .navigationTitle("Compétence travaillée")
        #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        DCompEntity.rollback()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ok") {
                        selectedWComp.addToDisciplineCompetencies(competency)
                        try? DCompEntity.saveIfContextHasChanged()
                        dismiss()
                    }
                }
            }
    }
}

// struct ConnectToWCompModal_Previews: PreviewProvider {
//    static var previews: some View {
//        ConnectToWCompModal()
//    }
// }
