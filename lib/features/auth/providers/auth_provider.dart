import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/runtime/app_runtime.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  if (AppRuntime.isDemoMode) return Stream<User?>.value(null);
  return FirebaseAuth.instance.authStateChanges();
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).asData?.value;
});

final authRepositoryProvider = Provider((ref) => AuthRepository());

class AuthRepository {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  GoogleSignIn get _googleSignIn => GoogleSignIn();
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  void _requireFirebase() {
    if (AppRuntime.isDemoMode) {
      throw Exception('Firebase is not configured yet. Add real firebase_options.dart values.');
    }
  }

  // Email & Password Sign Up
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    _requireFirebase();
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await credential.user!.updateDisplayName(fullName);

    // Save user to Firestore
    await _firestore.collection('users').doc(credential.user!.uid).set({
      'uid': credential.user!.uid,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'photoUrl': '',
      'wishlist': [],
      'loyaltyPoints': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return credential;
  }

  // Email & Password Sign In
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _requireFirebase();
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Google Sign In
  Future<UserCredential> signInWithGoogle() async {
    _requireFirebase();
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google sign in cancelled');

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);

    // Create user doc if new
    final userDoc = await _firestore
        .collection('users')
        .doc(userCredential.user!.uid)
        .get();

    if (!userDoc.exists) {
      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'uid': userCredential.user!.uid,
        'fullName': userCredential.user!.displayName ?? '',
        'email': userCredential.user!.email ?? '',
        'phone': userCredential.user!.phoneNumber ?? '',
        'photoUrl': userCredential.user!.photoURL ?? '',
        'wishlist': [],
        'loyaltyPoints': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return userCredential;
  }

  // Forgot Password
  Future<void> sendPasswordResetEmail(String email) async {
    _requireFirebase();
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Sign Out
  Future<void> signOut() async {
    if (AppRuntime.isDemoMode) return;
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
