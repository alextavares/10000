// Mocks generated by Mockito 5.4.6 from annotations
// in myapp/test/screens/habits/habits_screen_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i5;
import 'dart:typed_data' as _i13;
import 'dart:ui' as _i9;

import 'package:cloud_firestore/cloud_firestore.dart' as _i4;
import 'package:firebase_auth/firebase_auth.dart' as _i2;
import 'package:firebase_core/firebase_core.dart' as _i3;
import 'package:flutter/material.dart' as _i8;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i12;
import 'package:myapp/models/habit.dart' as _i7;
import 'package:myapp/services/ai_service.dart' as _i11;
import 'package:myapp/services/auth_service.dart' as _i10;
import 'package:myapp/services/habit_service.dart' as _i6;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: must_be_immutable
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeUserCredential_0 extends _i1.SmartFake
    implements _i2.UserCredential {
  _FakeUserCredential_0(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeUserMetadata_1 extends _i1.SmartFake implements _i2.UserMetadata {
  _FakeUserMetadata_1(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeMultiFactor_2 extends _i1.SmartFake implements _i2.MultiFactor {
  _FakeMultiFactor_2(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeIdTokenResult_3 extends _i1.SmartFake implements _i2.IdTokenResult {
  _FakeIdTokenResult_3(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeConfirmationResult_4 extends _i1.SmartFake
    implements _i2.ConfirmationResult {
  _FakeConfirmationResult_4(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeUser_5 extends _i1.SmartFake implements _i2.User {
  _FakeUser_5(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeFirebaseApp_6 extends _i1.SmartFake implements _i3.FirebaseApp {
  _FakeFirebaseApp_6(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeSettings_7 extends _i1.SmartFake implements _i4.Settings {
  _FakeSettings_7(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeCollectionReference_8<T extends Object?> extends _i1.SmartFake
    implements _i4.CollectionReference<T> {
  _FakeCollectionReference_8(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeWriteBatch_9 extends _i1.SmartFake implements _i4.WriteBatch {
  _FakeWriteBatch_9(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeLoadBundleTask_10 extends _i1.SmartFake
    implements _i4.LoadBundleTask {
  _FakeLoadBundleTask_10(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeQuerySnapshot_11<T1 extends Object?> extends _i1.SmartFake
    implements _i4.QuerySnapshot<T1> {
  _FakeQuerySnapshot_11(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeQuery_12<T extends Object?> extends _i1.SmartFake
    implements _i4.Query<T> {
  _FakeQuery_12(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeDocumentReference_13<T extends Object?> extends _i1.SmartFake
    implements _i4.DocumentReference<T> {
  _FakeDocumentReference_13(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeFuture_14<T1> extends _i1.SmartFake implements _i5.Future<T1> {
  _FakeFuture_14(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

/// A class which mocks [HabitService].
///
/// See the documentation for Mockito's code generation for more information.
class MockHabitService extends _i1.Mock implements _i6.HabitService {
  MockHabitService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  bool get hasListeners =>
      (super.noSuchMethod(Invocation.getter(#hasListeners), returnValue: false)
          as bool);

  @override
  _i5.Future<List<_i7.Habit>> getHabits() =>
      (super.noSuchMethod(
            Invocation.method(#getHabits, []),
            returnValue: _i5.Future<List<_i7.Habit>>.value(<_i7.Habit>[]),
          )
          as _i5.Future<List<_i7.Habit>>);

  @override
  _i5.Future<void> addHabit({
    required String? title,
    required String? categoryName,
    required _i8.IconData? categoryIcon,
    required _i9.Color? categoryColor,
    required _i7.HabitFrequency? frequency,
    required _i7.HabitTrackingType? trackingType,
    required DateTime? startDate,
    List<int>? daysOfWeek,
    List<int>? daysOfMonth,
    List<DateTime>? specificYearDates,
    int? timesPerPeriod,
    String? periodType,
    int? repeatEveryDays,
    bool? isFlexible,
    bool? alternateDays,
    DateTime? targetDate,
    _i8.TimeOfDay? reminderTime,
    bool? notificationsEnabled = false,
    String? priority = 'Normal',
    String? description,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#addHabit, [], {
              #title: title,
              #categoryName: categoryName,
              #categoryIcon: categoryIcon,
              #categoryColor: categoryColor,
              #frequency: frequency,
              #trackingType: trackingType,
              #startDate: startDate,
              #daysOfWeek: daysOfWeek,
              #daysOfMonth: daysOfMonth,
              #specificYearDates: specificYearDates,
              #timesPerPeriod: timesPerPeriod,
              #periodType: periodType,
              #repeatEveryDays: repeatEveryDays,
              #isFlexible: isFlexible,
              #alternateDays: alternateDays,
              #targetDate: targetDate,
              #reminderTime: reminderTime,
              #notificationsEnabled: notificationsEnabled,
              #priority: priority,
              #description: description,
            }),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<_i7.Habit?> getHabitById(String? id) =>
      (super.noSuchMethod(
            Invocation.method(#getHabitById, [id]),
            returnValue: _i5.Future<_i7.Habit?>.value(),
          )
          as _i5.Future<_i7.Habit?>);

  @override
  _i5.Future<void> updateHabit(_i7.Habit? habitToUpdate) =>
      (super.noSuchMethod(
            Invocation.method(#updateHabit, [habitToUpdate]),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<void> deleteHabit(String? id) =>
      (super.noSuchMethod(
            Invocation.method(#deleteHabit, [id]),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<void> markHabitCompletion(
    String? habitId,
    DateTime? date,
    bool? completed,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#markHabitCompletion, [habitId, date, completed]),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  void addListener(_i9.VoidCallback? listener) => super.noSuchMethod(
    Invocation.method(#addListener, [listener]),
    returnValueForMissingStub: null,
  );

  @override
  void removeListener(_i9.VoidCallback? listener) => super.noSuchMethod(
    Invocation.method(#removeListener, [listener]),
    returnValueForMissingStub: null,
  );

  @override
  void dispose() => super.noSuchMethod(
    Invocation.method(#dispose, []),
    returnValueForMissingStub: null,
  );

  @override
  void notifyListeners() => super.noSuchMethod(
    Invocation.method(#notifyListeners, []),
    returnValueForMissingStub: null,
  );
}

/// A class which mocks [AuthService].
///
/// See the documentation for Mockito's code generation for more information.
class MockAuthService extends _i1.Mock implements _i10.AuthService {
  MockAuthService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.Stream<_i2.User?> get authStateChanges =>
      (super.noSuchMethod(
            Invocation.getter(#authStateChanges),
            returnValue: _i5.Stream<_i2.User?>.empty(),
          )
          as _i5.Stream<_i2.User?>);

  @override
  bool get isSignedIn =>
      (super.noSuchMethod(Invocation.getter(#isSignedIn), returnValue: false)
          as bool);

  @override
  _i5.Future<_i2.UserCredential> signInWithEmailAndPassword(
    String? email,
    String? password,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#signInWithEmailAndPassword, [email, password]),
            returnValue: _i5.Future<_i2.UserCredential>.value(
              _FakeUserCredential_0(
                this,
                Invocation.method(#signInWithEmailAndPassword, [
                  email,
                  password,
                ]),
              ),
            ),
          )
          as _i5.Future<_i2.UserCredential>);

  @override
  _i5.Future<_i2.UserCredential> createUserWithEmailAndPassword(
    String? email,
    String? password,
    String? name,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#createUserWithEmailAndPassword, [
              email,
              password,
              name,
            ]),
            returnValue: _i5.Future<_i2.UserCredential>.value(
              _FakeUserCredential_0(
                this,
                Invocation.method(#createUserWithEmailAndPassword, [
                  email,
                  password,
                  name,
                ]),
              ),
            ),
          )
          as _i5.Future<_i2.UserCredential>);

  @override
  _i5.Future<void> signOut() =>
      (super.noSuchMethod(
            Invocation.method(#signOut, []),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<void> sendPasswordResetEmail(String? email) =>
      (super.noSuchMethod(
            Invocation.method(#sendPasswordResetEmail, [email]),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<void> updateProfile({String? displayName, String? photoURL}) =>
      (super.noSuchMethod(
            Invocation.method(#updateProfile, [], {
              #displayName: displayName,
              #photoURL: photoURL,
            }),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<void> updateEmail(String? email) =>
      (super.noSuchMethod(
            Invocation.method(#updateEmail, [email]),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<void> updatePassword(String? password) =>
      (super.noSuchMethod(
            Invocation.method(#updatePassword, [password]),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<void> deleteAccount() =>
      (super.noSuchMethod(
            Invocation.method(#deleteAccount, []),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<Map<String, dynamic>?> getUserProfile() =>
      (super.noSuchMethod(
            Invocation.method(#getUserProfile, []),
            returnValue: _i5.Future<Map<String, dynamic>?>.value(),
          )
          as _i5.Future<Map<String, dynamic>?>);

  @override
  _i5.Future<void> updateLastLogin() =>
      (super.noSuchMethod(
            Invocation.method(#updateLastLogin, []),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);
}

/// A class which mocks [AIService].
///
/// See the documentation for Mockito's code generation for more information.
class MockAIService extends _i1.Mock implements _i11.AIService {
  MockAIService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  String get apiKey =>
      (super.noSuchMethod(
            Invocation.getter(#apiKey),
            returnValue: _i12.dummyValue<String>(
              this,
              Invocation.getter(#apiKey),
            ),
          )
          as String);

  @override
  String get model =>
      (super.noSuchMethod(
            Invocation.getter(#model),
            returnValue: _i12.dummyValue<String>(
              this,
              Invocation.getter(#model),
            ),
          )
          as String);

  @override
  _i5.Future<List<String>> generateHabitSuggestions(String? category) =>
      (super.noSuchMethod(
            Invocation.method(#generateHabitSuggestions, [category]),
            returnValue: _i5.Future<List<String>>.value(<String>[]),
          )
          as _i5.Future<List<String>>);

  @override
  _i5.Future<String> generateHabitInsights(List<_i7.Habit>? habits) =>
      (super.noSuchMethod(
            Invocation.method(#generateHabitInsights, [habits]),
            returnValue: _i5.Future<String>.value(
              _i12.dummyValue<String>(
                this,
                Invocation.method(#generateHabitInsights, [habits]),
              ),
            ),
          )
          as _i5.Future<String>);

  @override
  _i5.Future<String> generateHabitPlan(
    String? goal,
    List<String>? preferences,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#generateHabitPlan, [goal, preferences]),
            returnValue: _i5.Future<String>.value(
              _i12.dummyValue<String>(
                this,
                Invocation.method(#generateHabitPlan, [goal, preferences]),
              ),
            ),
          )
          as _i5.Future<String>);

  @override
  _i5.Future<String> generateWeeklySummary(
    List<_i7.Habit>? habits,
    DateTime? weekStart,
    DateTime? weekEnd,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#generateWeeklySummary, [
              habits,
              weekStart,
              weekEnd,
            ]),
            returnValue: _i5.Future<String>.value(
              _i12.dummyValue<String>(
                this,
                Invocation.method(#generateWeeklySummary, [
                  habits,
                  weekStart,
                  weekEnd,
                ]),
              ),
            ),
          )
          as _i5.Future<String>);
}

/// A class which mocks [User].
///
/// See the documentation for Mockito's code generation for more information.
class MockUser extends _i1.Mock implements _i2.User {
  MockUser() {
    _i1.throwOnMissingStub(this);
  }

  @override
  bool get emailVerified =>
      (super.noSuchMethod(Invocation.getter(#emailVerified), returnValue: false)
          as bool);

  @override
  bool get isAnonymous =>
      (super.noSuchMethod(Invocation.getter(#isAnonymous), returnValue: false)
          as bool);

  @override
  _i2.UserMetadata get metadata =>
      (super.noSuchMethod(
            Invocation.getter(#metadata),
            returnValue: _FakeUserMetadata_1(
              this,
              Invocation.getter(#metadata),
            ),
          )
          as _i2.UserMetadata);

  @override
  List<_i2.UserInfo> get providerData =>
      (super.noSuchMethod(
            Invocation.getter(#providerData),
            returnValue: <_i2.UserInfo>[],
          )
          as List<_i2.UserInfo>);

  @override
  String get uid =>
      (super.noSuchMethod(
            Invocation.getter(#uid),
            returnValue: _i12.dummyValue<String>(this, Invocation.getter(#uid)),
          )
          as String);

  @override
  _i2.MultiFactor get multiFactor =>
      (super.noSuchMethod(
            Invocation.getter(#multiFactor),
            returnValue: _FakeMultiFactor_2(
              this,
              Invocation.getter(#multiFactor),
            ),
          )
          as _i2.MultiFactor);

  @override
  _i5.Future<void> delete() =>
      (super.noSuchMethod(
            Invocation.method(#delete, []),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<String?> getIdToken([bool? forceRefresh = false]) =>
      (super.noSuchMethod(
            Invocation.method(#getIdToken, [forceRefresh]),
            returnValue: _i5.Future<String?>.value(),
          )
          as _i5.Future<String?>);

  @override
  _i5.Future<_i2.IdTokenResult> getIdTokenResult([
    bool? forceRefresh = false,
  ]) =>
      (super.noSuchMethod(
            Invocation.method(#getIdTokenResult, [forceRefresh]),
            returnValue: _i5.Future<_i2.IdTokenResult>.value(
              _FakeIdTokenResult_3(
                this,
                Invocation.method(#getIdTokenResult, [forceRefresh]),
              ),
            ),
          )
          as _i5.Future<_i2.IdTokenResult>);

  @override
  _i5.Future<_i2.UserCredential> linkWithCredential(
    _i2.AuthCredential? credential,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#linkWithCredential, [credential]),
            returnValue: _i5.Future<_i2.UserCredential>.value(
              _FakeUserCredential_0(
                this,
                Invocation.method(#linkWithCredential, [credential]),
              ),
            ),
          )
          as _i5.Future<_i2.UserCredential>);

  @override
  _i5.Future<_i2.UserCredential> linkWithProvider(_i2.AuthProvider? provider) =>
      (super.noSuchMethod(
            Invocation.method(#linkWithProvider, [provider]),
            returnValue: _i5.Future<_i2.UserCredential>.value(
              _FakeUserCredential_0(
                this,
                Invocation.method(#linkWithProvider, [provider]),
              ),
            ),
          )
          as _i5.Future<_i2.UserCredential>);

  @override
  _i5.Future<_i2.UserCredential> reauthenticateWithProvider(
    _i2.AuthProvider? provider,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#reauthenticateWithProvider, [provider]),
            returnValue: _i5.Future<_i2.UserCredential>.value(
              _FakeUserCredential_0(
                this,
                Invocation.method(#reauthenticateWithProvider, [provider]),
              ),
            ),
          )
          as _i5.Future<_i2.UserCredential>);

  @override
  _i5.Future<_i2.UserCredential> reauthenticateWithPopup(
    _i2.AuthProvider? provider,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#reauthenticateWithPopup, [provider]),
            returnValue: _i5.Future<_i2.UserCredential>.value(
              _FakeUserCredential_0(
                this,
                Invocation.method(#reauthenticateWithPopup, [provider]),
              ),
            ),
          )
          as _i5.Future<_i2.UserCredential>);

  @override
  _i5.Future<void> reauthenticateWithRedirect(_i2.AuthProvider? provider) =>
      (super.noSuchMethod(
            Invocation.method(#reauthenticateWithRedirect, [provider]),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<_i2.UserCredential> linkWithPopup(_i2.AuthProvider? provider) =>
      (super.noSuchMethod(
            Invocation.method(#linkWithPopup, [provider]),
            returnValue: _i5.Future<_i2.UserCredential>.value(
              _FakeUserCredential_0(
                this,
                Invocation.method(#linkWithPopup, [provider]),
              ),
            ),
          )
          as _i5.Future<_i2.UserCredential>);

  @override
  _i5.Future<void> linkWithRedirect(_i2.AuthProvider? provider) =>
      (super.noSuchMethod(
            Invocation.method(#linkWithRedirect, [provider]),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<_i2.ConfirmationResult> linkWithPhoneNumber(
    String? phoneNumber, [
    _i2.RecaptchaVerifier? verifier,
  ]) =>
      (super.noSuchMethod(
            Invocation.method(#linkWithPhoneNumber, [phoneNumber, verifier]),
            returnValue: _i5.Future<_i2.ConfirmationResult>.value(
              _FakeConfirmationResult_4(
                this,
                Invocation.method(#linkWithPhoneNumber, [
                  phoneNumber,
                  verifier,
                ]),
              ),
            ),
          )
          as _i5.Future<_i2.ConfirmationResult>);

  @override
  _i5.Future<_i2.UserCredential> reauthenticateWithCredential(
    _i2.AuthCredential? credential,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#reauthenticateWithCredential, [credential]),
            returnValue: _i5.Future<_i2.UserCredential>.value(
              _FakeUserCredential_0(
                this,
                Invocation.method(#reauthenticateWithCredential, [credential]),
              ),
            ),
          )
          as _i5.Future<_i2.UserCredential>);

  @override
  _i5.Future<void> reload() =>
      (super.noSuchMethod(
            Invocation.method(#reload, []),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<void> sendEmailVerification([
    _i2.ActionCodeSettings? actionCodeSettings,
  ]) =>
      (super.noSuchMethod(
            Invocation.method(#sendEmailVerification, [actionCodeSettings]),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<_i2.User> unlink(String? providerId) =>
      (super.noSuchMethod(
            Invocation.method(#unlink, [providerId]),
            returnValue: _i5.Future<_i2.User>.value(
              _FakeUser_5(this, Invocation.method(#unlink, [providerId])),
            ),
          )
          as _i5.Future<_i2.User>);

  @override
  _i5.Future<void> updateEmail(String? newEmail) =>
      (super.noSuchMethod(
            Invocation.method(#updateEmail, [newEmail]),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<void> updatePassword(String? newPassword) =>
      (super.noSuchMethod(
            Invocation.method(#updatePassword, [newPassword]),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<void> updatePhoneNumber(
    _i2.PhoneAuthCredential? phoneCredential,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#updatePhoneNumber, [phoneCredential]),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<void> updateDisplayName(String? displayName) =>
      (super.noSuchMethod(
            Invocation.method(#updateDisplayName, [displayName]),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<void> updatePhotoURL(String? photoURL) =>
      (super.noSuchMethod(
            Invocation.method(#updatePhotoURL, [photoURL]),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<void> updateProfile({String? displayName, String? photoURL}) =>
      (super.noSuchMethod(
            Invocation.method(#updateProfile, [], {
              #displayName: displayName,
              #photoURL: photoURL,
            }),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<void> verifyBeforeUpdateEmail(
    String? newEmail, [
    _i2.ActionCodeSettings? actionCodeSettings,
  ]) =>
      (super.noSuchMethod(
            Invocation.method(#verifyBeforeUpdateEmail, [
              newEmail,
              actionCodeSettings,
            ]),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);
}

/// A class which mocks [FirebaseFirestore].
///
/// See the documentation for Mockito's code generation for more information.
class MockFirebaseFirestore extends _i1.Mock implements _i4.FirebaseFirestore {
  MockFirebaseFirestore() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.FirebaseApp get app =>
      (super.noSuchMethod(
            Invocation.getter(#app),
            returnValue: _FakeFirebaseApp_6(this, Invocation.getter(#app)),
          )
          as _i3.FirebaseApp);

  @override
  String get databaseURL =>
      (super.noSuchMethod(
            Invocation.getter(#databaseURL),
            returnValue: _i12.dummyValue<String>(
              this,
              Invocation.getter(#databaseURL),
            ),
          )
          as String);

  @override
  String get databaseId =>
      (super.noSuchMethod(
            Invocation.getter(#databaseId),
            returnValue: _i12.dummyValue<String>(
              this,
              Invocation.getter(#databaseId),
            ),
          )
          as String);

  @override
  _i4.Settings get settings =>
      (super.noSuchMethod(
            Invocation.getter(#settings),
            returnValue: _FakeSettings_7(this, Invocation.getter(#settings)),
          )
          as _i4.Settings);

  @override
  set app(_i3.FirebaseApp? _app) => super.noSuchMethod(
    Invocation.setter(#app, _app),
    returnValueForMissingStub: null,
  );

  @override
  set databaseURL(String? _databaseURL) => super.noSuchMethod(
    Invocation.setter(#databaseURL, _databaseURL),
    returnValueForMissingStub: null,
  );

  @override
  set databaseId(String? _databaseId) => super.noSuchMethod(
    Invocation.setter(#databaseId, _databaseId),
    returnValueForMissingStub: null,
  );

  @override
  set settings(_i4.Settings? settings) => super.noSuchMethod(
    Invocation.setter(#settings, settings),
    returnValueForMissingStub: null,
  );

  @override
  Map<dynamic, dynamic> get pluginConstants =>
      (super.noSuchMethod(
            Invocation.getter(#pluginConstants),
            returnValue: <dynamic, dynamic>{},
          )
          as Map<dynamic, dynamic>);

  @override
  _i4.CollectionReference<Map<String, dynamic>> collection(
    String? collectionPath,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#collection, [collectionPath]),
            returnValue: _FakeCollectionReference_8<Map<String, dynamic>>(
              this,
              Invocation.method(#collection, [collectionPath]),
            ),
          )
          as _i4.CollectionReference<Map<String, dynamic>>);

  @override
  _i4.WriteBatch batch() =>
      (super.noSuchMethod(
            Invocation.method(#batch, []),
            returnValue: _FakeWriteBatch_9(this, Invocation.method(#batch, [])),
          )
          as _i4.WriteBatch);

  @override
  _i5.Future<void> clearPersistence() =>
      (super.noSuchMethod(
            Invocation.method(#clearPersistence, []),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<void> enablePersistence([
    _i4.PersistenceSettings? persistenceSettings,
  ]) =>
      (super.noSuchMethod(
            Invocation.method(#enablePersistence, [persistenceSettings]),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i4.LoadBundleTask loadBundle(_i13.Uint8List? bundle) =>
      (super.noSuchMethod(
            Invocation.method(#loadBundle, [bundle]),
            returnValue: _FakeLoadBundleTask_10(
              this,
              Invocation.method(#loadBundle, [bundle]),
            ),
          )
          as _i4.LoadBundleTask);

  @override
  void useFirestoreEmulator(
    String? host,
    int? port, {
    bool? sslEnabled = false,
    bool? automaticHostMapping = true,
  }) => super.noSuchMethod(
    Invocation.method(
      #useFirestoreEmulator,
      [host, port],
      {#sslEnabled: sslEnabled, #automaticHostMapping: automaticHostMapping},
    ),
    returnValueForMissingStub: null,
  );

  @override
  _i5.Future<_i4.QuerySnapshot<T>> namedQueryWithConverterGet<T>(
    String? name, {
    _i4.GetOptions? options = const _i4.GetOptions(),
    required _i4.FromFirestore<T>? fromFirestore,
    required _i4.ToFirestore<T>? toFirestore,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #namedQueryWithConverterGet,
              [name],
              {
                #options: options,
                #fromFirestore: fromFirestore,
                #toFirestore: toFirestore,
              },
            ),
            returnValue: _i5.Future<_i4.QuerySnapshot<T>>.value(
              _FakeQuerySnapshot_11<T>(
                this,
                Invocation.method(
                  #namedQueryWithConverterGet,
                  [name],
                  {
                    #options: options,
                    #fromFirestore: fromFirestore,
                    #toFirestore: toFirestore,
                  },
                ),
              ),
            ),
          )
          as _i5.Future<_i4.QuerySnapshot<T>>);

  @override
  _i5.Future<_i4.QuerySnapshot<Map<String, dynamic>>> namedQueryGet(
    String? name, {
    _i4.GetOptions? options = const _i4.GetOptions(),
  }) =>
      (super.noSuchMethod(
            Invocation.method(#namedQueryGet, [name], {#options: options}),
            returnValue:
                _i5.Future<_i4.QuerySnapshot<Map<String, dynamic>>>.value(
                  _FakeQuerySnapshot_11<Map<String, dynamic>>(
                    this,
                    Invocation.method(
                      #namedQueryGet,
                      [name],
                      {#options: options},
                    ),
                  ),
                ),
          )
          as _i5.Future<_i4.QuerySnapshot<Map<String, dynamic>>>);

  @override
  _i4.Query<Map<String, dynamic>> collectionGroup(String? collectionPath) =>
      (super.noSuchMethod(
            Invocation.method(#collectionGroup, [collectionPath]),
            returnValue: _FakeQuery_12<Map<String, dynamic>>(
              this,
              Invocation.method(#collectionGroup, [collectionPath]),
            ),
          )
          as _i4.Query<Map<String, dynamic>>);

  @override
  _i5.Future<void> disableNetwork() =>
      (super.noSuchMethod(
            Invocation.method(#disableNetwork, []),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i4.DocumentReference<Map<String, dynamic>> doc(String? documentPath) =>
      (super.noSuchMethod(
            Invocation.method(#doc, [documentPath]),
            returnValue: _FakeDocumentReference_13<Map<String, dynamic>>(
              this,
              Invocation.method(#doc, [documentPath]),
            ),
          )
          as _i4.DocumentReference<Map<String, dynamic>>);

  @override
  _i5.Future<void> enableNetwork() =>
      (super.noSuchMethod(
            Invocation.method(#enableNetwork, []),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Stream<void> snapshotsInSync() =>
      (super.noSuchMethod(
            Invocation.method(#snapshotsInSync, []),
            returnValue: _i5.Stream<void>.empty(),
          )
          as _i5.Stream<void>);

  @override
  _i5.Future<T> runTransaction<T>(
    _i4.TransactionHandler<T>? transactionHandler, {
    Duration? timeout = const Duration(seconds: 30),
    int? maxAttempts = 5,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #runTransaction,
              [transactionHandler],
              {#timeout: timeout, #maxAttempts: maxAttempts},
            ),
            returnValue:
                _i12.ifNotNull(
                  _i12.dummyValueOrNull<T>(
                    this,
                    Invocation.method(
                      #runTransaction,
                      [transactionHandler],
                      {#timeout: timeout, #maxAttempts: maxAttempts},
                    ),
                  ),
                  (T v) => _i5.Future<T>.value(v),
                ) ??
                _FakeFuture_14<T>(
                  this,
                  Invocation.method(
                    #runTransaction,
                    [transactionHandler],
                    {#timeout: timeout, #maxAttempts: maxAttempts},
                  ),
                ),
          )
          as _i5.Future<T>);

  @override
  _i5.Future<void> terminate() =>
      (super.noSuchMethod(
            Invocation.method(#terminate, []),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<void> waitForPendingWrites() =>
      (super.noSuchMethod(
            Invocation.method(#waitForPendingWrites, []),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<void> setIndexConfiguration({
    required List<_i4.Index>? indexes,
    List<_i4.FieldOverrides>? fieldOverrides,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#setIndexConfiguration, [], {
              #indexes: indexes,
              #fieldOverrides: fieldOverrides,
            }),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<void> setIndexConfigurationFromJSON(String? json) =>
      (super.noSuchMethod(
            Invocation.method(#setIndexConfigurationFromJSON, [json]),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);
}
