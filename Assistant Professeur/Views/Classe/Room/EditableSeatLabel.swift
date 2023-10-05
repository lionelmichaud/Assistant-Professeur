//
//  EditableSeatLabel.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 29/10/2022.
//

import SwiftUI

/// Positionnement d'un élève d'une classe sur une place assise de la salle de classe
struct EditableSeatLabel: View {
    @ObservedObject
    var classe: ClasseEntity

    @ObservedObject
    var seat: SeatEntity

    var viewGeometrySize: CGSize
    var imageSize: CGSize

    let fontWeight: Font.Weight = .semibold

    @EnvironmentObject
    private var navigationModel: NavigationModel

    @State
    private var isAddingNewObserv = false

    @State
    private var isAddingNewColle = false

    // MARK: - ComputedProperties

    private var unSeatedEleves: [EleveEntity] {
        classe.unseatedEleves()
    }

    private var eleveOnSeat: EleveEntity? {
        RoomSeatManager.eleve(from: classe, seatedOn: seat)
    }

    private var nameOfEleveOnSeat: String {
        eleveOnSeat?.givenName ?? "Associer"
    }

    /// Menu de placement d'un élève sur une place de la salle de classe
    private var seatMenu: some View {
        Group {
            if let eleveOnSeat {
                Section {
                    // aller à la fiche élève
                    Button {
                        // Programatic Navigation
                        navigationModel.selectedTab = .eleve
                        navigationModel.selectedEleveMngObjId = eleveOnSeat.objectID
                    } label: {
                        Label(
                            "Fiche élève",
                            systemImage: "info.circle"
                        )
                    }
                    // ajouter un point de bonus
                    Button {
                        eleveOnSeat.viewBonus += 1
                    } label: {
                        Label(
                            "Ajouter bonus",
                            systemImage: "hand.thumbsup"
                        )
                    }
                    // ajouter un point de malus
                    Button {
                        eleveOnSeat.viewBonus -= 1
                    } label: {
                        Label(
                            "Ajouter malus",
                            systemImage: "hand.thumbsdown"
                        )
                    }

                    // ajouter une observation
                    Button {
                        isAddingNewObserv = true
                    } label: {
                        Label(
                            "Nouvelle observation",
                            systemImage: ObservEntity.defaultImageName
                        )
                    }
                    // ajouter une colle
                    Button {
                        isAddingNewColle = true
                    } label: {
                        Label(
                            "Nouvelle colle",
                            systemImage: "lock.fill"
                        )
                    }
                }

                Section {
                    // enlever l'élève qui était assis à cette place
                    Button(role: .destructive) {
                        withAnimation {
                            // enlever l'élève qui était assis à cette place
                            eleveOnSeat.seat = nil
                            try? EleveEntity.saveIfContextHasChanged()
                        }
                    } label: {
                        Label(
                            "Libérer la place",
                            systemImage: "chair"
                        )
                    }
                }
            }

            Section {
                ForEach(unSeatedEleves, id: \.objectID) { eleve in
                    Button(eleve.displayName) {
                        withAnimation {
                            // enlever l'élève qui était assis à cette place
                            eleveOnSeat?.seat = nil
                            // pour y mettre cet élève là
                            eleve.seat = seat
                            try? EleveEntity.saveIfContextHasChanged()
                        }
                    }
                }
            }
        }
    }

    var body: some View {
        SeatLabel(
            label: nameOfEleveOnSeat,
            backgoundColor: eleveOnSeat == nil ? .pink : .blue
        )
        .contextMenu {
            seatMenu
        } preview: {
            if let eleveOnSeat {
                // Photo de l'élève
                TrombineView(eleve: eleveOnSeat)
                // Nom de l'élève
                EleveTextName(
                    eleve: eleveOnSeat,
                    fontWeight: fontWeight
                )
                .multilineTextAlignment(.center)
            } else {
                Image(systemName: "questionmark.app.dashed")
                    .resizable()
                    .scaledToFit()
                    .frame(minWidth: 75, minHeight: 75)
            }
        }
        .offset(posInView(
            relativePos: seat.locInRoom,
            geometrySize: viewGeometrySize,
            imageSize: imageSize
        )
        )
        .sheet(isPresented: $isAddingNewObserv) {
            NavigationStack {
                ObservCreatorModal(eleve: eleveOnSeat!)
                    .presentationDetents([.medium])
            }
        }
        .sheet(isPresented: $isAddingNewColle) {
            NavigationStack {
                ColleCreatorModal(eleve: eleveOnSeat!)
            }
            .presentationDetents([.medium])
        }
    }

    // MARK: - Methods

    /// Convertit la position de l'objet situé à une position relative (%) `relativePos` à l'intérieur de l'image de taille `imageSize`
    /// dans une position absolue en pixels dans la vue définie par `geometrySize`.
    /// - Parameters:
    ///   - relativePos: position relative (%) de l'objet dans l'image de taille `imageSize`
    ///   - geometrySize: taille de la vue contenant l'image (alignée .topLeading)
    ///   - imageSize: taille de l'image dans laquelle se situe l'objet
    /// - Returns: position absolue en pixels de l'objet dans la vue définie par `geometrySize`
    private func posInView(
        relativePos: CGPoint,
        geometrySize: CGSize,
        imageSize: CGSize
    ) -> CGSize {
        let imageSizeRatio = imageSize.width / imageSize.height
        let geometrySizeRatio = geometrySize.width / geometrySize.height

        if imageSizeRatio >= geometrySizeRatio {
            return CGSize(
                width: relativePos.x * geometrySize.width,
                height: relativePos.y * (geometrySize.width * imageSize.height / imageSize.width)
            )
        } else {
            return CGSize(
                width: relativePos.x * (geometrySize.height * imageSize.width / imageSize.height),
                height: relativePos.y * geometrySize.height
            )
        }
    }
}

// struct EditablePlaceLabel_Previews: PreviewProvider {
//    static var previews: some View {
//        EditableSeatLabel()
//    }
// }
