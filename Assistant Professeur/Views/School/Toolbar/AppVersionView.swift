//
//  AppVersionView.swift
//  Patrimonio
//
//  Created by Lionel MICHAUD on 23/04/2021.
//

import AppFoundation
import SwiftUI

struct AppVersionView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            // Infos Appli
            GroupBox {
                Text(AppVersion.shared.name ?? "Assistant Professeur")
                    .font(.title)
                    .fontWeight(.heavy)
                Text("Version: \(AppVersion.shared.theVersion ?? "?")")
                    .font(.title3)
                    .foregroundColor(.secondary)
                if let date = AppVersion.shared.date {
                    Text(date, style: Text.DateStyle.date)
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                if let comment = AppVersion.shared.comment {
                    Text(comment)
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
            }

            // Infos Historique
            Form {
                Section {
                    // Historique des révisions
                    RevisionHistoryView(revisions: AppVersion.shared.revisionHistory)
                }
                #if DEBUG
                    Section {
                        // Liste des directories utilisées par l'application
                        DirectoriesListView()
                    }
                #endif
            }
        }
        .padding(.top)
        #if os(iOS)
            .navigationBarHidden(true)
        #endif
    }
}

struct RevisionHistoryView: View {
    var revisions: [Version]
    @State
    private var expanded = true

    var body: some View {
        DisclosureGroup(
            isExpanded: $expanded,
            content: {
                ForEach(revisions, id: \.self) { revision in
                    RevisionView(revision: revision)
                }
                .foregroundColor(.secondary)
            },
            label: {
                Text("HISTORIQUE DES REVISIONS").font(.headline)
            }
        )
    }
}

struct RevisionView: View {
    var revision: Version

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if let version = revision.version {
                    Text(version)
                        .fontWeight(.heavy)
                }
                if let date = revision.date {
                    Text("(") + Text(date, style: Text.DateStyle.date) + Text(") :")
                }
            }
            .font(.subheadline)

            Text(revision.comment ?? "")
                .multilineTextAlignment(.leading)
                .lineSpacing(10.0)
                .padding(.leading)
        }
    }
}

struct DirectoriesListView: View {
    @State
    private var expanded = false

    var body: some View {
        DisclosureGroup(
            isExpanded: $expanded,
            content: {
                Text("Resources & Application:")
                    .font(.headline)
                    .padding(.bottom, 2)
                Text(Bundle.main.resourcePath!)
                    .textSelection(.enabled)

                Text("Application Support:")
                    .font(.headline)
                    .padding(.bottom, 2)
                Text(URL.applicationSupportDirectory.path(percentEncoded: false))
                    .textSelection(.enabled)

                Text("Home:")
                    .font(.headline)
                    .padding(.bottom, 2)
                Text(URL.homeDirectory.path(percentEncoded: false))
                    .textSelection(.enabled)

                VStack(alignment: .leading) {
                    Text("Documents:")
                        .font(.headline)
                        .padding(.bottom, 2)
                    Text(URL.documentsDirectory.path(percentEncoded: false))
                        .textSelection(.enabled)
                }
                Text("Library:")
                    .font(.headline)
                    .padding(.bottom, 2)
                Text(URL.libraryDirectory.path(percentEncoded: false))
                    .textSelection(.enabled)

                Text("temporary:")
                    .font(.headline)
                    .padding(.bottom, 2)
                Text(URL.temporaryDirectory.path(percentEncoded: false))
                    .textSelection(.enabled)
            },
            label: {
                Text("REPERTOIRES DE L'APPLICATION").font(.headline)
            }
        )
    }
}

struct AppVersionView_Previews: PreviewProvider {
    static var previews: some View {
        AppVersionView()
    }
}

struct RevisionView_Previews: PreviewProvider {
    static var previews: some View {
        RevisionView(revision: Version()
            .versioned("2.0.0")
            .commented(with: "Descriptif de version"))
            .previewLayout(.sizeThatFits)
    }
}

struct RevisionHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        RevisionHistoryView(revisions: AppVersion.shared.revisionHistory)
            .previewLayout(.sizeThatFits)
    }
}

struct DirectoriesListView_Previews: PreviewProvider {
    static var previews: some View {
        DirectoriesListView()
    }
}
