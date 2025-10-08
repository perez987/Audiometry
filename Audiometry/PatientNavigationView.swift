//
//  PatientNavigationView.swift
//  Audiometry
//
//  Created by GitHub Copilot on 20/09/2025.
//  Modified by perez987 on 20/09/2025.
//
//  FIXED: Language switching Menu to avoid ViewBridge errors
//  - Removed BorderlessButtonMenuStyle() that could cause ViewBridge issues
//  - Added checkmark indicator for currently selected language
//  - Menu now properly observes LanguageManager for UI updates
//

import SwiftUI
import CoreData

struct PatientNavigationView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var languageManager = LanguageManager.shared
    @State private var searchText = ""
    @State private var showingSearchResults = false
    @State private var searchResults: [Patient] = []
	@State private var showingPrintView = false
	@State private var printAllPatients = false

    let currentPatient: Patient?
    let allPatients: [Patient]
    let onPatientSelected: (Patient) -> Void
    let onNewPatient: () -> Void
    let onSavePatient: () -> Void
    let onForceSave: () -> Void
    
    var currentIndex: Int {
        guard let current = currentPatient else { return -1 }
        return allPatients.firstIndex(of: current) ?? -1
    }
    
    var hasPrevious: Bool {
        currentIndex > 0 && !allPatients.isEmpty
    }
    
    var hasNext: Bool {
        currentIndex < allPatients.count - 1 && currentIndex >= 0
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Top row: Language selector, search box and Find button
            HStack(spacing: 12) {
                // Language Selector
                Menu {
                    ForEach(LanguageManager.Language.allCases, id: \.self) { language in
                        Button(action: {
                            // Add small delay to avoid ViewBridge errors from rapid UI updates
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                languageManager.setLanguage(language)
                            }
                        }) {
                            HStack {
                                Text(language.displayName)
                                if languageManager.currentLanguage == language {
//                                Spacer()
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "globe")
                        Text("language".localized)
                    }
                }
                .help("select_language".localized) //Tooltip

                Spacer()
                
                // Search
                HStack {
                    TextField("search_placeholder".localized, text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 300)
                        .onSubmit {
                            performSearch()
                        }
                    
                    Button("search_patient".localized) {
                        performSearch()
                    }
                    .frame(width: 80)
                    .disabled(searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            
            // Bottom row: Patient management buttons (New, Save, Prev, Next)
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
            PatientSearchResultsView(
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
        
        // MARK: workaround to resolve the issue with the search function:
        // - Search returns "No patients found" on the first attempt
        // - Navigating patient list using Next/Back buttons
        // is required for the search to work.
        // It's a work in progress
        
        if allPatients.isEmpty {
                 let thisPatient = allPatients[currentIndex]
                 onPatientSelected(thisPatient)
             }
        else {
            if hasPrevious {
//                 let previousPatient = allPatients[currentIndex - 1]
//                 onPatientSelected(previousPatient)
                onPatientSelected(allPatients[currentIndex - 1])
            }
            else if hasNext {
//                 let previousPatient = allPatients[currentIndex + 1]
//                 onPatientSelected(previousPatient)
                onPatientSelected(allPatients[currentIndex + 1])
            }
            else {
                if (currentIndex == 0) {
                    onPatientSelected(allPatients[currentIndex + 1])
                }
                else if (currentIndex == allPatients.count-1) {
                    onPatientSelected(allPatients[currentIndex - 1])
                }
            }
        }
        
        // Search using the shared persistence controller
        searchResults = PersistenceController.shared.searchPatients(by: trimmedSearch)
        showingSearchResults = true
        }
    }

struct PatientSearchResultsView: View {
    let searchResults: [Patient]
    let searchText: String
    let onPatientSelected: (Patient) -> Void
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
                            VStack(alignment: .leading, spacing: 8) {
                                Text(patient.name.isEmpty ? "not_specified".localized : patient.name)
                                    .font(.title2)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                
                                HStack {
                                    Text("age_label".localized)
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                    Text(patient.age.isEmpty ? "not_specified".localized : patient.age)
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    Text(DateFormatter.shortDateTime.string(from: patient.dateModified))
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 4)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
//                Spacer()
                
            }
            .navigationTitle("search_patient".localized + ": \(searchText)")
            .toolbar {
                ToolbarItem(placement: .principal) {
                	Text("search_results_for".localized + " \"\(searchText)\"")
                    .font(.headline)
            }
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel".localized) {
                        onDismiss()
                    }
                }
            }
			.frame(minWidth: 320, idealWidth: 320, maxWidth: 320, minHeight: 300, idealHeight: 300, maxHeight: 300)
    }
}

extension DateFormatter {
    static let shortDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}
