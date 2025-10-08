//
//  PrintReportViewSwiftUI.swift
//  Audiometry
//
//  Print report view for SwiftUI data storage
//
//  Created by GitHub Copilot on 20/09/2025.
//  Modified by perez987 on 20/09/2025.
//

import SwiftUI
import AppKit
import PDFKit

struct PrintReportViewSwiftUI: View {
	@ObservedObject private var languageManager = LanguageManager.shared
	let patients: [PatientData]

	init(patient: PatientData) {
		self.patients = [patient]
	}

	init(patients: [PatientData]) {
		self.patients = patients
	}

	var body: some View {
		ScrollView {
			VStack(spacing: 30) {
				ForEach(patients) { patient in
					patientReport(patient: patient)

					if patient.id != patients.last?.id {
						Divider()
							.padding(.vertical, 20)
					}
				}
			}
			.padding(20)
		}
		.frame(width: 550)
	}

	@MainActor
	private func printReport() {
			// Create a printable version without ScrollView
		let printableContent = VStack(spacing: 30) {
			ForEach(patients) { patient in
				patientReport(patient: patient)

				if patient.id != patients.last?.id {
					Divider()
						.padding(.vertical, 20)
				}
			}
		}
			.padding(20)
			.frame(width: 550)

			// Use the shared print helper
		PrintReportHelpers.printReport(content: printableContent)
	}

	@ViewBuilder
	private func patientReport(patient: PatientData) -> some View {
		VStack(alignment: .leading, spacing: 20) {
			HStack {
					// Title
				Text("patient_report".localized)
					.font(.title)
					.fontWeight(.bold)
					.foregroundStyle(.primary)
					.padding(8)
					.border(Color.secondary, width: 1)

				Image(systemName: "person.circle")
					.font(.system(size: 38))
					//					.foregroundColor(.blue)

				Spacer()

				Button(action: {
					printReport()
				}) {
					Image(systemName: "printer")
						.font(.system(size: 24))
				}
				.buttonStyle(PlainButtonStyle())
				.help("print_preview".localized)

					//                Spacer()
					//
					//                Text("esc_cancel".localized)
					//                    .font(.callout)
					//                    .foregroundStyle(.secondary)

			}

				// Patient Information Section

			VStack(alignment: .leading, spacing: 8) {

					//				Text("patient_information".localized)
					//					.font(.headline)
					//					.fontWeight(.semibold)
					//					.foregroundStyle(.primary)
					//					.padding(8)
					//					.border(Color.secondary, width: 1)

					//				Divider()
					//					.background(Color.blue)

				Text("\("name".localized) \(patient.name.isEmpty ? "not_specified".localized : patient.name)")
					.foregroundStyle(.primary)
					.padding(8)
					.border(Color.secondary, width: 1)
				Text("\("age".localized) \(patient.age.isEmpty ? "not_specified".localized : patient.age)")
					.foregroundStyle(.primary)
					.padding(8)
					.border(Color.secondary, width: 1)
				Text("\("job".localized) \(patient.job.isEmpty ? "not_specified".localized : patient.job)")
					.foregroundStyle(.primary)
					.padding(8)
					.border(Color.secondary, width: 1)
			}

				// Audiometric Testing Section
			VStack(alignment: .leading, spacing: 8) {
				Text("audiometric_testing_results".localized)
					.font(.headline)
					.fontWeight(.semibold)

				Divider()
					.background(Color.blue)

				HStack {
					Text("frequency_hz".localized)
						.frame(width: 150, alignment: .leading)
						.fontWeight(.semibold)
					Text("right_ear".localized)
						.frame(width: 100, alignment: .center)
						.fontWeight(.semibold)
					Text("left_ear".localized)
						.frame(width: 100, alignment: .center)
						.fontWeight(.semibold)
				}

				frequencyRow(frequency: "500", rightValue: patient.rightEar500, leftValue: patient.leftEar500)
				frequencyRow(frequency: "1000", rightValue: patient.rightEar1000, leftValue: patient.leftEar1000)
				frequencyRow(frequency: "2000", rightValue: patient.rightEar2000, leftValue: patient.leftEar2000)
				frequencyRow(frequency: "4000", rightValue: patient.rightEar4000, leftValue: patient.leftEar4000)
				frequencyRow(frequency: "8000", rightValue: patient.rightEar8000, leftValue: patient.leftEar8000)
			}

				// Results Section
			VStack(alignment: .leading, spacing: 8) {
				Text("assessment_results".localized)
					.font(.headline)
					.fontWeight(.semibold)

				Divider()
					.background(Color.blue)

				Text("hearing_loss_assessment".localized)
					.fontWeight(.semibold)

				Text("\("right_ear".localized): \(calculateHearingLoss(frequencies: patient.getRightEarValues()))")
				Text("\("left_ear".localized): \(calculateHearingLoss(frequencies: patient.getLeftEarValues()))")
				Text("\("bilateral".localized): \(calculateBilateralHearingLoss(right: patient.getRightEarValues(), left: patient.getLeftEarValues()))")

				Divider()
					.background(Color.blue)

				Text("sal_index".localized)
					.fontWeight(.semibold)

				Text("\("right_ear".localized) SAL: \(calculateSAL(frequencies: patient.getRightEarValues())) - \(getSALDegree(sal: calculateSALValue(frequencies: patient.getRightEarValues())))")
				Text("\("left_ear".localized) SAL: \(calculateSAL(frequencies: patient.getLeftEarValues())) - \(getSALDegree(sal: calculateSALValue(frequencies: patient.getLeftEarValues())))")

				Divider()
					.background(Color.blue)

				Text("eli_index".localized)
					.fontWeight(.semibold)

				Text("\("right_ear".localized) ELI: \(calculateELI(frequencies: patient.getRightEarValues())) - \(getELIDegree(eli: calculateELIValue(frequencies: patient.getRightEarValues())))")
				Text("\("left_ear".localized) ELI: \(calculateELI(frequencies: patient.getLeftEarValues())) - \(getELIDegree(eli: calculateELIValue(frequencies: patient.getLeftEarValues())))")
			}

				// Information Section
			VStack(alignment: .leading, spacing: 8) {
				Text("parameters_summary".localized)
					.font(.headline)
					.fontWeight(.semibold)

				Divider()
					.background(Color.blue)

				Text("test_frequencies".localized)
				Text("results_measured".localized)
				Text("sal_description".localized)
				Text("eli_description".localized)
			}
		}
	}

	private func frequencyRow(frequency: String, rightValue: String, leftValue: String) -> some View {
		HStack {
			Text(frequency)
				.frame(width: 150, alignment: .leading)
			Text(rightValue.isEmpty ? "-" : "\(rightValue) dB")
				.frame(width: 100, alignment: .center)
			Text(leftValue.isEmpty ? "-" : "\(leftValue) dB")
				.frame(width: 100, alignment: .center)
		}
	}

		// MARK: - Calculation Functions

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

	private func calculateBilateralHearingLoss(right: [Double], left: [Double]) -> String {
		let rightAverage = right.reduce(0, +) / Double(right.count)
		let leftAverage = left.reduce(0, +) / Double(left.count)
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

	private func calculateSAL(frequencies: [Double]) -> String {
		let sal = calculateSALValue(frequencies: frequencies)
		return String(format: "%.1f dB", sal)
	}

	private func calculateSALValue(frequencies: [Double]) -> Double {
		let speechFrequencies = Array(frequencies.prefix(3))
		return speechFrequencies.reduce(0, +) / Double(speechFrequencies.count)
	}

	private func getSALDegree(sal: Double) -> String {
		if sal <= 25 {
			return "normal".localized
		} else if sal <= 40 {
			return "mild".localized
		} else if sal <= 55 {
			return "moderate".localized
		} else if sal <= 70 {
			return "moderate_severe".localized
		} else if sal <= 90 {
			return "severe".localized
		} else {
			return "profound".localized
		}
	}

	private func calculateELI(frequencies: [Double]) -> String {
		let eli = calculateELIValue(frequencies: frequencies)
		return String(format: "%.1f dB", eli)
	}

	private func calculateELIValue(frequencies: [Double]) -> Double {
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
			return "normal".localized
		} else if eli <= 40 {
			return "mild".localized
		} else if eli <= 55 {
			return "moderate".localized
		} else if eli <= 70 {
			return "moderate_severe".localized
		} else if eli <= 90 {
			return "severe".localized
		} else {
			return "profound".localized
		}
	}
}
