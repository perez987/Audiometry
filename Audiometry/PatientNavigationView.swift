//
//  PatientNavigationView.swift
//  Audiometry
//
//  Created by GitHub Copilot on 2025/01/10.
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
        HStack(spacing: 12) {
            // Language Selector
            Menu {
                ForEach(LanguageManager.Language.allCases, id: \.self) { language in
                    Button(language.displayName) {
                        languageManager.setLanguage(language)
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "globe")
//                    Text("language".localized)
                }
            }
            .menuStyle(BorderlessButtonMenuStyle())
            
            Spacer()
            
            // Search
            HStack {
                TextField("search_placeholder".localized, text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 200)
                    .onSubmit {
                        performSearch()
                    }
                
                Button("search_patient".localized) {
                    performSearch()
                }
                .disabled(searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            
            Spacer()
            
            // Patient Navigation
            HStack(spacing: 8) {
                Button("new_patient".localized) {
                    onNewPatient()
                }
                
                Button("save_patient".localized) {
                    onSavePatient()
                }
                .disabled(currentPatient == nil)
                
                Divider()
                    .frame(height: 20)
                
                Button("previous_patient".localized) {
                    if hasPrevious {
                        let previousPatient = allPatients[currentIndex - 1]
                        onPatientSelected(previousPatient)
                    }
                }
                .disabled(!hasPrevious)
                
                Text("\(currentIndex + 1) / \(allPatients.count)")
                    .foregroundColor(.secondary)
                    .frame(minWidth: 60)
                
                Button("next_patient".localized) {
                    if hasNext {
                        let nextPatient = allPatients[currentIndex + 1]
                        onPatientSelected(nextPatient)
                    }
                }
                .disabled(!hasNext)
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
        NavigationView {
            VStack {
                if searchResults.isEmpty {
                    Text("no_patients_found".localized)
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    List(searchResults) { patient in
                        Button(action: {
                            onPatientSelected(patient)
                        }) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(patient.name.isEmpty ? "not_specified".localized : patient.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                HStack {
                                    Text("age_label".localized)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(patient.age.isEmpty ? "not_specified".localized : patient.age)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    Text(DateFormatter.shortDateTime.string(from: patient.dateModified))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 2)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                Spacer()
            }
            .navigationTitle("search_patient".localized + ": \(searchText)")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel".localized) {
                        onDismiss()
                    }
                }
            }
        }
        .frame(minWidth: 500, minHeight: 400)
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
