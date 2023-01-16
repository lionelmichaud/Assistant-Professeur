//
//  ClasseViewModel.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 20/12/2022.
//

import Foundation

class ClasseViewModel: ObservableObject {

    // MARK: - Properties

    @Published var levelEnum      : LevelClasse = .n6ieme
    @Published var numero         : Int         = 1
    @Published var segpa          : Bool        = false
    @Published var disciplineEnum : Discipline  = .technologie
    @Published var heures         : Double      = 0.0
    @Published var isFlagged      : Bool        = false
    @Published var annotation     : String      = ""
    @Published var appreciation   : String      = ""

    // MARK: - Initializers

    internal init(
        levelEnum      : LevelClasse = .n6ieme,
        numero         : Int         = 1,
        segpa          : Bool        = false,
        disciplineEnum : Discipline  = .technologie,
        heures         : Double      = 0.0,
        isFlagged      : Bool        = false,
        annotation     : String      = "",
        appreciation   : String      = ""
    ) {
        self.levelEnum      = levelEnum
        self.numero         = numero
        self.segpa          = segpa
        self.disciplineEnum = disciplineEnum
        self.heures         = heures
        self.isFlagged      = isFlagged
        self.annotation     = annotation
        self.appreciation   = appreciation
    }

    convenience init(from classe: ClasseEntity) {
        self.init()
        self.update(from: classe)
    }

    // MARK: - Methods

    func update(from classe: ClasseEntity) {
        self.levelEnum      = classe.levelEnum
        self.numero         = Int(classe.numero)
        self.segpa          = classe.segpa
        self.disciplineEnum = classe.disciplineEnum
        self.heures         = classe.heures
        self.isFlagged      = classe.isFlagged
        self.annotation     = classe.viewAnnotation
        self.appreciation   = classe.viewAppreciation
    }

    /// Créer une entité `ClasseEntity` à partir du VM et
    /// sauvegarder le veiwContext.
    ///
    /// Crée un Groupe 0 pour les élèves de la classe n'appartenant à aucun groupe
    func createAndSaveEntity(_ inSchool: SchoolEntity) {
        ClasseEntity.create(
            level        : levelEnum,
            numero       : numero,
            segpa        : segpa,
            discipline   : disciplineEnum,
            heures       : heures,
            isFlagged    : isFlagged,
            annotation   : annotation,
            appreciation : appreciation,
            dans         : inSchool
        )
    }
}
