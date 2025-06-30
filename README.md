# OversizeServices

[![Swift 6.0](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A comprehensive collection of service modules for Apple platforms that provides easy-to-use interfaces for system frameworks including HealthKit, StoreKit, Core Location, EventKit, Contacts, UserNotifications, and File Management with iCloud support.

## Features

- 🏥 **Health Services** - HealthKit integration for health data management
- 🛒 **Store Services** - StoreKit integration for in-app purchases and App Store reviews
- 📍 **Location Services** - Core Location wrapper for GPS and geocoding
- 📅 **Calendar Services** - EventKit integration for calendar and event management
- 👥 **Contacts Services** - Contacts framework integration
- 🔔 **Notification Services** - Local notifications management
- 📁 **File Manager Services** - File operations with iCloud Documents support
- 🏭 **Dependency Injection** - Factory-based service registration and injection
- 🌐 **Multi-platform** - Support for iOS, macOS, tvOS, and watchOS

## Requirements

- **iOS** 15.0+
- **macOS** 12.0+
- **tvOS** 15.0+
- **watchOS** 9.0+
- **Swift** 6.0+
- **Xcode** 16.4+

## Installation

### Swift Package Manager

Add OversizeServices to your project using Swift Package Manager:

1. In Xcode, select "File" → "Add Package Dependencies"
2. Enter the repository URL: `https://github.com/oversizedev/OversizeServices.git`
3. Choose the version you want to use

Or add it to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/oversizedev/OversizeServices.git", .upToNextMajor(from: "1.19.0"))
]
```

Then import the specific services you need:

```swift
import OversizeServices
import OversizeHealthService
import OversizeStoreService
import OversizeLocationService
import OversizeCalendarService
import OversizeContactsService
import OversizeNotificationService
import OversizeFileManagerService
```

## Services Documentation

### 🏥 OversizeHealthService

Provides HealthKit integration for health data management.

**Features:**
- Blood pressure monitoring and recording
- Body mass index tracking
- Heart rate data management
- HealthKit authorization handling

**Usage Example:**

```swift
import OversizeHealthService
import FactoryKit

// Inject the service
@Injected(\.bodyMassService) var bodyMassService: BodyMassServiceProtocol
@Injected(\.bloodPressureService) var bloodPressureService: BloodPressureService

// Save blood pressure data
let result = await bloodPressureService.saveBloodPressure(
    systolic: 120,
    diastolic: 80,
    heartRate: 75,
    date: Date(),
    syncId: UUID(),
    syncVersion: 1
)

// Fetch blood pressure history
let historyResult = await bloodPressureService.fetchBloodPressure(
    startDate: Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date(),
    endDate: Date()
)
```

### 🛒 OversizeStoreService

StoreKit integration for in-app purchases and App Store functionality.

**Features:**
- Product catalog management
- Purchase handling
- Subscription management
- App Store review requests
- Transaction verification

**Usage Example:**

```swift
import OversizeStoreService
import FactoryKit

// Inject the services
@Injected(\.storeKitService) var storeKitService: StoreKitService
@Injected(\.appStoreReviewService) var reviewService: AppStoreReviewService

// Request products
let productIds = ["com.example.premium", "com.example.subscription"]
let result = await storeKitService.requestProducts(productIds: productIds)

switch result {
case .success(let products):
    // Handle products
    print("Found \(products.nonConsumable.count) non-consumable products")
case .failure(let error):
    // Handle error
    print("Failed to fetch products: \(error)")
}

// Request App Store review
reviewService.requestReview()
```

### 📍 OversizeLocationService

Core Location services wrapper for GPS and geocoding functionality.

**Features:**
- Current location retrieval
- Authorization management
- Address geocoding
- Reverse geocoding
- Location permission handling

**Usage Example:**

```swift
import OversizeLocationService
import FactoryKit

// Inject the service
@Injected(\.locationService) var locationService: LocationServiceProtocol

// Get current location
do {
    if let coordinate = try await locationService.currentLocation() {
        print("Current location: \(coordinate.latitude), \(coordinate.longitude)")
        
        // Get address from coordinates
        let address = try await locationService.fetchAddressFromLocation(coordinate)
        print("Address: \(address.formattedAddress)")
    }
} catch {
    print("Location error: \(error)")
}

// Check permissions
let permissionResult = locationService.permissionsStatus()
switch permissionResult {
case .success(let hasPermission):
    print("Location permission granted: \(hasPermission)")
case .failure(let error):
    print("Permission error: \(error)")
}
```

### 📅 OversizeCalendarService

EventKit integration for calendar and event management.

**Features:**
- Event creation and modification
- Calendar access management
- Recurring events support
- Event reminders and alarms
- Calendar source management

**Usage Example:**

```swift
import OversizeCalendarService

let calendarService = CalendarService()

// Create a new event
let result = await calendarService.createEvent(
    title: "Team Meeting",
    notes: "Weekly team sync",
    startDate: Date(),
    endDate: Date().addingTimeInterval(3600), // 1 hour later
    isAllDay: false,
    location: "Conference Room A",
    alarms: [.fiveMinutes, .fifteenMinutes],
    recurrenceRules: .weekly
)

switch result {
case .success(let eventCreated):
    print("Event created successfully: \(eventCreated)")
case .failure(let error):
    print("Failed to create event: \(error)")
}

// Fetch calendars
let calendarsResult = await calendarService.fetchCalendars()
```

### 👥 OversizeContactsService

Contacts framework integration for contact management.

**Features:**
- Contact fetching and enumeration
- Contact access authorization
- Contact data retrieval with custom keys
- Contact sorting and filtering

**Usage Example:**

```swift
import OversizeContactsService
import FactoryKit

// Inject the service
@Injected(\.contactsService) var contactsService: ContactsService

// Request access to contacts
let accessResult = await contactsService.requestAccess()

switch accessResult {
case .success:
    // Fetch all contacts
    let contactsResult = await contactsService.fetchContacts()
    
    switch contactsResult {
    case .success(let contacts):
        print("Found \(contacts.count) contacts")
        for contact in contacts {
            print("Contact: \(contact.givenName) \(contact.familyName)")
        }
    case .failure(let error):
        print("Failed to fetch contacts: \(error)")
    }
case .failure(let error):
    print("Access denied: \(error)")
}
```

### 🔔 OversizeNotificationService

Local notifications management with UserNotifications framework.

**Features:**
- Local notification scheduling
- Notification authorization
- Pending notifications management
- Custom notification content
- Time-based and location-based triggers

**Usage Example:**

```swift
import OversizeNotificationService
import FactoryKit

// Inject the service
@Injected(\.localNotificationService) var notificationService: LocalNotificationServiceProtocol

// Request notification permissions
let accessResult = await notificationService.requestAccess()

switch accessResult {
case .success:
    // Schedule a notification
    await notificationService.scheduleNotification(
        id: UUID(),
        title: "Reminder",
        body: "Don't forget your appointment",
        timeInterval: 3600, // 1 hour from now
        repeatNotification: false,
        scheduleType: .time,
        dateComponents: DateComponents()
    )
    
    // Check pending notifications
    let pendingIds = await notificationService.fetchPendingIds()
    print("Pending notifications: \(pendingIds.count)")
    
case .failure(let error):
    print("Notification access denied: \(error)")
}
```

### 📁 OversizeFileManagerService

File management with iCloud Documents support.

**Features:**
- Local document management
- iCloud Documents integration
- File synchronization
- Document picker integration
- Cloud storage availability checking

**Usage Example:**

```swift
import OversizeFileManagerService
import FactoryKit

// Inject the services
@Injected(\.fileManagerService) var fileManager: FileManagerServiceProtocol
@Injected(\.cloudDocumentsService) var cloudService: CloudDocumentsServiceProtocol
@Injected(\.fileManagerSyncService) var syncService: FileManagerSyncServiceProtocol

// Check iCloud availability
let iCloudResult = syncService.isICloudContainerAvailable()

switch iCloudResult {
case .success(let available):
    if available {
        print("iCloud is available")
        
        // Save document to iCloud
        let fileURL = URL(fileURLWithPath: "/path/to/document.pdf")
        let saveResult = await syncService.saveDocument(
            fileURL: fileURL,
            folder: "Documents",
            location: .iCloud
        )
        
        switch saveResult {
        case .success(let savedURL):
            print("Document saved to: \(savedURL)")
        case .failure(let error):
            print("Save failed: \(error)")
        }
    }
case .failure(let error):
    print("iCloud not available: \(error)")
}

// Save document locally
let localURL = URL(fileURLWithPath: "/path/to/local/document.pdf")
let localResult = await fileManager.saveDocument(pickedURL: localURL, folder: "LocalDocs")
```

### 🏭 OversizeServices (Core)

The main module that provides service registration and dependency injection setup.

**Usage Example:**

```swift
import OversizeServices
import FactoryKit

// Services are automatically registered and can be injected using Factory
@Injected(\.someService) var service: SomeServiceProtocol

// Or resolve manually
let container = Container.shared
let service = container.someService()
```

## Dependencies

OversizeServices depends on several other packages from the Oversize ecosystem:

- **[OversizeCore](https://github.com/oversizedev/OversizeCore)** - Core utilities and extensions
- **[OversizeModels](https://github.com/oversizedev/OversizeModels)** - Shared data models
- **[OversizeLocalizable](https://github.com/oversizedev/OversizeLocalizable)** - Localization support
- **[Factory](https://github.com/hmlongco/Factory)** - Dependency injection container

## License

OversizeServices is released under the MIT license. See [LICENSE](LICENSE) for details.

---

<div align="center">

**Made with ❤️ by the Oversize**

</div>
