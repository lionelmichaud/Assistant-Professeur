//
//  UserPreferences.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 15/05/2023.
//

import Combine
import Foundation

/// @MainActor
final class UserPreferences: ObservableObject, Codable {
    // MARK: - Générales

    /// Champ annotation
    public var interoperability: Interoperability = .ecoleDirecte
    public var nameDisplayOrder: NameOrdering = .nomPrenom
    public var nameSortOrder: NameOrdering = .nomPrenom

    // MARK: - School

    /// Champ annotation
    @Published
    public var schoolAnnotationEnabled: Bool = true

    // MARK: - Classe

    /// Champ appéciation
    @Published
    public var classeAppreciationEnabled: Bool = true
    /// Champ annotation
    @Published
    public var classeAnnotationEnabled: Bool = true

    // MARK: - Elève

    /// Champ appéciation
    @Published
    public var eleveAppreciationEnabled: Bool = true
    /// Champ annotation
    @Published
    public var eleveAnnotationEnabled: Bool = true
    /// Champ trombine
    @Published
    public var eleveTrombineEnabled: Bool = true
    /// Champ bonus / malus
    @Published
    public var eleveBonusEnabled: Bool = true
    @Published
    public var maxBonusMalus: Int = 100
    @Published
    public var maxBonusIncrement: Int = 1

    // MARK: - Programmes

    /// Champ annotation
    @Published
    public var programAnnotationEnabled: Bool = true

    // MARK: - Séquences

    /// Champ annotation
    @Published
    public var sequenceAnnotationEnabled: Bool = true

    @Published
    public var margeInterSequence: Int = 1

    // MARK: - Activités

    /// Champ annotation
    @Published
    public var activityAnnotationEnabled: Bool = true

    // MARK: - Horaires

    /// Durée d'une séance de cours en minutes
    @Published
    public var seanceDuration: Int = 55

    /// Durée inter-cours en minutes
    @Published
    public var interSeancesDuration: Int = 0

    /// Durée de la récréation en minutes
    @Published
    public var recreationDuration: Int = 20

    /// Durée de la pause déjeuner en minutes
    @Published
    public var lunchDuration: Int = 75

    /// Heure du début de la journée de cours
    @Published
    public var hourOfFirstSeance: Int = 8
    @Published
    public var minutesOfFirstSeance: Int = 15

    // MARK: - Année scolaire

    @Published
    public var scolarYear = DateInterval(start: .now, end: .now)
    @Published
    public var autumnVacation = DateInterval(start: .now, end: .now)
    @Published
    public var noelVacation = DateInterval(start: .now, end: .now)
    @Published
    public var winterVacation = DateInterval(start: .now, end: .now)
    @Published
    public var paqueVacation = DateInterval(start: .now, end: .now)

    private lazy var decoder = JSONDecoder()
    private lazy var encoder = JSONEncoder()

    // MARK: - Computed Properties

    var objectWillChangeSequence: AsyncPublisher<Publishers.Buffer<ObservableObjectPublisher>> {
        objectWillChange
            .buffer(size: 1, prefetch: .byRequest, whenFull: .dropOldest)
            .values
    }

    var jsonData: Data? {
        get {
            // retourne self encodé JSON
            try? encoder.encode(self)
        }
        set {
            // décode self à partir des données fournies au format JSON
            guard let data = newValue,
                  let result = try? decoder.decode(Self.self, from: data)
            else {
                return
            }

            interoperability = result.interoperability
            nameDisplayOrder = result.nameDisplayOrder
            nameSortOrder = result.nameSortOrder
            schoolAnnotationEnabled = result.schoolAnnotationEnabled
            classeAppreciationEnabled = result.classeAppreciationEnabled
            classeAnnotationEnabled = result.classeAnnotationEnabled
            eleveAppreciationEnabled = result.eleveAppreciationEnabled
            eleveAnnotationEnabled = result.eleveAnnotationEnabled
            eleveTrombineEnabled = result.eleveTrombineEnabled
            eleveBonusEnabled = result.eleveBonusEnabled
            maxBonusMalus = result.maxBonusMalus
            maxBonusIncrement = result.maxBonusIncrement
            programAnnotationEnabled = result.programAnnotationEnabled
            sequenceAnnotationEnabled = result.sequenceAnnotationEnabled
            margeInterSequence = result.margeInterSequence
            activityAnnotationEnabled = result.activityAnnotationEnabled
            seanceDuration = result.seanceDuration
            interSeancesDuration = result.interSeancesDuration
            recreationDuration = result.recreationDuration
            lunchDuration = result.lunchDuration
            hourOfFirstSeance = result.hourOfFirstSeance
            minutesOfFirstSeance = result.minutesOfFirstSeance

            scolarYear = result.scolarYear
            autumnVacation = result.autumnVacation
            noelVacation = result.noelVacation
            winterVacation = result.winterVacation
            paqueVacation = result.paqueVacation
        }
    }

    // MARK: - Initializer

    init() {}

    // MARK: - Codable conformance

    enum CodingKeys: CodingKey {
        case interoperability
        case nameDisplayOrder
        case nameSortOrder
        case schoolAnnotationEnabled
        case classeAppreciationEnabled
        case classeAnnotationEnabled
        case eleveAppreciationEnabled
        case eleveAnnotationEnabled
        case eleveTrombineEnabled
        case eleveBonusEnabled
        case maxBonusMalus
        case maxBonusIncrement
        case programAnnotationEnabled
        case sequenceAnnotationEnabled
        case margeInterSequence
        case activityAnnotationEnabled
        case seanceDuration
        case interSeancesDuration
        case recreationDuration
        case lunchDuration
        case hourOfFirstSeance
        case minutesOfFirstSeance
        case scolarYear
        case autumnVacation
        case noelVacation
        case winterVacation
        case paqueVacation
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.interoperability = try container.decode(Interoperability.self, forKey: .interoperability)
        self.nameDisplayOrder = try container.decode(NameOrdering.self, forKey: .nameDisplayOrder)
        self.nameSortOrder = try container.decode(NameOrdering.self, forKey: .nameSortOrder)
        self.schoolAnnotationEnabled = try container.decode(Bool.self, forKey: .schoolAnnotationEnabled)
        self.classeAppreciationEnabled = try container.decode(Bool.self, forKey: .classeAppreciationEnabled)
        self.classeAnnotationEnabled = try container.decode(Bool.self, forKey: .classeAnnotationEnabled)
        self.eleveAppreciationEnabled = try container.decode(Bool.self, forKey: .eleveAppreciationEnabled)
        self.eleveAnnotationEnabled = try container.decode(Bool.self, forKey: .eleveAnnotationEnabled)
        self.eleveTrombineEnabled = try container.decode(Bool.self, forKey: .eleveTrombineEnabled)
        self.eleveBonusEnabled = try container.decode(Bool.self, forKey: .eleveBonusEnabled)
        self.maxBonusMalus = try container.decode(Int.self, forKey: .maxBonusMalus)
        self.maxBonusIncrement = try container.decode(Int.self, forKey: .maxBonusIncrement)
        self.programAnnotationEnabled = try container.decode(Bool.self, forKey: .programAnnotationEnabled)
        self.sequenceAnnotationEnabled = try container.decode(Bool.self, forKey: .sequenceAnnotationEnabled)
        self.margeInterSequence = try container.decode(Int.self, forKey: .margeInterSequence)
        self.activityAnnotationEnabled = try container.decode(Bool.self, forKey: .activityAnnotationEnabled)
        self.seanceDuration = try container.decode(Int.self, forKey: .seanceDuration)
        self.interSeancesDuration = try container.decode(Int.self, forKey: .interSeancesDuration)
        self.recreationDuration = try container.decode(Int.self, forKey: .recreationDuration)
        self.lunchDuration = try container.decode(Int.self, forKey: .lunchDuration)
        self.hourOfFirstSeance = try container.decode(Int.self, forKey: .hourOfFirstSeance)
        self.minutesOfFirstSeance = try container.decode(Int.self, forKey: .minutesOfFirstSeance)

        self.scolarYear = try container.decode(DateInterval.self, forKey: .scolarYear)
        self.autumnVacation = try container.decode(DateInterval.self, forKey: .autumnVacation)
        self.noelVacation = try container.decode(DateInterval.self, forKey: .noelVacation)
        self.winterVacation = try container.decode(DateInterval.self, forKey: .winterVacation)
        self.paqueVacation = try container.decode(DateInterval.self, forKey: .paqueVacation)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.interoperability, forKey: .interoperability)
        try container.encode(self.nameDisplayOrder, forKey: .nameDisplayOrder)
        try container.encode(self.nameSortOrder, forKey: .nameSortOrder)
        try container.encode(self.schoolAnnotationEnabled, forKey: .schoolAnnotationEnabled)
        try container.encode(self.classeAppreciationEnabled, forKey: .classeAppreciationEnabled)
        try container.encode(self.classeAnnotationEnabled, forKey: .classeAnnotationEnabled)
        try container.encode(self.eleveAppreciationEnabled, forKey: .eleveAppreciationEnabled)
        try container.encode(self.eleveAnnotationEnabled, forKey: .eleveAnnotationEnabled)
        try container.encode(self.eleveTrombineEnabled, forKey: .eleveTrombineEnabled)
        try container.encode(self.eleveBonusEnabled, forKey: .eleveBonusEnabled)
        try container.encode(self.maxBonusMalus, forKey: .maxBonusMalus)
        try container.encode(self.maxBonusIncrement, forKey: .maxBonusIncrement)
        try container.encode(self.programAnnotationEnabled, forKey: .programAnnotationEnabled)
        try container.encode(self.sequenceAnnotationEnabled, forKey: .sequenceAnnotationEnabled)
        try container.encode(self.margeInterSequence, forKey: .margeInterSequence)
        try container.encode(self.activityAnnotationEnabled, forKey: .activityAnnotationEnabled)
        try container.encode(self.seanceDuration, forKey: .seanceDuration)
        try container.encode(self.interSeancesDuration, forKey: .interSeancesDuration)
        try container.encode(self.recreationDuration, forKey: .recreationDuration)
        try container.encode(self.lunchDuration, forKey: .lunchDuration)
        try container.encode(self.hourOfFirstSeance, forKey: .hourOfFirstSeance)
        try container.encode(self.minutesOfFirstSeance, forKey: .minutesOfFirstSeance)

        try container.encode(self.scolarYear, forKey: .scolarYear)
        try container.encode(self.autumnVacation, forKey: .autumnVacation)
        try container.encode(self.noelVacation, forKey: .noelVacation)
        try container.encode(self.winterVacation, forKey: .winterVacation)
        try container.encode(self.paqueVacation, forKey: .paqueVacation)
    }
}
