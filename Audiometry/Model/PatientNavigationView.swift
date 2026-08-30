//
//  PatientNavigationView.swift
//  Audiometry
//
//  Modified by perez987 on 20/09/2025.
//

import SwiftUI

struct PatientNavigationView: View {
    @ObservedObject var languageManager = LanguageManager.shared
    @ObservedObject var dataStore = PatientDataStore.shared
    @State private var searchText = ""
    @State private var showingSearchResults = false
    @State private var searchResults: [PatientData] = []
	@State private var showingPrintView = false
	@State private var printAllPatients = false
	@State private var showingDeleteConfirmation = false

    let currentPatient: PatientData?
    let allPatients: [PatientData]
    let onPatientSelected: (PatientData) -> Void
    let onNewPatient: () -> Void
    let onSavePatient: () -> Void
    let onDeletePatient: () -> Void
    let onForceSave: () -> Void
    
    var currentIndex: Int {
        guard let current = currentPatient else { return -1 }
        return allPatients.firstIndex(where: { $0.id == current.id }) ?? -1
    }
    
    var hasPrevious: Bool {
        currentIndex > 0
    }
    
    var hasNext: Bool {
        currentIndex >= 0 && currentIndex < allPatients.count - 1
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Top row: Language selector and search
            HStack(spacing: 12) {
                // Language Menu
                Menu {
                    ForEach(LanguageManager.Language.allCases, id: \.self) { language in
                        Button(action: {
                            languageManager.setLanguage(language)
                        }) {
                            HStack {
                                Text(language.displayName)
                                if languageManager.currentLanguage == language {
//                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(languageManager.currentLanguage.displayName)
//                        Image(systemName: "chevron.down")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.thinMaterial, in: Capsule())
                    .overlay(
                           RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue)
                           )
                }
                .help("select_language".localized)

                Spacer()
                
                // Search Field
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("search_by_name".localized, text: $searchText)
                        .textFieldStyle(.plain)
                        .frame(width: 300)
                        .onSubmit {
                            performSearch()
                        }
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.thinMaterial, in: Capsule())
            }
            
            // Second row: Patient management buttons
            HStack(spacing: 6) {
                Spacer()

                // New Patient Button
                Button {
                    onNewPatient()
                } label: {
                    Label("new_patient".localized, systemImage: "person.badge.plus")
                }
                .buttonStyle(.bordered)
                .tint(.blue)
                .help(Text("add_new_patient".localized))

                // Save Patient Button
                Button {
                    onSavePatient()
                } label: {
                    Label("save_patient".localized, systemImage: "square.and.arrow.down")
                }
                .buttonStyle(.bordered)
                .tint(.purple)
                .help(Text("save_data".localized))

                // Delete Patient Button
                Button {
                    showingDeleteConfirmation = true
                } label: {
                    Label("delete_patient".localized, systemImage: "trash")
                }
                .buttonStyle(.bordered)
                .tint(.red)
                .help(Text("delete_patient_tooltip".localized))
                .disabled(currentPatient == nil)
                .confirmationDialog("delete_patient_confirm".localized, isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
                    Button("delete_patient_action".localized, role: .destructive) {
                        onDeletePatient()
                    }
                    Button("cancel".localized, role: .cancel) {}
                }

                Divider()
                    .frame(height: 20)

                // Print Report Button
                Button {
                    printAllPatients = false
                    showingPrintView = true
                } label: {
                    Label("print_report".localized, systemImage: "printer")
                }
                .buttonStyle(.bordered)
                .tint(.indigo)
                .help(Text("print_report_preview".localized))
                .disabled(currentPatient == nil)

                Spacer()
            }

            // Third row: Navigation label and controls
            HStack(spacing: 6) {
                Spacer()

                Text("navigation_buttons_label".localized)
                    .font(.body)
                    .foregroundStyle(.primary)

                // Navigation Controls
                Button {
                    if hasPrevious {
                        let previousPatient = allPatients[currentIndex - 1]
                        onPatientSelected(previousPatient)
                    }
                } label: {
                    Image(systemName: "chevron.left")
                }
                .buttonStyle(.bordered)
                .help(Text("see_previous".localized))
                .disabled(!hasPrevious)

                Text("\(currentIndex + 1) / \(allPatients.count)")
                    .foregroundStyle(.primary)
                    .font(.callout)
                    .monospacedDigit()
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial, in: Capsule())

                Button {
                    if hasNext {
                        let nextPatient = allPatients[currentIndex + 1]
                        onPatientSelected(nextPatient)
                    }
                } label: {
                    Image(systemName: "chevron.right")
                }
                .buttonStyle(.bordered)
                .help(Text("see_next".localized))
                .disabled(!hasNext)

                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.top, 10)
        .padding(.bottom, 6)
        .sheet(isPresented: $showingSearchResults) {
            PatientSearchResultsViewSwiftUI(
                searchResults: searchResults,
                searchText: searchText,
                onPatientSelected: { patient in
                    onPatientSelected(patient)
                    showingSearchResults = false
                },
                onDismiss: {
                    showingSearchResults = false
                }
            )
        }

		.sheet(isPresented: $showingPrintView) {
			if printAllPatients {
				PrintReportView(patients: allPatients)
			} else if let patient = currentPatient {
				PrintReportView(patient: patient)
			}
		}
		
    }
    
    private func performSearch() {
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedSearch.isEmpty else { return }
        
        // Force save any pending changes before searching
        onForceSave()
        
        // Search using the shared data store
        searchResults = dataStore.searchPatients(by: trimmedSearch)
        showingSearchResults = true
    }
}

struct PatientSearchResultsViewSwiftUI: View {
    let searchResults: [PatientData]
    let searchText: String
    let onPatientSelected: (PatientData) -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        VStack {
            if searchResults.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "person.fill.questionmark")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("no_patients_found".localized)
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
                .padding(40)
            } else {
                List(searchResults) { patient in
                    Button(action: {
                        onPatientSelected(patient)
                    }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(patient.name)
                                .font(.headline)
                            HStack {
                                if !patient.age.isEmpty {
                                    Text("\("age_label".localized) \(patient.age)")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                if !patient.job.isEmpty {
                                    Text("•")
                                        .foregroundStyle(.secondary)
                                    Text(patient.job)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .listRowBackground(Color.clear)
                }
                .scrollContentBackground(.hidden)
            }
        }
        .background(.ultraThinMaterial)
        .frame(minWidth: 320, idealWidth: 320, maxWidth: 320, minHeight: 300, idealHeight: 300, maxHeight: 300)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("search_results_for".localized + " \"\(searchText)\"")
                    .font(.headline)
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("close".localized) {
                    onDismiss()
                }
            }
        }
    }
}
