//
//  JsonImportExportMng.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 14/02/2023.
//

import Foundation

/// Export/Import vers/depuis des fichiers JSON
enum JsonImportExportMng { // swiftlint:disable:this type_body_length
    static let ownerFileName = String(describing: OwnerEntity.self) + ".json"
    static let schoolsFileName = String(describing: SchoolEntity.self) + ".json"
    static let programsFileName = String(describing: ProgramEntity.self) + ".json"
    static let wCompetenciesFileName = String(describing: WCompChapterEntity.self) + ".json"
    static let dCompetenciesFileName = String(describing: DThemeEntity.self) + ".json"
}
