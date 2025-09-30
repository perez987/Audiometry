# Developer Guide: Dual Storage Implementation

## Overview

This guide explains how to work with the dual storage system implemented in the Audiometry application.

## Architecture

### Storage Mode Toggle

The application uses `@AppStorage` to persist the user's storage mode choice:

```swift
@AppStorage("storageMode") private var storageModeRaw: String = StorageMode.coreData.rawValue
```

This value persists across app launches, so users maintain their storage preference.

### View Switching

The main `AudiometryApp` uses conditional view rendering based on the selected storage mode:

```swift
if storageMode == .coreData {
    ContentView()
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
} else {
    ContentViewSwiftUI()
}
```

## CoreData Implementation

### Key Components

1. **PersistenceController**: Singleton managing the CoreData stack
   ```swift
   let persistenceController = PersistenceController.shared
   ```

2. **Patient Entity**: NSManagedObject subclass
   - Managed by CoreData
   - Requires explicit saving through context

3. **ViewContext**: Passed through SwiftUI environment
   ```swift
   .environment(\.managedObjectContext, persistenceController.container.viewContext)
   ```

### CRUD Operations

**Create:**
```swift
let newPatient = Patient.create(in: viewContext)
```

**Read:**
```swift
let patients = PersistenceController.shared.fetchPatients()
```

**Update:**
```swift
patient.name = "New Name"
patient.updateModifiedDate()
try viewContext.save()
```

**Delete:**
```swift
PersistenceController.shared.deletePatient(patient)
```

### Search

```swift
let results = PersistenceController.shared.searchPatients(by: "search term")
```

## SwiftUI Storage Implementation

### Key Components

1. **PatientDataStore**: ObservableObject managing patient array
   ```swift
   @ObservedObject private var dataStore = PatientDataStore.shared
   ```

2. **PatientData**: Simple struct conforming to Codable
   - Automatically encodes/decodes to JSON
   - No context management needed

3. **File-based Persistence**: JSON file in Application Support directory

### CRUD Operations

**Create:**
```swift
let newPatient = PatientData()
dataStore.addPatient(newPatient)
```

**Read:**
```swift
let patients = dataStore.fetchPatients()
```

**Update:**
```swift
var patient = currentPatient
patient.name = "New Name"
patient.updateModifiedDate()
dataStore.updatePatient(patient)
```

**Delete:**
```swift
dataStore.deletePatient(patient)
```

### Search

```swift
let results = dataStore.searchPatients(by: "search term")
```

## Adding New Fields

### CoreData Approach

1. Open `DataModel.xcdatamodeld` in Xcode
2. Select the Patient entity
3. Add attribute with name and type
4. Update `Patient.swift`:
   ```swift
   @NSManaged public var newField: String
   ```
5. Update the `create()` method to initialize:
   ```swift
   patient.newField = ""
   ```
6. Create a new model version for migration
7. Update views to use the new field

### SwiftUI Storage Approach

1. Update `PatientData.swift`:
   ```swift
   struct PatientData: Codable, Identifiable {
       // Existing fields...
       var newField: String = ""  // Add with default value
   }
   ```
2. Update the initializer if needed
3. Update views to use the new field
4. No migration needed - JSONDecoder handles missing fields

## Best Practices

### CoreData

1. **Always save on the main thread** for UI operations
2. **Use background contexts** for batch operations
3. **Handle save errors** appropriately
4. **Don't pass NSManagedObjects between threads**
5. **Use fetch request batch sizes** for large datasets

Example:
```swift
do {
    try viewContext.save()
} catch {
    print("Error saving: \(error.localizedDescription)")
}
```

### SwiftUI Storage

1. **Batch updates** when possible to avoid multiple file writes
2. **Handle file I/O errors** gracefully
3. **Use debouncing** for auto-save (already implemented)
4. **Consider memory usage** with large datasets
5. **Validate data** before saving

Example:
```swift
do {
    let data = try JSONEncoder().encode(patients)
    try data.write(to: fileURL)
} catch {
    print("Error saving: \(error.localizedDescription)")
}
```

## Testing

### Testing CoreData

Use in-memory store for tests:
```swift
let controller = PersistenceController(inMemory: true)
```

### Testing SwiftUI Storage

Use a separate test instance:
```swift
let testStore = PatientDataStore()
testStore.patients = [/* test data */]
```

## Data Location

### CoreData
```
~/Library/Containers/perez987.Audiometry/Data/Library/Application Support/Audiometry/
├── DataModel.sqlite
├── DataModel.sqlite-shm
└── DataModel.sqlite-wal
```

### SwiftUI Storage
```
~/Library/Application Support/Audiometry/
└── patients.json
```

## Debugging

### CoreData

Enable CoreData SQL logging:
```bash
-com.apple.CoreData.SQLDebug 1
```

View the database:
```bash
sqlite3 ~/Library/Containers/perez987.Audiometry/Data/Library/Application\ Support/Audiometry/DataModel.sqlite
.tables
SELECT * FROM ZPATIENT;
```

### SwiftUI Storage

View the JSON file:
```bash
cat ~/Library/Application\ Support/Audiometry/patients.json
```

Pretty print:
```bash
cat ~/Library/Application\ Support/Audiometry/patients.json | python3 -m json.tool
```

## Common Issues

### CoreData

**Issue**: "Could not merge changes"
- **Solution**: Ensure `automaticallyMergesChangesFromParent = true` is set

**Issue**: Faulting errors
- **Solution**: Access properties on the main thread where objects were created

**Issue**: Memory leaks
- **Solution**: Don't retain NSManagedObjects longer than necessary

### SwiftUI Storage

**Issue**: Data not persisting
- **Solution**: Ensure `savePatients()` is called after updates

**Issue**: Large file size
- **Solution**: Consider compressing JSON or switching to CoreData

**Issue**: Slow loading
- **Solution**: Implement pagination or switch to CoreData for large datasets

## Migration Between Storage Systems

Currently, data is NOT automatically migrated between storage systems. To implement migration:

1. Read data from source storage
2. Convert to target storage format
3. Write to target storage
4. Implement UI for migration trigger

Example concept:
```swift
func migrateCoreDataToSwiftUI() {
    let patients = PersistenceController.shared.fetchPatients()
    for coreDataPatient in patients {
        var swiftUIPatient = PatientData()
        swiftUIPatient.name = coreDataPatient.name
        swiftUIPatient.age = coreDataPatient.age
        // ... copy all fields
        PatientDataStore.shared.addPatient(swiftUIPatient)
    }
}
```

## Performance Monitoring

### Measure Save Performance

```swift
let start = Date()
// Perform save operation
let elapsed = Date().timeIntervalSince(start)
print("Save took \(elapsed) seconds")
```

### Measure Load Performance

```swift
let start = Date()
let patients = dataStore.fetchPatients()
let elapsed = Date().timeIntervalSince(start)
print("Load took \(elapsed) seconds for \(patients.count) patients")
```

## Future Enhancements

1. **Data migration tool** - Allow users to transfer data between storage systems
2. **Export/Import** - Support CSV or JSON export/import
3. **Backup/Restore** - Implement backup functionality
4. **Cloud sync** - Add iCloud support (easier with CoreData)
5. **Search improvements** - Add full-text search capabilities
6. **Undo/Redo** - Implement undo functionality (easier with CoreData)

## References

- [Apple CoreData Documentation](https://developer.apple.com/documentation/coredata)
- [Codable Documentation](https://developer.apple.com/documentation/swift/codable)
- [SwiftUI Data Flow](https://developer.apple.com/documentation/swiftui/managing-model-data-in-your-app)
- [ObservableObject Protocol](https://developer.apple.com/documentation/combine/observableobject)
