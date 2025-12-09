//
//  PrintReportHelpers.swift
//  Audiometry
//
//  Shared helpers for print report functionality
//
//  Modified by perez987 on 20/09/2025.
//

import SwiftUI
import AppKit
import PDFKit

/// Helper functions for printing patient reports
enum PrintReportHelpers {

    /// Print a SwiftUI view by rendering it to PDF and opening it
    /// - Parameter content: The SwiftUI view to print
@MainActor
static func printReport<Content: View>(content: Content) {
        // Render the view to an image using ImageRenderer with explicit size
    let renderer = ImageRenderer(content: content)

        // Set explicit size for rendering (8.5" x 11" at 72 DPI)
    renderer.proposedSize = ProposedViewSize(width: 612, height: 792)
    renderer.scale = 2.0 // High quality (144 DPI)

        // Get the rendered image
    guard let nsImage = renderer.nsImage else {
        showError("Unable to render the report. View maybe is too complex or has invalid content.")
        return
    }

        // Verify the image has content
    guard nsImage.size.width > 0 && nsImage.size.height > 0 else {
        showError("Rendered image has invalid dimensions: \(nsImage.size).")
        return
    }

        // Create a PDF document
    let pdfDocument = PDFDocument()

        // Create a PDF page from the image
    guard let pdfPage = PDFPage(image: nsImage) else {
        showError("Unable to create PDF page from rendered image.")
        return
    }

        // Add the page to the document
    pdfDocument.insert(pdfPage, at: 0)

        // Save to temporary file
    let url = URL.temporaryDirectory.appending(path: "PatientReport.pdf")

        // Write the PDF document to file
    guard pdfDocument.write(to: url) else {
        showError("Unable to save PDF file.")
        return
    }

        // Open with system PDF viewer
    NSWorkspace.shared.open(url)
}

    /// Show an error alert dialog
    /// - Parameter message: The error message to display
static func showError(_ message: String) {
    let alert = NSAlert()
    alert.messageText = "Print Error"
    alert.informativeText = message.localized
    alert.alertStyle = .warning
    alert.addButton(withTitle: "OK")
    alert.runModal()
}
}
