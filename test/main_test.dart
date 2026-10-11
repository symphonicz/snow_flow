import 'package:flutter_test/flutter_test.dart';
import 'package:snow_flow/features/entries/presentation/entries_page.dart';
import 'package:snow_flow/main.dart';
import 'package:snow_flow/router.dart';

void main() {
  testWidgets('app opens the entries page through the router', (tester) async {
    final router = createRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(SnowFlowApp(router: router));

    expect(find.byType(EntriesPage), findsOneWidget);
    expect(router.state.matchedLocation, entriesPath);
  });
}
