import 'package:dewwit/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('displays the Dewwit app shell', (WidgetTester tester) async {
    await tester.pumpWidget(const DewwitApp());

    expect(find.text('Dewwit'), findsOneWidget);
  });
}
