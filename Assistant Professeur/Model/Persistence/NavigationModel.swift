/*
 See LICENSE folder for this sample’s licensing information.

 Abstract:
 A navigation model used to persist and restore the navigation state.
 */

import Combine
import CoreData
import SwiftUI

/// @MainActor
final class NavigationModel: ObservableObject, Codable {
    // MARK: - Embeded Types

    enum Tab: Int, Hashable, Codable {
        case userSettings, school, classe, eleve, warning, program, competence
    }

    enum WarningSelection: String, Hashable, Codable, CaseIterable {
        case observation = "Observations"
        case colle = "Colles"

        var imageName: String {
            switch self {
                case .observation:
                    return "rectangle.and.text.magnifyingglass"
                case .colle:
                    return "lock"
            }
        }
    }

    enum CodingKeys: String, CodingKey {
        case columnVisibility
        case selectedTab
        case selectedWarningType
        case selectedProgramId
        case selectedObservId
        case selectedColleId
        case selectedEleveId
        case selectedClasseId
        case selectedSchoolId
        case filterObservation
        case filterColle
        case filterFlag
    }

    // MARK: - Properties

    @Published
    var columnVisibility: NavigationSplitViewVisibility
    @Published
    var selectedTab: Tab
    @Published
    var selectedWarningType: WarningSelection?
    @Published
    var programPath = NavigationPath()
    /// TODO: - Trouver une autre solution
    @Published
    var selectedProgramId: NSManagedObjectID?
    @Published
    var selectedSequenceId: NSManagedObjectID?
    @Published
    var selectedActivityId: NSManagedObjectID?
    @Published
    var selectedObservId: NSManagedObjectID?
    @Published
    var selectedColleId: NSManagedObjectID?
    @Published
    var selectedEleveId: NSManagedObjectID?
    @Published
    var selectedClasseId: NSManagedObjectID?
    @Published
    var selectedSchoolId: NSManagedObjectID?

    @Published
    var filterObservation: Bool
    @Published
    var filterColle: Bool
    @Published
    var filterFlag: Bool

    private lazy var decoder = JSONDecoder()
    private lazy var encoder = JSONEncoder()

    // MARK: - Computed Properties

    var jsonData: Data? {
        get { try? encoder.encode(self) }
        set {
            guard let data = newValue,
                  let model = try? decoder.decode(Self.self, from: data)
            else {
                return
            }
            columnVisibility = model.columnVisibility
            selectedProgramId = model.selectedProgramId
            selectedSequenceId = model.selectedSequenceId
            selectedActivityId = model.selectedActivityId
            selectedTab = model.selectedTab
            selectedWarningType = model.selectedWarningType
            selectedObservId = model.selectedObservId
            selectedColleId = model.selectedColleId
            selectedEleveId = model.selectedEleveId
            selectedClasseId = model.selectedClasseId
            selectedSchoolId = model.selectedSchoolId
            filterObservation = model.filterObservation
            filterColle = model.filterColle
            filterFlag = model.filterFlag
        }
    }

    var objectWillChangeSequence: AsyncPublisher<Publishers.Buffer<ObservableObjectPublisher>> {
        objectWillChange
            .buffer(size: 1, prefetch: .byRequest, whenFull: .dropOldest)
            .values
    }

    // MARK: - Initializers

    init(
        columnVisibility: NavigationSplitViewVisibility = .all,
        selectedTab: Tab = .school,
        selectedWarningType: WarningSelection = .observation,
        selectedProgramId: NSManagedObjectID? = nil,
        selectedSequenceId: NSManagedObjectID? = nil,
        selectedActivityId: NSManagedObjectID? = nil,
        selectedObservId: NSManagedObjectID? = nil,
        selectedColleId: NSManagedObjectID? = nil,
        selectedEleveId: NSManagedObjectID? = nil,
        selectedClasseId: NSManagedObjectID? = nil,
        selectedSchoolId: NSManagedObjectID? = nil,
        filterObservation: Bool = false,
        filterColle: Bool = false,
        filterFlag: Bool = false
    ) {
        #if DEBUG
            print("NavigationModel() initialization has started")
        #endif
        self.columnVisibility = columnVisibility
        self.selectedTab = selectedTab
        self.selectedWarningType = selectedWarningType
        self.selectedProgramId = selectedProgramId
        self.selectedSequenceId = selectedSequenceId
        self.selectedActivityId = selectedActivityId
        self.selectedObservId = selectedObservId
        self.selectedColleId = selectedColleId
        self.selectedEleveId = selectedEleveId
        self.selectedClasseId = selectedClasseId
        self.selectedSchoolId = selectedSchoolId
        self.filterObservation = filterObservation
        self.filterColle = filterColle
        self.filterFlag = filterFlag
        #if DEBUG
            print("NavigationModel() initialization has completed")
        #endif
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.selectedTab = try container.decode(
            NavigationModel.Tab.self, forKey: .selectedTab
        )
        self.selectedWarningType = try container.decodeIfPresent(
            NavigationModel.WarningSelection.self, forKey: .selectedWarningType
        )

//        self.selectedProgramId = try container.decodeIfPresent(
//            UUID.self, forKey: .selectedProgramId)

        //        self.selectedObservId = try container.decodeIfPresent(
//            Observation.ID.self, forKey: .selectedObservId)
//
//        self.selectedColleId = try container.decodeIfPresent(
//            Colle.ID.self, forKey: .selectedColleId)
//
//        self.selectedEleveId = try container.decodeIfPresent(
//            NSManagedObjectID.self, forKey: .selectedEleveId)
//
//        self.selectedClasseId = try container.decodeIfPresent(
//            Classe.ID.self, forKey: .selectedClasseId)
//
//        self.selectedSchoolId = try container.decodeIfPresent(
//            SchoolEntity.ID.self, forKey: .selectedSchoolId)

        self.filterObservation = try container.decode(
            Bool.self, forKey: .filterObservation
        )

        self.filterColle = try container.decode(
            Bool.self, forKey: .filterColle
        )

        self.filterFlag = try container.decode(
            Bool.self, forKey: .filterFlag
        )

        self.columnVisibility = try container.decode(
            NavigationSplitViewVisibility.self, forKey: .columnVisibility
        )
    }

    // MARK: - Methods

    func resetSelections() {
        selectedTab = .school
        selectedWarningType = .observation
        selectedProgramId = nil
        selectedSequenceId = nil
        selectedActivityId = nil
        selectedObservId = nil
        selectedColleId = nil
        selectedEleveId = nil
        selectedClasseId = nil
        selectedSchoolId = nil
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(selectedTab, forKey: .selectedTab)
        try container.encode(selectedWarningType, forKey: .selectedWarningType)
//        try container.encodeIfPresent(selectedProgramId, forKey: .selectedProgramId)
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
}
