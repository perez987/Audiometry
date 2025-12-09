//
//  PersistenceController.swift
//  Audiometry
//
//  Modified by perez987 on 20/09/2025.
//

import CoreData
import Foundation

struct PersistenceController {
    static let shared = PersistenceController()
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Add sample data for previews
        let samplePatient = Patient.create(in: viewContext)
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
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Unresolved error: \(nsError), \(nsError.localizedDescription)")
//            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "DataModel")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        } else {
            // Copy sample database on first run
            copySampleDatabaseIfNeeded()
        }
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                print("Unresolved error: \(error), \(error.localizedDescription)")
//                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    // MARK: - Sample Data Initialization
    private func copySampleDatabaseIfNeeded() {
        let fileManager = FileManager.default
        
        // Get the default store URL (where CoreData will save the database)
        // Use the container's default store description URL
        guard let storeURL = container.persistentStoreDescriptions.first?.url else {
            print("Could not determine store URL")
            return
        }
        
        // Check if database already exists
        if fileManager.fileExists(atPath: storeURL.path) {
            return // Database already exists, no need to copy
        }
        
        // Get the sample database from Resources bundle
        // Try without subdirectory first (files added to bundle root)
        guard let sampleURL = Bundle.main.url(forResource: "DataModel", withExtension: "sqlite") else {
            print("Sample database not found in Resources")
            return
        }
        
        // Create the Application Support directory if it doesn't exist
        let directoryURL = storeURL.deletingLastPathComponent()
        try? fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        
        // Copy the sample database to the store location
        do {
            try fileManager.copyItem(at: sampleURL, to: storeURL)
            print("Successfully copied sample CoreData database to: \(storeURL.path)")
            
            // Also copy the accompanying -shm and -wal files if they exist
            let shmSampleURL = sampleURL.deletingPathExtension().appendingPathExtension("sqlite-shm")
            let walSampleURL = sampleURL.deletingPathExtension().appendingPathExtension("sqlite-wal")
            let shmStoreURL = storeURL.deletingPathExtension().appendingPathExtension("sqlite-shm")
            let walStoreURL = storeURL.deletingPathExtension().appendingPathExtension("sqlite-wal")
            
            if fileManager.fileExists(atPath: shmSampleURL.path) {
                try? fileManager.copyItem(at: shmSampleURL, to: shmStoreURL)
            }
            if fileManager.fileExists(atPath: walSampleURL.path) {
                try? fileManager.copyItem(at: walSampleURL, to: walStoreURL)
            }
        } catch {
            print("Error copying sample database: \(error.localizedDescription)")
        }
    }
}

// MARK: - Convenience methods for data operations
extension PersistenceController {
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
//                let nsError = error as NSError
                print("Unresolved error: \(error), \(error.localizedDescription)")
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    func deletePatient(_ patient: Patient) {
        let context = container.viewContext
        context.delete(patient)
        save()
    }
    
    func fetchPatients() -> [Patient] {
        let context = container.viewContext
        
        // Process any pending changes to ensure we have the most up-to-date data
        context.processPendingChanges()
        
        // If there are unsaved changes, save them to ensure consistency with search
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving changes before fetch: \(error.localizedDescription)")
            }
        }
        
        let request: NSFetchRequest<Patient> = Patient.fetchRequest()
        // Sort by dateModified
//        request.sortDescriptors = [NSSortDescriptor(keyPath: \Patient.dateModified, ascending: false)]
        // Sort by patient name
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Patient.name, ascending: true)]
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching patients: \(error.localizedDescription)")
            return []
        }
    }
    
    func searchPatients(by name: String) -> [Patient] {
        let context = container.viewContext
        
        // Process any pending changes to ensure we have the most up-to-date data
        context.processPendingChanges()
        
        // If there are unsaved changes, save them to ensure search includes all data
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving changes before search: \(error.localizedDescription)")
            }
        }
        
        let request: NSFetchRequest<Patient> = Patient.fetchRequest()
        request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", name)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Patient.name, ascending: true)]
        // Ensure we get fresh data from the persistent store
        request.returnsObjectsAsFaults = false
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error searching patients: \(error.localizedDescription)")
            return []
        }
    }
}
