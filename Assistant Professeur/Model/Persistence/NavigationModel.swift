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

    enum TabSelection: String, Hashable, Codable {
        case userSettings = "Réglages"
        case school = "Etablissement"
        case classe = "Classes"
        case eleve = "Elèves"
        case warning = "Avertissements"
        case program = "Programmes"
        case competence = "Compétences"

        var imageName: String {
            switch self {
                case .userSettings:
                    return ""
                case .school:
                    return "building.2"
                case .classe:
                    return "person.3.sequence"
                case .eleve:
                    return "graduationcap"
                case .warning:
                    return "hand.raised"
                case .program:
                    return "books.vertical"
                case .competence:
                    return ""
            }
        }
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
        case selectedSequenceId
        case selectedActivityId
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
    var selectedTab: TabSelection
    @Published
    var selectedWarningType: WarningSelection?
    @Published
    var programPath = NavigationPath()

    /// TODO: - Trouver une autre solution
    @Published
    var selectedProgramMngObjId: NSManagedObjectID? {
        willSet(newValue) {
            selectedProgramId =
                ProgramEntity.id(MngObjID: newValue)
        }
    }

    var selectedProgramId: UUID?

    @Published
    var selectedSequenceMngObjId: NSManagedObjectID? {
        willSet(newValue) {
            selectedSequenceId =
                SequenceEntity.id(MngObjID: newValue)
        }
    }

    var selectedSequenceId: UUID?

    @Published
    var selectedActivityMngObjId: NSManagedObjectID? {
        willSet(newValue) {
            selectedActivityId =
                ActivityEntity.id(MngObjID: newValue)
        }
    }

    var selectedActivityId: UUID?

    @Published
    var selectedObservMngObjId: NSManagedObjectID? {
        willSet(newValue) {
            selectedObservId =
                ObservEntity.id(MngObjID: newValue)
        }
    }

    var selectedObservId: UUID?

    @Published
    var selectedColleMngObjId: NSManagedObjectID? {
        willSet(newValue) {
            selectedColleId =
                ColleEntity.id(MngObjID: newValue)
        }
    }

    var selectedColleId: UUID?

    @Published
    var selectedEleveMngObjId: NSManagedObjectID? {
        willSet(newValue) {
            selectedEleveId =
                EleveEntity.id(MngObjID: newValue)
        }
    }

    var selectedEleveId: UUID?

    @Published
    var selectedClasseMngObjId: NSManagedObjectID? {
        willSet(newValue) {
            selectedClasseId =
                ClasseEntity.id(MngObjID: newValue)
        }
    }

    var selectedClasseId: UUID?

    @Published
    var selectedSchoolMngObjId: NSManagedObjectID? {
        willSet(newValue) {
            selectedSchoolId =
                SchoolEntity.id(MngObjID: newValue)
        }
    }

    var selectedSchoolId: UUID?

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
        get {
            // retourne l'état de navigation encodé JSON
            try? encoder.encode(self)
        }
        set {
            // décode l'état de navigation à partir des données fournies au format JSON
            guard let data = newValue,
                  let model = try? decoder.decode(Self.self, from: data)
            else {
                return
            }
            // initialize l'état de navigation en conséquence
            columnVisibility = model.columnVisibility
            selectedTab = model.selectedTab
            selectedWarningType = model.selectedWarningType

            selectedProgramMngObjId = model.selectedProgramMngObjId
            selectedSequenceMngObjId = model.selectedSequenceMngObjId
            selectedActivityMngObjId = model.selectedActivityMngObjId
            selectedObservMngObjId = model.selectedObservMngObjId
            selectedColleMngObjId = model.selectedColleMngObjId
            selectedEleveMngObjId = model.selectedEleveMngObjId
            selectedClasseMngObjId = model.selectedClasseMngObjId
            selectedSchoolMngObjId = model.selectedSchoolMngObjId

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
        selectedTab: TabSelection = .school,
        selectedWarningType: WarningSelection? = nil,
        selectedProgramMngObjId: NSManagedObjectID? = nil,
        selectedSequenceMngObjId: NSManagedObjectID? = nil,
        selectedActivityMngObjId: NSManagedObjectID? = nil,
        selectedObservMngObjId: NSManagedObjectID? = nil,
        selectedColleMngObjId: NSManagedObjectID? = nil,
        selectedEleveMngObjId: NSManagedObjectID? = nil,
        selectedClasseMngObjId: NSManagedObjectID? = nil,
        selectedSchoolMngObjId: NSManagedObjectID? = nil,
        filterObservation: Bool = false,
        filterColle: Bool = false,
        filterFlag: Bool = false
    ) {
        #if DEBUG
            print(">> NavigationModel() initialization has started")
        #endif
        self.columnVisibility = columnVisibility
        self.selectedTab = selectedTab
        self.selectedWarningType = selectedWarningType

        self.selectedProgramMngObjId = selectedProgramMngObjId
        self.selectedSequenceMngObjId = selectedSequenceMngObjId
        self.selectedActivityMngObjId = selectedActivityMngObjId
        self.selectedObservMngObjId = selectedObservMngObjId
        self.selectedColleMngObjId = selectedColleMngObjId
        self.selectedEleveMngObjId = selectedEleveMngObjId
        self.selectedClasseMngObjId = selectedClasseMngObjId
        self.selectedSchoolMngObjId = selectedSchoolMngObjId
        
        self.filterObservation = filterObservation
        self.filterColle = filterColle
        self.filterFlag = filterFlag
        #if DEBUG
            print(">> NavigationModel() initialization has completed")
        #endif
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.selectedTab = try container.decode(
            NavigationModel.TabSelection.self, forKey: .selectedTab
        )
        self.selectedWarningType = try container.decodeIfPresent(
            NavigationModel.WarningSelection.self, forKey: .selectedWarningType
        )

        self.selectedProgramId = try container.decodeIfPresent(
            UUID.self, forKey: .selectedProgramId
        )
        selectedProgramMngObjId =
            ProgramEntity.managedObjectID(id: selectedProgramId)

        self.selectedSequenceId = try container.decodeIfPresent(
            UUID.self, forKey: .selectedSequenceId
        )
        selectedSequenceMngObjId =
            SequenceEntity.managedObjectID(id: selectedSequenceId)

        self.selectedActivityId = try container.decodeIfPresent(
            UUID.self, forKey: .selectedActivityId
        )
        selectedActivityMngObjId =
            ActivityEntity.managedObjectID(id: selectedActivityId)

        self.selectedObservId = try container.decodeIfPresent(
            UUID.self, forKey: .selectedObservId
        )
        selectedObservMngObjId =
            ObservEntity.managedObjectID(id: selectedObservId)

        self.selectedColleId = try container.decodeIfPresent(
            UUID.self, forKey: .selectedColleId
        )
        selectedColleMngObjId =
            ColleEntity.managedObjectID(id: selectedColleId)

        self.selectedEleveId = try container.decodeIfPresent(
            UUID.self, forKey: .selectedEleveId
        )
        selectedEleveMngObjId =
            EleveEntity.managedObjectID(id: selectedEleveId)

        self.selectedClasseId = try container.decodeIfPresent(
            UUID.self, forKey: .selectedClasseId
        )
        selectedClasseMngObjId =
            ClasseEntity.managedObjectID(id: selectedClasseId)

        self.selectedSchoolId = try container.decodeIfPresent(
            UUID.self, forKey: .selectedSchoolId
        )
        selectedSchoolMngObjId =
            SchoolEntity.managedObjectID(id: selectedSchoolId)

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

        selectedProgramMngObjId = nil
        selectedSequenceMngObjId = nil
        selectedActivityMngObjId = nil
        selectedObservMngObjId = nil
        selectedColleMngObjId = nil
        selectedEleveMngObjId = nil
        selectedClasseMngObjId = nil
        selectedSchoolMngObjId = nil
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(selectedTab, forKey: .selectedTab)
        try container.encode(selectedWarningType, forKey: .selectedWarningType)

        try container.encodeIfPresent(selectedProgramId, forKey: .selectedProgramId)
        try container.encodeIfPresent(selectedSequenceId, forKey: .selectedSequenceId)
        try container.encodeIfPresent(selectedActivityId, forKey: .selectedSequenceId)
        try container.encodeIfPresent(selectedObservId, forKey: .selectedObservId)
        try container.encodeIfPresent(selectedColleId, forKey: .selectedColleId)
        try container.encodeIfPresent(selectedEleveId, forKey: .selectedEleveId)
        try container.encodeIfPresent(selectedClasseId, forKey: .selectedClasseId)
        try container.encodeIfPresent(selectedSchoolId, forKey: .selectedSchoolId)

        try container.encode(filterObservation, forKey: .filterObservation)
        try container.encode(filterColle, forKey: .filterColle)
        try container.encode(filterFlag, forKey: .filterFlag)
        try container.encode(columnVisibility, forKey: .columnVisibility)
    }
}
