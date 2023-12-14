//
//  SettingsGeneral.swift
//  Cahier du Professeur (iOS)
//
//  Created by Lionel MICHAUD on 18/09/2022.
//

import HelpersView
import OSLog
import SwiftUI
import UserNotifications

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "SettingsGeneral"
)

struct SettingsGeneral: View {
    @Environment(UserContext.self)
    private var userContext

    var body: some View {
        @Bindable var userContext = userContext
        List {
            // Type d'interopérabilité avec les ENT
            Text("Importation de listes d'élèves au format")
            CasePicker(
                pickedCase: $userContext.prefs.interoperabilityEnum,
                label: "Interopérabilté avec"
            )
            .pickerStyle(.segmented)
            VStack(alignment: .leading) {
                Text("Les fichiers **`\(userContext.prefs.interoperabilityEnum.pickerString)`** importés doivent être au format CSV:")
                switch userContext.prefs.interoperabilityEnum {
                    case .proNote:
                        Group {
                            Text("1) Les fichiers liste d'élèves doivent contenir 3 colonnes nommées: **'Nom'**; **'Prén.'**; **'S'**.")
                                .padding(.top, 2)
                            Text("2) La colonne **'S'** contient le sexe avec pour convention **'Masculin'** ou **'Féminin'**.")
                                .padding(.top, 2)
                        }
                        .padding(.leading)

                    case .ecoleDirecte:
                        Group {
                            Text("1) Les fichiers liste d'élèves doivent contenir 3 colonnes nommées: **'Nom'**; **'Sexe'**.")
                                .padding(.top, 2)
                            Text("2) La colonne **'Nom'** contient les nom (sans espace) et prénom séparés par un espace.")
                                .padding(.top, 2)
                            Text("3) La colonne **'Sexe'** contient le sexe avec pour convention **'M'** ou **'F'**.")
                                .padding(.top, 2)
                        }
                        .padding(.leading)
                }
            }
            .foregroundColor(.secondary)

            Section {
                // Ordre d'affichage des noms des élèves
                Text("Ordre d'affichage des noms des élèves")
                CasePicker(
                    pickedCase: $userContext.prefs.nameDisplayOrderEnum,
                    label: "Ordre d'affichage des noms"
                )
                .pickerStyle(.segmented)
                // Ordre de tri des noms des élèves
                Text("Ordre de tri des noms des élèves")
                CasePicker(
                    pickedCase: $userContext.prefs.nameSortOrderEnum,
                    label: "Ordre de tri des noms"
                )
                .pickerStyle(.segmented)
            } header: {
                Text("Affichage")
                    .style(.sectionHeader)
            }

            Section {
                // Notification quotidienne des ToDo du jour éventuels
                Toggle("Quotidienne", isOn: $userContext.prefs.notificationsEnabled)

                // Alerte au lancement de l'app sur les ToDo du jour
                Toggle("Au lancement de l'App", isOn: $userContext.prefs.launchAlertEnabled)

                #if DEBUG
                    Button {
                        addTestNotification()
                    } label: {
                        Label("Tester une notification", systemImage: "bell")
                    }
                    .tint(.orange)
                #endif

            } header: {
                Text("Notification des rappels")
                    .style(.sectionHeader)
            } footer: {
                Text("""
                Vous pouvez activer une notification quotidienne ou au lanement de l'App, pour vous informer des éventuelles tâches à réaliser pour la journée en cours telles que des impressions de document ou chargements de documents partagés sur l'ENT.
                """)
            }
            .onChange(of: userContext.prefs.notificationsEnabled) { oldValue, newValue in
                manageNotificationSettingChanges(oldValue: oldValue, newValue: newValue)
            }
            // .listRowSeparator(.hidden)
        }
        #if os(iOS)
        .navigationTitle("Préférences Générales")
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

// MARK: - Methods

extension SettingsGeneral {
    private func manageNotificationSettingChanges(
        oldValue: Bool,
        newValue: Bool
    ) {
        let UNCenter = UNUserNotificationCenter.current()
        switch (oldValue, newValue) {
            case (false, true):
                // Try to register first notification request for daily ToDo reminders
                Task {
                    // Requests authorization to allow local and remote notifications for your app.
                    do {
                        let authorized = try await UNCenter.requestAuthorization(
                            options: [.alert, .badge, .sound]
                        )
                        // The value of authorized is true when the person grants authorization for one or more options.
                        if authorized {
                            #if DEBUG
                                customLog.log(
                                    level: .info,
                                    "Authorization for notifications has been GRANTED by user"
                                )
                            #endif
                            // register first notification request for daily ToDo reminders
                            await ReminderTaskManager.shared.schedulNextReminderNotification()
                        }
                    } catch {
                        customLog.log(
                            level: .error,
                            "Failed to request authorization for notifications with Error: \(error.localizedDescription)"
                        )
                    }
                }

            case (true, false):
                // Retirer toute notification pouvant déjà exister.
                Task {
                    await ReminderTaskManager.shared.removeNextReminderNotification()
                }

            default: break
        }
    }

    private func addTestNotification() {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "Test notification"
        content.subtitle = "Sous-titre"
        content.sound = UNNotificationSound.default

        var dateComponents = DateComponents()
        dateComponents.hour = 9
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        center.add(request)
    }
}

struct SettingsGeneral_Previews: PreviewProvider {
    static var previews: some View {
        SettingsGeneral()
            .environmentObject(UserPrefEntity())
    }
}
