/*
 See LICENSE folder for this sample’s licensing information.

 Abstract:
 A navigation model used to persist and restore the navigation state.
 */

import Combine
import CoreData
import os
import SwiftUI

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "NavigationModel"
)

/// A navigation model used to persist and restore the navigation state.
/// @MainActor
final class NavigationModel: ObservableObject, Codable {
    // MARK: - Embeded Types

    enum CodingKeys: String, CodingKey {
        case columnVisibility
        case selectedTab
        case selectedPrefTab
        case selectedWarningType
        case selectedCompetenceType
        case classPath
        case programPath
        case selectedProgramId
        case selectedSequenceId
        case selectedActivityId
        case selectedObservId
        case selectedColleId
        case selectedEleveId
        case selectedClasseId
        case selectedSchoolId
        case selectedWorkedCompChapterId
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
    var selectedPrefTab: PrefTabSelection
    @Published
    var selectedWarningType: WarningSelection?
    @Published
    var selectedCompetenceType: CompetencyTypeSelection?
    @Published
    var classPath = [ClasseNavigationRoute]()
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
    var selectedWorkedCompChapterMngObjId: NSManagedObjectID? {
        willSet(newValue) {
            selectedWorkedCompChapterId =
                WorkedCompChapterEntity.id(MngObjID: newValue)
        }
    }

    var selectedWorkedCompChapterId: UUID?

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
            guard let data = newValue else {
                return
            }
            do {
                #if DEBUG
                    print(">> NavigationModel() JSON decoding has started")
                #endif
                let model = try decoder.decode(Self.self, from: data)
                // initialize l'état de navigation en conséquence
                columnVisibility = model.columnVisibility
                selectedTab = model.selectedTab
                selectedPrefTab = model.selectedPrefTab
                selectedWarningType = model.selectedWarningType
                selectedCompetenceType = model.selectedCompetenceType

                selectedProgramMngObjId = model.selectedProgramMngObjId
                selectedSequenceMngObjId = model.selectedSequenceMngObjId
                selectedActivityMngObjId = model.selectedActivityMngObjId
                selectedObservMngObjId = model.selectedObservMngObjId
                selectedColleMngObjId = model.selectedColleMngObjId
                selectedEleveMngObjId = model.selectedEleveMngObjId
                selectedClasseMngObjId = model.selectedClasseMngObjId
                selectedSchoolMngObjId = model.selectedSchoolMngObjId
                selectedWorkedCompChapterMngObjId = model.selectedWorkedCompChapterMngObjId

                filterObservation = model.filterObservation
                filterColle = model.filterColle
                filterFlag = model.filterFlag

                classPath = model.classPath
                programPath = model.programPath
                #if DEBUG
                    print(">> NavigationModel() JSON decoding has completed")
                #endif
            } catch {
                customLog.log(
                    level: .error,
                    "Erreur de décodage JSON de NavigationModel: \(error.localizedDescription)"
                )
            }
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
        selectedPrefTab: PrefTabSelection = .general,
        selectedWarningType: WarningSelection? = nil,
        selectedCompetenceType: CompetencyTypeSelection? = nil,
        selectedProgramMngObjId: NSManagedObjectID? = nil,
        selectedSequenceMngObjId: NSManagedObjectID? = nil,
        selectedActivityMngObjId: NSManagedObjectID? = nil,
        selectedObservMngObjId: NSManagedObjectID? = nil,
        selectedColleMngObjId: NSManagedObjectID? = nil,
        selectedEleveMngObjId: NSManagedObjectID? = nil,
        selectedClasseMngObjId: NSManagedObjectID? = nil,
        selectedSchoolMngObjId: NSManagedObjectID? = nil,
        selectedWorkedCompChapterMngObjId: NSManagedObjectID? = nil,
        filterObservation: Bool = false,
        filterColle: Bool = false,
        filterFlag: Bool = false
    ) {
        #if DEBUG
            print(">> NavigationModel() initialization has started")
        #endif
        self.columnVisibility = columnVisibility
        self.selectedTab = selectedTab
        self.selectedPrefTab = selectedPrefTab
        self.selectedWarningType = selectedWarningType
        self.selectedCompetenceType = selectedCompetenceType

        self.selectedProgramMngObjId = selectedProgramMngObjId
        self.selectedSequenceMngObjId = selectedSequenceMngObjId
        self.selectedActivityMngObjId = selectedActivityMngObjId
        self.selectedObservMngObjId = selectedObservMngObjId
        self.selectedColleMngObjId = selectedColleMngObjId
        self.selectedEleveMngObjId = selectedEleveMngObjId
        self.selectedClasseMngObjId = selectedClasseMngObjId
        self.selectedSchoolMngObjId = selectedSchoolMngObjId
        self.selectedWorkedCompChapterMngObjId = selectedWorkedCompChapterMngObjId

        self.filterObservation = filterObservation
        self.filterColle = filterColle
        self.filterFlag = filterFlag

        self.classPath = []
        self.programPath = NavigationPath()

        #if DEBUG
            print(">> NavigationModel() initialization has completed")
        #endif
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.selectedTab = try container.decode(
            NavigationModel.TabSelection.self, forKey: .selectedTab
        )
        self.selectedPrefTab = try container.decode(
            PrefTabSelection.self, forKey: .selectedPrefTab
        )
        self.selectedWarningType = try container.decodeIfPresent(
            WarningSelection.self, forKey: .selectedWarningType
        )
        self.selectedCompetenceType = try container.decodeIfPresent(
            CompetencyTypeSelection.self, forKey: .selectedCompetenceType
        )
        // FIXME: Plante dans ClasseSideBar si on décode ici
//        self.classPath = try container.decode(
//            [ClasseNavigationRoute].self, forKey: .classPath
//        )
//        do {
//            let representation = try container.decode(
//                NavigationPath.CodableRepresentation.self, forKey: .programPath)
//            self.programPath = NavigationPath(representation)
//        } catch {
//            self.programPath = NavigationPath()
//        }

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

        self.selectedWorkedCompChapterId = try container.decodeIfPresent(
            UUID.self, forKey: .selectedWorkedCompChapterId
        )
        selectedWorkedCompChapterMngObjId =
            WorkedCompChapterEntity.managedObjectID(id: selectedWorkedCompChapterId)

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
        selectedPrefTab = .general
        selectedWarningType = .observation
        selectedCompetenceType = .disciplineCompetencies

        selectedProgramMngObjId = nil
        selectedSequenceMngObjId = nil
        selectedActivityMngObjId = nil
        selectedObservMngObjId = nil
        selectedColleMngObjId = nil
        selectedEleveMngObjId = nil
        selectedClasseMngObjId = nil
        selectedSchoolMngObjId = nil
        selectedWorkedCompChapterMngObjId = nil

        classPath = []
        programPath = NavigationPath()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(selectedTab, forKey: .selectedTab)
        try container.encode(selectedPrefTab, forKey: .selectedPrefTab)
        try container.encodeIfPresent(selectedWarningType, forKey: .selectedWarningType)
        try container.encodeIfPresent(selectedCompetenceType, forKey: .selectedCompetenceType)

        try container.encodeIfPresent(selectedProgramId, forKey: .selectedProgramId)
        try container.encodeIfPresent(selectedSequenceId, forKey: .selectedSequenceId)
        try container.encodeIfPresent(selectedActivityId, forKey: .selectedSequenceId)
        try container.encodeIfPresent(selectedObservId, forKey: .selectedObservId)
        try container.encodeIfPresent(selectedColleId, forKey: .selectedColleId)
        try container.encodeIfPresent(selectedEleveId, forKey: .selectedEleveId)
        try container.encodeIfPresent(selectedClasseId, forKey: .selectedClasseId)
        try container.encodeIfPresent(selectedSchoolId, forKey: .selectedSchoolId)
        try container.encodeIfPresent(selectedWorkedCompChapterId, forKey: .selectedWorkedCompChapterId)

        try container.encode(filterObservation, forKey: .filterObservation)
        try container.encode(filterColle, forKey: .filterColle)
        try container.encode(filterFlag, forKey: .filterFlag)
        try container.encode(columnVisibility, forKey: .columnVisibility)

        try container.encode(classPath, forKey: .classPath)

        if let representation = programPath.codable {
            try container.encode(representation, forKey: .programPath)
        }
    }
}
