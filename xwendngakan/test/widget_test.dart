import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:xwendngakan/main.dart';
import 'package:xwendngakan/providers/app_provider.dart';

void main() {
  testWidgets('App builds smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppProvider(),
        child: const XwendngakanApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('edu book'), findsWidgets);
  });
}
