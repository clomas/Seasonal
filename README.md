# Seasonal

A seasonal produce guide for Australia. Find out which fruit, vegetables and herbs are in season where you live, month by month or season by season, and keep a list of your favourites.

Seasonal is a personal project and was my first iOS app. It has now been rebuilt in SwiftUI for iOS 26 with Liquid Glass, while the original UIKit app still ships for older versions of iOS.

## Features

- **Months and Seasons**: swipe through the year to see what's in season. The title menu jumps straight to any month or season, and the list opens on the current one.
- **Favourites**: like produce to keep it in a Favourites tab. Likes sync through iCloud and are kept on the device, so they work offline.
- **Search**: a system search tab that searches whichever view you came from.
- **Category filter**: show only fruit, vegetables or herbs.
- **Months-in-season capsule**: each row shows the months an item is in season, with the current month marked.
- **Location aware**: produce is specific to each state and territory. Your location is detected on first launch (or you can pick it), and can be changed in Settings.
- **Themes**: Fresh, Citrus, Berry and Ocean accent themes, or Automatic, which follows the current season. Light, dark or system appearance.
- **Liquid Glass**: native tab bar, toolbars, glass buttons and a layered app icon made with Icon Composer.
- **Accessibility**: Dynamic Type through to the accessibility sizes, VoiceOver labels (the month capsule reads out the months in full), and accent colours that meet WCAG AA in light, dark and high-contrast modes.
- **Offline friendly**: each region's produce is cached on disk after the first download, so later launches only need to refresh likes.

## From UIKit to SwiftUI

### Where it started

I'm a self-taught developer. I first learnt C# at work while writing Swift in my spare time, and Seasonal was the first app I released on the App Store. It began loosely as MVC, with pods including Infinite Layout, which I later removed to build the infinite `UICollectionView` myself. I then rewrote it in MVVM-C as I learnt more about design principles, and learnt a lot about the benefits and hurdles of that pattern along the way.

### Where it is now

The iOS 26 app is a ground-up SwiftUI rewrite. Rather than port the coordinators and view models, it leans on what SwiftUI and the system now provide:

| | UIKit app (iOS 15–25) | SwiftUI app (iOS 26+) |
|---|---|---|
| Pattern | MVVM-C: view controllers, view models and coordinators | Observable state shared through the environment |
| State | Delegates and callbacks | `@Observable` models (`AppCoordinator`, `ProduceStore`, `MainScreenState`) |
| Navigation | Custom menu bar and child view controllers | `TabView` with a search tab, `toolbarTitleMenu`, sheets |
| Paging | Hand-built infinite `UICollectionView` | Paging `ScrollView` shared by months and seasons through a `PeriodType` protocol |
| Concurrency | Completion handlers | async/await, `CLLocationUpdate`, `NWPathMonitor` as an async sequence, Swift 6 strict concurrency |
| Data | CloudKit fetched on every launch | CloudKit behind a `ProduceProviding` protocol, with an in-memory cache and a versioned disk cache |
| Onboarding | Custom welcome screens | TipKit, with a one-time swipe "peek" to show that the pager scrolls |
| Testing | XCTest | Swift Testing, snapshot tests and XCUITest |

### How the two apps live side by side

`SceneDelegate` checks a feature toggle and the OS version, then starts either `AppCoordinator` (SwiftUI) or `AppCoordinatorOld` (UIKit). Both conform to `AppCoordinatorVersionProtocol`, so the scene doesn't care which one it gets. The legacy app lives in `Seasonal/< iOS 26` and is left alone unless a change needs it.

Both apps read and write likes in the same on-device format, so favourites carry over when a device updates to iOS 26.

### Architecture

```
SceneDelegate
└── AppCoordinator          network → location → CloudKit, drives the launch state
    └── RootScreen
        ├── InitialScreen   loading, location picker and error states
        └── MainTabScreen   Favourites · Months · Seasons · Search
            └── ProduceTabView
                ├── PeriodPagerView<Months | Seasons>
                └── ProduceList → ProduceListRow
```

- **`AppCoordinator`** owns the launch flow as a single `AppCoordinatorState`: wait for the network, find the location (saved, detected, or chosen), then fetch the produce. Each step is a cancellable task, so retries and location changes never race.
- **`ProduceStore`** is the single source of truth for produce. It filters by period and favourites through a small cache, applies likes optimistically and chains the CloudKit syncs, so a quick like-then-unlike reaches the server in order. Failed unlikes are queued in `PendingUnlikes` so they don't come back on the next launch.
- **`MainScreenState`** holds the tab, category, search text and current page. The search tab rebuilds the screen it was opened from, and both copies share this state so they stay on the same month.
- **Services** sit behind small protocols (`ProduceProviding`, `ProduceDiskCaching`), so the store can be tested with in-memory mocks.
- **Design system**: spacing and fonts come from `DesignSystem` tokens, text from a String Catalog, and colours, symbols and links from their own namespaces, so there are no magic values in the views.

## Testing

- **Unit tests** (Swift Testing): the store, caches, likes, period maths, CloudKit record mapping and error messages, and theme contrast ratios.
- **Snapshot tests** using [swift-snapshot-testing](https://github.com/pointfreeco/swift-snapshot-testing), recorded on the iPhone 17 Pro simulator.
- **UI tests** (XCUITest) for onboarding, tab navigation, paging, filtering, search, likes and settings.

Launch with the `use-mock-data` argument to skip the network, location and CloudKit and load preview data.

## Requirements

- Xcode 26
- iOS 26 for the SwiftUI app; iOS 15.6 for the UIKit app

## Feedback

I'm always trying to learn and improve, particularly with Swift, so any feedback is very welcome. Open an issue or get in touch through the app's Settings screen.
