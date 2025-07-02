import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/models/category.dart';
import 'package:myapp/models/habit.dart'; // Import Habit model
import 'package:myapp/services/habit_service.dart'; // Import HabitService
import 'package:myapp/utils/logger.dart';
import 'package:uuid/uuid.dart';


class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = const Uuid();

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _userCategoriesCollection {
    if (_userId == null) {
      throw Exception("User not authenticated to access categories.");
    }
    // Custom categories will be stored under a user's specific collection
    // or a top-level collection filtered by userId.
    // Using a top-level collection for simplicity here, filtered by userId.
    return _firestore.collection('categories');
  }

  // Fetches custom categories for the current user and merges them with default categories.
  Future<List<Category>> getCategories() async {
    List<Category> defaultCategories = Category.defaultCategories;
    if (_userId == null) {
      Logger.info("[CategoryService] No user logged in, returning only default categories.");
      return defaultCategories;
    }

    try {
      final querySnapshot = await _userCategoriesCollection
          .where('userId', isEqualTo: _userId)
          .orderBy('createdAt', descending: false)
          .get();

      List<Category> customCategories = querySnapshot.docs
          .map((doc) => Category.fromMap(doc.data()))
          .toList();

      // Combine and ensure custom categories override defaults if names match
      Map<String, Category> combinedCategoriesMap = {};
      for (var cat in defaultCategories) {
        combinedCategoriesMap[cat.name.toLowerCase()] = cat;
      }
      for (var cat in customCategories) {
        combinedCategoriesMap[cat.name.toLowerCase()] = cat; // Custom overrides default
      }

      List<Category> allCategories = combinedCategoriesMap.values.toList();
      allCategories.sort((a, b) {
        if (a.isDefault && !b.isDefault) return -1;
        if (!a.isDefault && b.isDefault) return 1;
        return a.name.compareTo(b.name);
      });

      Logger.info("[CategoryService] Fetched ${customCategories.length} custom categories for user $_userId.");
      return allCategories;
    } catch (e, stackTrace) {
      Logger.error('Error fetching categories: $e', e, stackTrace);
      return defaultCategories; // Fallback to defaults on error
    }
  }

  Future<Category> addCategory({
    required String name,
    required IconData icon,
    required Color color,
  }) async {
    if (_userId == null) {
      throw Exception("User not authenticated. Cannot add category.");
    }

    // Check if a category with the same name already exists for this user or as a default
    final existingCategories = await getCategories();
    if (existingCategories.any((cat) => cat.name.toLowerCase() == name.toLowerCase())) {
        throw Exception("Uma categoria com o nome '$name' já existe.");
    }

    final newCategory = Category(
      id: _uuid.v4(),
      name: name,
      icon: icon,
      color: color,
      isDefault: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      userId: _userId,
    );

    try {
      await _userCategoriesCollection.doc(newCategory.id).set(newCategory.toMap());
      Logger.info('Custom category added: ${newCategory.name} by user $_userId');
      return newCategory;
    } catch (e, stackTrace) {
      Logger.error('Error adding category: $e', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateCategory(Category category) async {
    if (_userId == null) {
      throw Exception("User not authenticated. Cannot update category.");
    }
    if (category.isDefault) {
      throw ArgumentError("Default categories cannot be modified.");
    }
    if (category.userId != _userId) {
      throw Exception("User not authorized to update this category.");
    }

    // Check if another category (excluding the current one) already has the new name
    final existingCategories = await getCategories();
    if (existingCategories.any((cat) => cat.id != category.id && cat.name.toLowerCase() == category.name.toLowerCase())) {
        throw Exception("Outra categoria já existe com o nome '${category.name}'.");
    }

    final updatedCategory = category.copyWith(updatedAt: DateTime.now());

    try {
      await _userCategoriesCollection.doc(updatedCategory.id).update(updatedCategory.toMap());
      Logger.info('Category updated: ${updatedCategory.name} by user $_userId');
    } catch (e, stackTrace) {
      Logger.error('Error updating category: $e', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteCategory(String categoryId, {HabitService? habitService}) async {
    if (_userId == null) {
      throw Exception("User not authenticated. Cannot delete category.");
    }

    final categoryDoc = await _userCategoriesCollection.doc(categoryId).get();
    if (!categoryDoc.exists) {
      Logger.warning("Attempted to delete non-existent or non-custom category: $categoryId");
      // Check if it's a default category by ID (name check is better for user-facing messages)
      bool isDefaultById = Category.defaultCategories.any((cat) => cat.id == categoryId);
      if(isDefaultById) {
         throw ArgumentError("Categorias padrão não podem ser excluídas.");
      }
      // If not default and not found, it might have been already deleted or an invalid ID.
      return;
    }

    final categoryToDelete = Category.fromMap(categoryDoc.data()!);
    if (categoryToDelete.isDefault) {
      throw ArgumentError("Categorias padrão não podem ser excluídas.");
    }
    if (categoryToDelete.userId != _userId) {
      throw Exception("User not authorized to delete this category.");
    }

    try {
      // Reassign habits using this category to "Outros"
      // This requires HabitService to be available.
      if (habitService != null) {
        final habitsToUpdate = await habitService.getHabitsByCategory(categoryId);
        final defaultOtherCategory = Category.defaultCategories.firstWhere(
            (cat) => cat.name.toLowerCase() == "outros",
            orElse: () => throw Exception("Default category 'Outros' not found.")
        );

        WriteBatch batch = _firestore.batch();
        for (Habit habit in habitsToUpdate) {
          final habitRef = _firestore.collection('users').doc(_userId).collection('habits').doc(habit.id);
          batch.update(habitRef, {'category': defaultOtherCategory.name}); // Use name for consistency
        }
        await batch.commit();
        Logger.info("Reassigned ${habitsToUpdate.length} habits from category '$categoryId' to '${defaultOtherCategory.name}'.");
      } else {
        Logger.warning("HabitService not provided to deleteCategory. Habits will not be reassigned.");
      }

      await _userCategoriesCollection.doc(categoryId).delete();
      Logger.info('Category deleted: $categoryId by user $_userId');
    } catch (e, stackTrace) {
      Logger.error('Error deleting category $categoryId: $e', e, stackTrace);
      rethrow;
    }
  }

  Future<Category?> getCategoryById(String categoryId) async {
    // Check default categories first by ID
    final defaultCategory = Category.defaultCategories.firstWhere(
        (cat) => cat.id == categoryId,
        orElse: () => Category(id: '', name: '', icon: Icons.error, color: Colors.transparent, isDefault: false, createdAt: DateTime.now(), updatedAt: DateTime.now()) // Temporary invalid Category
    );

    if (defaultCategory.id.isNotEmpty && defaultCategory.name.isNotEmpty) { // Found a valid default category
        return defaultCategory;
    }

    // If not a default category, try fetching from user's custom categories
    if (_userId == null) {
        Logger.warning("[CategoryService] No user logged in, cannot fetch custom category by ID unless it's a default one.");
        return null;
    }

    try {
      final docSnapshot = await _userCategoriesCollection.doc(categoryId).get();
      if (docSnapshot.exists) {
        final category = Category.fromMap(docSnapshot.data()!);
        // Ensure the fetched custom category belongs to the current user
        if (category.userId == _userId) {
          return category;
        } else {
          Logger.warning("Attempt to access category $categoryId not belonging to user $_userId");
          return null;
        }
      }
      Logger.info("Category with ID $categoryId not found in custom or default categories.");
      return null;
    } catch (e, stackTrace) {
      Logger.error('Error fetching category by ID $categoryId: $e', e, stackTrace);
      return null;
    }
  }

  Future<Category?> getCategoryByName(String name) async {
    // First, check custom categories for the current user
    if (_userId != null) {
      try {
        final querySnapshot = await _userCategoriesCollection
            .where('userId', isEqualTo: _userId)
            .where('name', isEqualTo: name) // Firestore is case-sensitive, consider storing names lowercase for case-insensitive search
            .limit(1)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          return Category.fromMap(querySnapshot.docs.first.data());
        }
      } catch (e, stackTrace) {
        Logger.error('Error fetching custom category by name $name for user $_userId: $e', e, stackTrace);
        // Continue to check default categories
      }
    }

    // If not found in custom or no user, check default categories (case-insensitive)
    try {
      final defaultCategory = Category.defaultCategories.firstWhere(
        (cat) => cat.name.toLowerCase() == name.toLowerCase(),
      );
      return defaultCategory;
    } catch (e) {
      // This catch block will be hit if firstWhere doesn't find an element
      Logger.info("Category with name '$name' not found in default categories either.");
      return null;
    }
  }

  // This method might not be strictly necessary if default categories are always available statically
  // and custom categories are fetched per user.
  // Keeping it commented out as its utility depends on specific app initialization logic.
  /*
  Future<void> initializeDefaultCategoriesForUser() async {
    if (_userId == null) return;

    // This logic assumes default categories are NOT stored per user in Firestore,
    // but are mixed in at runtime. If they were to be copied, this would be different.
    Logger.info("[CategoryService] Default categories are handled globally, no per-user initialization needed in Firestore.");
  }
  */
}
