import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/category.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  // Collection reference
  CollectionReference<Map<String, dynamic>> get _categoriesCollection {
    if (_userId == null) throw Exception('User not authenticated');
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('categories');
  }

  // Create a new category
  Future<Category> createCategory({
    required String name,
    required int iconCodePoint,
    required int color,
  }) async {
    try {
      final docRef = _categoriesCollection.doc();
      final category = Category(
        id: docRef.id,
        name: name,
        icon: IconData(iconCodePoint, fontFamily: 'MaterialIcons'),
        color: Color(color),
        isDefault: false,
        taskIds: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await docRef.set(category.toMap());
      return category;
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  // Get all categories (custom + default)
  Stream<List<Category>> getAllCategories() {
    return _categoriesCollection.snapshots().map((snapshot) {
      final customCategories = snapshot.docs
          .map((doc) => Category.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
      
      // Combine custom categories with default ones
      return [...customCategories, ...Category.defaultCategories];
    });
  }

  // Get custom categories only
  Stream<List<Category>> getCustomCategories() {
    return _categoriesCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Category.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  // Update a category
  Future<void> updateCategory(Category category) async {
    if (category.isDefault) {
      throw Exception('Cannot update default categories');
    }

    try {
      await _categoriesCollection.doc(category.id).update({
        'name': category.name,
        'icon': category.icon.codePoint,
        'color': category.color.value,
        'taskIds': category.taskIds,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  // Delete a category
  Future<void> deleteCategory(String categoryId) async {
    try {
      // First, remove category from all tasks that use it
      final tasksSnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('tasks')
          .where('category', isEqualTo: categoryId)
          .get();

      final batch = _firestore.batch();

      // Update all tasks to remove the category
      for (final doc in tasksSnapshot.docs) {
        batch.update(doc.reference, {'category': null});
      }

      // Delete the category
      batch.delete(_categoriesCollection.doc(categoryId));

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  // Add task to category
  Future<void> addTaskToCategory(String categoryId, String taskId) async {
    try {
      await _categoriesCollection.doc(categoryId).update({
        'taskIds': FieldValue.arrayUnion([taskId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add task to category: $e');
    }
  }

  // Remove task from category
  Future<void> removeTaskFromCategory(String categoryId, String taskId) async {
    try {
      await _categoriesCollection.doc(categoryId).update({
        'taskIds': FieldValue.arrayRemove([taskId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to remove task from category: $e');
    }
  }

  // Get category by ID
  Future<Category?> getCategoryById(String categoryId) async {
    // Check if it's a default category
    final defaultCategory = Category.defaultCategories
        .firstWhere((cat) => cat.id == categoryId, orElse: () => Category(
          id: '',
          name: '',
          icon: Icons.dashboard_rounded,
          color: const Color(0xFFE91E63),
          isDefault: false,
          taskIds: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
    
    if (defaultCategory.id.isNotEmpty) {
      return defaultCategory;
    }

    // Otherwise, fetch from Firestore
    try {
      final doc = await _categoriesCollection.doc(categoryId).get();
      if (doc.exists) {
        return Category.fromMap({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get category: $e');
    }
  }

  // Initialize default categories for new users
  Future<void> initializeDefaultCategories() async {
    try {
      final snapshot = await _categoriesCollection.limit(1).get();
      
      // If user already has categories, don't initialize
      if (snapshot.docs.isNotEmpty) return;

      // Note: We don't store default categories in Firestore
      // They are always available from Category.defaultCategories
    } catch (e) {
      throw Exception('Failed to initialize categories: $e');
    }
  }
}
