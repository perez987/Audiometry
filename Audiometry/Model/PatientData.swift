//
//  PatientData.swift
//  Audiometry
//
//  SwiftUI native data storage model
//
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
        name = ""
        age = ""
        job = ""
        rightEar500 = ""
        rightEar1000 = ""
        rightEar2000 = ""
        rightEar4000 = ""
        rightEar8000 = ""
        leftEar500 = ""
        leftEar1000 = ""
        leftEar2000 = ""
        leftEar4000 = ""
        leftEar8000 = ""
        dateCreated = Date()
        dateModified = Date()
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
            Double(rightEar8000) ?? 0,
        ]
    }

    func getLeftEarValues() -> [Double] {
        return [
            Double(leftEar500) ?? 0,
            Double(leftEar1000) ?? 0,
            Double(leftEar2000) ?? 0,
            Double(leftEar4000) ?? 0,
            Double(leftEar8000) ?? 0,
        ]
    }
}
