// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_front/app/app.dart';
import 'package:mobile_front/features/splash_screen/widget/splash_screen_widget.dart';

void main() {
  testWidgets('Menampilkan splash screen saat aplikasi dibuka',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(SplashScreenWidget), findsOneWidget);
  });
}
