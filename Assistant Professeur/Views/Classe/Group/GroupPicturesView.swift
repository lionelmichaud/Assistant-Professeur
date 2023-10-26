//
//  GroupPicturesView.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 16/10/2022.
//

import SwiftUI

struct GroupPicturesView: View {
    @ObservedObject
    var groupe: GroupEntity

    let searchString: String

    @EnvironmentObject
    private var navig: NavigationModel

    let smallColumns = [
        GridItem(
            .adaptive(minimum: 120, maximum: 200),
            alignment: .top
        )
    ]
    let font: Font = .title3
    let fontWeight: Font.Weight = .semibold

    var body: some View {
        LazyVGrid(
            columns: smallColumns,
            spacing: 4
        ) {
            ForEach(groupe.filteredElevesSortedByName(searchString: searchString), id: \.objectID) { eleve in
                VStack {
                    TrombineInteractivView(eleve: eleve)

                    // Nom de l'élève
                    EleveTextName(
                        eleve: eleve,
                        fontWeight: fontWeight
                    )
                    .multilineTextAlignment(.center)
                }
                .onTapGesture {
                    // Programatic Navigation
                    DeepLinkManager.handle(
                        navigateTo: .eleve(eleve: eleve),
                        using: navig
                    )
                }
            }
        }
    }
}

// struct GroupPicturesView_Previews: PreviewProvider {
//    static var previews: some View {
//        TestEnvir.createFakes()
//        return Group {
//            List {
//                GroupPicturesView(group: TestEnvir.group)
//                    .environmentObject(NavigationModel(selectedClasseId: TestEnvir.classeStore.items.first!.id))
//                    .environmentObject(TestEnvir.schoolStore)
//                    .environmentObject(TestEnvir.classeStore)
//                    .environmentObject(TestEnvir.eleveStore)
//                    .environmentObject(TestEnvir.colleStore)
//                    .environmentObject(TestEnvir.observStore)
//            }
//            .previewDevice("iPad mini (6th generation)")
//
//            List {
//                GroupPicturesView(group: TestEnvir.group)
//                    .environmentObject(NavigationModel(selectedClasseId: TestEnvir.classeStore.items.first!.id))
//                    .environmentObject(TestEnvir.schoolStore)
//                    .environmentObject(TestEnvir.classeStore)
//                    .environmentObject(TestEnvir.eleveStore)
//                    .environmentObject(TestEnvir.colleStore)
//                    .environmentObject(TestEnvir.observStore)
//            }
//            .previewDevice("iPhone 13")
//        }
//    }
// }
