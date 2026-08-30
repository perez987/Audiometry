//
//  ContentView.swift
//  Audiometry
//
//  Modified by perez987 on 20/09/2025.
//

import Combine
import SwiftUI

struct ContentView: View {
    @ObservedObject private var languageManager = LanguageManager.shared
    @ObservedObject private var dataStore = PatientDataStore.shared

    // Current patient being edited
    @State private var currentPatient: PatientData?
    @State private var allPatients: [PatientData] = []

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

    /// Auto-save with debouncing using structured concurrency
    @State private var autoSaveTask: Task<Void, any Error>?

    var body: some View {
        VStack(spacing: 0) {
            // Navigation bar
            PatientNavigationView(
                currentPatient: currentPatient,
                allPatients: allPatients,
                onPatientSelected: loadPatient,
                onNewPatient: createNewPatient,
                onSavePatient: saveCurrentPatient,
                onDeletePatient: deleteCurrentPatient,
                onForceSave: forceSavePendingChanges
            )
            .padding(.vertical, 8)
            .padding(.bottom, 6)
            .background(.ultraThinMaterial)
            .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 3)

//            Divider()
            Spacer()

            // Main content
            ZStack {
                // Gradient background so glass cards have something to show through
                LinearGradient(
                    colors: [
                        Color(red: 0.55, green: 0.75, blue: 1.0).opacity(0.25),
                        Color(red: 0.65, green: 0.55, blue: 1.0).opacity(0.20),
                        Color(red: 0.45, green: 0.65, blue: 0.95).opacity(0.25),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Title with gradient
                        Text("patient_report".localized)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.indigo, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .padding(.bottom, 10)

                        // Patient Information Section
                        GroupBox("patient_information".localized) {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("name".localized)
                                        .frame(width: 72, alignment: .leading)
                                    TextField("enter_patient_name".localized, text: $patientName)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(width: 380)
                                        .onChange(of: patientName) { _, _ in
                                            updateCurrentPatient()
                                        }
                                }

                                HStack {
                                    Text("age".localized)
                                        .frame(width: 72, alignment: .leading)
                                    TextField("enter_age".localized, text: $patientAge)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(width: 140)
                                        .onChange(of: patientAge) { _, _ in
                                            updateCurrentPatient()
                                        }
                                    Spacer()
                                }

                                HStack {
                                    Text("job".localized)
                                        .frame(width: 72, alignment: .leading)
                                    TextField("enter_job_occupation".localized, text: $patientJob)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(width: 380)
                                        .onChange(of: patientJob) { _, _ in
                                            updateCurrentPatient()
                                        }
                                }
                            }
                            .padding()
                        }
                        .groupBoxStyle(GlassGroupBoxStyle())

                        // Audiometric Testing Section
                        GroupBox("audiometric_testing_results".localized) {
                            VStack(spacing: 16) {
                                // Header
                                HStack {
                                    Text("frequency_hz".localized)
                                        .frame(width: 120, alignment: .leading)
                                        .fontWeight(.semibold)
                                    Text("right_ear".localized)
                                        .frame(width: 100, alignment: .center)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(Color.red)
                                    Text("left_ear".localized)
                                        .frame(width: 100, alignment: .center)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(Color.blue)
                                }

                                Divider()

                                // Frequency rows with alternating background
                                frequencyRow(frequency: "500 Hz", rightValue: $rightEar500, leftValue: $leftEar500, rowIndex: 0)
                                frequencyRow(frequency: "1000 Hz", rightValue: $rightEar1000, leftValue: $leftEar1000, rowIndex: 1)
                                frequencyRow(frequency: "2000 Hz", rightValue: $rightEar2000, leftValue: $leftEar2000, rowIndex: 2)
                                frequencyRow(frequency: "4000 Hz", rightValue: $rightEar4000, leftValue: $leftEar4000, rowIndex: 3)
                                frequencyRow(frequency: "8000 Hz", rightValue: $rightEar8000, leftValue: $leftEar8000, rowIndex: 4)
                            }
                            .padding()
                        }
                        .groupBoxStyle(GlassGroupBoxStyle())

                        // Results Section
                        GroupBox("assessment_results".localized) {
                            VStack(alignment: .leading, spacing: 12) {
                                // Hearing Loss Calculations
                                Text("hearing_loss_assessment".localized)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(.thinMaterial, in: Capsule())

                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        resultRow(
                                            label: "right_ear".localized,
                                            result: calculateHearingLoss(frequencies: getRightEarValues()),
                                            color: .red,
                                            accentColor: colorForFrequencies(getRightEarValues())
                                        )
                                        resultRow(
                                            label: "left_ear".localized,
                                            result: calculateHearingLoss(frequencies: getLeftEarValues()),
                                            color: .blue,
                                            accentColor: colorForFrequencies(getLeftEarValues())
                                        )
                                        resultRow(
                                            label: "bilateral".localized,
                                            result: calculateBilateralHearingLoss(),
                                            color: .primary,
                                            accentColor: colorForFrequencies(
                                                getRightEarValues() + getLeftEarValues()
                                            )
                                        )
                                    }
                                    Spacer()
                                }

                                Divider()

                                // SAL Index
                                Text("sal_index".localized)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(.thinMaterial, in: Capsule())

                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        resultRow(
                                            label: "\("right_ear".localized) SAL",
                                            result: "\(calculateSAL(frequencies: getRightEarValues())) - \(getSALDegree(sal: calculateSALValue(frequencies: getRightEarValues())))",
                                            color: .red,
                                            accentColor: colorForFrequencies(Array(getRightEarValues().prefix(3)))
                                        )
                                        resultRow(
                                            label: "\("left_ear".localized) SAL",
                                            result: "\(calculateSAL(frequencies: getLeftEarValues())) - \(getSALDegree(sal: calculateSALValue(frequencies: getLeftEarValues())))",
                                            color: .blue,
                                            accentColor: colorForFrequencies(Array(getLeftEarValues().prefix(3)))
                                        )
                                    }
                                    Spacer()
                                }

                                Divider()

                                // ELI Index
                                Text("eli_index".localized)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(.thinMaterial, in: Capsule())

                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        resultRow(
                                            label: "\("right_ear".localized) ELI",
                                            result: "\(calculateELI(frequencies: getRightEarValues())) - \(getELIDegree(eli: calculateELIValue(frequencies: getRightEarValues())))",
                                            color: .red,
                                            accentColor: colorForFrequencies(getRightEarValues())
                                        )
                                        resultRow(
                                            label: "\("left_ear".localized) ELI",
                                            result: "\(calculateELI(frequencies: getLeftEarValues())) - \(getELIDegree(eli: calculateELIValue(frequencies: getLeftEarValues())))",
                                            color: .blue,
                                            accentColor: colorForFrequencies(getLeftEarValues())
                                        )
                                    }
                                    Spacer()
                                }
                            }
                            .padding()
                        }
                        .groupBoxStyle(GlassGroupBoxStyle())

                        // Information Section
                        GroupBox("parameters_summary".localized) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("\("patient_label".localized) \(patientName.isEmpty ? "not_specified".localized : patientName)")
                                Text("\("age-label".localized) \(patientAge.isEmpty ? "not_specified".localized : patientAge)")
                                Text("\("occupation_label".localized) \(patientJob.isEmpty ? "not_specified".localized : patientJob)")

                                Divider()

                                Text("test_frequencies".localized)
                                Text("results_measured".localized)
                                Text("sal_description".localized)
                                Text("eli_description".localized)
                            }
                            .padding()
                        }
                        .groupBoxStyle(GlassGroupBoxStyle())
                    }
                    .padding()
                }
            } // ZStack
            .padding(.bottom, 20)
        }
        .frame(minWidth: 580, idealWidth: 580, maxWidth: 580, minHeight: 610, idealHeight: 610, maxHeight: 1186)
        .onAppear {
            loadAllPatients()
            if allPatients.isEmpty {
                createNewPatient()
            } else {
                loadPatient(allPatients.first!)
            }
        }
    }

    /// Helper function to create frequency input rows with alternating background
    private func frequencyRow(frequency: String, rightValue: Binding<String>, leftValue: Binding<String>, rowIndex: Int) -> some View {
        HStack {
            Text(frequency)
                .frame(width: 120, alignment: .leading)

            TextField("db_placeholder".localized, text: rightValue)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 100)
                .onChange(of: rightValue.wrappedValue) { _, _ in
                    updateCurrentPatient()
                }

            TextField("db_placeholder".localized, text: leftValue)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 100)
                .onChange(of: leftValue.wrappedValue) { _, _ in
                    updateCurrentPatient()
                }
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 4)
        .background {
            if !rowIndex.isMultiple(of: 2) {
                RoundedRectangle(cornerRadius: 4).fill(.ultraThinMaterial)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }

    /// Helper to display a labeled result row with color accent
    private func resultRow(label: String, result: String, color: Color, accentColor: Color) -> some View {
        HStack(spacing: 6) {
            Capsule()
                .fill(accentColor.opacity(0.8))
                .frame(width: 8, height: 8)
            Text("\(label):")
                .foregroundStyle(color)
                .fontWeight(.medium)
            Text(result)
                .foregroundStyle(accentColor)
        }
    }

    // MARK: - Color helper based on average dB

    private func colorForFrequencies(_ frequencies: [Double]) -> Color {
        guard !frequencies.isEmpty else { return .secondary }
        let average = frequencies.reduce(0, +) / Double(frequencies.count)
        switch average {
        case ...25: return Color(red: 0.26, green: 0.62, blue: 0.28)
        case 26 ... 40: return .brown
        case 41 ... 55: return Color(red: 0.9, green: 0.4, blue: 0.0)
        case 56 ... 70: return Color(red: 0.7, green: 0.3, blue: 0.2)
        case 71 ... 90: return .red
        default: return Color(red: 0.7, green: 0.0, blue: 0.0)
        }
    }

    // MARK: - Patient Management Functions

    private func loadAllPatients() {
        allPatients = dataStore.fetchPatients()
    }

    private func createNewPatient() {
        let newPatient = PatientData()
        currentPatient = newPatient
        dataStore.addPatient(newPatient)
        allPatients.insert(newPatient, at: 0)
        clearForm()
    }

    private func loadPatient(_ patient: PatientData) {
        // Cancel any pending auto-save for the previous patient
        autoSaveTask?.cancel()

        currentPatient = patient
        patientName = patient.name
        patientAge = patient.age
        patientJob = patient.job
        rightEar500 = patient.rightEar500
        rightEar1000 = patient.rightEar1000
        rightEar2000 = patient.rightEar2000
        rightEar4000 = patient.rightEar4000
        rightEar8000 = patient.rightEar8000
        leftEar500 = patient.leftEar500
        leftEar1000 = patient.leftEar1000
        leftEar2000 = patient.leftEar2000
        leftEar4000 = patient.leftEar4000
        leftEar8000 = patient.leftEar8000
    }

    private func updateCurrentPatient() {
        guard var patient = currentPatient else { return }

        patient.name = patientName
        patient.age = patientAge
        patient.job = patientJob
        patient.rightEar500 = rightEar500
        patient.rightEar1000 = rightEar1000
        patient.rightEar2000 = rightEar2000
        patient.rightEar4000 = rightEar4000
        patient.rightEar8000 = rightEar8000
        patient.leftEar500 = leftEar500
        patient.leftEar1000 = leftEar1000
        patient.leftEar2000 = leftEar2000
        patient.leftEar4000 = leftEar4000
        patient.leftEar8000 = leftEar8000
        patient.updateModifiedDate()

        currentPatient = patient

        // Auto-save with debouncing using structured concurrency
        autoSaveTask?.cancel()
        autoSaveTask = Task {
            try await Task.sleep(for: .seconds(1))
            dataStore.updatePatient(patient)
        }
    }

    private func saveCurrentPatient() {
        guard let patient = currentPatient else { return }
        dataStore.updatePatient(patient)
        loadAllPatients() // Refresh the list
    }

    private func deleteCurrentPatient() {
        guard let patient = currentPatient else { return }
        autoSaveTask?.cancel()
        dataStore.deletePatient(patient)
        loadAllPatients()
        if let first = allPatients.first {
            loadPatient(first)
        } else {
            createNewPatient()
        }
    }

    private func forceSavePendingChanges() {
        // Cancel any pending auto-save and execute it immediately
        autoSaveTask?.cancel()
        if let patient = currentPatient {
            dataStore.updatePatient(patient)
        }
        // Refresh the patient list to ensure consistency
        loadAllPatients()
    }

    private func clearForm() {
        patientName = ""
        patientAge = ""
        patientJob = ""
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
    }

    // MARK: - Helper functions to get ear values as arrays

    private func getRightEarValues() -> [Double] {
        [
            Double(rightEar500) ?? 0,
            Double(rightEar1000) ?? 0,
            Double(rightEar2000) ?? 0,
            Double(rightEar4000) ?? 0,
            Double(rightEar8000) ?? 0,
        ]
    }

    private func getLeftEarValues() -> [Double] {
        [
            Double(leftEar500) ?? 0,
            Double(leftEar1000) ?? 0,
            Double(leftEar2000) ?? 0,
            Double(leftEar4000) ?? 0,
            Double(leftEar8000) ?? 0,
        ]
    }

    // MARK: - Localized Classification Functions

    private func localizedClassification(_ classification: String) -> String {
        switch classification.lowercased() {
        case "normal": "normal".localized
        case "mild": "mild".localized
        case "moderate": "moderate".localized
        case "moderate-severe": "moderate_severe".localized
        case "severe": "severe".localized
        case "profound": "profound".localized
        default: classification
        }
    }

    // MARK: - Hearing Loss Calculation

    private func calculateHearingLoss(frequencies: [Double]) -> String {
        let average = frequencies.reduce(0, +) / Double(frequencies.count)

        if average <= 25 {
            return "\(String(format: "%.1f", average)) dB - \("normal".localized)"
        } else if average <= 40 {
            return "\(String(format: "%.1f", average)) dB - \("mild".localized)"
        } else if average <= 55 {
            return "\(String(format: "%.1f", average)) dB - \("moderate".localized)"
        } else if average <= 70 {
            return "\(String(format: "%.1f", average)) dB - \("moderate_severe".localized)"
        } else if average <= 90 {
            return "\(String(format: "%.1f", average)) dB - \("severe".localized)"
        } else {
            return "\(String(format: "%.1f", average)) dB - \("profound".localized)"
        }
    }

    /// Bilateral Hearing Loss Calculation
    private func calculateBilateralHearingLoss() -> String {
        let rightValues = getRightEarValues()
        let leftValues = getLeftEarValues()

        let rightAverage = rightValues.reduce(0, +) / Double(rightValues.count)
        let leftAverage = leftValues.reduce(0, +) / Double(leftValues.count)
        let bilateralAverage = (rightAverage + leftAverage) / 2

        if bilateralAverage <= 25 {
            return "\(String(format: "%.1f", bilateralAverage)) dB - \("normal".localized)"
        } else if bilateralAverage <= 40 {
            return "\(String(format: "%.1f", bilateralAverage)) dB - \("mild".localized)"
        } else if bilateralAverage <= 55 {
            return "\(String(format: "%.1f", bilateralAverage)) dB - \("moderate".localized)"
        } else if bilateralAverage <= 70 {
            return "\(String(format: "%.1f", bilateralAverage)) dB - \("moderate_severe".localized)"
        } else if bilateralAverage <= 90 {
            return "\(String(format: "%.1f", bilateralAverage)) dB - \("severe".localized)"
        } else {
            return "\(String(format: "%.1f", bilateralAverage)) dB - \("profound".localized)"
        }
    }

    /// SAL Index Calculation (Speech Audiometry Level)
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
            "normal".localized
        } else if sal <= 40 {
            "mild".localized
        } else if sal <= 55 {
            "moderate".localized
        } else if sal <= 70 {
            "moderate_severe".localized
        } else if sal <= 90 {
            "severe".localized
        } else {
            "profound".localized
        }
    }

    /// ELI Index Calculation (Ear Loss Index)
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
            "normal".localized
        } else if eli <= 40 {
            "mild".localized
        } else if eli <= 55 {
            "moderate".localized
        } else if eli <= 70 {
            "moderate_severe".localized
        } else if eli <= 90 {
            "severe".localized
        } else {
            "profound".localized
        }
    }
}

// MARK: - Glass GroupBox Style

struct GlassGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            configuration.label
                .font(.headline)
                .padding(.bottom, 6)
            configuration.content
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
    }
}

#Preview {
    ContentView()
}
