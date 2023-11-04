//
//  ToDoView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 29/10/2023.
//

import AppFoundation
import HelpersView
import SwiftUI

/// Picker selectors
enum ToDoAction: String, PickableEnumP {
    case print = "A IMPRIMER POUR ÉLÈVES"
    case load = "A PARTAGER SUR ENT"

    var pickerString: String { self.rawValue }
    var imageName: String {
        switch self {
            case .print:
                DocumentEntity.forEleveImageName

            case .load:
                DocumentEntity.forEntImageName
        }
    }
}

/// Liste des documents à imprimer
/// dans un certain nombre d'exemplaires avant une certaine date
struct ToDoView: View {
    let seances: [Seance]

    @State
    private var selectedAction: ToDoAction = .print

    var body: some View {
        VStack(alignment: .leading) {
            VStack {
                Picker("Action", selection: $selectedAction ) {
                    ForEach(ToDoAction.allCases, id: \.self) { enu in
                        Label(enu.pickerString, systemImage: enu.imageName)
                    }
                }
                .pickerStyle(.segmented)
            }.padding()

            switch selectedAction {
                case .print:
                    DocsToBePrintedScrollView(seances: seances)

                case .load:
                    DocsToBeLoadedScrollView(seances: seances)
            }
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("A faire dans le mois à venir")
        #endif
    }

}

// #Preview("DocToBePrintedView") {
//    DisclosureGroup(isExpanded: .constant(true)) {
//        DocToBePrintedGroupBox(
//            levelClasse: LevelClasse.n3ieme.displayString,
//            title: "Le nom du document à imprimer qui est très très long et ne tient pas sur une seule ligne",
//            quantity: 64,
//            beforeDate: .now
//        )
//        DocToBePrintedGroupBox(
//            levelClasse: LevelClasse.n0terminale.displayString,
//            title: "Le nom d'un autre document à imprimer qui est très très long et ne tient pas sur une seule ligne",
//            quantity: 128,
//            beforeDate: 1.months.fromNow!
//        )
//    } label: {
//        Label("A imprimer pour le mois à venir", systemImage: "printer")
//            .font(.headline)
//            .fontWeight(.bold)
//            .padding(.bottom)
//    }
//    .padding(.leading)
// }
