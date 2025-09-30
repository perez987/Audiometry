# Visual Architecture Guide

## System Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                      AudiometryApp.swift                     │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │         Storage Mode Picker (Segmented Control)      │  │
│  │        [ CoreData Storage | SwiftUI Storage ]        │  │
│  └──────────────────────────────────────────────────────┘  │
│                            │                                 │
│                            │                                 │
│              ┌─────────────┴──────────────┐                 │
│              ▼                            ▼                 │
│  ┌───────────────────────┐   ┌───────────────────────┐    │
│  │   CoreData Mode       │   │   SwiftUI Mode        │    │
│  │                       │   │                       │    │
│  │  ContentView          │   │  ContentViewSwiftUI   │    │
│  │  PatientNavigationView│   │  PatientNavigation... │    │
│  │  Patient (NSManaged)  │   │  PatientData (Struct) │    │
│  │  PersistenceController│   │  PatientDataStore     │    │
│  └───────────┬───────────┘   └───────────┬───────────┘    │
│              │                            │                 │
│              ▼                            ▼                 │
│  ┌───────────────────────┐   ┌───────────────────────┐    │
│  │  SQLite Database      │   │  JSON File            │    │
│  │  DataModel.sqlite     │   │  patients.json        │    │
│  └───────────────────────┘   └───────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

## CoreData Architecture

```
┌──────────────────────────────────────────────────┐
│              ContentView.swift                    │
│  ┌────────────────────────────────────────────┐  │
│  │  @Environment(\.managedObjectContext)      │  │
│  │  @State private var currentPatient         │  │
│  │  @State private var allPatients            │  │
│  └────────────────────────────────────────────┘  │
│                     │                             │
│                     ▼                             │
│  ┌────────────────────────────────────────────┐  │
│  │         Patient.swift (NSManagedObject)    │  │
│  │  - id: UUID                                │  │
│  │  - name: String                            │  │
│  │  - age: String                             │  │
│  │  - rightEar500-8000: String                │  │
│  │  - leftEar500-8000: String                 │  │
│  └────────────────────────────────────────────┘  │
│                     │                             │
│                     ▼                             │
│  ┌────────────────────────────────────────────┐  │
│  │    PersistenceController.swift             │  │
│  │  ┌──────────────────────────────────────┐  │  │
│  │  │  NSPersistentContainer               │  │  │
│  │  │  - container: NSPersistentContainer  │  │  │
│  │  │  - viewContext                       │  │  │
│  │  └──────────────────────────────────────┘  │  │
│  │  Methods:                                  │  │
│  │  - fetchPatients()                         │  │
│  │  - deletePatient()                         │  │
│  │  - searchPatients()                        │  │
│  │  - save()                                  │  │
│  └────────────────────────────────────────────┘  │
│                     │                             │
│                     ▼                             │
│  ┌────────────────────────────────────────────┐  │
│  │       DataModel.xcdatamodeld               │  │
│  │  Entity: Patient                           │  │
│  │  Attributes: id, name, age, job, ears...   │  │
│  └────────────────────────────────────────────┘  │
│                     │                             │
│                     ▼                             │
│           SQLite Database                         │
│       (~/Library/.../DataModel.sqlite)            │
└──────────────────────────────────────────────────┘
```

## SwiftUI Storage Architecture

```
┌──────────────────────────────────────────────────┐
│           ContentViewSwiftUI.swift                │
│  ┌────────────────────────────────────────────┐  │
│  │  @ObservedObject dataStore                 │  │
│  │  @State private var currentPatient         │  │
│  │  @State private var allPatients            │  │
│  └────────────────────────────────────────────┘  │
│                     │                             │
│                     ▼                             │
│  ┌────────────────────────────────────────────┐  │
│  │         PatientData.swift (Struct)         │  │
│  │  struct PatientData: Codable, Identifiable │  │
│  │  - id: UUID                                │  │
│  │  - name: String                            │  │
│  │  - age: String                             │  │
│  │  - rightEar500-8000: String                │  │
│  │  - leftEar500-8000: String                 │  │
│  └────────────────────────────────────────────┘  │
│                     │                             │
│                     ▼                             │
│  ┌────────────────────────────────────────────┐  │
│  │    PatientDataStore.swift                  │  │
│  │  class PatientDataStore: ObservableObject  │  │
│  │  ┌──────────────────────────────────────┐  │  │
│  │  │  @Published var patients: [Patient]  │  │  │
│  │  │  private let fileManager             │  │  │
│  │  │  private let documentsDirectory      │  │  │
│  │  └──────────────────────────────────────┘  │  │
│  │  Methods:                                  │  │
│  │  - loadPatients()                          │  │
│  │  - savePatients()                          │  │
│  │  - fetchPatients()                         │  │
│  │  - addPatient()                            │  │
│  │  - updatePatient()                         │  │
│  │  - deletePatient()                         │  │
│  │  - searchPatients()                        │  │
│  └────────────────────────────────────────────┘  │
│                     │                             │
│                     ▼                             │
│  ┌────────────────────────────────────────────┐  │
│  │        JSONEncoder / JSONDecoder           │  │
│  │  - Encodes struct to JSON                  │  │
│  │  - Decodes JSON to struct                  │  │
│  └────────────────────────────────────────────┘  │
│                     │                             │
│                     ▼                             │
│            JSON File                              │
│   (~/Library/Application Support/patients.json)  │
└──────────────────────────────────────────────────┘
```

## Data Flow Comparison

### CoreData Data Flow

```
User Input
    │
    ▼
TextField onChange
    │
    ▼
Update Patient Properties
    │
    ▼
patient.name = newValue
patient.updateModifiedDate()
    │
    ▼
Debounced Auto-Save (1 second delay)
    │
    ▼
viewContext.save()
    │
    ▼
CoreData writes to SQLite
    │
    ▼
Data Persisted
```

### SwiftUI Storage Data Flow

```
User Input
    │
    ▼
TextField onChange
    │
    ▼
Update Struct Properties
    │
    ▼
var patient = currentPatient
patient.name = newValue
patient.updateModifiedDate()
    │
    ▼
Debounced Auto-Save (1 second delay)
    │
    ▼
dataStore.updatePatient(patient)
    │
    ▼
JSONEncoder encodes array
    │
    ▼
Write JSON to file
    │
    ▼
Data Persisted
```

## Component Mapping

### CoreData Components → SwiftUI Storage Components

```
┌────────────────────────────────┬────────────────────────────────┐
│        CoreData                │      SwiftUI Storage           │
├────────────────────────────────┼────────────────────────────────┤
│ Patient (NSManagedObject)      │ PatientData (Struct)          │
│ PersistenceController          │ PatientDataStore              │
│ NSPersistentContainer          │ FileManager + JSON            │
│ NSManagedObjectContext         │ ObservableObject              │
│ ContentView                    │ ContentViewSwiftUI            │
│ PatientNavigationView          │ PatientNavigationViewSwiftUI  │
│ DataModel.xcdatamodeld         │ (Not needed)                  │
│ viewContext.save()             │ dataStore.savePatients()      │
│ fetchRequest                   │ Array.filter                  │
│ NSPredicate                    │ String.contains               │
└────────────────────────────────┴────────────────────────────────┘
```

## State Management

### CoreData State Management

```
┌──────────────────────────────────────┐
│          ContentView                  │
│                                       │
│  @Environment(\.managedObjectContext) │ ← Injected
│      ↓                                │
│  Patient (NSManagedObject)            │ ← Managed by CoreData
│      ↓                                │
│  Changes tracked automatically        │
│      ↓                                │
│  viewContext.save()                   │ ← Explicit save
│      ↓                                │
│  UI updates via @FetchRequest         │ ← Automatic updates
└──────────────────────────────────────┘
```

### SwiftUI Storage State Management

```
┌──────────────────────────────────────┐
│       ContentViewSwiftUI              │
│                                       │
│  @ObservedObject dataStore            │ ← Injected
│      ↓                                │
│  PatientData (Struct)                 │ ← Value type (copied)
│      ↓                                │
│  Manual tracking of changes           │
│      ↓                                │
│  dataStore.updatePatient()            │ ← Explicit update
│      ↓                                │
│  UI updates via @Published            │ ← Automatic updates
└──────────────────────────────────────┘
```

## File Organization

```
Audiometry/
│
├── CoreData Files
│   ├── Patient.swift              (86 lines)
│   ├── PersistenceController.swift(142 lines)
│   ├── ContentView.swift          (490 lines)
│   ├── PatientNavigationView.swift(236 lines)
│   └── DataModel.xcdatamodeld/
│
├── SwiftUI Storage Files
│   ├── PatientData.swift          (75 lines)
│   ├── PatientDataStore.swift     (130 lines)
│   ├── ContentViewSwiftUI.swift   (485 lines)
│   └── PatientNavigationViewSwiftUI.swift (220 lines)
│
├── Shared Files
│   ├── AudiometryApp.swift        (Modified)
│   ├── StorageMode.swift          (20 lines)
│   ├── LanguageManager.swift
│   ├── AudiometryCalculations.swift
│   └── AppDelegate.swift
│
└── Documentation
    ├── README.md
    ├── STORAGE_COMPARISON.md
    ├── DEVELOPER_GUIDE.md
    ├── QUICK_REFERENCE.md
    ├── IMPLEMENTATION_SUMMARY.md
    └── VISUAL_ARCHITECTURE.md
```

## Memory Usage Comparison

### CoreData Memory Pattern

```
App Launch
    │
    ▼
Load CoreData Stack (1-2 MB)
    │
    ▼
Fetch Patients (Lazy Loading)
    │
    ├─► Patient 1 (Faulted) ─► Access ─► Load into memory
    ├─► Patient 2 (Faulted) ─► Access ─► Load into memory
    └─► Patient 3 (Faulted) ─► Not accessed ─► Stays faulted
    
Memory: Stack + Active Objects Only
```

### SwiftUI Storage Memory Pattern

```
App Launch
    │
    ▼
Load JSON File
    │
    ▼
Decode ALL Patients at Once
    │
    ├─► Patient 1 (In Memory)
    ├─► Patient 2 (In Memory)
    ├─► Patient 3 (In Memory)
    └─► ... All patients loaded
    
Memory: All Data in Memory Always
```

## Summary

Both architectures provide the same functionality but with different approaches:

- **CoreData**: Object-oriented, database-backed, lazy loading
- **SwiftUI Storage**: Value-oriented, file-backed, eager loading

Choose based on:
- Dataset size
- Performance requirements
- Team expertise
- Maintenance preferences
- Future scalability needs
