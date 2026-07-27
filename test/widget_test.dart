import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:tiny_signs/main.dart';
import 'package:tiny_signs/providers/app_state.dart';

void main() {
  testWidgets('Tiny Signs home screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const TinySignsApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Tiny Signs'), findsOneWidget);
    expect(find.text('Start Learning'), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
  });
}
