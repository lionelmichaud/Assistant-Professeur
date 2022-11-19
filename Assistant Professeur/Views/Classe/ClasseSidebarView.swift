//
//  ClasseBrowserView.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 21/04/2022.
//

import SwiftUI

struct ClasseSidebarView: View {
    @EnvironmentObject private var navigationModel : NavigationModel
    @EnvironmentObject private var schoolStore : SchoolStore
    @EnvironmentObject private var classeStore : ClasseStore

    var body: some View {
        List(selection: $navigationModel.selectedClasseId) {
            if classeStore.items.isEmpty {
                Text("Aucune classe actuellement")
            } else {
                /// pour chaque Etablissement
                ForEach(schoolStore.sortedSchools()) { $school in
                    if school.nbOfClasses != 0 {
                        Section {
                            /// pour chaque Classe
                            ClasseSidebarSchoolSubview(school: $school)
                        } header: {
                            Text(school.displayString)
                                .font(.callout)
                                .foregroundColor(.secondary)
                                .fontWeight(.bold)
                        }
                    }
                }
            }
        }
        .navigationTitle("Les Classes")
    }
}

struct ClasseSidebarSchoolSubview : View {
    @Binding
    var school: School

    @EnvironmentObject private var navigationModel : NavigationModel
    @EnvironmentObject private var classeStore     : ClasseStore
    @EnvironmentObject private var eleveStore      : EleveStore
    @EnvironmentObject private var colleStore      : ColleStore
    @EnvironmentObject private var observStore     : ObservationStore

    var body: some View {
        /// pour chaque Classe
        ForEach(classeStore.sortedClasses(dans: school)) { $classe in
            ClassBrowserRow(classe: classe)
            .swipeActions {
                // supprimer une classe
                Button(role: .destructive) {
                    withAnimation {
                        // supprimer la classe et tous ses descendants
                        // puis retirer la classe de l'établissement auquelle elle appartient
                        SchoolManager().retirer(classe      : classe,
                                                deSchool    : &school,
                                                classeStore : classeStore,
                                                eleveStore  : eleveStore,
                                                observStore : observStore,
                                                colleStore  : colleStore)
                    }
                } label: {
                    Label("Supprimer", systemImage: "trash")
                }

                // flager une classe
                Button {
                    withAnimation {
                        classe.isFlagged.toggle()
                    }
                } label: {
                    if classe.isFlagged {
                        Label("Sans drapeau", systemImage: "flag.slash")
                    } else {
                        Label("Avec drapeau", systemImage: "flag.fill")
                    }
                }.tint(.orange)
            }
        }
    }
}

struct ClasseSidebarView_Previews: PreviewProvider {
    static var previews: some View {
        TestEnvir.createFakes()
        return Group {
            ClasseSidebarView()
                .environmentObject(NavigationModel(selectedClasseId: TestEnvir.classeStore.items.first!.id))
                .environmentObject(TestEnvir.schoolStore)
                .environmentObject(TestEnvir.classeStore)
                .environmentObject(TestEnvir.eleveStore)
                .environmentObject(TestEnvir.colleStore)
                .environmentObject(TestEnvir.observStore)
                .previewDevice("iPad mini (6th generation)")

            ClasseSidebarView()
                .environmentObject(NavigationModel(selectedClasseId: TestEnvir.classeStore.items.first!.id))
                .environmentObject(TestEnvir.schoolStore)
                .environmentObject(TestEnvir.classeStore)
                .environmentObject(TestEnvir.eleveStore)
                .environmentObject(TestEnvir.colleStore)
                .environmentObject(TestEnvir.observStore)
                .previewDevice("iPhone 13")
        }
    }
}
