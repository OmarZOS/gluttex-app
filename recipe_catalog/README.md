

# Gluttex recipe_catalog

**Gluttex recipe_catalog** is a Flutter-based package designed to streamline recipe and ingredient management. Whether you're crafting a cookbook, a meal planner, or a recipe-sharing platform, this package provides powerful tools for handling ingredients, calculating quantities, and organizing culinary content.

## Features

- **Recipe Management**: Add, edit, and organize recipes with intuitive forms.
- **Ingredient Handling**: Manage ingredients with details like quantity, units, and categories.
- **Search and Filter**: Quickly find recipes and ingredients using a built-in search bar.
- **Interactive UI**: Popup dialogs for ingredient input and dynamic recipe form handling.
- **Customizable Quantities**: Fine-tune ingredient quantities for various serving sizes.
- **JSON Integration**: Parse and manage recipe and ingredient data efficiently from JSON responses.

## Getting Started

### Prerequisites

Before using Gluttex recipe_catalog, ensure you have the following:

- **Flutter SDK**: Version 3.0.0 or higher.
- Familiarity with **Dart** programming and Flutter state management tools such as `Provider`.

### Installation

Add the necessary dependencies to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.5
```

### Setup

1. **State Management with Provider**:
   Include `ChangeNotifierProvider` in your widget tree to manage the app state:

   ```dart
   import 'package:provider/provider.dart';
   import 'recipe_change_notifier.dart';

   void main() {
     runApp(
       MultiProvider(
         providers: [
           ChangeNotifierProvider(
             create: (_) => RecipeChangeNotifier(),
           ),
         ],
         child: MyApp(),
       ),
     );
   }
   ```

2. **Recipe Form and Ingredient Popup**:
   Use the provided widgets and methods to build recipe forms with dynamic ingredient handling.

   ```dart
   import 'package:recipe_catalog/recipe_form_widget.dart';

   class MyApp extends StatelessWidget {
     @override
     Widget build(BuildContext context) {
       return MaterialApp(
         home: RecipeFormWidget(),
       );
     }
   }
   ```

3. **JSON Parsing**:
   Ensure your recipe and ingredient models align with the JSON structure you're working with. Leverage Dart’s `jsonDecode` to parse responses into objects.

## Usage

- **Create Recipes**: Use the recipe form to input recipe names, instructions, and ingredients.
- **Manage Ingredients**: Add ingredients via popups with quantity and unit input fields.
- **Search and Filter**: Implement search functionality for quick access to specific recipes or ingredients.

## Example

Here's a simple example of adding a recipe:

```dart
final recipe = Recipe(
  name: 'Gluten-Free Pancakes',
  ingredients: [
    Ingredient(name: 'Almond Flour', quantity: 2, unit: 'cups'),
    Ingredient(name: 'Eggs', quantity: 3, unit: 'pieces'),
  ],
  instructions: 'Mix all ingredients and cook on a heated pan.',
);
```

## Screenshots

*(Include screenshots showcasing the recipe form, ingredient popup, and recipe list.)*

## Contributions

We welcome contributions! Feel free to open issues or submit pull requests to enhance the package.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

## Acknowledgments

- Flutter and Dart communities for their robust frameworks and libraries.
- Developers contributing to open-source culinary apps and tools.

