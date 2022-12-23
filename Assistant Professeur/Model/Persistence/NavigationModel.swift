/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A navigation model used to persist and restore the navigation state.
*/

import SwiftUI
import Combine
import CoreData

@MainActor
final class NavigationModel: ObservableObject, Codable {
    enum Tab: Int, Hashable, Codable {
        case userSettings, school, classe, eleve, colle, observation
    }
    @Published var columnVisibility  : NavigationSplitViewVisibility
    @Published var selectedTab       : Tab
//    @Published var selectedObservId  : Observation.ID?
//    @Published var selectedColleId   : Colle.ID?
    @Published var selectedEleveId   : NSManagedObjectID?
    @Published var selectedClasseId  : NSManagedObjectID?
    @Published var selectedSchoolId  : NSManagedObjectID?
    @Published var filterObservation : Bool
    @Published var filterColle       : Bool
    @Published var filterFlag        : Bool

    private lazy var decoder = JSONDecoder()
    private lazy var encoder = JSONEncoder()

    init(columnVisibility  : NavigationSplitViewVisibility = .doubleColumn,
         selectedTab       : Tab              = .school,
//         selectedObservId  : Observation.ID?  = nil,
//         selectedColleId   : Colle.ID?        = nil,
         selectedEleveId   : NSManagedObjectID? = nil,
         selectedClasseId  : NSManagedObjectID? = nil,
         selectedSchoolId  : NSManagedObjectID? = nil,
         filterObservation : Bool              = false,
         filterColle       : Bool              = false,
         filterFlag        : Bool              = false
    ) {
        self.columnVisibility  = columnVisibility
        self.selectedTab       = selectedTab
//        self.selectedObservId  = selectedObservId
//        self.selectedColleId   = selectedColleId
        self.selectedEleveId   = selectedEleveId
        self.selectedClasseId  = selectedClasseId
        self.selectedSchoolId  = selectedSchoolId
        self.filterObservation = filterObservation
        self.filterColle       = filterColle
        self.filterFlag        = filterFlag
    }

    var jsonData: Data? {
        get { try? encoder.encode(self) }
        set {
            guard let data = newValue,
                  let model = try? decoder.decode(Self.self, from: data)
            else { return }
            columnVisibility  = model.columnVisibility
            selectedTab       = model.selectedTab
//            selectedObservId  = model.selectedObservId
//            selectedColleId   = model.selectedColleId
            selectedEleveId   = model.selectedEleveId
            selectedClasseId  = model.selectedClasseId
            selectedSchoolId  = model.selectedSchoolId
            filterObservation = model.filterObservation
            filterColle       = model.filterColle
            filterFlag        = model.filterFlag
        }
    }

    var objectWillChangeSequence: AsyncPublisher<Publishers.Buffer<ObservableObjectPublisher>> {
        objectWillChange
            .buffer(size: 1, prefetch: .byRequest, whenFull: .dropOldest)
            .values
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.selectedTab = try container.decode(
            NavigationModel.Tab.self, forKey: .selectedTab)

//        self.selectedObservId = try container.decodeIfPresent(
//            Observation.ID.self, forKey: .selectedObservId)
//
//        self.selectedColleId = try container.decodeIfPresent(
//            Colle.ID.self, forKey: .selectedColleId)
//
//        self.selectedEleveId = try container.decodeIfPresent(
//            Eleve.ID.self, forKey: .selectedEleveId)
//
//        self.selectedClasseId = try container.decodeIfPresent(
//            Classe.ID.self, forKey: .selectedClasseId)
//
//        self.selectedSchoolId = try container.decodeIfPresent(
//            SchoolEntity.ID.self, forKey: .selectedSchoolId)

        self.filterObservation = try container.decode(
            Bool.self, forKey: .filterObservation)

        self.filterColle = try container.decode(
            Bool.self, forKey: .filterColle)

        self.filterFlag = try container.decode(
            Bool.self, forKey: .filterFlag)

        self.columnVisibility = try container.decode(
            NavigationSplitViewVisibility.self, forKey: .columnVisibility)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(selectedTab, forKey: .selectedTab)
//        try container.encodeIfPresent(selectedObservId, forKey: .selectedObservId)
//        try container.encodeIfPresent(selectedColleId,  forKey: .selectedColleId)
//        try container.encodeIfPresent(selectedEleveId,  forKey: .selectedEleveId)
//        try container.encodeIfPresent(selectedClasseId, forKey: .selectedClasseId)
//        try container.encodeIfPresent(selectedSchoolId, forKey: .selectedSchoolId)
        try container.encode(filterObservation, forKey: .filterObservation)
        try container.encode(filterColle, forKey: .filterColle)
        try container.encode(filterFlag, forKey: .filterFlag)
        try container.encode(columnVisibility, forKey: .columnVisibility)
    }

    enum CodingKeys: String, CodingKey {
        case columnVisibility
        case selectedTab
//        case selectedObservId
//        case selectedColleId
        case selectedEleveId
        case selectedClasseId
        case selectedSchoolId
        case filterObservation
        case filterColle
        case filterFlag
    }
}
