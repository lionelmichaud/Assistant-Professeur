//
//  SchoolDetail.swift
//  Cahier du Professeur (iOS)
//
//  Created by Lionel MICHAUD on 09/10/2022.
//

import Files
import HelpersView
import os
import SwiftUI

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "SchoolDetail"
)

struct SchoolDetail: View {
    @ObservedObject
    var school: SchoolEntity

    @EnvironmentObject
    private var navigationModel: NavigationModel

    // MARK: - Computed Properties

    /// Vue du nom de l'établissement
    private var nameView: some View {
        HStack {
            Image(systemName: school.levelEnum.imageName)
                .imageScale(.large)
                .foregroundColor(school.levelEnum.imageColor)
            TextField("Nom", text: $school.viewName)
                .font(.title2)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
        }
        .listRowSeparator(.hidden)
    }

    var body: some View {
        VStack {
            // nom de l'établissement
            GroupBox {
                nameView
            }
            .padding(.horizontal, 60)

            List {
                // infos sur l'établissement
                NavigationLink(value: SchoolNavigationRoute.infos(school.id)) {
                    Label("Informations", systemImage: "info.circle")
                        .fontWeight(.bold)
                    }
                // Liste des cours précédents terminés
                NavigationLink(value: SchoolNavigationRoute.previousSeances(school.id)) {
                    Label("Cours précédents", systemImage: "clock.arrow.circlepath")
                        .fontWeight(.bold)
                }
                // Le cours en cours
                NavigationLink(value: SchoolNavigationRoute.currentSeances(school.id)) {
                    Label("Cours actuel", systemImage: "clock.badge.checkmark")
                        .fontWeight(.bold)
                }
                // Liste des cours à venir
                NavigationLink(value: SchoolNavigationRoute.nextSeances(school.id)) {
                    Label("Prochains cours", systemImage: "clock")
                        .fontWeight(.bold)
                }

                // Section liste des classes
                ClasseListSection(school: school)

                // Section liste des événements
                EventListSection(school: school)

                // Section liste des documents utiles
                SchoolDocumentListSection(school: school)

                // Section liste des salles de classe
                RoomListSection(school: school)

                // Section liste des ressources
                RessourceListSection(school: school)
            }
        }
        #if os(iOS)
        .navigationTitle("Etablissement")
        .navigationBarTitleDisplayMode(.inline)
        #endif
        // .onChange(of: schoolVM, perform: save)
        // .onDisappear(perform: save)
    }

    private func save() {
        try? SchoolEntity.saveIfContextHasChanged()
        // school.refresh()
    }
}

struct SchoolDetail_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        return Group {
            SchoolDetail(school: SchoolEntity.all().first!)
                .padding()
                .environmentObject(NavigationModel(selectedSchoolMngObjId: SchoolEntity.all().first!.objectID))
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPad mini (6th generation)")

            SchoolDetail(school: SchoolEntity.all().first!)
                .padding()
                .environmentObject(NavigationModel(selectedSchoolMngObjId: SchoolEntity.all().first!.objectID))
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPhone 13")
        }
    }
}
