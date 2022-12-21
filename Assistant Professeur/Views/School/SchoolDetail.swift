//
//  SchoolDetail.swift
//  Cahier du Professeur (iOS)
//
//  Created by Lionel MICHAUD on 09/10/2022.
//

import SwiftUI
import os
import HelpersView
import Files

private let customLog = Logger(subsystem : "com.michaud.lionel.Cahier-du-Professeur",
                               category  : "SchoolDetail")

struct SchoolDetail: View {
    @ObservedObject
    var school: SchoolEntity

    @EnvironmentObject
    private var navigationModel : NavigationModel

    @State
    private var alertItem: AlertItem?

    @Preference(\.schoolAnnotationEnabled)
    private var schoolAnnotation

    // MARK: - Computed Properties

    /// Vue du nom de l'établissement
    private var nameView: some View {
        HStack {
            Image(systemName: school.levelEnum == .lycee ? "building.2" : "building")
                .imageScale(.large)
                .foregroundColor(school.levelEnum == .lycee ? .mint : .orange)
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
                // note sur la classe
                if schoolAnnotation {
                     AnnotationView(annotation: $school.viewAnnotation)
                }

                // édition de la liste des classes
                ClassList(school: school)

                // édition de la liste des événements
                EventList(school: school)

                // édition de la liste des documents utiles
                //                    DocumentList(school: $school)

                // édition de la liste des salles de classe
                //                    RoomList(school: $school)

                // édition de la liste des ressources
                //                    RessourceList(school: $school)
            }
            #if os(iOS)
            .navigationTitle("Etablissement")
            .navigationBarTitleDisplayMode(.inline)
            #endif
            //.onChange(of: schoolVM, perform: save)
        }
        .onDisappear(perform: save)
    }

    func save() {
        try? SchoolEntity.saveIfContextHasChanged()
        //school.refresh()
    }
}

//struct SchoolDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        TestEnvir.createFakes()
//        return Group {
//            NavigationStack {
//                SchoolDetail(school: .constant(TestEnvir.schoolStore.items.first!))
//                    .environmentObject(NavigationModel(selectedSchoolId: TestEnvir.schoolStore.items.first!.id))
//                    .environmentObject(TestEnvir.schoolStore)
//                    .environmentObject(TestEnvir.classeStore)
//                    .environmentObject(TestEnvir.eleveStore)
//                    .environmentObject(TestEnvir.colleStore)
//                    .environmentObject(TestEnvir.observStore)
//            }
//            .previewDevice("iPad mini (6th generation)")
//
//            NavigationStack {
//                SchoolDetail(school: .constant(TestEnvir.schoolStore.items.first!))
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
//}
