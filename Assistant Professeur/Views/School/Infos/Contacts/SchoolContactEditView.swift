//
//  OrganizationEditView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 11/05/2023.
//

import AppFoundation
import Contacts
import HelpersView
import OSLog
import SwiftUI

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "SchoolContactEditView"
)

/// Présentation des informations sur l'établissement obtenue auprès de
/// l'appplication Contacts
struct SchoolContactEditView: View {
    @ObservedObject
    var school: SchoolEntity

    /// Focused filed manager
    enum FocusableField: Hashable {
        case phone
        case mail
        case url
        case street
        case postalCode
        case city
        case none

        mutating func moveToNext() {
            switch self {
                case .phone:
                    self = .mail
                case .mail:
                    self = .url
                case .url:
                    self = .street
                case .street:
                    self = .postalCode
                case .postalCode:
                    self = .city
                case .city:
                    self = .none
                case .none:
                    self = .none
            }
        }
    }

    @FocusState
    private var focus: FocusableField?

    @State
    private var alertTitle = ""
    @State
    private var alertMessage = ""
    @State
    private var alertIsPresented = false

    @State
    private var phoneNumber: String = ""
    @State
    private var emailAddress: String = ""
    @State
    private var urlAddress: String = ""
    @State
    private var street: String = ""
    @State
    private var postalCode: String = ""
    @State
    private var city: String = ""

    @State
    private var contactStore = CNContactStore()

    @State
    private var contactGroup: CNGroup?

    var body: some View {
        Section {
            TextField("Numéro de téléphone", text: $phoneNumber)
            #if os(iOS) || os(tvOS)
                .keyboardType(.phonePad)
            #endif
                .textContentType(.telephoneNumber)
                .submitLabel(.next)
                .focused($focus, equals: .phone)
                .onChange(of: phoneNumber) {
                    phoneNumber = phoneNumber.formatPhoneNumber()
                }
            TextField("Adresse e-mail", text: $emailAddress)
            #if os(iOS) || os(tvOS)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
            #endif
                .submitLabel(.next)
                .focused($focus, equals: .mail)
            TextField("Site Web", text: $urlAddress)
            #if os(iOS) || os(tvOS)
                .keyboardType(.URL)
                .textInputAutocapitalization(.never)
            #endif
                .submitLabel(.next)
                .focused($focus, equals: .url)
            TextField("Rue", text: $street)
                .submitLabel(.next)
                .focused($focus, equals: .street)
            HStack {
                TextField("CP", text: $postalCode)
                #if os(iOS) || os(tvOS)
                    .keyboardType(.numberPad)
                #endif
                    .submitLabel(.next)
                    .focused($focus, equals: .postalCode)
                Divider()
                TextField("Ville", text: $city)
                    .autocorrectionDisabled(false)
                    .submitLabel(.next)
                    .focused($focus, equals: .city)
            }
            Button(
                action: {
                    Task {
                        await saveContact()
                    }
                },
                label: {
                    Text("Mettre à jour l'app Contacts")
                }
            )
            .buttonStyle(.borderless)
            .disabled(!ContactManager.shared.isAccessAuthorized)
            .horizontallyAligned(.center)
        } header: {
            Label(
                "Coordonnées de l'établissement",
                systemImage: school.levelEnum.imageName
            )
            .font(.callout)
            .foregroundColor(.secondary)
            .fontWeight(.bold)
        }
        // .textFieldStyle(.roundedBorder)
        .autocorrectionDisabled()
        .onSubmit {
            focus?.moveToNext()
        }
        .alert(
            alertTitle,
            isPresented: $alertIsPresented,
            actions: {},
            message: { Text(alertMessage) }
        )
        .onAppear {
            focus = SchoolContactEditView.FocusableField.none
        }
        .task {
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
                return
            }

            do {
                if let schoolContact = try await ContactManager.shared
                    .organizationContact(
                        inContactGroup: contactGroup,
                        inContactStore: contactStore,
                        withOrganizationName: school.viewName
                    ),
                    let contact = ContactEnum(from: schoolContact) {
                    if case let ContactEnum.organization(_, phoneNumber, emailAddress, urlAddress, street, city, postalCode) = contact {
                        self.phoneNumber = phoneNumber
                        self.emailAddress = emailAddress
                        self.urlAddress = urlAddress
                        self.street = street
                        self.city = city
                        self.postalCode = postalCode
                    }
                }
            } catch {
                customLog.error(
                    "La tentative de récupération des contacts dans l'appli **Contacts** pour cet établissement a échouée."
                )
                alertTitle = "Echec"
                alertMessage = "La tentative de récupération des vos contacts dans votre appli **Contacts** pour cet établissement a échouée."
                alertIsPresented = true
            }
        }
    }

    private func saveContact() async {
        let contact =
            ContactEnum.organization(
                organization: school.viewName,
                phoneNumber: phoneNumber,
                emailAddress: emailAddress,
                urlAddress: urlAddress,
                street: street,
                city: city,
                postalCode: postalCode
            )
        guard let contactGroup else {
            return
        }
        if await ContactManager.shared
            .saveOrUpdate(
                contact: contact,
                inContactGroup: contactGroup,
                inContactStore: contactStore
            ) {
            alertTitle = "Le contact a été enregistré."
            alertMessage = ""
            alertIsPresented.toggle()
        } else {
            alertTitle = "Echec"
            alertMessage = "La tentative d'enregistrement des ce contact dans votre appli **Contacts** pour cet établissement a échouée."
            alertIsPresented.toggle()
        }
    }
}

struct OrganizationEditView_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        return Group {
            NavigationStack {
                EmptyView()
                SchoolContactEditView(school: SchoolEntity.all().first!)
            }
            .environmentObject(NavigationModel(selectedSchoolMngObjId: SchoolEntity.all().first!.objectID))
            .environment(\.managedObjectContext, CoreDataManager.shared.context)
            .previewDevice("iPad mini (6th generation)")

            NavigationStack {
                EmptyView()
                SchoolContactEditView(school: SchoolEntity.all().first!)
            }
            .padding()
            .environmentObject(NavigationModel(selectedSchoolMngObjId: SchoolEntity.all().first!.objectID))
            .environment(\.managedObjectContext, CoreDataManager.shared.context)
            .previewDevice("iPhone 13")
        }
    }
}
