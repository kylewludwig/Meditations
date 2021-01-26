# Meditations

Unofficial clone of the Ten Percent Happier for iOS. Follows Raymond Law's Clean Swift (VIP) user interface design pattern.

#### Features
- Dark mode support
- Image caching

### Getting Started
1. `git clone git clone https://github.com/kylewludwig/meditations` to copy the repository via HTTPS.
2. `cd Meditations` to move into the root directory.
3. `brew install` to install [SwiftLint](https://github.com/realm/SwiftLint) with [Homebrew](https://brew.sh/).
4. `open -a Xcode Meditations.xcodeproj` to open the app in XCode.
5. Choose a target device and press ▶️ on the top-left corner of XCode to run the application.

### Contributing
1. [SwiftLint](https://github.com/realm/SwiftLint) is installed via [Homebrew](https://brew.sh/). Changes to current warning or error behavior can be made in the root repository to `.swiftlint.yml`.
2. Follow [Clean Swift](https://clean-swift.com/) architecture to add new features and unit tests.
3. Make a `new-feature` branch, add commits, then squash and merge back into `develop` (with a reviewer on the pull request.)

### Release
1. Request access to Meditations in your [Apple Developer](https://developer.apple.com/) account.
2. Go to `Certificates, IDs and Profiles` and generate a certificate for development (to launch on devices) and distribution (to release on the App Store and Testflight.)
3. Download the certificates and double-click them in your Downloads folder to install them into your KeyChain. They should appear in `Targets` > `Meditations` > `Signing & Capabilities`.
4. Increment the Version or Build in `Targets` > `Meditations` as needed for the next release.
5. Go to `Product > Archive` to create a `.xcarchive` of the application for release.
6. Press `Distribute App` > `App Store Connect` > (wait for loading) Next including automatic signing and ticking all checkboxes.
7. Press `Upload` then login to App Store Connect and wait for the latest build to appear.
8. Follow all steps on App Store Connect to either release to the App Store (for production releases) or Test Flight (for beta releases)
