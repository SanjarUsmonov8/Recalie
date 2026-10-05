import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:recalie/data/local/app_database.dart';
import 'package:recalie/features/discover/catalog_api.dart';
import 'package:recalie/main.dart';

final _catalogApiClient = CatalogApiClient(
  baseUrl: 'https://example.test/api/v1',
  client: MockClient(
    (_) async => http.Response(
      '[{"slug":"english","name":"English","subtitle":"Words and grammar","icon":"translate","color_start":"#2563EB","color_end":"#60A5FA","cover_image_url":""}]',
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
    ),
  ),
);

void main() {
  testWidgets('capsule navigation switches between Recalie pages', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    await tester.pumpWidget(
      RecalieApp(
        database: database,
        showPictureGroups: false,
        catalogApiClient: _catalogApiClient,
      ),
    );

    expect(find.text('Recalie'), findsOneWidget);
    expect(find.byKey(const Key('recalieNavigationBar')), findsOneWidget);
    expect(find.byKey(const Key('recalieAddButton')), findsOneWidget);

    await tester.tap(find.byKey(const Key('recalieNavDiscover')));
    await tester.pumpAndSettle();
    expect(find.text('Discover'), findsOneWidget);

    await tester.tap(find.byKey(const Key('recalieNavAi')));
    await tester.pumpAndSettle();
    expect(find.text('AI Coach'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await database.close();
  });

  testWidgets('settings page changes the app theme', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    await tester.pumpWidget(
      RecalieApp(
        database: database,
        showPictureGroups: false,
        catalogApiClient: _catalogApiClient,
      ),
    );

    await tester.tap(find.byKey(const Key('settingsButton')));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    await tester.tap(find.byKey(const Key('darkThemeOption')));
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await database.close();
  });
}
