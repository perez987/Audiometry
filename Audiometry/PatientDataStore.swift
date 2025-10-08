//
//  PatientDataStore.swift
//  Audiometry
//
//  SwiftUI native data storage manager
//
//  Created by GitHub Copilot on 20/09/2025.
//  Modified by perez987 on 20/09/2025.
//

import Foundation
import SwiftUI
import Combine

class PatientDataStore: ObservableObject {
    static let shared = PatientDataStore()
    
    @Published var patients: [PatientData] = []
    
    private let saveKey = "SavedPatients"
    private let fileManager = FileManager.default
    private let documentsDirectory: URL
    
    init() {
        // Get the application support directory
        let appSupportDir = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDirectory = appSupportDir.appendingPathComponent("Audiometry", isDirectory: true)
        
        // Create directory if it doesn't exist
        try? fileManager.createDirectory(at: appDirectory, withIntermediateDirectories: true)
        
        documentsDirectory = appDirectory
        loadPatients()
    }
    
    // MARK: - File Path
    private var patientsFileURL: URL {
        documentsDirectory.appendingPathComponent("patients.json")
    }
    
    // MARK: - Load and Save
    func loadPatients() {
        guard fileManager.fileExists(atPath: patientsFileURL.path) else {
            patients = []
            return
        }
        
        do {
            let data = try Data(contentsOf: patientsFileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            patients = try decoder.decode([PatientData].self, from: data)
            print("Loaded \(patients.count) patients from SwiftUI storage")
        } catch {
            print("Error loading patients from SwiftUI storage: \(error.localizedDescription)")
            patients = []
        }
    }
    
    func savePatients() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(patients)
            try data.write(to: patientsFileURL, options: .atomic)
            print("Saved \(patients.count) patients to SwiftUI storage")
        } catch {
            print("Error saving patients to SwiftUI storage: \(error.localizedDescription)")
        }
    }
    
    // MARK: - CRUD Operations
    func fetchPatients() -> [PatientData] {
        // Sort by name
        return patients.sorted { $0.name < $1.name }
    }
    
    func addPatient(_ patient: PatientData) {
        patients.append(patient)
        savePatients()
    }
    
    func updatePatient(_ patient: PatientData) {
        if let index = patients.firstIndex(where: { $0.id == patient.id }) {
            patients[index] = patient
            savePatients()
        }
    }
    
    func deletePatient(_ patient: PatientData) {
        patients.removeAll { $0.id == patient.id }
        savePatients()
    }
    
    func searchPatients(by name: String) -> [PatientData] {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmedName.isEmpty else {
            return fetchPatients()
        }
        
        return patients.filter { patient in
            patient.name.lowercased().contains(trimmedName)
        }.sorted { $0.name < $1.name }
    }
    
    // MARK: - Preview Helper
    static var preview: PatientDataStore {
        let store = PatientDataStore()
        
        var samplePatient = PatientData()
        samplePatient.name = "John Sketches"
        samplePatient.age = "45"
        samplePatient.job = "Engineer"
        samplePatient.rightEar500 = "25"
        samplePatient.rightEar1000 = "30"
        samplePatient.rightEar2000 = "35"
        samplePatient.rightEar4000 = "40"
        samplePatient.rightEar8000 = "45"
        samplePatient.leftEar500 = "20"
        samplePatient.leftEar1000 = "25"
        samplePatient.leftEar2000 = "30"
        samplePatient.leftEar4000 = "35"
        samplePatient.leftEar8000 = "40"
        
        store.patients = [samplePatient]
        return store
    }
}
