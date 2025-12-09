//
//  AudiometryCalculations.swift
//  Audiometry
//
//  Modified by perez987 on 20/09/2025.
//

import Foundation

/// Audiometry calculation utilities for hearing assessment
struct AudiometryCalculations {

    // MARK: - Hearing Loss Classification

    /// Calculate hearing loss level and classification
    /// - Parameter frequencies: Array of dB HL values for tested frequencies
    /// - Returns: Tuple containing average dB and classification string
static func calculateHearingLoss(frequencies: [Double]) -> (average: Double, classification: String) {
    guard !frequencies.isEmpty else { return (0.0, "No data") }

    let average = frequencies.reduce(0, +) / Double(frequencies.count)
    let classification = classifyHearingLoss(average: average)

    return (average, classification)
}

    /// Classify hearing loss based on average dB HL
    /// - Parameter average: Average dB HL value
    /// - Returns: Classification string
static func classifyHearingLoss(average: Double) -> String {
    switch average {
    case ...25:
        return "Normal"
    case 26...40:
        return "Mild"
    case 41...55:
        return "Moderate"
    case 56...70:
        return "Moderate-Severe"
    case 71...90:
        return "Severe"
    default:
        return "Profound"
    }
}

    // MARK: - SAL Index (Speech Audiometry Level)

    /// Calculate SAL index using speech frequencies (500, 1000, 2000 Hz)
    /// - Parameter frequencies: Array of all frequency values [500, 1000, 2000, 4000, 8000]
    /// - Returns: Tuple containing SAL value and classification
static func calculateSAL(frequencies: [Double]) -> (value: Double, classification: String) {
    guard frequencies.count >= 3 else { return (0.0, "Insufficient data") }

        // Use first three frequencies (500, 1000, 2000 Hz)
    let speechFrequencies = Array(frequencies.prefix(3))
    let salValue = speechFrequencies.reduce(0, +) / Double(speechFrequencies.count)
    let classification = classifyHearingLoss(average: salValue)

    return (salValue, classification)
}

    // MARK: - ELI Index (Ear Loss Index)

    /// Calculate ELI index using weighted frequencies
    /// - Parameter frequencies: Array of frequency values [500, 1000, 2000, 4000, 8000]
    /// - Returns: Tuple containing ELI value and classification
static func calculateELI(frequencies: [Double]) -> (value: Double, classification: String) {
    guard frequencies.count >= 5 else { return (0.0, "Insufficient data") }

        // Frequency weights: 500Hz(15%), 1000Hz(25%), 2000Hz(25%), 4000Hz(25%), 8000Hz(10%)
    let weights = [0.15, 0.25, 0.25, 0.25, 0.10]

    var weightedSum = 0.0
    for (index, frequency) in frequencies.enumerated() {
        if index < weights.count {
            weightedSum += frequency * weights[index]
        }
    }

    let classification = classifyHearingLoss(average: weightedSum)
    return (weightedSum, classification)
}

    // MARK: - Bilateral Calculations

    /// Calculate bilateral hearing loss from both ears
    /// - Parameters:
    ///   - rightEar: Array of right ear frequency values
    ///   - leftEar: Array of left ear frequency values
    /// - Returns: Tuple containing bilateral average and classification
static func calculateBilateralHearingLoss(rightEar: [Double], leftEar: [Double]) -> (average: Double, classification: String) {
    let rightResult = calculateHearingLoss(frequencies: rightEar)
    let leftResult = calculateHearingLoss(frequencies: leftEar)

    let bilateralAverage = (rightResult.average + leftResult.average) / 2
    let classification = classifyHearingLoss(average: bilateralAverage)

    return (bilateralAverage, classification)
}

    // MARK: - Utility Functions

    /// Format dB value for display
    /// - Parameter value: dB value
    /// - Returns: Formatted string
static func formatDB(_ value: Double) -> String {
    return String(format: "%.1f dB", value)
}

    /// Validate frequency input
    /// - Parameter value: Input value to validate
    /// - Returns: True if valid dB HL value (0-120 dB)
static func isValidHearingLevel(_ value: Double) -> Bool {
    return value >= 0 && value <= 120
}
}

// MARK: - Test Functions

#if DEBUG
extension AudiometryCalculations {

    /// Test function for calculation validation
static func runTests() {
    print("Running Audiometry Calculations Tests...")

        // Test normal hearing
    let normalHearing = [10.0, 15.0, 20.0, 25.0, 20.0]
    let normalResult = calculateHearingLoss(frequencies: normalHearing)
    print("Normal hearing test: \(formatDB(normalResult.average)) - \(normalResult.classification)")

        // Test mild hearing loss
    let mildLoss = [30.0, 35.0, 40.0, 45.0, 50.0]
    let mildResult = calculateHearingLoss(frequencies: mildLoss)
    print("Mild loss test: \(formatDB(mildResult.average)) - \(mildResult.classification)")

        // Test SAL calculation
    let salResult = calculateSAL(frequencies: normalHearing)
    print("SAL test: \(formatDB(salResult.value)) - \(salResult.classification)")

        // Test ELI calculation
    let eliResult = calculateELI(frequencies: mildLoss)
    print("ELI test: \(formatDB(eliResult.value)) - \(eliResult.classification)")

        // Test bilateral calculation
    let bilateralResult = calculateBilateralHearingLoss(rightEar: normalHearing, leftEar: mildLoss)
    print("Bilateral test: \(formatDB(bilateralResult.average)) - \(bilateralResult.classification)")

    print("Tests completed.")
}
}
#endif
