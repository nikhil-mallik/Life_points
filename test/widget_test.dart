import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:game2d/main.dart';
import 'package:game2d/services/storage_service.dart';

// Create a mock StorageService
class MockStorageService extends Mock implements StorageService {
  @override
  Future<bool> isFirstLaunch() async => true;
  
  @override
  Future<void> init() async {}
}

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    // Create a mock storage service
    final mockStorageService = MockStorageService();
    
    // Build our app and trigger a frame with the mock service
    await tester.pumpWidget(MyApp(
      storageService: mockStorageService,
      isFirstLaunch: true,
    ));
    
    // Verify the app builds without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
