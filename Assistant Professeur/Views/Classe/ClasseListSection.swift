//
//  ClasseListSection.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 31/10/2022.
//

import SwiftUI

/// Liste des classes d'un établissement
struct ClasseListSection: View {
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
                ClasseBrowserRow(classe: classe)

                    .onTapGesture {
                        // Programatic Navigation
                        navigationModel.selectedTab = .classe
                        navigationModel.selectedClasseMngObjId = classe.objectID
                    }

                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        // supprimer une classe
                        Button(role: .destructive) {
                            withAnimation {
                                // supprimer la classe et tous ses descendants
                                try? classe.delete()
                                if navigationModel.selectedClasseMngObjId == classe.objectID {
                                    navigationModel.selectedClasseMngObjId = nil
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

            // Tableau de bord des Bonus / Malus
            NavigationLink(value: SchoolNavigationRoute.bonusMalus(school)) {
                Label("Tableau de bord des Bonus / Malus", systemImage: "plusminus")
                    .fontWeight(.bold)
            }
        } header: {
            // titre
            HStack {
                Text("Classes (\(school.nbOfClasses))")
                    .style(.sectionHeader)
                Spacer()
                Text("\(school.heures.formatted(.number.precision(.fractionLength(1)))) heures")
                    .style(.sectionHeader)
            }
        }
        // Modal: ajout d'une nouvelle classe
        .sheet(isPresented: $isAddingNewClasse) {
            NavigationStack {
                ClasseCreatorModal(inSchool: school)
                    .presentationDetents([.medium])
            }
        }
    }
}

struct ClassList_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        return Group {
            List {
                ClasseListSection(school: SchoolEntity.all().first!)
            }
            .padding()
            .environmentObject(NavigationModel(selectedSchoolMngObjId: SchoolEntity.all().first!.objectID))
            .environment(\.managedObjectContext, CoreDataManager.shared.context)
            .previewDevice("iPad mini (6th generation)")

            List {
                ClasseListSection(school: SchoolEntity.all().first!)
            }
            .padding()
            .environmentObject(NavigationModel(selectedSchoolMngObjId: SchoolEntity.all().first!.objectID))
            .environment(\.managedObjectContext, CoreDataManager.shared.context)
            .previewDevice("iPhone 13")
        }
    }
}
