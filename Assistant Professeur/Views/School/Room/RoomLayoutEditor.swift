//
//  RoomLayoutEditor.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 22/10/2022.
//

import Files
import HelpersView
import os
import SwiftUI

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "RoomLayoutEditor"
)

struct RoomLayoutEditor: View {
    @ObservedObject
    var room: RoomEntity

    @Environment(\.dismiss)
    private var dismiss

    @Environment(\.horizontalSizeClass)
    private var hClass

    @State
    private var alertTitle = ""

    @State
    private var alertMessage = ""

    @State
    private var alertIsPresented = false

    @State
    private var isShowingDeletePlanConfirmDialog: Bool = false

    @State
    private var isShowingChangePlanConfirmDialog: Bool = false

    @State
    private var isImportingImageFile = false

    // MARK: - Computed Properties

    private var title: String {
        if hClass == .regular {
            return "Places: positionnées \(room.nbSeatPositionned) - non positionnées: \(room.nbSeatUnpositionned)"
        } else {
            return "Places non positionnées: \(room.nbSeatUnpositionned)"
        }
    }

    var body: some View {
        RoomPlanEditView(room: room)
        #if os(iOS)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
        #endif
            .toolbarTitleMenu {
                // Positionner une nouvelle place au centre du plan de la salle de classe
                if room.nbSeatUnpositionned > 0 {
                    Button {
                        withAnimation {
                            _ = room.addSeatToPlan(x: 0.5, y: 0.5)
                        }
                    } label: {
                        Label("Positionner une place", systemImage: "chair")
                    }
                }
                // Supprimer tous les positionnements de places dans la salle de classe (layout)
                if room.nbSeatPositionned > 0 {
                    Button(role: .destructive) {
                        withAnimation {
                            // Supprime le plan de salle de classe `room`.
                            // Tous les sièges seront libérés des élèves assis dessus dans l'ensemble des classes.
                            room.removeAllSeatsFromPlan()
                        }
                    } label: {
                        Label("Effacer toutes les places", systemImage: "trash.fill")
                    }
                }
            }
            .alert(
                alertTitle,
                isPresented: $alertIsPresented,
                actions: {},
                message: { Text(alertMessage) }
            )
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button("OK") {
                        dismiss()
                    }
                }
                if room.planExists {
                    ToolbarItemGroup(placement: .automatic) {
                        Menu {
                            // Suppression du plan de la salle de classe
                            Button(role: .destructive) {
                                isShowingDeletePlanConfirmDialog.toggle()
                            } label: {
                                Label("Supprimer le plan", systemImage: "trash")
                            }
                            // Modification du plan de la salle de classe
                            Button(role: .destructive) {
                                isShowingChangePlanConfirmDialog.toggle()
                            } label: {
                                Text("Changer de plan")
                            }

                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                        // Confirmation de Suppression du plan de la salle de classe
                        .confirmationDialog(
                            "Suppression du plan",
                            isPresented: $isShowingDeletePlanConfirmDialog,
                            titleVisibility: .visible
                        ) {
                            Button("Supprimer", role: .destructive) {
                                withAnimation {
                                    room.deleteRoomPlan()
                                }
                            }
                        } message: {
                            Text("Cette action supprimera le plan de la salle de classe ainsi que toutes les places associées.\n") +
                                Text("Cette action ne supprimera pas la salle de classe elle-même.\n") +
                                Text("Cette action ne peut pas être annulée.")
                        }
                        // Confirmation de changement du plan de la salle de classe
                        .confirmationDialog(
                            "Changement du plan",
                            isPresented: $isShowingChangePlanConfirmDialog,
                            titleVisibility: .visible
                        ) {
                            Button("Changer", role: .destructive) {
                                isImportingImageFile.toggle()
                            }
                        } message: {
                            Text("Cette action supprimera le plan actuel de la salle de classe ainsi que toutes les places associées.\n") +
                                Text("Cette action ne supprimera pas la salle de classe elle-même.\n") +
                                Text("Cette action ne peut pas être annulée.")
                        }
                        // Importer un fichier PNG ou JPEG
                        .fileImporter(
                            isPresented: $isImportingImageFile,
                            allowedContentTypes: [.png, .jpeg],
                            allowsMultipleSelection: false
                        ) { result in
                            withAnimation {
                                if case .success = result {
                                    // Supprimer le plan
                                    room.deleteRoomPlan()
                                }

                                // pour le remplacer par celui qui vients d'être choisi
                                var image: UIImage?
                                (
                                    image,
                                    alertTitle,
                                    alertMessage,
                                    alertIsPresented
                                ) = ImportExportManager.importImage(result: result)
                                if let image {
                                    room.viewUIImage = image
                                }
                            }
                        }
                    }
                }
            }
    }
}

// struct RoomPlacement_Previews: PreviewProvider {
//    static var room: Room = {
//        var r = Room(name: "TECHNO-2", capacity: 12)
//        r.addSeatToPlan(Seat(x: 0.0, y: 0.0))
//        r.addSeatToPlan(Seat(x: 0.25, y: 0.25))
//        r.addSeatToPlan(Seat(x: 0.5, y: 0.5))
//        r.addSeatToPlan(Seat(x: 0.75, y: 0.75))
//        r.addSeatToPlan(Seat(x: 0.98, y: 0.98))
//        return r
//    }()
//    static var previews: some View {
//        TestEnvir.createFakes()
//        return Group {
//            NavigationStack {
//                RoomEditor(room: .constant(room),
//                           school: TestEnvir.schoolStore.items.first!)
//                .environmentObject(NavigationModel(selectedClasseId: TestEnvir.classeStore.items.first!.id))
//                .environmentObject(TestEnvir.schoolStore)
//                .environmentObject(TestEnvir.classeStore)
//                .environmentObject(TestEnvir.eleveStore)
//                .environmentObject(TestEnvir.colleStore)
//                .environmentObject(TestEnvir.observStore)
//            }
//            .previewDevice("iPad mini (6th generation)")
//
//            NavigationStack {
//                RoomEditor(room: .constant(Room(name: "TECHNO-2",
//                                                capacity: 12)),
//                           school: TestEnvir.schoolStore.items.first!)
//                .environmentObject(NavigationModel(selectedClasseId: TestEnvir.classeStore.items.first!.id))
//                .environmentObject(TestEnvir.schoolStore)
//                .environmentObject(TestEnvir.classeStore)
//                .environmentObject(TestEnvir.eleveStore)
//                .environmentObject(TestEnvir.colleStore)
//                .environmentObject(TestEnvir.observStore)
//            }
//            .previewDevice("iPhone 13")
//        }
//    }
// }
