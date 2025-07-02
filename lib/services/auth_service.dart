import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/utils/logger.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream para mudanças de autenticação
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Usuário atual
  User? get currentUser => _auth.currentUser;

  // Verifica se está logado
  bool get isSignedIn => currentUser != null;

  /// Signs in anonymously.
  /// This is useful for testing or allowing users to try the app without creating an account.
  Future<UserCredential> signInAnonymously() async {
    try {
      Logger.debug('Tentando fazer login anônimo...');
      final userCredential = await _auth.signInAnonymously();
      Logger.info('Login anônimo bem-sucedido. UID: ${userCredential.user?.uid}');
      
      // Criar um documento básico para o usuário anônimo
      if (userCredential.user != null) {
        try {
          await _firestore.collection('users').doc(userCredential.user!.uid).set({
            'isAnonymous': true,
            'createdAt': FieldValue.serverTimestamp(),
            'lastLogin': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          Logger.debug('Documento de usuário anônimo criado');
        } catch (e) {
          Logger.error('Erro ao criar documento de usuário anônimo: $e');
          // Não falhar se não conseguir criar o documento
        }
      }
      
      return userCredential;
    } catch (e) {
      Logger.error('Erro ao fazer login anônimo: $e');
      rethrow;
    }
  }

  /// Login com email e senha
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      Logger.debug('Tentando fazer login com email...');
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      Logger.info('Login com email bem-sucedido. UID: ${userCredential.user?.uid}');
      return userCredential;
    } catch (e) {
      Logger.error('Erro ao fazer login com email: $e');
      rethrow;
    }
  }

  /// Registro com email e senha
  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      Logger.debug('Tentando criar conta com email...');
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      Logger.info('Conta criada com sucesso. UID: ${userCredential.user?.uid}');
      return userCredential;
    } catch (e) {
      Logger.error('Erro ao criar conta com email: $e');
      rethrow;
    }
  }

  /// Login com Google - Simplificado para web
  Future<UserCredential?> signInWithGoogle() async {
    try {
      Logger.debug('Iniciando login com Google...');
      
      // Para web, usar o provider diretamente
      final googleProvider = GoogleAuthProvider();
      
      // Adicionar scopes se necessário
      googleProvider.addScope('email');
      googleProvider.addScope('profile');
      
      // Sign in with popup para web
      final userCredential = await _auth.signInWithPopup(googleProvider);
      
      Logger.info('Login com Google bem-sucedido. UID: ${userCredential.user?.uid}');
      return userCredential;
    } catch (e) {
      Logger.error('Erro ao fazer login com Google: $e');
      rethrow;
    }
  }

  /// Atualizar último login
  Future<void> updateLastLogin() async {
    try {
      if (currentUser != null) {
        await _firestore.collection('users').doc(currentUser!.uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
        Logger.debug('Último login atualizado');
      }
    } catch (e) {
      Logger.error('Erro ao atualizar último login: $e');
      // Não falhar se não conseguir atualizar
    }
  }

  /// Logout
  Future<void> signOut() async {
    try {
      Logger.debug('Fazendo logout...');
      await _auth.signOut();
      Logger.info('Logout realizado com sucesso');
    } catch (e) {
      Logger.error('Erro ao fazer logout: $e');
      rethrow;
    }
  }

  /// Redefinir senha
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      Logger.debug('Enviando email de redefinição de senha...');
      await _auth.sendPasswordResetEmail(email: email);
      Logger.info('Email de redefinição de senha enviado para: $email');
    } catch (e) {
      Logger.error('Erro ao enviar email de redefinição: $e');
      rethrow;
    }
  }
}
