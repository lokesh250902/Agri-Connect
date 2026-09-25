import 'package:flutter_test/flutter_test.dart';

import 'package:agri_voice_ai/main.dart';

void main() {
  testWidgets('App builds and shows the home screen title', (WidgetTester tester) async {
    await tester.pumpWidget(const AgriVoiceApp());

    expect(find.text('Agri Voice AI'), findsWidgets);
  });
}
