# Dual Storage System - Quick Reference

## File Structure

```
Audiometry/
├── CoreData Implementation
│   ├── Patient.swift                      (NSManagedObject)
│   ├── PersistenceController.swift        (CoreData stack)
│   ├── DataModel.xcdatamodeld             (CoreData model)
│   ├── ContentView.swift                  (UI for CoreData)
│   └── PatientNavigationView.swift        (Navigation for CoreData)
│
├── SwiftUI Storage Implementation
│   ├── PatientData.swift                  (Codable struct)
│   ├── PatientDataStore.swift             (ObservableObject)
│   ├── ContentViewSwiftUI.swift           (UI for SwiftUI storage)
│   └── PatientNavigationViewSwiftUI.swift (Navigation for SwiftUI)
│
├── Shared Components
│   ├── AudiometryApp.swift                (App entry point with storage selector)
│   ├── StorageMode.swift                  (Enum for storage modes)
│   ├── LanguageManager.swift              (Localization)
│   ├── AudiometryCalculations.swift       (Hearing loss calculations)
│   └── AppDelegate.swift                  (App delegate)
│
└── Documentation
    ├── README.md                          (Main readme)
    ├── STORAGE_COMPARISON.md              (Detailed comparison)
    └── DEVELOPER_GUIDE.md                 (Developer guide)
```

## Data Flow

### CoreData Flow
```
User Input → ContentView → Patient (NSManagedObject) → ViewContext → PersistenceController → SQLite Database
```

### SwiftUI Storage Flow
```
User Input → ContentViewSwiftUI → PatientData (Struct) → PatientDataStore → JSON File
```

## Storage Toggle

The storage mode can be toggled via the segmented control in `AudiometryApp`:

```swift
Picker("", selection: $storageModeRaw) {
    ForEach(StorageMode.allCases, id: \.rawValue) { mode in
        Text(mode.displayName).tag(mode.rawValue)
    }
}
```

The selection is persisted using `@AppStorage`:
```swift
@AppStorage("storageMode") private var storageModeRaw: String
```

## Key Differences at a Glance

| Aspect | CoreData | SwiftUI Storage |
|--------|----------|-----------------|
| Data Model | NSManagedObject class | Codable struct |
| Storage Format | SQLite | JSON |
| Persistence Manager | PersistenceController | PatientDataStore |
| Context Management | NSManagedObjectContext | ObservableObject |
| Memory Usage | Lazy loading | All in memory |
| Complexity | Higher | Lower |
| Best for | Large datasets | Small datasets |

## How to Switch Storage Modes

1. Use the segmented control at the top of the window
2. Select "CoreData Storage" or "SwiftUI Storage"
3. The app immediately switches to the selected storage
4. Each storage system has its own separate data

**Note:** Data is NOT shared between storage modes. Each maintains independent storage.

## Quick Start for Developers

### Using CoreData
```swift
// Create
let patient = Patient.create(in: viewContext)
patient.name = "John Doe"
try viewContext.save()

// Read
let patients = PersistenceController.shared.fetchPatients()

// Update
patient.name = "Jane Doe"
try viewContext.save()

// Delete
PersistenceController.shared.deletePatient(patient)
```

### Using SwiftUI Storage
```swift
// Create
var patient = PatientData()
patient.name = "John Doe"
PatientDataStore.shared.addPatient(patient)

// Read
let patients = PatientDataStore.shared.fetchPatients()

// Update
patient.name = "Jane Doe"
PatientDataStore.shared.updatePatient(patient)

// Delete
PatientDataStore.shared.deletePatient(patient)
```

## Benefits of Dual Implementation

1. **Learning Tool** - Compare two different storage approaches
2. **Performance Testing** - Measure real-world performance differences
3. **Flexibility** - Choose the best approach for your needs
4. **Migration Path** - Easy to switch if requirements change

## Future Considerations

- **Data Migration Tool** - Move data between storage systems
- **Hybrid Approach** - Use both simultaneously for different data types
- **Performance Metrics** - Built-in performance monitoring
- **User Preference** - Let users choose based on their needs

## Related Documents

- [STORAGE_COMPARISON.md](STORAGE_COMPARISON.md) - Detailed feature comparison
- [DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md) - Implementation details
- [README.md](README.md) - Main project documentation
