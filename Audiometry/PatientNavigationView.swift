//
//  PatientNavigationView.swift
//  Audiometry
//
//  Created by GitHub Copilot on 2025/01/10.
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
                Button("new_patient".localized) {
                    onNewPatient()
                }
//                .frame(width: 80)
                
                Button("save_patient".localized) {
                    onSavePatient()
                }
//                .frame(width: 80)
                .disabled(currentPatient == nil)
                
                Divider()
                    .frame(height: 20)
                
                Button("previous_patient".localized) {
                    if hasPrevious {
                        let previousPatient = allPatients[currentIndex - 1]
                        onPatientSelected(previousPatient)
                    }
                }
//                .frame(width: 80)
                .disabled(!hasPrevious)
                
                Text("\(currentIndex + 1) / \(allPatients.count)")
                    .foregroundColor(.secondary)
//                    .frame(minWidth: 50, idealWidth: 50, maxWidth: 50)
                
                Button("next_patient".localized) {
                    if hasNext {
                        let nextPatient = allPatients[currentIndex + 1]
                        onPatientSelected(nextPatient)
                    }
                }
//                .frame(width: 80)
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
    }
    
    private func performSearch() {
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedSearch.isEmpty else { return }
        
        // Force save any pending changes before searching to ensure data consistency
        onForceSave()
        
        // Add a small delay to ensure the save operation completes before searching
        // This prevents race conditions between auto-save and search operations
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.executeSearch(trimmedSearch)
        }
    }
    
    private func executeSearch(_ searchTerm: String) {
        // Use the local viewContext to ensure consistency with current data
        let context = viewContext
        
        // Process any remaining pending changes
        context.processPendingChanges()
        
        let request: NSFetchRequest<Patient> = Patient.fetchRequest()
        request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchTerm)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Patient.name, ascending: true)]
        // Ensure we get fresh data from the persistent store
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(request)
            DispatchQueue.main.async {
                self.searchResults = results
                // Add small delay before showing sheet to prevent ViewBridge errors
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    self.showingSearchResults = true
                }
            }
        } catch {
            print("Error searching patients: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.searchResults = []
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    self.showingSearchResults = true
                }
            }
        }
    }
}

struct PatientSearchResultsView: View {
    let searchResults: [Patient]
    let searchText: String
    let onPatientSelected: (Patient) -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("search_patient".localized + ": \(searchText)")
                    .font(.title2)
                    .fontWeight(.medium)
                Spacer()
                Button("cancel".localized) {
                    onDismiss()
                }
            }
            .padding()
            
            if searchResults.isEmpty {
                // Empty state
                VStack(spacing: 16) {
                    Image(systemName: "person.fill.questionmark")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("no_patients_found".localized)
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .padding(40)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Results list
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(searchResults) { patient in
                            Button(action: {
                                onPatientSelected(patient)
                            }) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(patient.name.isEmpty ? "not_specified".localized : patient.name)
                                        .font(.title3)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
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
                                .padding()
                                .background(Color(NSColor.controlBackgroundColor))
                                .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
            }
        }
        .frame(minWidth: 400, idealWidth: 500, maxWidth: 600, minHeight: 300, idealHeight: 400, maxHeight: 500)
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
