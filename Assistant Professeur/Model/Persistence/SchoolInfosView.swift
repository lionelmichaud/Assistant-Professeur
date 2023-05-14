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

    @Preference(\.schoolAnnotationEnabled)
    private var schoolAnnotation

    var body: some View {
        List {
            // note sur la classe
            if schoolAnnotation {
                AnnotationEditView(annotation: $school.viewAnnotation)
                    .padding(.top)
            }

            // Contact de l'établissement
            SchoolContactEditView(school: school)

            // Contacts de personnes de l'établissement
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
