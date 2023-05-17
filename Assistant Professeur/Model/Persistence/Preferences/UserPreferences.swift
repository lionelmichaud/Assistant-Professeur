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

    @Published
    public var eleve = ElevePref()

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

    @Published
    public var horaire = DailySchedulePref()

    // MARK: - Année scolaire

    @Published
    public var schoolYear = SchoolYearPref()

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

            eleve = result.eleve

            programAnnotationEnabled = result.programAnnotationEnabled
            sequenceAnnotationEnabled = result.sequenceAnnotationEnabled
            margeInterSequence = result.margeInterSequence
            activityAnnotationEnabled = result.activityAnnotationEnabled

            horaire = result.horaire

            schoolYear = result.schoolYear
        }
    }

    // MARK: - Initializer

    init() {}

    // MARK: - Codable conformance

    enum CodingKeys: CodingKey {
        case interoperability, nameDisplayOrder, nameSortOrder
        case schoolAnnotationEnabled
        case classeAppreciationEnabled, classeAnnotationEnabled
        case eleve
        case programAnnotationEnabled
        case sequenceAnnotationEnabled, margeInterSequence
        case activityAnnotationEnabled
        case horaire
        case schoolYear
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.interoperability = try container.decode(Interoperability.self, forKey: .interoperability)
        self.nameDisplayOrder = try container.decode(NameOrdering.self, forKey: .nameDisplayOrder)
        self.nameSortOrder = try container.decode(NameOrdering.self, forKey: .nameSortOrder)

        self.schoolAnnotationEnabled = try container.decode(Bool.self, forKey: .schoolAnnotationEnabled)

        self.classeAppreciationEnabled = try container.decode(Bool.self, forKey: .classeAppreciationEnabled)
        self.classeAnnotationEnabled = try container.decode(Bool.self, forKey: .classeAnnotationEnabled)

        self.eleve = try container.decode(ElevePref.self, forKey: .eleve)

        self.programAnnotationEnabled = try container.decode(Bool.self, forKey: .programAnnotationEnabled)
        self.sequenceAnnotationEnabled = try container.decode(Bool.self, forKey: .sequenceAnnotationEnabled)
        self.margeInterSequence = try container.decode(Int.self, forKey: .margeInterSequence)
        self.activityAnnotationEnabled = try container.decode(Bool.self, forKey: .activityAnnotationEnabled)

        self.horaire = try container.decode(DailySchedulePref.self, forKey: .horaire)

        self.schoolYear = try container.decode(SchoolYearPref.self, forKey: .schoolYear)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.interoperability, forKey: .interoperability)
        try container.encode(self.nameDisplayOrder, forKey: .nameDisplayOrder)
        try container.encode(self.nameSortOrder, forKey: .nameSortOrder)

        try container.encode(self.schoolAnnotationEnabled, forKey: .schoolAnnotationEnabled)

        try container.encode(self.classeAppreciationEnabled, forKey: .classeAppreciationEnabled)
        try container.encode(self.classeAnnotationEnabled, forKey: .classeAnnotationEnabled)

        try container.encode(self.eleve, forKey: .eleve)

        try container.encode(self.programAnnotationEnabled, forKey: .programAnnotationEnabled)
        try container.encode(self.sequenceAnnotationEnabled, forKey: .sequenceAnnotationEnabled)
        try container.encode(self.margeInterSequence, forKey: .margeInterSequence)
        try container.encode(self.activityAnnotationEnabled, forKey: .activityAnnotationEnabled)

        try container.encode(self.horaire, forKey: .horaire)

        try container.encode(self.schoolYear, forKey: .schoolYear)
    }
}
