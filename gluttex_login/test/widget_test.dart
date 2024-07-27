import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gluttex_core/app/AuthService.dart';
import 'package:gluttex_core/app/UserService.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:gluttex_impl_app/gluttex_impl_app.dart';
import 'package:gluttex_impl_app/gluttex_impl_auth.dart';
import 'package:gluttex_impl_mediation/gluttex_impl_mediation.dart';
import 'package:gluttex_login/screens/registration_screen.dart';
import 'package:locator/locator.dart';
import 'package:provider/provider.dart';
import 'package:gluttex_impl_app/user_change_notifier.dart';

void main() {
  testWidgets('RegistrationForm Test', (WidgetTester tester) async {
    // Create a fake AppUserNotifier to provide the necessary methods for the form.

    GluttexLocator.registerSingletonService<AppUserService>(
        AppUserServiceImpl());
    GluttexLocator.registerSingletonService<StorageService>(
        StorageServiceImpl());
    GluttexLocator.registerSingletonService<AuthService>(AuthServiceImpl());

    final appUserNotifier = AppUserNotifier();

    // Build the RegistrationForm widget inside a Provider.
    await tester.pumpWidget(
      ChangeNotifierProvider<AppUserNotifier>.value(
        value: appUserNotifier,
        child: MaterialApp(
          home: Scaffold(
            body: RegistrationForm(),
          ),
        ),
      ),
    );

    // Verify the form fields are present.
    expect(find.byType(TextFormField),
        findsNWidgets(5)); // Number of TextFormFields
    expect(find.byType(DropdownButtonFormField<String>),
        findsNWidgets(4)); // Number of DropdownButtonFormField<String>s

    // Fill in the form fields.
    await tester.enterText(
        find.byType(TextFormField).at(0), 'testuser'); // Username
    await tester.enterText(
        find.byType(TextFormField).at(1), 'password123'); // Password
    await tester
        .tap(find.byType(DropdownButtonFormField<String>).at(0)); // User Type
    await tester.pumpAndSettle();
    await tester.tap(find.text('Client').last); // Select 'Client'
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byType(TextFormField).at(2), 'John'); // First Name
    await tester.enterText(
        find.byType(TextFormField).at(3), 'Doe'); // Last Name
    await tester.tap(find.byType(TextFormField).at(4)); // Birthdate
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK').last); // Select Date
    await tester.pumpAndSettle();

    await tester
        .tap(find.byType(DropdownButtonFormField<String>).at(1)); // Gender
    await tester.pumpAndSettle();
    await tester.tap(find.text('Male').last); // Select 'Male'
    await tester.pumpAndSettle();

    await tester
        .tap(find.byType(DropdownButtonFormField<String>).at(2)); // Nationality
    await tester.pumpAndSettle();
    await tester.tap(find.text('Algerian').last); // Select 'Algerian'
    await tester.pumpAndSettle();

    await tester
        .tap(find.byType(DropdownButtonFormField<String>).at(3)); // Blood Type
    await tester.pumpAndSettle();
    await tester.tap(find.text('O+').last); // Select 'O+'
    await tester.pumpAndSettle();

    // Submit the form.
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // Verify if the form data is logged (for this example, we're just printing to the console).
    expect(find.text('Register'), findsOneWidget);
  });
}
