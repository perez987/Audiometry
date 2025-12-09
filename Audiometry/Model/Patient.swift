//
//  Patient.swift
//  Audiometry
//
//  Modified by perez987 on 20/09/2025.
//

import Foundation
import CoreData
import SwiftUI

@objc(Patient)
public class Patient: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var age: String
    @NSManaged public var job: String
    @NSManaged public var rightEar500: String
    @NSManaged public var rightEar1000: String
    @NSManaged public var rightEar2000: String
    @NSManaged public var rightEar4000: String
    @NSManaged public var rightEar8000: String
    @NSManaged public var leftEar500: String
    @NSManaged public var leftEar1000: String
    @NSManaged public var leftEar2000: String
    @NSManaged public var leftEar4000: String
    @NSManaged public var leftEar8000: String
    @NSManaged public var dateCreated: Date
    @NSManaged public var dateModified: Date
}

extension Patient {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Patient> {
        return NSFetchRequest<Patient>(entityName: "Patient")
    }
    
    static func create(in context: NSManagedObjectContext) -> Patient {
        let patient = Patient(context: context)
        patient.id = UUID()
        patient.name = ""
        patient.age = ""
        patient.job = ""
        patient.rightEar500 = ""
        patient.rightEar1000 = ""
        patient.rightEar2000 = ""
        patient.rightEar4000 = ""
        patient.rightEar8000 = ""
        patient.leftEar500 = ""
        patient.leftEar1000 = ""
        patient.leftEar2000 = ""
        patient.leftEar4000 = ""
        patient.leftEar8000 = ""
        patient.dateCreated = Date()
        patient.dateModified = Date()
        return patient
    }
    
    func updateModifiedDate() {
        dateModified = Date()
    }
    
    // Helper methods for calculations
    func getRightEarValues() -> [Double] {
        return [
            Double(rightEar500) ?? 0,
            Double(rightEar1000) ?? 0,
            Double(rightEar2000) ?? 0,
            Double(rightEar4000) ?? 0,
            Double(rightEar8000) ?? 0
        ]
    }
    
    func getLeftEarValues() -> [Double] {
        return [
            Double(leftEar500) ?? 0,
            Double(leftEar1000) ?? 0,
            Double(leftEar2000) ?? 0,
            Double(leftEar4000) ?? 0,
            Double(leftEar8000) ?? 0
        ]
    }
}

extension Patient: Identifiable {
    
}
