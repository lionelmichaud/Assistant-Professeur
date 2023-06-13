//
//  FileOperationTypes.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 04/06/2023.
//

import Foundation
import UniformTypeIdentifiers

enum FileImportOperation {
    case importTrombines
    case importModel
    case none

    var allowedContentTypes: [UTType] {
        switch self {
            case .importTrombines: return [.jpeg]
            case .importModel: return [.json, .pdf, .png, .jpeg]
            case .none: return []
        }
    }
}

enum FileExportOperation {
    case exportJsonModel(annexFileNames: [String])
    case exportCsvEleveList
    case exportCsvPrograms
    case exportCsvCompetencies
    case none

    /// Liste de toutes les URL des fichiers à exporter
    var urls: [URL] {
        switch self {
            case let .exportJsonModel(annexFileNames):
                return ImportExportManager.cachesURLsToShare(
                    fileNames: [
                        JsonImportExportMng.ownerFileName,
                        JsonImportExportMng.schoolsFileName,
                        JsonImportExportMng.programsFileName,
                        JsonImportExportMng.wCompetenciesFileName,
                        JsonImportExportMng.dCompetenciesFileName
                    ] + annexFileNames
                )

            case .exportCsvEleveList:
                return ImportExportManager.cachesURLsToShare(
                    fileNames: [
                        CsvImportExportMng.csvEleveListFileName
                    ]
                )

            case .exportCsvPrograms:
                return ImportExportManager.cachesURLsToShare(
                    fileNames: [
                        CsvImportExportMng.csvProgramListFileName
                    ]
                )

            case .exportCsvCompetencies:
                return ImportExportManager.cachesURLsToShare(
                    fileNames: [
                        CsvImportExportMng.csvCompetencyListFileName
                    ]
                )

            case .none: return []
        }
    }
}
