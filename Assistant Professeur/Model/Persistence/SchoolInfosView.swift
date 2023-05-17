//
//  SchoolInfosView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 10/05/2023.
//

import Contacts
import HelpersView
import SwiftUI

struct SchoolInfosView: View {
    @ObservedObject
    var school: SchoolEntity

    @EnvironmentObject
    private var pref: UserPreferences

    var body: some View {
        List {
            // note sur la classe
            if pref.schoolAnnotationEnabled {
                AnnotationEditView(annotation: $school.viewAnnotation)
            }
            // Coordonnées de l'établissement
            SchoolContactEditView(school: school)

            // Login/Password d'accès au réseau local de l'établissement
            LoginPasswordEditView(
                title: "Accès au réseaux local",
                id: $school.viewIdNetwork,
                pwd: $school.viewPwdNetwork
            )

            // Login/Password d'accès à l'ENT de l'établissement
            LoginPasswordEditView(
                title: "Accès à l'ENT",
                id: $school.viewIdENT,
                pwd: $school.viewPwdENT
            )

            Section {
                // Code d'accès à l'entrée de l'établissement
                LabeledContent {
                    TextField("Entrée", text: $school.viewCodeEntree)
                } label: {
                    Image(systemName: "door.left.hand.closed")
                        .imageScale(.large)
                }

                // Code d'accès au photocopieur de l'établissement
                LabeledContent {
                    TextField("Photocopieur", text: $school.viewCodePhotocopie)
                } label: {
                    Image(systemName: "scanner")
                        .imageScale(.large)
                }
            } header: {
                Label("Code d'accès", systemImage: "lock")
                    .bold()
            }
            #if os(iOS) || os(tvOS)
            .textInputAutocapitalization(.never)
            #endif

            // Contacts d'autres personnes de l'établissement
            PersonsContactsView(school: school)
        }
        // .listStyle(.plain)
        #if os(iOS)
        .navigationTitle("Informations")
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct SchoolInfosView_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        return Group {
            NavigationStack {
                EmptyView()
                SchoolInfosView(school: SchoolEntity.all().first!)
            }
            .environmentObject(NavigationModel(selectedSchoolMngObjId: SchoolEntity.all().first!.objectID))
            .environment(\.managedObjectContext, CoreDataManager.shared.context)
            .previewDevice("iPad mini (6th generation)")

            NavigationStack {
                EmptyView()
                SchoolInfosView(school: SchoolEntity.all().first!)
            }
            .padding()
            .environmentObject(NavigationModel(selectedSchoolMngObjId: SchoolEntity.all().first!.objectID))
            .environment(\.managedObjectContext, CoreDataManager.shared.context)
            .previewDevice("iPhone 13")
        }
    }
}
