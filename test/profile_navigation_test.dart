import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Profile does not route its removed Bookmark shortcut to Discover', () {
    final String source = File(
      'lib/modules/dashboard/profile/presentation/profile_screen.dart',
    ).readAsStringSync();

    expect(source, isNot(contains("arg: {'initialIndex': 2}")));
  });
}
