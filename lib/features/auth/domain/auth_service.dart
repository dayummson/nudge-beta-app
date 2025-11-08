import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
  AuthService({GoogleSignIn? googleSignIn, FirebaseAuth? firebaseAuth})
    : _googleSignIn = googleSignIn ?? GoogleSignIn(),
      _auth = firebaseAuth ?? FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn;
  final FirebaseAuth _auth;

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
  }
}
