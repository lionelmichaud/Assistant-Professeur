//
//  RessourceEditor.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 19/06/2022.
//

import SwiftUI
import HelpersView

struct RessourceEditor: View {
    @ObservedObject
    var ressource: RessourceEntity

    @Environment(\.horizontalSizeClass)
    var hClass

    var nameView: some View {
        HStack {
            Image(systemName: "latch.2.case")
                .sfSymbolStyling()
                .foregroundColor(.accentColor)
            TextField("Nom de la ressource", text: $ressource.name.bound)
                .textFieldStyle(.roundedBorder)
        }
        .onChange(of: ressource.viewName) {
            try? RessourceEntity.saveIfContextHasChanged()
        }
    }

    var quantityView: some View {
        Stepper(value : $ressource.quantity,
                in    : 1 ... 100,
                step  : 1) {
            HStack {
                Text(hClass == .regular ? "Quantité disponible" : "Quantité")
                Spacer()
                Text("\(ressource.quantity)")
                    .foregroundColor(.secondary)
            }
            .onChange(of: ressource.quantity) {
                try? RessourceEntity.saveIfContextHasChanged()
            }
        }
    }

    var body: some View {
        if hClass == .regular {
            HStack {
                nameView
                quantityView
                    .frame(maxWidth: 280)
            }
        } else {
            GroupBox {
                nameView
                quantityView
            }
        }
    }
}

struct RessourceEditor_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        return Group {
            RessourceEditor(ressource: RessourceEntity.all().first!)
                .padding()
                .environmentObject(NavigationModel(selectedSchoolMngObjId: SchoolEntity.all().first!.objectID))
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPad mini (6th generation)")

            RessourceEditor(ressource: RessourceEntity.all().first!)
                .padding()
                .environmentObject(NavigationModel(selectedSchoolMngObjId: SchoolEntity.all().first!.objectID))
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPhone 13")
        }
    }
}
