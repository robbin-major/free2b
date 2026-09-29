import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_template/widget/event_image.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('bounds network image decoding to rendered logical size', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetDevicePixelRatio);

    late BuildContext buildContext;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (BuildContext context) {
            buildContext = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    final SizedBox imageBox = const EventImage(
      imageUrl: 'https://example.com/event.jpg',
      width: 76,
      height: 50,
    ).build(buildContext) as SizedBox;
    final CachedNetworkImage image = imageBox.child! as CachedNetworkImage;
    expect(image.memCacheWidth, 152);
    expect(image.memCacheHeight, 100);
  });
}
