import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service for handling user authentication.
class AuthService {
  /// Firebase Auth instance.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Firestore instance.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream of auth state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Gets the current user.
  User? get currentUser => _auth.currentUser;

  /// Gets the current user ID.
  String? get currentUserId => _auth.currentUser?.uid;

  /// Checks if the user is signed in.
  bool get isSignedIn => _auth.currentUser != null;

  /// Signs in with email and password.
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    }
  }

  /// Creates a new user with email and password.
  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    UserCredential? userCredential;
    
    try {
      print('Tentando criar usuário com email: $email');
      
      // Create the user in Firebase Auth
      userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      print('Usuário criado com sucesso no Firebase Auth. UID: ${userCredential.user?.uid}');

      // Update the user's display name
      if (userCredential.user != null) {
        try {
          await userCredential.user!.updateDisplayName(name);
          print('Nome de exibição do usuário atualizado: $name');
        } catch (displayNameError) {
          // Não falhe se não conseguir atualizar o nome de exibição
          print('Erro ao atualizar nome de exibição: $displayNameError');
        }

        // Create a user document in Firestore - continuará mesmo se falhar
        try {
          await _createUserDocument(userCredential.user!, name);
        } catch (firestoreError) {
          print('Erro no Firestore não impediu a criação da conta: $firestoreError');
        }
      }

      return userCredential;
    } catch (e) {
      print('Erro ao criar usuário: $e');
      
      // Se a autenticação foi criada mas ocorreu erro posteriormente, tente limpar
      if (userCredential?.user != null) {
        try {
          print('Tentando limpar usuário criado parcialmente: ${userCredential!.user!.uid}');
          await userCredential.user!.delete();
          print('Usuário criado parcialmente foi excluído após erro');
        } catch (cleanupError) {
          print('Erro ao limpar usuário: $cleanupError');
        }
      }
      
      rethrow;
    }
  }

  /// Creates a user document in Firestore.
  Future<void> _createUserDocument(User user, String name) async {
    try {
      print('Tentando criar documento do usuário no Firestore. UID: ${user.uid}');
      
      // Verifica se já existe um documento para este usuário
      final docRef = _firestore.collection('users').doc(user.uid);
      final docSnapshot = await docRef.get().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('Timeout ao verificar documento existente');
          throw TimeoutException('Firestore operation timed out');
        },
      );
      
      if (docSnapshot.exists) {
        print('Documento já existe, atualizando');
        await docRef.update({
          'name': name,
          'email': user.email,
          'lastUpdated': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        }).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            print('Timeout ao atualizar documento');
            throw TimeoutException('Firestore update operation timed out');
          },
        );
      } else {
        print('Criando novo documento');
        await docRef.set({
          'name': name,
          'email': user.email,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
          'isNewUser': true,
        }).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            print('Timeout ao criar documento');
            throw TimeoutException('Firestore set operation timed out');
          },
        );
      }
      
      print('Documento do usuário criado/atualizado com sucesso no Firestore');
    } catch (e) {
      // Não rethrow aqui para evitar falha na criação da conta se o Firestore falhar
      print('Erro ao criar documento do usuário: $e');
      // Logue detalhes específicos que podem ser úteis
      print('User UID: ${user.uid}, Name: $name, Email: ${user.email}');
      
      // Tentativa alternativa de criar um documento mínimo
      if (e.toString().contains('permission-denied') || e.toString().contains('PERMISSION_DENIED')) {
        print('Tentando método alternativo devido a erro de permissão');
        try {
          // Tente uma operação mais simples
          await _firestore.collection('users').doc(user.uid).set({
            'email': user.email,
          }, SetOptions(merge: true));
          print('Documento mínimo criado com sucesso');
        } catch (fallbackError) {
          print('Método alternativo também falhou: $fallbackError');
        }
      }
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  /// Sends a password reset email.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error sending password reset email: $e');
      rethrow;
    }
  }

  /// Updates the user's profile.
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        await user.updatePhotoURL(photoURL);

        // Update the user document in Firestore
        if (displayName != null) {
          await _firestore.collection('users').doc(user.uid).update({
            'name': displayName,
          });
        }
      }
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  /// Updates the user's email.
  Future<void> updateEmail(String email) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateEmail(email);

        // Update the user document in Firestore
        await _firestore.collection('users').doc(user.uid).update({
          'email': email,
        });
      }
    } catch (e) {
      print('Error updating email: $e');
      rethrow;
    }
  }

  /// Updates the user's password.
  Future<void> updatePassword(String password) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(password);
      }
    } catch (e) {
      print('Error updating password: $e');
      rethrow;
    }
  }

  /// Deletes the user's account.
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Delete the user document from Firestore
        await _firestore.collection('users').doc(user.uid).delete();

        // Delete the user from Firebase Auth
        await user.delete();
      }
    } catch (e) {
      print('Error deleting account: $e');
      rethrow;
    }
  }

  /// Gets the user's profile data.
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  /// Updates the user's last login timestamp.
  Future<void> updateLastLogin() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error updating last login: $e');
    }
  }
}
