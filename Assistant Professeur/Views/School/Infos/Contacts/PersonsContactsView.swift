//
//  PersonContactEditView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 13/05/2023.
//

import Contacts
import HelpersView
import os
import SwiftUI

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "PersonsContactsView"
)

struct PersonsContactsView: View {
    @ObservedObject
    var school: SchoolEntity

    @State
    private var loadingStatus: ContactsLoadingStatus = .pending

    @State
    private var contactStore = CNContactStore()

    @State
    private var contacts = [CNContact]()

    @State
    private var contactGroup: CNGroup?

    @State
    private var contactSortOrder: ContactManager.SortOrder = .byJobTitle

    @State
    private var alertTitle = ""

    @State
    private var alertMessage = ""

    @State
    private var alertIsPresented = false

    var body: some View {
        Section {
            // Choix de l'ordre de tri
            Picker("Tri", selection: $contactSortOrder) {
                Text("Tri par Nom").tag(ContactManager.SortOrder.byName)
                Text("Tri par Titre").tag(ContactManager.SortOrder.byJobTitle)
            }
            .pickerStyle(.segmented)

            // Liste des contacts
            loadingStatus.view
        } header: {
            Label("Contacts", systemImage: "person")
                .font(.callout)
                .foregroundColor(.secondary)
                .fontWeight(.bold)
        } footer: {
            Text("Les contacts de votre appli **Contacts**, enregistrés dans la liste nommée **\(school.viewName)** sont affichés ici.")
        }
        .alert(
            alertTitle,
            isPresented: $alertIsPresented,
            actions: {},
            message: { Text(alertMessage) }
        )
        // Récupérer les contacts dans l'appli "Contacts"
        .task(id: contactSortOrder) {
            loadingStatus = .pending

            (
                contactGroup,
                alertIsPresented,
                alertTitle,
                alertMessage
            ) = await ContactManager.shared.requestContactsAccess(
                contactStore: contactStore,
                groupName: school.viewName
            )
            guard let contactGroup else {
                loadingStatus = .failed
                return
            }

            loadingStatus = .loading

            do {
                contacts = try ContactManager.shared.allPersonContacts(
                    inOrganizationName: school.viewName,
                    inContactGroup: contactGroup,
                    inContactStore: contactStore,
                    sortedBy: contactSortOrder
                )
                loadingStatus = .finished(contacts: contacts)
            } catch {
                customLog.log(
                    level: .error,
                    "La tentative de récupération des contacts dans l'appli **Contacts** pour cet établissement à échouée."
                )
                loadingStatus = .finished(contacts: [])
                alertTitle = "Echec"
                alertMessage = "La tentative de récupération des vos contacts dans votre appli **Contacts** pour cet établissement à échouée."
                alertIsPresented = true
            }
        }
    }
}

struct PersonContactEditView_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        return Group {
            NavigationStack {
                EmptyView()
                PersonsContactsView(school: SchoolEntity.all().first!)
            }
            .environmentObject(NavigationModel(selectedSchoolMngObjId: SchoolEntity.all().first!.objectID))
            .environment(\.managedObjectContext, CoreDataManager.shared.context)
            .previewDevice("iPad mini (6th generation)")

            NavigationStack {
                EmptyView()
                PersonsContactsView(school: SchoolEntity.all().first!)
            }
            .padding()
            .environmentObject(NavigationModel(selectedSchoolMngObjId: SchoolEntity.all().first!.objectID))
            .environment(\.managedObjectContext, CoreDataManager.shared.context)
            .previewDevice("iPhone 13")
        }
    }
}
