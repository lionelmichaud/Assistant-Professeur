//
//  ClassList.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 31/10/2022.
//

import SwiftUI

struct ClassList: View {
    @ObservedObject
    var school: SchoolEntity

    @EnvironmentObject
    private var navigationModel: NavigationModel

    @State
    private var isAddingNewClasse = false

    // MARK: - Computed Properties

    var body: some View {
        Section {
            // ajouter une classe
            Button {
                isAddingNewClasse = true
            } label: {
                Label("Ajouter une classe", systemImage: "plus.circle.fill")
            }
            .buttonStyle(.borderless)

            // édition de la liste des classes
            ForEach(school.classesSortedByLevelNumber) { classe in
                ClassBrowserRow(classe: classe)

                    .onTapGesture {
                        // Programatic Navigation
                        navigationModel.selectedTab = .classe
                        navigationModel.selectedClasseId = classe.objectID
                    }

                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        // supprimer une classe
                        Button(role: .destructive) {
                            withAnimation {
                                // supprimer la classe et tous ses descendants
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
                        // flager une classe
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
        } header: {
            // titre
            HStack {
                Text("Classes (\(school.nbOfClasses))")
                Spacer()
                Text("\(school.heures.formatted(.number.precision(.fractionLength(1)))) h")
            }
            .font(.callout)
            .foregroundColor(.secondary)
            .fontWeight(.bold)
        }
        // Modal: ajout d'une nouvelle classe
        .sheet(isPresented: $isAddingNewClasse) {
            NavigationStack {
                ClassCreatorModal(inSchool: school)
                    .presentationDetents([.medium])
            }
        }
    }
}

// struct ClassList_Previews: PreviewProvider {
//    static var previews: some View {
//        TestEnvir.createFakes()
//        return Group {
//            List {
//                ClassList(school: .constant(TestEnvir.schoolStore.items.first!))
//                    .environmentObject(NavigationModel(selectedSchoolId: TestEnvir.schoolStore.items.first!.id))
//                    .environmentObject(TestEnvir.schoolStore)
//                    .environmentObject(TestEnvir.classeStore)
//                    .environmentObject(TestEnvir.eleveStore)
//                    .environmentObject(TestEnvir.colleStore)
//                    .environmentObject(TestEnvir.observStore)
//            }
//            .previewDevice("iPad mini (6th generation)")
//
//            List {
//                ClassList(school: .constant(TestEnvir.schoolStore.items.first!))
//                    .environmentObject(NavigationModel(selectedSchoolId: TestEnvir.schoolStore.items.first!.id))
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
