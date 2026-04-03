import 'package:flutter_test/flutter_test.dart';
import 'package:pet_finder/main.dart';

void main() {
  testWidgets('PetFinder app smoke test', (WidgetTester tester) async {
    // Minimal smoke test — only verifies the app compiles
    expect(PetFinderApp, isNotNull);
  });
}
