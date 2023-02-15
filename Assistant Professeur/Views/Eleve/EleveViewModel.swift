//
//  EleveViewModel.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 23/12/2022.
//

import Foundation

class EleveViewModel: ObservableObject {

    // MARK: - Properties

    @Published var sexEnum      : Sexe   = .male
    @Published var familyName   : String = ""
    @Published var givenName    : String = ""
    @Published var isFlagged    : Bool   = false
    @Published var annotation   : String = ""
    @Published var appreciation : String = ""
    @Published var bonus        : Int    = 0

    // MARK: - Initializers

    internal init(
        sexEnum      : Sexe   = .male,
        familyName   : String = "",
        givenName    : String = "",
        isFlagged    : Bool   = false,
        annotation   : String = "",
        appreciation : String = "",
        bonus        : Int    = 0
    ) {
        self.sexEnum      = sexEnum
        self.familyName   = familyName
        self.givenName    = givenName
        self.isFlagged    = isFlagged
        self.annotation   = annotation
        self.appreciation = appreciation
        self.bonus        = bonus
    }

    convenience init(from eleve: EleveEntity) {
        self.init()
        self.update(from: eleve)
    }

    // MARK: - Methods

    func update(from eleve: EleveEntity) {
        self.sexEnum      = eleve.sexEnum
        self.familyName   = eleve.viewFamilyName
        self.givenName    = eleve.viewGivenName
        self.isFlagged    = eleve.isFlagged
        self.annotation   = eleve.viewAnnotation
        self.appreciation = eleve.viewAppreciation
        self.bonus        = Int(eleve.bonus)
    }

    func save(_ inClasse: ClasseEntity) {
        let eleve = EleveEntity.create()

        // classe d'appartenance.
        // mandatory
        eleve.classe = inClasse

        // groupe d'appartenance.
        // mandatory
        eleve.group = inClasse.groupOfUngroupedEleves

        eleve.setSex(sexEnum)
        eleve.familyName   = familyName
        eleve.givenName    = givenName
        eleve.isFlagged    = isFlagged
        eleve.annotation   = annotation
        eleve.appreciation = appreciation
        eleve.bonus        = Int16(bonus)

        // ajouter une note pour chaque évaluation de la classe
        inClasse.allExams.forEach { exam in
            MarkEntity.create(pourEleve: eleve, pourExam: exam)
        }

        try? EleveEntity.saveIfContextHasChanged()
    }
}
