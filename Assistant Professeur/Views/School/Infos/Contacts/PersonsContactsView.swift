//
//  PersonContactEditView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 13/05/2023.
//

import SwiftUI

struct PersonsContactsView: View {
    @ObservedObject
    var school: SchoolEntity

    @StateObject
    private var viewModel = ContactsViewModel()

    @State
    private var alert = AlertInfo()

    @State
    private var contactSortOrder: ContactManager.SortOrder = .byJobTitle

    var body: some View {
        Section {
            // Choix de l'ordre de tri
            Picker("Tri", selection: $contactSortOrder) {
                Text("Tri par Nom").tag(ContactManager.SortOrder.byName)
                Text("Tri par Titre").tag(ContactManager.SortOrder.byJobTitle)
            }
            .pickerStyle(.segmented)

            // Liste des contacts
            viewModel.status.view
        } header: {
            Label("Contacts", systemImage: "person")
                .font(.callout)
                .foregroundColor(.secondary)
                .fontWeight(.bold)
        } footer: {
            Text("Les contacts de votre appli **Contacts**, enregistrés dans la liste nommée **\(school.viewName)** sont affichés ici.")
        }
        .alert(
            alert.title,
            isPresented: $alert.isPresented,
            actions: {},
            message: { Text(alert.message) }
        )
        // Récupérer les contacts dans l'appli "Contacts"
        .task(id: contactSortOrder) {
            let alert = await viewModel.getAllContacts(
                forSchoolName: school.viewName,
                contactSortOrder: contactSortOrder
            )
            self.alert = alert
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
