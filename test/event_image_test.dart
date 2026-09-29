import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_template/widget/event_image.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('bounds network image decoding to rendered logical size', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(400, 800),
            devicePixelRatio: 2,
          ),
          child: Scaffold(
            body: EventImage(
              imageUrl: 'https://example.com/event.jpg',
              width: 76,
              height: 50,
            ),
          ),
        ),
      ),
    );

    final CachedNetworkImage image =
        tester.widget<CachedNetworkImage>(find.byType(CachedNetworkImage));
    expect(image.memCacheWidth, 152);
    expect(image.memCacheHeight, 100);
  });
}
