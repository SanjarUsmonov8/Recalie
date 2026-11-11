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
        enableAds: false,
        catalogApiClient: _catalogApiClient,
      ),
    );

    expect(find.text('Recalie'), findsOneWidget);
    expect(find.byKey(const Key('recalieNavigationBar')), findsOneWidget);
    expect(find.byKey(const Key('recalieAddButton')), findsOneWidget);

    await tester.tap(find.byKey(const Key('recalieNavDiscover')));
    // Native ads complete on the platform side, so waiting for every possible
    // frame to settle is not appropriate in a widget test.
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Discover'), findsOneWidget);

    await tester.tap(find.byKey(const Key('recalieNavAi')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('AI Coach'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
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
    await tester.pumpAndSettle();
    await database.close();
  });

  testWidgets('plans page changes and persists the membership plan', (
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

    await tester.tap(find.byKey(const Key('premiumButton')));
    await tester.pumpAndSettle();

    expect(find.text('Choose your plan'), findsOneWidget);
    expect(find.text(r'$1.99 / month'), findsOneWidget);
    expect(find.text(r'$4.99 / month'), findsOneWidget);

    await tester.ensureVisible(find.text('Choose Plus'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose Plus'));
    await tester.pumpAndSettle();

    final preference = await (database.select(
      database.appPreferences,
    )..where((row) => row.key.equals('membership_plan'))).getSingle();
    expect(preference.value, 'plus');
    final expiryPreference =
        await (database.select(database.appPreferences)
              ..where((row) => row.key.equals('membership_plan_expires_at')))
            .getSingle();
    final expiry = DateTime.parse(expiryPreference.value);
    expect(expiry.isAfter(DateTime.now()), isTrue);
    expect(find.text('Choose Plus'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await database.close();
  });

  testWidgets('profile page edits and persists the user name', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    await tester.pumpWidget(
      RecalieApp(
        database: database,
        showPictureGroups: false,
        catalogApiClient: _catalogApiClient,
      ),
    );
    await tester.tap(find.byKey(const Key('profileButton')).hitTestable());
    await tester.pumpAndSettle();

    expect(find.text('Your Name'), findsOneWidget);
    expect(find.text('Sets'), findsOneWidget);
    expect(find.text('Plan'), findsOneWidget);
    expect(find.text('Active until'), findsOneWidget);
    expect(find.byKey(const Key('walnutProfileCard')), findsOneWidget);
    await tester.tap(find.byKey(const Key('editProfileButton')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('profileNameField')),
      'Ada Lovelace',
    );
    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Ada Lovelace'), findsOneWidget);
    final preference = await (database.select(
      database.appPreferences,
    )..where((row) => row.key.equals('profile_name'))).getSingle();
    expect(preference.value, 'Ada Lovelace');

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await database.close();
  });
}
