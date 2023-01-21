//
//  ProgramViewModel.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 21/01/2023.
//

import Foundation

class ProgramViewModel: ObservableObject {

    // MARK: - Properties

    @Published var disciplineEnum : Discipline  = .technologie
    @Published var levelEnum      : LevelClasse = .n6ieme
    @Published var segpa          : Bool        = false
    @Published var annotation     : String      = ""

    // MARK: - Initializers
    internal init(
        disciplineEnum : Discipline  = .technologie,
        levelEnum      : LevelClasse = .n6ieme,
        segpa          : Bool        = false,
        annotation     : String      = ""
    ) {
        self.disciplineEnum = disciplineEnum
        self.levelEnum      = levelEnum
        self.segpa          = segpa
        self.annotation     = annotation
    }

    convenience init(from program: ProgramEntity) {
        self.init()
        self.update(from: program)
    }

    // MARK: - Methods

    func update(from program: ProgramEntity) {
        self.disciplineEnum = program.disciplineEnum
        self.levelEnum      = program.levelEnum
        self.segpa          = program.segpa
        self.annotation     = program.viewAnnotation
    }

    /// Créer une entité `ProgramEntity` à partir du VM et
    /// sauvegarder le viewContext.
    ///
    /// Crée un Groupe 0 pour les élèves de la classe n'appartenant à aucun groupe
    func createAndSaveEntity() {
        ProgramEntity.create(
            discipline   : disciplineEnum,
            level        : levelEnum,
            segpa        : segpa,
            annotation   : annotation
        )
    }

}
