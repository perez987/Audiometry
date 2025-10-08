    private func performSearch() {
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedSearch.isEmpty else { return }
        
          // MARK: workaround to resolve the issue with the search function:
        // - Search returns "No patients found" on the first attempt
        // - Navigating patient list using Next/Back buttons
        // is required for the search to work.
        
        if allPatients.isEmpty {
                 let thisPatient = allPatients[currentIndex]
                 onPatientSelected(thisPatient)
             }
        else {
            if hasPrevious {
//                 let previousPatient = allPatients[currentIndex - 1]
//                 onPatientSelected(previousPatient)
                onPatientSelected(allPatients[currentIndex - 1])
            }
            else if hasNext {
//                 let previousPatient = allPatients[currentIndex + 1]
//                 onPatientSelected(previousPatient)
                onPatientSelected(allPatients[currentIndex + 1])
            }
            else {
                if (currentIndex == 0) {
                    onPatientSelected(allPatients[currentIndex + 1])
                }
                else if (currentIndex == allPatients.count-1) {
                    onPatientSelected(allPatients[currentIndex - 1])
                }
            }
        }
        
        // MARK: -
