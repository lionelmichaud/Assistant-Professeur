//
//  GroupPicturesView.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 16/10/2022.
//

import SwiftUI

struct GroupPicturesView : View {
    @ObservedObject
    var groupe : GroupEntity

    let searchString : String

    @EnvironmentObject
    private var navigationModel : NavigationModel

    @Preference(\.nameDisplayOrder)
    private var nameDisplayOrder

    let smallColumns = [GridItem(.adaptive(minimum: 120, maximum: 200))]
    let font       : Font        = .title3
    let fontWeight : Font.Weight = .semibold

    var body: some View {
        LazyVGrid(columns: smallColumns,
                  spacing: 4) {
            ForEach(groupe.filteredElevesSortedByName(searchString: searchString), id: \.objectID) { eleve in
                VStack {
                    if eleve.hasImageTrombine {
                        eleve.viewImageTrombine
                        //Image(systemName: "questionmark.square.dashed")
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(15)
                            .shadow(radius: 5)
                            .accessibility(hidden: false)
                    } else {
                        eleve.viewImageTrombine
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(15)
                            .shadow(radius: 5)
                            .accessibility(hidden: false)
                            .foregroundColor(.secondary)
                    }
                    
                    /// Nom de l'élève
                    Text(eleve.displayName2lines(nameDisplayOrder))
                        .multilineTextAlignment(.center)
                        .fontWeight(fontWeight)
                        .elevNameStyling(hasTrouble: eleve.hasTrouble,
                                         hasAddTime: eleve.hasAddTime)
                }
                .onTapGesture {
                    // Programatic Navigation
                    navigationModel.selectedTab     = .eleve
                    navigationModel.selectedEleveId = eleve.objectID
                }
            }
        }
    }
}

//struct GroupPicturesView_Previews: PreviewProvider {
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
//}
