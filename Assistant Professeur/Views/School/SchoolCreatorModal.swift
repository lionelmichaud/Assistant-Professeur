//
//  SchoolCreator.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 20/06/2022.
//

import SwiftUI
import HelpersView

struct SchoolCreatorModal: View {

    @StateObject
    private var schoolVM = SchoolViewModel()

    @FocusState
    private var isNameFocused: Bool

    @State
    private var alertTitle = ""

    @State
    private var alertIsPresented = false

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        // Nom de l'établissement
        Form {
            HStack {
                Image(systemName: schoolVM.niveau == .lycee ? "building.2" : "building")
                    .imageScale(.large)
                    .foregroundColor(schoolVM.niveau == .lycee ? .mint : .orange)
                TextField("Nom", text: $schoolVM.name)
                    .font(.title2)
                    .textFieldStyle(.roundedBorder)
                    .submitLabel(.done)
                    .focused($isNameFocused)
            }
            // Type d'établissement
            CasePicker(pickedCase: $schoolVM.niveau,
                       label: "Type d'établissement")
            .pickerStyle(.segmented)
            .listRowSeparator(.hidden)
        }
        .alert(
            alertTitle,
            isPresented: $alertIsPresented,
            actions: {}
        )
        .onAppear {
            isNameFocused = true
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuler") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Ok") {
                    if schoolVM.name.isEmpty {
                        alertTitle = "Il faut nommer l'établissement"
                        alertIsPresented.toggle()
                    } else {
                        // Ajouter le nouvel établissement
                        withAnimation {
                            schoolVM.save()
                        }
                        dismiss()
                    }
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
        NavigationStack {
            EmptyView()
            SchoolCreatorModal()
        }
    }
}
