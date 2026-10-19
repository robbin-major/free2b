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

  testWidgets('passes fit and alignment through without changing its bounds', (
    WidgetTester tester,
  ) async {
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
      imageUrl: 'https://example.com/small-event.jpg',
      width: 154,
      height: 88,
      fit: BoxFit.contain,
      alignment: Alignment.topCenter,
    ).build(buildContext) as SizedBox;
    final CachedNetworkImage image = imageBox.child! as CachedNetworkImage;

    expect(imageBox.width, 154);
    expect(imageBox.height, 88);
    expect(image.fit, BoxFit.contain);
    expect(image.alignment, Alignment.topCenter);
  });
}
