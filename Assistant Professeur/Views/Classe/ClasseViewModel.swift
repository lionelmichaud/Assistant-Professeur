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

    /// Créer une entité School à partir du VM et
    /// sauvegarder le veiwContext.
    ///
    /// Crée un Groupe 0 pour les élèves de la classe n'appartenant à aucun groupe
    /// - Parameter inSchool: <#inSchool description#>
    func createAndSaveEntity(_ inSchool: SchoolEntity) {
        let classe = ClasseEntity.create()
        // établissement d'appartenance.
        // mandatory
        classe.school = inSchool

        // créer un Groupe 0 pour les élèves de la classe
        // n'appartenant à aucun groupe.
        // mandatory
        let group0 = GroupEntity.create()
        group0.number = 0
        group0.classe = classe

        classe.setLevel(levelEnum)
        classe.numero         = Int32(numero)
        classe.segpa          = segpa
        classe.setDiscipline(disciplineEnum)
        classe.heures         = heures
        classe.isFlagged      = isFlagged
        classe.annotation     = annotation
        classe.appreciation   = appreciation

        try? ClasseEntity.saveIfContextHasChanged()
    }
}
