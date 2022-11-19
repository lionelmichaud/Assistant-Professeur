//
//  SchoolSidebarViewModel.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 18/11/2022.
//

import Foundation

class SchoolSidebarViewModel: NSObject, ObservableObject {

    // MARK: - Properties

    @Published var schoolsVM: [NiveauSchool : [SchoolViewModel]] = {
        var dico = [NiveauSchool : [SchoolViewModel]]()
        NiveauSchool.allCases.forEach { level in
            dico[level] = [ ]
        }
        return dico
    }()

    // MARK: - Computed Properties

    /// Retourn true s'il n'existe aucun établissement
    var isEmpty: Bool {
        schoolsVM.allSatisfy { _ , value in
            value.isEmpty
        }
    }

    // MARK: - Methods

    /// Retourn true s'il n'existe aucun établissement de `niveau`
    /// - Parameter niveau: niveau de l'établissement
    func isEmptyFor( _ niveau: NiveauSchool) -> Bool {
        schoolsVM[niveau]?.isEmpty ?? true
    }

    /// Charger tous les objets `SchoolEntity` à partir du persistentContainer de Core Data
    func getAllItems() {
        let allItems: [SchoolEntity] = SchoolEntity.all()
        
        //DispatchQueue.main.async {
        NiveauSchool.allCases.forEach { level in
            var schoolsVM = [SchoolViewModel]()

            allItems.forEach { school in
                let schoolVM = SchoolViewModel(school: school)
                if schoolVM.niveau == level {
                    schoolsVM.append(schoolVM)
                }
            }

            self.schoolsVM[level] = schoolsVM
        }
        //}
    }

    /// Supprimer du store l'objet `SchoolEntity` contenu dans `schoolVM`
    func delete(schoolVM: SchoolViewModel) {
        let school: SchoolEntity? = SchoolEntity.byId(id: schoolVM.id)
        if let school {
            try? school.delete()
        }
    }
}
