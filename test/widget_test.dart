import 'package:flutter_test/flutter_test.dart';
import 'package:xaneo_lang_studio/main.dart';

void main() {
  testWidgets('App starts without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const XaneoLangStudioApp());
  });
}
