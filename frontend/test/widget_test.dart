import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';

class _MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _MockHttpOverrides();
  });

  testWidgets('App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const EPharmacyApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
