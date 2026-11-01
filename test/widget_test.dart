import 'package:flutter_test/flutter_test.dart';

import 'package:koral/app/koral_app.dart';

void main() {
  testWidgets(
    'without database settings the app explains setup instead of faking data',
    (tester) async {
      await tester.pumpWidget(const KoralApp());

      expect(find.text('Koral needs its database settings'), findsOneWidget);
      expect(
        find.textContaining('--dart-define-from-file=env.json'),
        findsOneWidget,
      );
    },
  );
}
