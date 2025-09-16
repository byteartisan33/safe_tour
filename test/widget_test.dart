// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:safe_tour/main.dart';

void main() {
  testWidgets('Splash screen loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TouristSafetyApp());

    // Verify that our splash screen loads with the app title.
    expect(find.text('Smart Tourist Safety'), findsOneWidget);
    expect(find.text('Monitoring & Incident Response System'), findsOneWidget);
    expect(find.text('Select Your Preferred Language'), findsOneWidget);

    // Verify that navigation buttons are present.
    expect(find.text('New User - Register'), findsOneWidget);
    expect(find.text('Existing User - Login'), findsOneWidget);
  });
}
