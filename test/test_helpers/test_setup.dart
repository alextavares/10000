import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import '../mock_firebase_options.dart';

Future<void> setupTestEnvironment() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Criar arquivo .env temporário para testes
  dotenv.testLoad(fileInput: '''
GOOGLE_API_KEY=test_api_key
OPENAI_API_KEY=test_openai_key
''');
}

// Mock do Firebase para testes
Future<void> initializeFirebaseForTests() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: MockFirebaseOptions.currentPlatform,
  );
}

// Helper para criar um MockFirebaseAuth
MockFirebaseAuth createMockFirebaseAuth() {
  return MockFirebaseAuth(
    mockUser: MockUser(
      isAnonymous: false,
      uid: 'test-uid',
      email: 'test@example.com',
      displayName: 'Test User',
    ),
  );
}

// Helper para criar um FakeFirebaseFirestore
FakeFirebaseFirestore createFakeFirestore() {
  return FakeFirebaseFirestore();
}
