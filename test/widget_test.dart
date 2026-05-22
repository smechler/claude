import 'package:flutter_test/flutter_test.dart';
import 'package:condokey/app.dart';
import 'package:condokey/providers/app_provider.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('App renders home screen', (tester) async {
    final provider = AppProvider();
    await provider.init();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const CondoKeyApp(),
      ),
    );

    expect(find.text('Access'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
  });
}
