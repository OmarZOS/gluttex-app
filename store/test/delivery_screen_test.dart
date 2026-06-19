import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';

import 'package:event/delivery_change_notifier.dart';
import 'package:gluttex_core/business/Delivery.dart';
import 'package:gluttex_core/business/services/DeliveryService.dart';
import 'package:locator/locator.dart';

class MockDeliveryService extends Mock implements DeliveryService {}

Delivery makeDelivery(
  int id, {
  String status = 'PENDING',
}) {
  return Delivery(
    id_delivery: id,
    delivery_status: status,
    delivery_package_count: 1,
    delivery_total_weight: 1,
    delivery_address_id: 1,
    recipient_person: 1,
  );
}

Widget makeTestable(Widget child, DeliveryChangeNotifier notifier) {
  return ChangeNotifierProvider<DeliveryChangeNotifier>.value(
    value: notifier,
    child: MaterialApp(home: child),
  );
}

void main() {
  late DeliveryChangeNotifier notifier;
  late MockDeliveryService service;

  setUp(() {
    service = MockDeliveryService();
    AppLocator.registerSingletonService<DeliveryService>(service);

    notifier = DeliveryChangeNotifier();
  });

  tearDown(() {
    notifier.dispose();
  });

  group('tab layout', () {
    testWidgets('renders delivery tabs', (tester) async {
      await tester.pumpWidget(
        makeTestable(const DeliveryTabbedView(), notifier),
      );

      expect(find.byType(TabBar), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Delivered'), findsOneWidget);
      expect(find.text('Cancelled'), findsOneWidget);
    });
  });

  group('data display', () {
    testWidgets('pending deliveries appear in pending tab', (tester) async {
      when(() => service.getAllDeliveries(0, 10)).thenAnswer(
        (_) async => [
          makeDelivery(1, status: 'PENDING'),
        ],
      );

      await tester.pumpWidget(
        makeTestable(const DeliveryTabbedView(), notifier),
      );

      await notifier.fetchFirstPage();
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('delivered deliveries appear after tab switch', (tester) async {
      when(() => service.getAllDeliveries(0, 10)).thenAnswer(
        (_) async => [
          makeDelivery(2, status: 'DELIVERED'),
        ],
      );

      await tester.pumpWidget(
        makeTestable(const DeliveryTabbedView(), notifier),
      );

      await notifier.fetchFirstPage();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delivered'));
      await tester.pumpAndSettle();

      expect(find.text('2'), findsOneWidget);
    });
  });

  group('loading state', () {
    testWidgets('shows loading indicator', (tester) async {
      when(() => service.getAllDeliveries(0, 10)).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 50));
        return [];
      });

      await tester.pumpWidget(
        makeTestable(const DeliveryTabbedView(), notifier),
      );

      notifier.fetchFirstPage();
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('reactivity', () {
    testWidgets('UI updates when notifier updates delivery', (tester) async {
      when(() => service.getAllDeliveries(0, 10)).thenAnswer(
        (_) async => [
          makeDelivery(1, status: 'PENDING'),
        ],
      );

      when(() => service.updateDelivery(any())).thenAnswer(
        (_) async => makeDelivery(1, status: 'DELIVERED'),
      );

      await tester.pumpWidget(
        makeTestable(const DeliveryTabbedView(), notifier),
      );

      await notifier.fetchFirstPage();
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);

      await notifier.updateDelivery(makeDelivery(1, status: 'DELIVERED'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delivered'));
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);
    });
  });

  group('empty state', () {
    testWidgets('shows empty message when no deliveries', (tester) async {
      when(() => service.getAllDeliveries(0, 10)).thenAnswer((_) async => []);

      await tester.pumpWidget(
        makeTestable(const DeliveryTabbedView(), notifier),
      );

      await notifier.fetchFirstPage();
      await tester.pumpAndSettle();

      expect(find.textContaining('No deliveries'), findsOneWidget);
    });
  });
}
