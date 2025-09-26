//
//  ContentView.swift
//  Audiometry
//
//  Created by perez987 on 2025/09/25.
//


import SwiftUI

struct ContentView: View {
    // Patient Information
@State private var patientName: String = ""
@State private var patientAge: String = ""
@State private var patientJob: String = ""

    // Frequency test results in dB HL (Hearing Level)
    // Right ear frequencies: 500, 1000, 2000, 4000, 8000 Hz
@State private var rightEar500: String = ""
@State private var rightEar1000: String = ""
@State private var rightEar2000: String = ""
@State private var rightEar4000: String = ""
@State private var rightEar8000: String = ""

    // Left ear frequencies: 500, 1000, 2000, 4000, 8000 Hz
@State private var leftEar500: String = ""
@State private var leftEar1000: String = ""
@State private var leftEar2000: String = ""
@State private var leftEar4000: String = ""
@State private var leftEar8000: String = ""

var body: some View {
    ScrollView {
        VStack(alignment: .leading, spacing: 20) {
                // Title
            Text("Patient report")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 10)

                // Patient Information Section
            GroupBox("Patient Information") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Name:")
                            .frame(width: 60, alignment: .leading)
                        TextField("Enter patient name", text: $patientName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }

                    HStack {
                        Text("Age:")
                            .frame(width: 60, alignment: .leading)
                        TextField("Enter age", text: $patientAge)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 100)
                        Spacer()
                    }

                    HStack {
                        Text("Job:")
                            .frame(width: 60, alignment: .leading)
                        TextField("Enter job/occupation", text: $patientJob)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                .padding()
            }

                // Audiometric Testing Section
            GroupBox("Audiometric Testing Results (dB HL)") {
                VStack(spacing: 16) {
                        // Header
                    HStack {
                        Text("Frequency (Hz)")
                            .frame(width: 120, alignment: .leading)
                            .fontWeight(.semibold)
                        Text("Right Ear")
                            .frame(width: 100, alignment: .center)
                            .fontWeight(.semibold)
                        Text("Left Ear")
                            .frame(width: 100, alignment: .center)
                            .fontWeight(.semibold)
                    }

                    Divider()

                        // Frequency rows
                    frequencyRow(frequency: "500", rightValue: $rightEar500, leftValue: $leftEar500)
                    frequencyRow(frequency: "1000", rightValue: $rightEar1000, leftValue: $leftEar1000)
                    frequencyRow(frequency: "2000", rightValue: $rightEar2000, leftValue: $leftEar2000)
                    frequencyRow(frequency: "4000", rightValue: $rightEar4000, leftValue: $leftEar4000)
                    frequencyRow(frequency: "8000", rightValue: $rightEar8000, leftValue: $leftEar8000)
                }
                .padding()
            }

                // Results Section
            GroupBox("Assessment Results") {
                VStack(alignment: .leading, spacing: 12) {
                        // Hearing Loss Calculations
                    Text("Hearing Loss Assessment:")
                        .fontWeight(.semibold)

                    HStack {
                        VStack(alignment: .leading) {
                            Text("Right Ear: \(calculateHearingLoss(frequencies: getRightEarValues()))")
                            Text("Left Ear: \(calculateHearingLoss(frequencies: getLeftEarValues()))")
                            Text("Bilateral: \(calculateBilateralHearingLoss())")
                        }
                        Spacer()
                    }

                    Divider()

                        // SAL Index
                    Text("SAL Index (Speech Audiometry Level):")
                        .fontWeight(.semibold)

                    HStack {
                        VStack(alignment: .leading) {
                            Text("Right Ear SAL: \(calculateSAL(frequencies: getRightEarValues())) - \(getSALDegree(sal: calculateSALValue(frequencies: getRightEarValues())))")
                            Text("Left Ear SAL: \(calculateSAL(frequencies: getLeftEarValues())) - \(getSALDegree(sal: calculateSALValue(frequencies: getLeftEarValues())))")
                        }
                        Spacer()
                    }

                    Divider()

                        // ELI Index
                    Text("ELI Index (Ear Loss Index):")
                        .fontWeight(.semibold)

                    HStack {
                        VStack(alignment: .leading) {
                            Text("Right Ear ELI: \(calculateELI(frequencies: getRightEarValues())) - \(getELIDegree(eli: calculateELIValue(frequencies: getRightEarValues())))")
                            Text("Left Ear ELI: \(calculateELI(frequencies: getLeftEarValues())) - \(getELIDegree(eli: calculateELIValue(frequencies: getLeftEarValues())))")
                        }
                        Spacer()
                    }
                }
                .padding()
            }

                // Information Section
            GroupBox("Parameters Summary") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Patient: \(patientName.isEmpty ? "Not specified" : patientName)")
                    Text("Age: \(patientAge.isEmpty ? "Not specified" : patientAge)")
                    Text("Occupation: \(patientJob.isEmpty ? "Not specified" : patientJob)")

                    Divider()

                    Text("Test Frequencies: 500, 1000, 2000, 4000, 8000 Hz")
                    Text("Results are measured in dB HL (Hearing Level)")
                    Text("SAL Index: Average of 500, 1000, 2000 Hz (speech frequencies)")
                    Text("ELI Index: Average of all tested frequencies weighted for hearing loss impact")
                }
                .padding()
            }
        }
        .padding()
    }
    .frame(minWidth: 524, idealWidth: 524, maxWidth: 524, minHeight: 860, idealHeight: 860, maxHeight: 860)
}

    // Helper function to create frequency input rows
private func frequencyRow(frequency: String, rightValue: Binding<String>, leftValue: Binding<String>) -> some View {
    HStack {
        Text(frequency)
            .frame(width: 120, alignment: .leading)

        TextField("dB", text: rightValue)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .frame(width: 100)
//                .keyboardType(.numberPad)

        TextField("dB", text: leftValue)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .frame(width: 100)
//                .keyboardType(.numberPad)
    }
}

    // Helper functions to get ear values as arrays
private func getRightEarValues() -> [Double] {
    return [
        Double(rightEar500) ?? 0,
        Double(rightEar1000) ?? 0,
        Double(rightEar2000) ?? 0,
        Double(rightEar4000) ?? 0,
        Double(rightEar8000) ?? 0
    ]
}

private func getLeftEarValues() -> [Double] {
    return [
        Double(leftEar500) ?? 0,
        Double(leftEar1000) ?? 0,
        Double(leftEar2000) ?? 0,
        Double(leftEar4000) ?? 0,
        Double(leftEar8000) ?? 0
    ]
}

    // Hearing Loss Calculation
private func calculateHearingLoss(frequencies: [Double]) -> String {
    let average = frequencies.reduce(0, +) / Double(frequencies.count)

    if average <= 25 {
        return "\(String(format: "%.1f", average)) dB - Normal"
    } else if average <= 40 {
        return "\(String(format: "%.1f", average)) dB - Mild"
    } else if average <= 55 {
        return "\(String(format: "%.1f", average)) dB - Moderate"
    } else if average <= 70 {
        return "\(String(format: "%.1f", average)) dB - Moderate-Severe"
    } else if average <= 90 {
        return "\(String(format: "%.1f", average)) dB - Severe"
    } else {
        return "\(String(format: "%.1f", average)) dB - Profound"
    }
}

    // Bilateral Hearing Loss Calculation
private func calculateBilateralHearingLoss() -> String {
    let rightValues = getRightEarValues()
    let leftValues = getLeftEarValues()

    let rightAverage = rightValues.reduce(0, +) / Double(rightValues.count)
    let leftAverage = leftValues.reduce(0, +) / Double(leftValues.count)
    let bilateralAverage = (rightAverage + leftAverage) / 2

    if bilateralAverage <= 25 {
        return "\(String(format: "%.1f", bilateralAverage)) dB - Normal"
    } else if bilateralAverage <= 40 {
        return "\(String(format: "%.1f", bilateralAverage)) dB - Mild"
    } else if bilateralAverage <= 55 {
        return "\(String(format: "%.1f", bilateralAverage)) dB - Moderate"
    } else if bilateralAverage <= 70 {
        return "\(String(format: "%.1f", bilateralAverage)) dB - Moderate-Severe"
    } else if bilateralAverage <= 90 {
        return "\(String(format: "%.1f", bilateralAverage)) dB - Severe"
    } else {
        return "\(String(format: "%.1f", bilateralAverage)) dB - Profound"
    }
}

    // SAL Index Calculation (Speech Audiometry Level)
private func calculateSAL(frequencies: [Double]) -> String {
    let sal = calculateSALValue(frequencies: frequencies)
    return String(format: "%.1f dB", sal)
}

private func calculateSALValue(frequencies: [Double]) -> Double {
        // SAL uses speech frequencies: 500, 1000, 2000 Hz
    let speechFrequencies = Array(frequencies.prefix(3))
    return speechFrequencies.reduce(0, +) / Double(speechFrequencies.count)
}

private func getSALDegree(sal: Double) -> String {
    if sal <= 25 {
        return "Normal"
    } else if sal <= 40 {
        return "Mild"
    } else if sal <= 55 {
        return "Moderate"
    } else if sal <= 70 {
        return "Moderate-Severe"
    } else if sal <= 90 {
        return "Severe"
    } else {
        return "Profound"
    }
}

    // ELI Index Calculation (Ear Loss Index)
private func calculateELI(frequencies: [Double]) -> String {
    let eli = calculateELIValue(frequencies: frequencies)
    return String(format: "%.1f dB", eli)
}

private func calculateELIValue(frequencies: [Double]) -> Double {
        // ELI uses weighted average of all frequencies
        // Weights: 500Hz(0.15), 1000Hz(0.25), 2000Hz(0.25), 4000Hz(0.25), 8000Hz(0.1)
    let weights = [0.15, 0.25, 0.25, 0.25, 0.1]
    var weightedSum = 0.0

    for (index, frequency) in frequencies.enumerated() {
        if index < weights.count {
            weightedSum += frequency * weights[index]
        }
    }

    return weightedSum
}

private func getELIDegree(eli: Double) -> String {
    if eli <= 25 {
        return "Normal"
    } else if eli <= 40 {
        return "Mild"
    } else if eli <= 55 {
        return "Moderate"
    } else if eli <= 70 {
        return "Moderate-Severe"
    } else if eli <= 90 {
        return "Severe"
    } else {
        return "Profound"
    }
}
}

#Preview {
ContentView()
}

