//
//  PatientNavigationViewSwiftUI.swift
//  Audiometry
//
//  Navigation view for SwiftUI data storage
//
//  Modified by perez987 on 20/09/2025.
//

import SwiftUI

struct PatientNavigationViewSwiftUI: View {
    @ObservedObject var languageManager = LanguageManager.shared
    @ObservedObject var dataStore = PatientDataStore.shared
    @State private var searchText = ""
    @State private var showingSearchResults = false
    @State private var searchResults: [PatientData] = []
	@State private var showingPrintView = false
	@State private var printAllPatients = false

    let currentPatient: PatientData?
    let allPatients: [PatientData]
    let onPatientSelected: (PatientData) -> Void
    let onNewPatient: () -> Void
    let onSavePatient: () -> Void
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
        VStack(spacing: 8) {
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
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "globe")
                        Text(languageManager.currentLanguage.displayName)
                    }
                }
                .help("select_language".localized) //Tooltip

                Spacer()
                
                // Search Field
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("search_by_name".localized, text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 340)
                        .onSubmit {
                            performSearch()
                        }
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            
            // Bottom row: Patient management and navigation buttons
            HStack(spacing: 8) {
                Spacer()
                
                // New Patient Button
                Button("new_patient".localized) {
                    onNewPatient()
                }
				.help(Text("add_new_patient".localized))

                // Save Patient Button
                Button("save_patient".localized) {
                    onSavePatient()
                }
				.help(Text("save_data".localized))

				Divider()
					.frame(height: 20)
                
                // Print Report Button
                Button("print_report".localized) {
                    printAllPatients = false
                    showingPrintView = true
                }
				.help(Text("print_report_preview".localized))
				.disabled(currentPatient == nil)

                // Print All Reports Button
//                Button("print_all_reports".localized) {
//                    printAllPatients = true
//                    showingPrintView = true
//                }
//				.help(Text("print_all_reports_preview".localized))
//                .disabled(allPatients.isEmpty)
//                
//                Divider()
//                    .frame(height: 20)
                
                // Navigation Controls
                Button("previous_patient".localized) {
                    if hasPrevious {
                        let previousPatient = allPatients[currentIndex - 1]
                        onPatientSelected(previousPatient)
                    }
                }
				.help(Text("see_previous".localized))
                .disabled(!hasPrevious)
                
                Text("\(currentIndex + 1) / \(allPatients.count)")
                    .foregroundColor(.secondary)
                
                Button("next_patient".localized) {
                    if hasNext {
                        let nextPatient = allPatients[currentIndex + 1]
                        onPatientSelected(nextPatient)
                    }
                }
				.help(Text("see_next".localized))
                .disabled(!hasNext)
                
                Spacer()
            }
        }
        .padding(.horizontal)
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
				PrintReportViewSwiftUI(patients: allPatients)
			} else if let patient = currentPatient {
				PrintReportViewSwiftUI(patient: patient)
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
                        .foregroundColor(.secondary)
                    Text("no_patients_found".localized)
                        .font(.title2)
                        .foregroundColor(.secondary)
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
                                        .foregroundColor(.secondary)
                                }
                                if !patient.job.isEmpty {
                                    Text("•")
                                        .foregroundColor(.secondary)
                                    Text(patient.job)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
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
