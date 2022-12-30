//
//  ColleEditor.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 23/04/2022.
//

import SwiftUI
import HelpersView

struct ColleCreatorModal: View {
    @ObservedObject
    var eleve: EleveEntity

    @StateObject
    private var colleVM = ColleViewModel()

    @Environment(\.dismiss)
    private var dismiss

    // MARK: - Computed properties

    var isConsigneeLabel: some View {
        Label(
            title: {
                Text("Notifiée aux parents")
            }, icon: {
                Image(systemName: colleVM.isConsignee ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(colleVM.isConsignee ? .green : .gray)
            }
        )
    }

    var isVerifiedLabel: some View {
        Label(
            title: {
                Text("Signature des parents vérifiée")
            }, icon: {
                Image(systemName: colleVM.isVerified ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(colleVM.isVerified ? .green : .gray)
            }
        )
    }

    var body: some View {
        Form {
            HStack {
                Image(systemName: "lock")
                    .sfSymbolStyling()
                // date
                DatePicker("Date", selection: $colleVM.date)
                    .labelsHidden()
                    .listRowSeparator(.hidden)
                    .environment(\.locale, Locale.init(identifier: "fr_FR"))
            }

            // motif
            MotifEditor(motif: $colleVM.motifEnum,
                        description: $colleVM.descriptionMotif)

            // Durée
            HStack {
                Stepper("Durée",
                        value : $colleVM.duree,
                        in    : 1 ... 4,
                        step  : 1)
                Text("\(colleVM.duree) heures")
            }

            // checkbox isConsignee
            Button {
                colleVM.isConsignee.toggle()
            } label: {
                isConsigneeLabel
            }
            .buttonStyle(.plain)

            // checkbox isVerified
            Button {
                colleVM.isVerified.toggle()
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
                        colleVM.save(pourEleve: eleve)
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

//struct ColleCreator_Previews: PreviewProvider {
//    static var previews: some View {
//        TestEnvir.createFakes()
//        return Group {
//            NavigationStack {
//                ColleCreator(eleve: .constant(TestEnvir.eleveStore.items.first!))
//                    .environmentObject(NavigationModel(selectedColleId: TestEnvir.eleveStore.items.first!.id))
//                    .environmentObject(TestEnvir.schoolStore)
//                    .environmentObject(TestEnvir.classeStore)
//                    .environmentObject(TestEnvir.eleveStore)
//                    .environmentObject(TestEnvir.colleStore)
//                    .environmentObject(TestEnvir.observStore)
//            }
//            .previewDevice("iPad mini (6th generation)")
//
//            NavigationStack {
//                ColleCreator(eleve: .constant(TestEnvir.eleveStore.items.first!))
//                    .environmentObject(NavigationModel(selectedColleId: TestEnvir.eleveStore.items.first!.id))
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
