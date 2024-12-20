
# Gluttex Constants

**Gluttex Constants** is a Flutter package designed to centralize and standardize application-wide constants. This package helps maintain consistency across your Flutter application, making it easier to manage configuration values, UI settings, and reusable strings.

## Features

- **Centralized Configuration**: Define all constant values in one place for easy management.
- **UI Consistency**: Standardize padding, colors, fonts, and other UI elements.
- **Reusable Strings**: Store common text, error messages, and labels to prevent duplication.
- **Environment Separation**: Easily manage constants for multiple environments (e.g., development, staging, production).

## Getting Started

### Prerequisites

Ensure your Flutter environment is set up and running. The package integrates seamlessly with any Flutter project.

### Installation

Add the dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  gluttex_constants:
    git:
      url: https://github.com/your-repo/gluttex_constants.git
```

Then run:

```bash
flutter pub get
```

## Usage

### Example Structure

Here's an example of constants defined in this package:

```dart
class GluttexConstants {
  // General
  static const String appName = "Gluttex";
  
  // UI Padding and Margins
  static const double kDefaultPaddin = 16.0;

  // Colors
  static const Color primaryColor = Color(0xFF00A86B);
  static const Color secondaryColor = Color(0xFFFED766);

  // Error Messages
  static const String errorMessage = "Something went wrong. Please try again.";

  // Labels
  static const String searchTxt = "Search for items...";
}
```

### Using Constants in Your Project

Import the package and use constants throughout your app:

```dart
import 'package:gluttex_constants/gluttex_constants.dart';

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(GluttexConstants.appName),
      ),
      body: Padding(
        padding: EdgeInsets.all(GluttexConstants.kDefaultPaddin),
        child: Text(GluttexConstants.searchTxt),
      ),
    );
  }
}
```

### Environment Configuration

Generate localisation files:

  > flutter gen-l10n
  > 
  >
  >

## Benefits

- **Maintainability**: Keep all constants in a single file for easy updates.
- **Reusability**: Reduce code duplication by reusing common constants.
- **Scalability**: Easily adapt constants for growing projects.

## Contributions

Contributions are welcome! Open an issue or submit a pull request to suggest improvements or add new features.

## License

This project is licensed under the MIT License. See the `LICENSE` file for more details.
