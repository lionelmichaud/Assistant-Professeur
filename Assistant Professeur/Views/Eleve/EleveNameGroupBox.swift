//
//  EleveNameGroupBox.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 09/10/2022.
//

import SwiftUI
import HelpersView

struct EleveNameGroupBox: View {
    @ObservedObject
    var eleve: EleveEntity

    var isEditing: Bool

    @EnvironmentObject
    private var pref: UserPreferences

    /// Focused filed manager
    enum FocusableField: Hashable {
        case givenName
        case familyName

        mutating func moveToNext() {
            switch self {
                case .givenName:
                    self = .familyName
                case .familyName:
                    self = .givenName
            }
        }
    }

    @FocusState
    private var focus: FocusableField?

    // MARK: - Computed Properties

    private var sexEditView: some View {
        HStack {
            // Sexe de cet eleve
            CasePicker(pickedCase: $eleve.sexEnum, label: "Sexe")
                .pickerStyle(.menu)
        }
    }
    private var prenomEditView: some View {
        TextField("Prénom", text: $eleve.viewGivenName)
            .onSubmit {
                //eleve.viewGivenName.trim()
                focus?.moveToNext()
            }
            .textFieldStyle(.roundedBorder)
            .autocorrectionDisabled()
            .submitLabel(.next)
            .focused($focus, equals: .givenName)
    }
    private var nomEditView: some View {
        TextField("Nom", text: $eleve.viewFamilyName)
            .onSubmit {
                //eleve.viewFamilyName = eleve.viewFamilyName.trimmed.uppercased()
                focus?.moveToNext()
            }
            .textFieldStyle(.roundedBorder)
            .autocorrectionDisabled()
            .submitLabel(.next)
            .focused($focus, equals: .familyName)
    }

    var body: some View {
        GroupBox {
            if isEditing {
                // mode édition des sex, prénom, nom
                ViewThatFits(in: .horizontal) {
                    // priorité 1
                    HStack {
                        sexEditView
                        if pref.nameDisplayOrder == .nomPrenom {
                            nomEditView
                            prenomEditView
                        } else {
                            prenomEditView
                            nomEditView
                        }
                    }
                    // priorité 2
                    VStack {
                        sexEditView
                        if pref.nameDisplayOrder == .nomPrenom {
                            nomEditView
                            prenomEditView
                        } else {
                            prenomEditView
                            nomEditView
                        }
                    }
                }

            } else {
                EleveLabelWithTrombineFlag(eleve: eleve)
            }
        }
        .onAppear {
            focus = pref.nameDisplayOrder == .nomPrenom ? .familyName : .givenName
        }
    }
}

struct EleveNameGroupBox_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        return Group {
            EleveNameGroupBox(eleve: EleveEntity.all().first!, isEditing: true)
                .previewDevice("iPad mini (6th generation)")

            EleveNameGroupBox(eleve: EleveEntity.all().first!, isEditing: false)
                .previewDevice("iPhone 13")
        }
        .environmentObject(NavigationModel(selectedEleveMngObjId: EleveEntity.all().first!.objectID))
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
    }
}
