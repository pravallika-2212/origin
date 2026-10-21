import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:origin/main.dart';
import 'package:origin/features/landing/origin_cinematic_section.dart';
import 'package:origin/features/cart/order_success_page.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('OriginApp boots and mounts ProviderScope and MaterialApp.router', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: OriginApp(),
      ),
    );

    // Verify initial render
    expect(find.byType(OriginApp), findsOneWidget);
  });

  testWidgets('OriginCinematicSection renders and mounts with scrollController and collection cards', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final scrollController = ScrollController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            controller: scrollController,
            child: OriginCinematicSection(scrollController: scrollController),
          ),
        ),
      ),
    );

    await tester.pump();

    // Verify that the OriginCinematicSection is mounted
    expect(find.byType(OriginCinematicSection), findsOneWidget);

    // Verify the collection section heading is present
    expect(find.text("Explore the World's Royal Heritage"), findsOneWidget);

    // Verify key collection cards are rendered
    expect(find.text('Crowns & Tiaras'), findsOneWidget);
    expect(find.text('Royal Jewellery'), findsOneWidget);
    expect(find.text('Royal Fashion'), findsOneWidget);
    expect(find.text('Palace Décor'), findsOneWidget);
    expect(find.text('Antiques & Collectibles'), findsOneWidget);
    expect(find.text('Cultural Treasures'), findsOneWidget);
  });

  testWidgets('OrderSuccessPage renders confirmed acquisition with verified payment badge and details', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final testRouter = GoRouter(
      initialLocation: '/order-success/ORD-77492',
      routes: [
        GoRoute(
          path: '/order-success/:id',
          builder: (context, state) => OrderSuccessPage(
            orderId: state.pathParameters['id'] ?? 'ORD-77492',
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: testRouter,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify verified payment badge
    expect(find.text('PAYMENT VERIFIED & CONFIRMED'), findsOneWidget);
    expect(find.text('Welcome to the Custody of Royalty'), findsOneWidget);
    expect(find.text('ORD-77492'), findsOneWidget);
    expect(find.text('pay_MunichArchive884'), findsOneWidget);
  });
}
