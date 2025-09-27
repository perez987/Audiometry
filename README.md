# Audiometry

![Platform](https://img.shields.io/badge/macOS-13+-orange.svg)
![Xcode](https://img.shields.io/badge/Xcode-macOS13+-lavender.svg)
![Downloads](https://img.shields.io/github/downloads/perez987/Audiometry/total?label=Downloads&color=9494ff)

## App for macOS 13+

<img src="Images/Main-window.png" width="640px">

- Xcode 15.2 project
- App runs on macOS13+.

- Feature Summary:
  - patient data entry
  - audiometric test input
  - hearing loss assessment calculations
  - including SAL and ELI indices with results display
  - save patients data in core data
  - language system with English and Spanish
  - buttons to move back and forth between saved patients
  - search button.

## Patient data saved
  
Patient data are saved in the user folder as a SQLite database, at the following location:

`/Users/<user_name>/Library/Containers/perez987.Audiometry/Data/Library/Application Support/Audiometry/DataModel.sqlite`

## Extended information on features
  
### 🌐 Language Support
- **Bilingual Interface**: Switch between English and Spanish
- **Localized Classifications**: Hearing loss classifications in both languages
- **Complete UI Translation**: All interface elements support both languages.

### 💾 Patient Data Management
- **Core Data Integration**: Persistent storage of patient records
- **Save button**: Patient data saved
- **Patient Navigation**: Browse through saved patients with Previous/Next buttons
- **New Patient Creation**: Easy creation of new patient records

### 🔍 Search & Navigation
- **Patient Search**: Search patients by name with dedicated search interface
- **Patient Counter**: Shows current position in patient list (e.g., "1 / 3")
- **Quick Access**: Navigation bar with all essential functions

### 🏥 User Experience
- **Streamlined Workflow**: All patient management functions in top navigation bar
- **Preserved Functionality**: All original audiometry calculations maintained
- **macOS Design**: Native macOS interface following Apple's design guidelines

