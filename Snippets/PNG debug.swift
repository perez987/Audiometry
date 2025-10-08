			// Debug: Save NSImage as PNG to verify it has content
		if let tiffData = nsImage.tiffRepresentation,
		   let bitmapImage = NSBitmapImageRep(data: tiffData),
		   let pngData = bitmapImage.representation(using: .png, properties: [:]) {
			let debugURL = URL.temporaryDirectory.appending(path: "PatientReport_DEBUG.png")
			try? pngData.write(to: debugURL)
			print("DEBUG: Saved debug PNG to \(debugURL.path)")
		}
	
			// Before this:	
		// Create a PDF document
		//let pdfDocument = PDFDocument()
