//
//  RoomPlan.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 23/10/2022.
//

import SwiftUI
import os
import HelpersView

private let customLog = Logger(subsystem : "com.michaud.lionel.Cahier-du-Professeur",
                               category  : "RoomPlanEditView")

public func + (lhs: CGSize, rhs: CGSize) -> CGSize {
    return CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
}

struct RoomPlanEditView: View {
    @ObservedObject
    var room: RoomEntity

    @State
    private var alertTitle = ""

    @State
    private var alertMessage = ""

    @State
    private var alertIsPresented = false

    @State
    private var showLongPressMenu = false

    @State
    private var isImportingPngFile = false

    @State
    private var alertItem: AlertItem?

    // MARK: - Computd Properties

    private var imageSize: CGSize? {
        room.imageSize
    }

    var body: some View {
        if let imageSize {
            ZStack(alignment: .topLeading) {
                GeometryReader { viewGeometry in
                    /// Image du plan de la salle
                    room.viewImage
                        .resizable()
                        .elevTrombineStyling()

                    /// Symboles des places des élèves dans la salle
                    if room.nbSeatPositionned > 0 {
                        ForEach(room.allSeats, id:\.objectID) { seat in
                            DraggableSeatLabel(
                                seat             : seat,
                                viewGeometrySize : viewGeometry.size,
                                imageSize        : imageSize
                            )
                        }
                    }
                }
            }
        } else {
            VStack {
                Text("Pas de plan disponible pour la salle \"\(room.viewName)\"")
                    .padding()

                /// Télécharger un plan au format PNG
                Button {
                    isImportingPngFile.toggle()
                } label: {
                    Label("Importer un plan au format 'PNG' et nommé '\(room.fileName)'",
                          systemImage: "square.and.arrow.down")
                }
                /// Importer un fichier PNG
                .fileImporter(isPresented             : $isImportingPngFile,
                              allowedContentTypes     : [.png],
                              allowsMultipleSelection : false) { result in
                    // TODO: - renommer le fichier si le nom du fichier importé n'est pas le bon
                    importRoomPlanFromFile(result: result)
                }
                .alert(item: $alertItem, content: newAlert)
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

//struct RoomPlan_Previews: PreviewProvider {
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
//                RoomPlanEditView(room  : .constant(room),
//                                 school: TestEnvir.schoolStore.items.first!)
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
//                RoomPlanEditView(room  : .constant(room),
//                                 school: TestEnvir.schoolStore.items.first!)
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
