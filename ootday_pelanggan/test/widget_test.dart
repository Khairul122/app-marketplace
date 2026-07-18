import 'package:flutter_test/flutter_test.dart';
import 'package:ootday_pelanggan/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const OotdayApp());

    // Verify that the app title or some home page element exists.
    expect(find.textContaining('Fashionista'), findsOneWidget);
  });
}
