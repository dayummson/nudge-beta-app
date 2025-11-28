import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:nudge_1/core/services/device_service.dart';

/// Exception thrown when device account restrictions are violated.
class DeviceAccountException implements Exception {
  final String message;

  DeviceAccountException(this.message);

  @override
  String toString() => 'DeviceAccountException: $message';
}

/// Result of a Google sign-in or link operation
class GoogleSignInResult {
  final User? user;
  final String? googlePhotoUrl;

  GoogleSignInResult(this.user, this.googlePhotoUrl);
}

/// AuthService encapsulates authentication logic for the app.
///
/// Responsibilities:
/// - Provide a method to sign in with Google: [signInWithGoogle()].
/// - Provide a method to sign out: [signOut()].
///
/// This keeps Firebase-specific logic in one place so the UI can remain
/// simple and testable. To add other providers (Apple, Email/Password),
/// add additional methods here and reuse them from the UI.
class AuthService {
  AuthService({
    GoogleSignIn? googleSignIn,
    FirebaseAuth? firebaseAuth,
    DeviceService? deviceService,
  }) : _googleSignIn =
           googleSignIn ?? GoogleSignIn(scopes: ['email', 'profile']),
       _auth = firebaseAuth ?? FirebaseAuth.instance,
       _deviceService = deviceService ?? DeviceService();

  final GoogleSignIn _googleSignIn;
  final FirebaseAuth _auth;
  final DeviceService _deviceService;

  /// Sign in anonymously. Returns the [UserCredential] on success.
  ///
  /// This creates a new anonymous user account that can later be linked
  /// to a permanent account using [signInOrLinkWithGoogle].
  ///
  /// Throws [DeviceAccountException] if this device already has an associated account.
  Future<UserCredential> signInAnonymously() async {
    // Check if device already has an account
    final hasDeviceAccount = await _deviceService.hasDeviceAccount();
    if (hasDeviceAccount) {
      throw DeviceAccountException(
        'This device already has an associated account. Only one account per device is allowed.',
      );
    }

    final userCredential = await _auth.signInAnonymously();

    // Mark device as having an account
    await _deviceService.markDeviceHasAccount(userCredential.user!.uid);

    return userCredential;
  }

  /// Sign in using Google. Returns the signed-in [User] on success.
  ///
  /// Typical flow:
  /// 1. Start Google sign-in to get Google account and auth tokens.
  /// 2. Create a Firebase credential using [GoogleAuthProvider.credential].
  /// 3. If current user is anonymous, link the credential; otherwise sign in.
  ///
  /// Errors thrown by GoogleSignIn or FirebaseAuth will bubble up to the
  /// caller so the UI can display them.
  Future<GoogleSignInResult?> signInOrLinkWithGoogle() async {
    // Trigger the Google Authentication flow
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      // The user canceled the sign-in
      return null;
    }

    // Debug: Log Google user details
    debugPrint('🔍 Google Sign-In User:');
    debugPrint('  Display Name: ${googleUser.displayName}');
    debugPrint('  Email: ${googleUser.email}');
    debugPrint('  Photo URL: ${googleUser.photoUrl}');
    debugPrint('  ID: ${googleUser.id}');

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential for Firebase
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Check if current user is anonymous
    final currentUser = _auth.currentUser;
    debugPrint(
      '👤 Current user: ${currentUser?.uid}, isAnonymous: ${currentUser?.isAnonymous}',
    );

    User? resultUser;
    if (currentUser != null && currentUser.isAnonymous) {
      // Check if device already has an account (should be the current anonymous one)
      final deviceAccountId = await _deviceService.getDeviceAccountId();
      if (deviceAccountId != null && deviceAccountId != currentUser.uid) {
        throw DeviceAccountException(
          'Cannot link account: device is associated with a different account.',
        );
      }

      // Link the Google credential to the anonymous account
      debugPrint('🔗 Linking Google credential to anonymous account');
      final userCredential = await currentUser.linkWithCredential(credential);
      resultUser = userCredential.user;
      debugPrint(
        '✅ Linked user photo URL before reload: ${resultUser?.photoURL}',
      );

      // Reload the user to get updated profile information
      await resultUser?.reload();
      resultUser = _auth.currentUser; // Get the updated user
      debugPrint(
        '✅ Linked user photo URL after reload: ${resultUser?.photoURL}',
      );
      debugPrint(
        '✅ Linked user isAnonymous after reload: ${resultUser?.isAnonymous}',
      );
      debugPrint('✅ Linked user email after reload: ${resultUser?.email}');

      // Update device association to the linked account
      if (resultUser != null) {
        await _deviceService.markDeviceHasAccount(resultUser.uid);
      }

      // If Firebase user doesn't have photo URL but Google user does, we might need to handle this
      if (resultUser?.photoURL == null && googleUser.photoUrl != null) {
        debugPrint(
          '⚠️ Firebase user missing photo URL, but Google user has: ${googleUser.photoUrl}',
        );
        // Note: Firebase should populate photoURL from Google, but if not, we could manually set it
      }
    } else {
      // Normal sign-in flow - check if device already has an account
      final hasDeviceAccount = await _deviceService.hasDeviceAccount();
      if (hasDeviceAccount) {
        throw DeviceAccountException(
          'This device already has an associated account. Only one account per device is allowed.',
        );
      }

      debugPrint('🔐 Normal Google sign-in flow');
      final userCredential = await _auth.signInWithCredential(credential);
      resultUser = userCredential.user;
      debugPrint('✅ Signed in user photo URL: ${resultUser?.photoURL}');

      // Mark device as having an account
      if (resultUser != null) {
        await _deviceService.markDeviceHasAccount(resultUser.uid);
      }
    }

    return GoogleSignInResult(resultUser, googleUser.photoUrl);
  }

  /// Sign in using Google. Returns the signed-in [User] on success.
  ///
  /// Typical flow:
  /// 1. Start Google sign-in to get Google account and auth tokens.
  /// 2. Create a Firebase credential using [GoogleAuthProvider.credential].
  /// 3. Sign in to Firebase with that credential.
  ///
  /// Errors thrown by GoogleSignIn or FirebaseAuth will bubble up to the
  /// caller so the UI can display them.
  Future<User?> signInWithGoogle() async {
    // Trigger the Google Authentication flow
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      // The user canceled the sign-in
      return null;
    }

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential for Firebase
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase with the credential
    final userCredential = await _auth.signInWithCredential(credential);
    return userCredential.user;
  }

  /// Sign out from both Google and Firebase.
  Future<void> signOut() async {
    try {
      // Sign out from Firebase first
      await _auth.signOut();
    } finally {
      // Always try to sign out from Google as well (best-effort)
      try {
        await _googleSignIn.signOut();
      } catch (_) {
        // ignore errors during Google sign-out
      }
    }

    // Clear device account association
    await _deviceService.clearDeviceAccount();
  }
}
