//
//  SchoolCreator.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 20/06/2022.
//

import SwiftUI
import HelpersView

struct SchoolCreator: View {
    let addNewItem: (School) -> Void

    @State
    private var newSchool: School = School()

    @FocusState
    private var isNameFocused: Bool

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        // Nom de l'établissement
        Form {
            HStack {
                Image(systemName: newSchool.niveau == .lycee ? "building.2" : "building")
                    .imageScale(.large)
                    .foregroundColor(newSchool.niveau == .lycee ? .mint : .orange)
                TextField("Nouvel établissement", text: $newSchool.nom)
                    .font(.title2)
                    .textFieldStyle(.roundedBorder)
                    .focused($isNameFocused)
            }
            // Type d'établissement
            CasePicker(pickedCase: $newSchool.niveau,
                       label: "Type d'établissement")
            .pickerStyle(.segmented)
            .listRowSeparator(.hidden)
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuler") {
                    dismiss()
                }
            }
            ToolbarItem {
                Button("Ok") {
                    // Ajouter le nouvel établissement
                    withAnimation {
                        addNewItem(newSchool)
                    }
                    dismiss()
                }
            }
        }
        #if os(iOS)
        .navigationTitle("Nouvel Etablissement")
        #endif
    }
}

struct SchoolCreator_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EmptyView()
            SchoolCreator { _ in }
        }
    }
}
