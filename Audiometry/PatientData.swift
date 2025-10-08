//
//  PatientData.swift
//  Audiometry
//
//  SwiftUI native data storage model
//
//  Created by GitHub Copilot on 20/09/2025.
//  Modified by perez987 on 20/09/2025.
//

import Foundation
import SwiftUI

struct PatientData: Codable, Identifiable, Equatable {
    var id: UUID
    var name: String
    var age: String
    var job: String
    var rightEar500: String
    var rightEar1000: String
    var rightEar2000: String
    var rightEar4000: String
    var rightEar8000: String
    var leftEar500: String
    var leftEar1000: String
    var leftEar2000: String
    var leftEar4000: String
    var leftEar8000: String
    var dateCreated: Date
    var dateModified: Date
    
    init(id: UUID = UUID()) {
        self.id = id
        self.name = ""
        self.age = ""
        self.job = ""
        self.rightEar500 = ""
        self.rightEar1000 = ""
        self.rightEar2000 = ""
        self.rightEar4000 = ""
        self.rightEar8000 = ""
        self.leftEar500 = ""
        self.leftEar1000 = ""
        self.leftEar2000 = ""
        self.leftEar4000 = ""
        self.leftEar8000 = ""
        self.dateCreated = Date()
        self.dateModified = Date()
    }
    
    mutating func updateModifiedDate() {
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
