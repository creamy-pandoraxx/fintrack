import 'package:fintrack_mobile/app/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders FinTrack app shell', (tester) async {
    await tester.pumpWidget(const FinTrackApp());

    expect(find.text('FinTrack'), findsOneWidget);
  });
}
