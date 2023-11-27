//
//  ProgramViewModel.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 21/01/2023.
//

import Foundation

@Observable final class ProgramViewModel {

    // MARK: - Properties

    var disciplineEnum : Discipline 
    var levelEnum      : LevelClasse
    var segpa          : Bool       
    var annotation     : String     
    var url            : URL?

    // MARK: - Initializers
    internal init(
        disciplineEnum : Discipline  = .technologie,
        levelEnum      : LevelClasse = .n6ieme,
        segpa          : Bool        = false,
        annotation     : String      = "",
        url            : URL?        = nil
    ) {
        self.disciplineEnum = disciplineEnum
        self.levelEnum      = levelEnum
        self.segpa          = segpa
        self.annotation     = annotation
        self.url            = url
    }

    convenience init(from program: ProgramEntity) {
        self.init()
        self.update(from: program)
    }

    // MARK: - Methods

    func update(from program: ProgramEntity) {
        self.disciplineEnum = program.viewDisciplineEnum
        self.levelEnum      = program.viewLevelEnum
        self.segpa          = program.segpa
        self.annotation     = program.viewAnnotation
        self.url            = program.url
    }

    /// Créer une entité `ProgramEntity` à partir du VM et
    ///
    /// Crée un Groupe 0 pour les élèves de la classe n'appartenant à aucun groupe
    /// - Important: Saves the context
    func createAndSaveEntity() {
        ProgramEntity.create(
            discipline   : disciplineEnum,
            level        : levelEnum,
            segpa        : segpa,
            annotation   : annotation,
            url          : url
        )
    }

}
