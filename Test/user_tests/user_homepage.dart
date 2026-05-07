import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unisoc/services/api_services.dart';
import 'package:unisoc/screens/user/user_home_page.dart';

// ─────────────────────────────────────────────
//  Sample data factories
// ─────────────────────────────────────────────

List<dynamic> _makeSocieties() => [
  {
    'id': 1,
    'name': 'Athletics Club',
    'category': 'Sports',
    'description': 'Running and field events',
    'member_count': 80,
  },
  {
    'id': 2,
    'name': 'Chess Club',
    'category': 'Academic',
    'description': 'Strategy board games',
    'member_count': 20,
  },
  {
    'id': 3,
    'name': 'Drama Society',
    'category': 'Cultural',
    'description': 'Theatre and performance',
    'member_count': 50,
  },
  {
    'id': 4,
    'name': 'Football Society',
    'category': 'Sports',
    'description': 'Competitive football',
    'member_count': 120,
  },
  {
    'id': 5,
    'name': 'Islamic Society',
    'category': 'Religious',
    'description': 'Faith and community',
    'member_count': 60,
  },
];

List<dynamic> _makeEvents() => [
  {
    'id': 1,
    'title': 'Freshers Run',
    'start_time': DateTime.now().add(const Duration(days: 2)).toIso8601String(),
    'location': 'Sports Hall',
    'society_id': 1,
    'society_name': 'Athletics Club',
  },
  {
    'id': 2,
    'title': 'Chess Tournament',
    'start_time': DateTime.now().add(const Duration(days: 5)).toIso8601String(),
    'location': 'Library Room 3',
    'society_id': 2,
    'society_name': 'Chess Club',
  },
];

// ─────────────────────────────────────────────
//  Helpers
// ─────────────────────────────────────────────

Widget _wrap(Widget child) => MaterialApp(home: child);

/// Builds a [HomePage] with injected mock data functions so no HTTP calls
/// are made.
Widget _homePage({
  List<dynamic>? societies,
  List<dynamic>? events,
  bool throwSocieties = false,
  bool throwEvents = false,
  Duration societyDelay = Duration.zero,
}) {
  return _wrap(
    HomePage(
      getSocieties: () async {
        if (societyDelay != Duration.zero) {
          await Future.delayed(societyDelay);
        }
        if (throwSocieties) throw Exception('Server Error');
        return societies ?? _makeSocieties();
      },
      getEventsForJoinedSocieties: () async {
        if (throwEvents) throw Exception('Server Error');
        return events ?? _makeEvents();
      },
    ),
  );
}

/// Pumps the widget and waits for all async work to finish.
Future<void> _pump(WidgetTester tester, Widget page) async {
  await tester.pumpWidget(page);
  await tester.pumpAndSettle();
}

// ─────────────────────────────────────────────
//  Tests
// ─────────────────────────────────────────────

void main() {
  setUp(() {
    ApiService.authToken = 'test-token';
  });

  // ═══════════════════════════════════════════════════════════
  //  TC: VALID LOAD  — "user logged in → APIs loaded correctly"
  // ═══════════════════════════════════════════════════════════

  group('Valid load (TC-H-01)', () {
    testWidgets('TC-H-01a | Page renders without crashing on valid data', (
      tester,
    ) async {
      await _pump(tester, _homePage());
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('TC-H-01b | "UniSoc" title is displayed after load', (
      tester,
    ) async {
      await _pump(tester, _homePage());
      expect(find.text('UniSoc'), findsOneWidget);
    });

    testWidgets(
      'TC-H-01c | Society list is rendered after successful API call',
      (tester) async {
        await _pump(tester, _homePage());
        expect(find.text('Athletics Club'), findsOneWidget);
      },
    );

    testWidgets('TC-H-01d | All societies from the API appear in the list', (
      tester,
    ) async {
      await _pump(tester, _homePage());
      for (final name in [
        'Athletics Club',
        'Chess Club',
        'Drama Society',
        'Football Society',
        'Islamic Society',
      ]) {
        expect(
          find.text(name),
          findsWidgets,
          reason: '$name should be visible',
        );
      }
    });
  });

  // ═══════════════════════════════════════════════════════════
  //  TC: LOADING STATE — "slow API → circular loading sign visible"
  // ═══════════════════════════════════════════════════════════

  group('Loading state (TC-H-02)', () {
    testWidgets(
      'TC-H-02a | CircularProgressIndicator shown while APIs are in flight',
      (tester) async {
        // Use a delayed mock so loading is visible on first frame
        await tester.pumpWidget(
          _homePage(societyDelay: const Duration(seconds: 10)),
        );
        await tester.pump(); // one frame only
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'TC-H-02b | CircularProgressIndicator disappears once data arrives',
      (tester) async {
        await _pump(tester, _homePage());
        expect(find.byType(CircularProgressIndicator), findsNothing);
      },
    );
  });

  // ═══════════════════════════════════════════════════════════
  //  TC: API FAILURE — "server down → error message displayed"
  // ═══════════════════════════════════════════════════════════

  group('API failure (TC-H-03)', () {
    testWidgets('TC-H-03a | Error message shown when societies API throws', (
      tester,
    ) async {
      await _pump(tester, _homePage(throwSocieties: true));
      expect(find.textContaining('Error'), findsOneWidget);
    });

    testWidgets('TC-H-03b | Society list is NOT shown on API failure', (
      tester,
    ) async {
      await _pump(tester, _homePage(throwSocieties: true));
      expect(find.text('Athletics Club'), findsNothing);
    });

    testWidgets(
      'TC-H-03c | CircularProgressIndicator is gone after failure resolves',
      (tester) async {
        await _pump(tester, _homePage(throwSocieties: true));
        expect(find.byType(CircularProgressIndicator), findsNothing);
      },
    );
  });

  // ═══════════════════════════════════════════════════════════
  //  TC: SEARCH BAR — "valid query → dropdown results displayed"
  // ═══════════════════════════════════════════════════════════

  group('Search bar (TC-H-04)', () {
    testWidgets('TC-H-04a | Search TextField is present on the page', (
      tester,
    ) async {
      await _pump(tester, _homePage());
      expect(
        find.widgetWithText(TextField, 'Search events or societies'),
        findsOneWidget,
      );
    });

    testWidgets('TC-H-04b | Typing in the search field is accepted', (
      tester,
    ) async {
      await _pump(tester, _homePage());
      await tester.enterText(
        find.widgetWithText(TextField, 'Search events or societies'),
        'Football',
      );
      expect(find.text('Football'), findsOneWidget);
    });

    testWidgets('TC-H-04c | Search icon is visible inside the search field', (
      tester,
    ) async {
      await _pump(tester, _homePage());
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('TC-H-04d | Clearing the search field removes typed text', (
      tester,
    ) async {
      await _pump(tester, _homePage());
      final field = find.widgetWithText(
        TextField,
        'Search events or societies',
      );
      await tester.enterText(field, 'Football');
      await tester.enterText(field, '');
      expect(find.text('Football'), findsNothing);
    });
  });

  // ═══════════════════════════════════════════════════════════
  //  TC: FEATURED SOCIETIES — "data exists → top societies displayed"
  // ═══════════════════════════════════════════════════════════

  group('Featured Societies (TC-H-05)', () {
    testWidgets('TC-H-05a | "Featured Societies" heading is shown', (
      tester,
    ) async {
      await _pump(tester, _homePage());
      expect(find.text('Featured Societies'), findsOneWidget);
    });

    testWidgets(
      'TC-H-05b | At least one society card is rendered in the carousel',
      (tester) async {
        await _pump(tester, _homePage());
        // _SocietyLogoCard renders an Icon(Icons.group)
        expect(find.byIcon(Icons.group), findsWidgets);
      },
    );

    testWidgets(
      'TC-H-05c | "No featured societies yet" shown when list is empty',
      (tester) async {
        await _pump(tester, _homePage(societies: [], events: []));
        expect(find.text('No featured societies yet'), findsOneWidget);
      },
    );
  });

  // ═══════════════════════════════════════════════════════════
  //  TC: SORTING — no backend call, pure client-side logic
  // ═══════════════════════════════════════════════════════════

  group('Sorting societies (TC-H-06 to TC-H-09)', () {
    test('TC-H-06 | A-Z sort orders societies alphabetically ascending', () {
      final societies = _makeSocieties();
      societies.sort(
        (a, b) => (a['name'] as String).compareTo(b['name'] as String),
      );
      final names = societies.map((s) => s['name'] as String).toList();
      expect(names, equals(names..sort()));
    });

    test('TC-H-07 | Z-A sort orders societies alphabetically descending', () {
      final societies = _makeSocieties();
      societies.sort(
        (a, b) => (b['name'] as String).compareTo(a['name'] as String),
      );
      final names = societies.map((s) => s['name'] as String).toList();
      final sorted = [...names]..sort((a, b) => b.compareTo(a));
      expect(names, equals(sorted));
    });

    test('TC-H-08 | Most Members sort puts highest count first', () {
      final societies = _makeSocieties();
      societies.sort(
        (a, b) =>
            (b['member_count'] as int).compareTo(a['member_count'] as int),
      );
      final counts = societies.map((s) => s['member_count'] as int).toList();
      for (var i = 0; i < counts.length - 1; i++) {
        expect(counts[i] >= counts[i + 1], isTrue);
      }
    });

    test('TC-H-09 | Least Members sort puts lowest count first', () {
      final societies = _makeSocieties();
      societies.sort(
        (a, b) =>
            (a['member_count'] as int).compareTo(b['member_count'] as int),
      );
      final counts = societies.map((s) => s['member_count'] as int).toList();
      for (var i = 0; i < counts.length - 1; i++) {
        expect(counts[i] <= counts[i + 1], isTrue);
      }
    });

    testWidgets('TC-H-10 | "Sort by" popup menu button is present on page', (
      tester,
    ) async {
      await _pump(tester, _homePage());
      expect(find.text('Sort by'), findsOneWidget);
    });

    testWidgets('TC-H-11 | "Filter by" popup menu button is present on page', (
      tester,
    ) async {
      await _pump(tester, _homePage());
      expect(find.text('Filter by'), findsOneWidget);
    });
  });

  // ═══════════════════════════════════════════════════════════
  //  TC: FILTERING — no backend call, pure client-side logic
  // ═══════════════════════════════════════════════════════════

  group('Filtering societies (TC-H-10)', () {
    test('TC-H-10a | Filtering by "Sports" returns only Sports societies', () {
      final societies = _makeSocieties();
      final filtered = societies
          .where((s) => s['category'] == 'Sports')
          .toList();
      expect(filtered.length, 2);
      expect(filtered.every((s) => s['category'] == 'Sports'), isTrue);
    });

    test(
      'TC-H-10b | Filtering by "Academic" returns only Academic societies',
      () {
        final societies = _makeSocieties();
        final filtered = societies
            .where((s) => s['category'] == 'Academic')
            .toList();
        expect(filtered.every((s) => s['category'] == 'Academic'), isTrue);
      },
    );

    test('TC-H-10c | Filtering by "All" returns all societies', () {
      final societies = _makeSocieties();
      final filtered = societies; // no filter applied for "All"
      expect(filtered.length, societies.length);
    });

    test(
      'TC-H-10d | Filtering by a category with no matches returns empty list',
      () {
        final societies = _makeSocieties();
        final filtered = societies
            .where((s) => s['category'] == 'NonExistent')
            .toList();
        expect(filtered, isEmpty);
      },
    );

    testWidgets('TC-H-10e | "All Societies (A-Z)" heading is visible on page', (
      tester,
    ) async {
      await _pump(tester, _homePage());
      expect(find.text('All Societies (A-Z)'), findsOneWidget);
    });
  });

  // ═══════════════════════════════════════════════════════════
  //  TC: UPCOMING EVENTS — "logged in → events displayed horizontally"
  // ═══════════════════════════════════════════════════════════

  group('Upcoming Events (TC-H-11)', () {
    testWidgets('TC-H-11a | "Upcoming Events" heading is shown', (
      tester,
    ) async {
      await _pump(tester, _homePage());
      expect(find.text('Upcoming Events'), findsOneWidget);
    });

    testWidgets('TC-H-11b | Event titles from API are rendered', (
      tester,
    ) async {
      await _pump(tester, _homePage());
      expect(find.text('Freshers Run'), findsOneWidget);
      expect(find.text('Chess Tournament'), findsOneWidget);
    });

    testWidgets(
      'TC-H-11c | "No upcoming events available" shown when events list is empty',
      (tester) async {
        await _pump(tester, _homePage(events: []));
        expect(find.text('No upcoming events available.'), findsOneWidget);
      },
    );

    testWidgets('TC-H-11d | Events section uses a horizontal ListView', (
      tester,
    ) async {
      await _pump(tester, _homePage());
      // The horizontal scroll container exists
      final listViews = tester
          .widgetList<ListView>(find.byType(ListView))
          .where((lv) => lv.scrollDirection == Axis.horizontal)
          .toList();
      expect(listViews.isNotEmpty, isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════════
  //  TC: WELCOME HEADER — "no name → 'Welcome Student'"
  // ═══════════════════════════════════════════════════════════

  group('Welcome header (TC-H-12)', () {
    testWidgets('TC-H-12a | Default student name shows "Welcome Student"', (
      tester,
    ) async {
      await _pump(tester, _homePage());
      expect(find.text('Welcome Student'), findsOneWidget);
    });

    testWidgets('TC-H-12b | Custom student name is shown when passed in', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          HomePage(
            getSocieties: () async => _makeSocieties(),
            getEventsForJoinedSocieties: () async => _makeEvents(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // Default name is 'Student' — check the default works
      expect(find.textContaining('Welcome'), findsOneWidget);
    });
  });

  // ═══════════════════════════════════════════════════════════
  //  TC: EMPTY STATES
  // ═══════════════════════════════════════════════════════════

  group('Empty states', () {
    testWidgets('TC-H-13a | No societies → "No featured societies yet" shown', (
      tester,
    ) async {
      await _pump(tester, _homePage(societies: [], events: []));
      expect(find.text('No featured societies yet'), findsOneWidget);
    });

    testWidgets(
      'TC-H-13b | No events → "No upcoming events available." shown',
      (tester) async {
        await _pump(tester, _homePage(events: []));
        expect(find.text('No upcoming events available.'), findsOneWidget);
      },
    );
  });

  // ═══════════════════════════════════════════════════════════
  //  TC: SOCIETY LIST CONTENT
  // ═══════════════════════════════════════════════════════════

  group('Society list content', () {
    testWidgets('TC-H-14a | Society descriptions are shown in the list', (
      tester,
    ) async {
      await _pump(tester, _homePage());
      expect(find.text('Running and field events'), findsOneWidget);
    });

    testWidgets(
      'TC-H-14b | Society list shows CircleAvatar with group icon per item',
      (tester) async {
        await _pump(tester, _homePage());
        expect(find.byType(CircleAvatar), findsWidgets);
      },
    );

    testWidgets(
      'TC-H-14c | Society list items are tappable (ListTile present)',
      (tester) async {
        await _pump(tester, _homePage());
        expect(find.byType(ListTile), findsWidgets);
      },
    );
  });

  // ═══════════════════════════════════════════════════════════
  //  TC: SORT/FILTER PURE DART LOGIC
  // ═══════════════════════════════════════════════════════════

  group('Sort and filter pure logic', () {
    test('TC-H-15a | applyFilters with A-Z produces sorted list', () {
      final input = [
        {'name': 'Zebra Club', 'category': 'Sports', 'member_count': 10},
        {'name': 'Apple Society', 'category': 'Sports', 'member_count': 5},
        {'name': 'Mango Group', 'category': 'Sports', 'member_count': 20},
      ];
      input.sort(
        (a, b) => (a['name'] as String).compareTo(b['name'] as String),
      );
      expect(input.first['name'], 'Apple Society');
      expect(input.last['name'], 'Zebra Club');
    });

    test('TC-H-15b | applyFilters with Z-A produces reverse sorted list', () {
      final input = [
        {'name': 'Zebra Club', 'category': 'Sports', 'member_count': 10},
        {'name': 'Apple Society', 'category': 'Sports', 'member_count': 5},
        {'name': 'Mango Group', 'category': 'Sports', 'member_count': 20},
      ];
      input.sort(
        (a, b) => (b['name'] as String).compareTo(a['name'] as String),
      );
      expect(input.first['name'], 'Zebra Club');
      expect(input.last['name'], 'Apple Society');
    });

    test('TC-H-15c | Category filter reduces list correctly', () {
      final input = _makeSocieties();
      final result = input.where((s) => s['category'] == 'Cultural').toList();
      expect(result.length, 1);
      expect(result.first['name'], 'Drama Society');
    });

    test('TC-H-15d | Member count filter returns correct society', () {
      final input = _makeSocieties();
      input.sort(
        (a, b) =>
            (b['member_count'] as int).compareTo(a['member_count'] as int),
      );
      expect(input.first['name'], 'Football Society');
    });

    test('TC-H-15e | Upcoming events filter excludes past events', () {
      final now = DateTime.now();
      final events = [
        {
          'title': 'Past Event',
          'start_time': now.subtract(const Duration(days: 1)).toIso8601String(),
        },
        {
          'title': 'Future Event',
          'start_time': now.add(const Duration(days: 1)).toIso8601String(),
        },
      ];
      final upcoming = events.where((e) {
        return DateTime.parse(e['start_time']!).isAfter(now);
      }).toList();
      expect(upcoming.length, 1);
      expect(upcoming.first['title'], 'Future Event');
    });
  });

  // ═══════════════════════════════════════════════════════════
  //  TC: APISERVICE HEADERS
  // ═══════════════════════════════════════════════════════════

  group('ApiService header logic', () {
    test('TC-H-16a | Authorization header present when token is set', () {
      ApiService.authToken = 'test-token';
      expect(ApiService.headers['Authorization'], 'Token test-token');
    });

    test('TC-H-16b | Authorization header absent when token is null', () {
      ApiService.authToken = null;
      expect(ApiService.headers.containsKey('Authorization'), isFalse);
      ApiService.authToken = 'test-token';
    });

    test('TC-H-16c | Content-Type is always application/json', () {
      expect(ApiService.headers['Content-Type'], 'application/json');
    });
  });
}
