import 'package:adventure_hub/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows loading state then app navigation', (tester) async {
    await tester.pumpWidget(const AdventureHubApp());
    expect(find.byType(AdventureHubApp), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Adventure Hub'), findsWidgets);
    expect(find.text('Itinerary'), findsOneWidget);
    expect(find.text('Bookings'), findsOneWidget);
    expect(find.text('Budget'), findsOneWidget);
  });
}
