//
//  GroupPicturesView.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 16/10/2022.
//

import SwiftUI

//struct GroupPicturesView : View {
//    let group: GroupOfEleves
//
//    @EnvironmentObject private var navigationModel : NavigationModel
//    @EnvironmentObject private var eleveStore      : EleveStore
//
//    @Preference(\.nameDisplayOrder)
//    private var nameDisplayOrder
//
//    let smallColumns = [GridItem(.adaptive(minimum: 120, maximum: 200))]
//    let font       : Font        = .title3
//    let fontWeight : Font.Weight = .semibold
//
//    var body: some View {
//        LazyVGrid(columns: smallColumns,
//                  spacing: 4) {
//            ForEach(group.elevesID, id: \.self) { eleveID in
//                if let eleve = eleveStore.item(withID: eleveID) {
//                    VStack {
//                        if let trombine = Trombinoscope.eleveTrombineUrl(eleve: eleve) {
//                            // TODO: - Gérer ici la mise à jour de la photo par drag and drop
//                            LoadableImage(imageUrl: trombine,
//                                          placeholderImage: .constant(Image(systemName: "person.fill.questionmark")))
//                        }
//
//                        /// Nom de l'élève
//                        if eleve.troubleDys == nil {
//                            Text(eleve.displayName2lines(nameDisplayOrder))
//                                .multilineTextAlignment(.center)
//                                .fontWeight(fontWeight)
//                        } else {
//                            Text(eleve.displayName2lines(nameDisplayOrder))
//                                .multilineTextAlignment(.center)
//                                .fontWeight(fontWeight)
//                                .padding(2)
//                                .background {
//                                    RoundedRectangle(cornerRadius: 5)
//                                        .foregroundColor(.gray)
//                                }
//                        }
//                    }
//                    .onTapGesture {
//                        // Programatic Navigation
//                        navigationModel.selectedTab     = .eleve
//                        navigationModel.selectedEleveId = eleve.id
//                    }
//                }
//            }
//        }
//    }
//}

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
