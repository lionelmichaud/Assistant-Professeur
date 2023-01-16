//
//  ObservDetail.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 23/04/2022.
//

import SwiftUI
import HelpersView

struct ObservDetail: View {
    @ObservedObject
    var observ: ObservEntity

    // MARK: - Computed properties

    var isConsigneeLabel: some View {
        Label(
            title: {
                Text("Notifiée aux parents")
            }, icon: {
                Image(systemName: observ.isConsignee ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(observ.isConsignee ? .green : .gray)
            }
        )
    }

    var isVerifiedLabel: some View {
        Label(
            title: {
                Text("Signature des parents vérifiée")
            }, icon: {
                Image(systemName: observ.isVerified ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(observ.isVerified ? .green : .gray)
            }
        )
    }

    var body: some View {
        VStack {
            // élève
            if let eleve = observ.eleve {
                GroupBox {
                    EleveLabelWithTrombineFlag(eleve      : eleve,
                                               isEditable : false)
                }
            }

            // observations
            List {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .sfSymbolStyling()
                        .foregroundColor(observ.color)
                    // date
                    DatePicker("Date", selection: $observ.viewDate)
                        .labelsHidden()
                        .listRowSeparator(.hidden)
                        .environment(\.locale, Locale.init(identifier: "fr_FR"))
                }

                // motif
                MotifEditor(motif: $observ.motifEnum,
                            description: $observ.viewDescriptionMotif)

                // checkbox isConsignee
                Button {
                    observ.toggleIsConsignee()
                } label: {
                    isConsigneeLabel
                }
                .buttonStyle(.plain)

                // checkbox isVerified
                Button {
                    observ.toggleIsVerified()
                } label: {
                    isVerifiedLabel
                }
                .buttonStyle(.plain)
            }
        }
        #if os(iOS)
        .navigationTitle("Observation")
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

//struct ObservDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        TestEnvir.createFakes()
//        return Group {
//            NavigationStack {
//                ObservDetail(observ: .constant(TestEnvir.observStore.items.first!))
//                    .environmentObject(NavigationModel(selectedObservId: TestEnvir.observStore.items.first!.id))
//                    .environmentObject(TestEnvir.schoolStore)
//                    .environmentObject(TestEnvir.classeStore)
//                    .environmentObject(TestEnvir.eleveStore)
//                    .environmentObject(TestEnvir.colleStore)
//                    .environmentObject(TestEnvir.observStore)
//            }
//            .previewDevice("iPad mini (6th generation)")
//
//            NavigationStack {
//                ObservDetail(observ: .constant(TestEnvir.observStore.items.first!))
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
