//
//  ClasseBrowserView.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 21/04/2022.
//

import SwiftUI

struct ClasseSidebarView: View {
    @EnvironmentObject
    private var navigationModel : NavigationModel

    @SectionedFetchRequest<String, ClasseEntity>(
        fetchRequest      : ClasseEntity.requestAllSortedBySchoolnameLevelNumber,
        sectionIdentifier : \.school!.displayString,
        animation         : .default)
    private var classesSections: SectionedFetchResults<String, ClasseEntity>

    var body: some View {
        Text("EleveSidebarView")
        List(selection: $navigationModel.selectedClasseId) {
            if classesSections.isEmpty {
                Text("Aucune classe actuellement")
            } else {
                /// pour chaque Etablissement
                ForEach(classesSections) { section in
                    if section.isNotEmpty {
                        Section {
                            /// pour chaque Classe
                            ClasseSidebarSchoolSubview(schoolSection: section)
                        } header: {
                            Text(section.id)
                                .font(.callout)
                                .foregroundColor(.secondary)
                                .fontWeight(.bold)
                        }
                    }
                }
            }
        }
        .navigationTitle("Les Classes")
    }
}

struct ClasseSidebarSchoolSubview : View {
    var schoolSection: SectionedFetchResults<String, ClasseEntity>.Element

    @EnvironmentObject
    private var navigationModel : NavigationModel

    var body: some View {
        /// pour chaque Classe
        ForEach(schoolSection, id: \.objectID) { classe in
            ClassBrowserRow(classe: classe)
                .badge(classe.nbOfEleves)

                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    // supprimer la classe et tous ses descendants
                    Button(role: .destructive) {
                        withAnimation {
                            try? classe.delete()
                            if navigationModel.selectedClasseId == classe.objectID {
                                navigationModel.selectedClasseId = nil
                            }
                        }
                    } label: {
                        Label("Supprimer", systemImage: "trash")
                    }
                }

                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                // modifier le flag de la classe
                    Button {
                        withAnimation {
                            classe.toggleFlag()
                        }
                    } label: {
                        if classe.isFlagged {
                            Label("Sans drapeau", systemImage: "flag.slash")
                        } else {
                            Label("Avec drapeau", systemImage: "flag.fill")
                        }
                    }.tint(.orange)
                }
        }
    }
}

//struct ClasseSidebarView_Previews: PreviewProvider {
//    static var previews: some View {
//        TestEnvir.createFakes()
//        return Group {
//            ClasseSidebarView()
//                .environmentObject(NavigationModel(selectedClasseId: TestEnvir.classeStore.items.first!.id))
//                .environmentObject(TestEnvir.schoolStore)
//                .environmentObject(TestEnvir.classeStore)
//                .environmentObject(TestEnvir.eleveStore)
//                .environmentObject(TestEnvir.colleStore)
//                .environmentObject(TestEnvir.observStore)
//                .previewDevice("iPad mini (6th generation)")
//
//            ClasseSidebarView()
//                .environmentObject(NavigationModel(selectedClasseId: TestEnvir.classeStore.items.first!.id))
//                .environmentObject(TestEnvir.schoolStore)
//                .environmentObject(TestEnvir.classeStore)
//                .environmentObject(TestEnvir.eleveStore)
//                .environmentObject(TestEnvir.colleStore)
//                .environmentObject(TestEnvir.observStore)
//                .previewDevice("iPhone 13")
//        }
//    }
//}
