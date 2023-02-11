//
//  RoomLayoutEditor.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 22/10/2022.
//

import SwiftUI
import os
import Files
import HelpersView

private let customLog = Logger(subsystem : "com.michaud.lionel.Assistant-Professeur",
                               category  : "RoomLayoutEditor")

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
    private var isImportingPngFile = false

    @State
    private var alertItem: AlertItem?

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
                /// Positionner une nouvelle place au centre du plan de la salle de classe
                if room.nbSeatUnpositionned > 0 {
                    Button {
                        withAnimation {
                            _ = room.addSeatToPlan(x: 0.5, y: 0.5)
                        }
                    } label: {
                        Label("Positionner une place", systemImage: "chair")
                    }
                }
                /// Supprimer tous les positionnements de places dans la salle de classe (layout)
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
            .alert(item: $alertItem, content: newAlert)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button("OK") {
                        dismiss()
                    }
                }
                if room.planExists {
                    ToolbarItemGroup(placement: .automatic) {
                        Menu {
                            /// Suppression du plan de la salle de classe
                            Button(role: .destructive) {
                                isShowingDeletePlanConfirmDialog.toggle()
                            } label: {
                                Label("Supprimer le plan", systemImage: "trash")
                            }
                            /// Modification du plan de la salle de classe
                            Button(role: .destructive) {
                                isShowingChangePlanConfirmDialog.toggle()
                            } label: {
                                Text("Changer de plan")
                            }

                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                        /// Confirmation de Suppression du plan de la salle de classe
                        .confirmationDialog("Suppression du plan",
                                            isPresented: $isShowingDeletePlanConfirmDialog,
                                            titleVisibility : .visible) {
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
                        // TODO: - A tester
                        /// Confirmation de changement du plan de la salle de classe
                        .confirmationDialog("Changement du plan",
                                            isPresented: $isShowingChangePlanConfirmDialog,
                                            titleVisibility : .visible) {
                            Button("Changer", role: .destructive) {
                                isImportingPngFile.toggle()
                            }
                        } message: {
                            Text("Cette action supprimera le plan actuel de la salle de classe ainsi que toutes les places associées.\n") +
                            Text("Cette action ne supprimera pas la salle de classe elle-même.\n") +
                            Text("Cette action ne peut pas être annulée.")
                        }
                        /// Importer un fichier PNG
                        .fileImporter(isPresented             : $isImportingPngFile,
                                      allowedContentTypes     : [.png],
                                      allowsMultipleSelection : false) { result in
                            // supprimer le plan existant
                            withAnimation {
                                switch result {
                                    case .success:
                                        // Supprimer le plan
                                        room.deleteRoomPlan()

                                    case .failure:
                                        break
                                }

                                // pour le remplacer par celui qui vients d'être choisi
                                importRoomPlanFromFile(result: result)
                            }
                        }
                    }
                }
            }
    }

    // MARK: - Methods

    /// Importer le plan de la salle de classe à aprtir du fichier sélectionné par l'utilisateur
    /// - Parameter result: résultat de la sélection des fichiers issue de fileImporter.
    private func importRoomPlanFromFile(result: Result<[URL], Error>) {
        switch result {
            case .failure(let error):
                customLog.log(level: .fault,
                              "Error selecting file: \(error.localizedDescription)")
                alertTitle   = "Échec"
                alertMessage = "L'importation du fichier a échouée"
                alertIsPresented.toggle()

            case .success(let filesUrl):
                if let theFileURL = filesUrl.first {
                    // Si le fichier ne porte le bon nom, arrêter l'importation
                    guard theFileURL.pathComponents.last == room.fileName else {
                        customLog.log(level: .fault,
                                      "Le nom du fichier importé ne correspond pas au nom de la salle de classe.")
                        alertTitle   = "Échec"
                        alertMessage = "Le nom du fichier importé ne correspond pas au nom de la salle de classe."
                        alertIsPresented.toggle()
                        return
                    }

                    do {
                        guard let roomPlan = try ImportExportManager.loadUIImage(from: theFileURL) else {
                            customLog.log(level: .fault,
                                          "Le contenu de l'image n'est pas lisible.")
                            alertTitle   = "Échec"
                            alertMessage = "Le contenu de l'image n'est pas lisible."
                            alertIsPresented.toggle()
                            return
                        }
                        room.viewUIImage = roomPlan

                    } catch {
                        customLog.log(level: .fault,
                                      "L'importation du fichier a échouée.")
                        alertTitle   = "Échec"
                        alertMessage = "L'importation du fichier a échouée."
                        alertIsPresented.toggle()
                    }
                }
        }
    }
}

//struct RoomPlacement_Previews: PreviewProvider {
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
//}
