//
//  ObservCreator.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 23/04/2022.
//

import SwiftUI
import HelpersView

struct ObservCreatorModal: View {
    @ObservedObject
    var eleve: EleveEntity

    @StateObject
    private var observVM = ObservViewModel()

    @Environment(\.dismiss)
    private var dismiss

    // MARK: - Computed properties

    private var isConsigneeLabel: some View {
        Label(
            title: {
                Text("Notifiée aux parents")
            }, icon: {
                Image(systemName: observVM.isConsignee ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(observVM.isConsignee ? .green : .gray)
            }
        )
    }

    private var isVerifiedLabel: some View {
        Label(
            title: {
                Text("Signature des parents vérifiée")
            }, icon: {
                Image(systemName: observVM.isVerified ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(observVM.isVerified ? .green : .gray)
            }
        )
    }

    var body: some View {
        Form {
            HStack {
                Image(systemName: ObservEntity.defaultImageName)
                    .sfSymbolStyling()
                // date
                DatePicker("Date", selection: $observVM.date)
                    .labelsHidden()
                    .listRowSeparator(.hidden)
                    .environment(\.locale, Locale.init(identifier: "fr_FR"))
            }

            // motif
            MotifEditor(motif: $observVM.motifEnum,
                        description: $observVM.descriptionMotif)

            // checkbox isConsignee
            Button {
                observVM.isConsignee.toggle()
            } label: {
                isConsigneeLabel
            }
            .buttonStyle(.plain)

            // checkbox isVerified
            Button {
                observVM.isVerified.toggle()
            } label: {
                isVerifiedLabel
            }
            .buttonStyle(.plain)
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuler", role: .cancel) {
                    dismiss()
                }
            }
            ToolbarItem {
                Button("Ajouter") {
                    // Ajouter une nouvelle observation à l'élève
                    withAnimation {
                        observVM.createAndSaveEntity(pourEleve: eleve)
                    }
                    dismiss()
                }
            }
        }
        #if os(iOS)
        .navigationTitle("Nouvelle observation")
        #endif
    }
}

//struct ObservCreator_Previews: PreviewProvider {
//    static var previews: some View {
//        TestEnvir.createFakes()
//        return Group {
//            NavigationStack {
//                ObservCreatorModal(eleve: .constant(TestEnvir.eleveStore.items.first!))
//                    .environmentObject(NavigationModel())
//                    .environmentObject(TestEnvir.schoolStore)
//                    .environmentObject(TestEnvir.classeStore)
//                    .environmentObject(TestEnvir.eleveStore)
//                    .environmentObject(TestEnvir.colleStore)
//                    .environmentObject(TestEnvir.observStore)
//            }
//            .previewDevice("iPad mini (6th generation)")
//
//            NavigationStack {
//                ObservCreatorModal(eleve: .constant(TestEnvir.eleveStore.items.first!))
//                    .environmentObject(NavigationModel(selectedObservId: TestEnvir.observStore.items.first!.id))
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
