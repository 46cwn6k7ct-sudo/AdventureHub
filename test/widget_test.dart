import 'package:flutter_test/flutter_test.dart';
import 'package:adventure_hub/main.dart';

void main() {
  testWidgets('Adventure Hub starts', (tester) async {
    await tester.pumpWidget(const AdventureHubApp());
    expect(find.text('Home'), findsOneWidget);
  });
}
