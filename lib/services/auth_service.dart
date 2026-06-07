import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();
  static const String allowedDomain = '@souunit.com.br';
  static const String _googleWebClientId =
      '543136728839-4p7k04qqjob8lm8pk364mpmasd57mmql.apps.googleusercontent.com';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _googleInitialized = false;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  String get safeGreetingName {
    final email = currentUser?.email;
    if (!isInstitutionalEmail(email)) return 'Estudante';

    final localPart = email!.split('@').first.trim();
    final firstName = localPart.split('.').first;
    if (firstName.isEmpty) return 'Estudante';

    return firstName[0].toUpperCase() + firstName.substring(1).toLowerCase();
  }

  static bool isInstitutionalEmail(String? email) {
    return email?.trim().toLowerCase().endsWith(allowedDomain) ?? false;
  }

  bool get hasAllowedCurrentUser {
    return isInstitutionalEmail(currentUser?.email);
  }

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _validateInstitutionalEmail(email);

    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    return _ensureAllowedCredential(credential);
  }

  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _validateInstitutionalEmail(email);

    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    return _ensureAllowedCredential(credential);
  }

  Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider()
        ..setCustomParameters({'hd': 'souunit.com.br'});
      final credential = await _auth.signInWithPopup(provider);
      return _ensureAllowedCredential(credential);
    }

    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux) {
      throw const GoogleSignInUnsupportedPlatformException();
    }

    await _ensureGoogleInitialized();

    final googleUser = await _googleSignIn.authenticate();
    final googleAuth = googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    return _ensureAllowedCredential(userCredential);
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}

    await _auth.signOut();
  }

  Future<void> signOutIfDomainIsInvalid() async {
    final user = currentUser;
    if (user != null && !isInstitutionalEmail(user.email)) {
      await signOut();
      throw const AuthDomainException();
    }
  }

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;

    await _googleSignIn.initialize(serverClientId: _googleWebClientId);
    _googleInitialized = true;
  }

  Future<UserCredential> _ensureAllowedCredential(
    UserCredential credential,
  ) async {
    if (!isInstitutionalEmail(credential.user?.email)) {
      await signOut();
      throw const AuthDomainException();
    }

    return credential;
  }

  void _validateInstitutionalEmail(String email) {
    if (!isInstitutionalEmail(email)) {
      throw const AuthDomainException();
    }
  }
}

class GoogleSignInUnsupportedPlatformException implements Exception {
  const GoogleSignInUnsupportedPlatformException();

  @override
  String toString() {
    return 'Login com Google disponível no Android/iOS/macOS ou no navegador.';
  }
}

class AuthDomainException implements Exception {
  const AuthDomainException();

  @override
  String toString() {
    return 'Use uma conta institucional ${AuthService.allowedDomain}.';
  }
}
