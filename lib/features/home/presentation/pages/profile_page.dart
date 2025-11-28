import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nudge_1/features/auth/domain/auth_service.dart';
import 'package:nudge_1/features/auth/domain/entities/user.dart' as domain_user;
import 'package:nudge_1/firebase/firestore/user_service.dart';

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// User service provider
final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

// Auth state provider
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Current user data provider
final currentUserProvider = FutureProvider<domain_user.User?>((ref) async {
  final authState = ref.watch(authStateProvider);
  final firebaseUser = authState.value;

  if (firebaseUser == null) return null;

  try {
    final userService = ref.read(userServiceProvider);
    final firestoreUser = await userService.getUser(firebaseUser.uid);

    if (firestoreUser != null) {
      // Use Firestore data as primary, but fall back to Firebase Auth data
      debugPrint('📊 Using Firestore data for user ${firebaseUser.uid}');
      debugPrint(
        '🖼️ Firestore profilePhotoUrl: ${firestoreUser.profilePhotoUrl}',
      );
      debugPrint('🖼️ Firebase photoURL: ${firebaseUser.photoURL}');
      return domain_user.User(
        id: firestoreUser.id,
        email: firestoreUser.email.isNotEmpty
            ? firestoreUser.email
            : firebaseUser.email ?? '',
        username: firestoreUser.username.isNotEmpty
            ? firestoreUser.username
            : firebaseUser.displayName ??
                  firebaseUser.email?.split('@').first ??
                  'user',
        displayName: firestoreUser.displayName.isNotEmpty
            ? firestoreUser.displayName
            : firebaseUser.displayName ??
                  firebaseUser.email?.split('@').first ??
                  'User',
        phoneNumber: firestoreUser.phoneNumber ?? firebaseUser.phoneNumber,
        profilePhotoUrl: firestoreUser.profilePhotoUrl ?? firebaseUser.photoURL,
        createdAt:
            firestoreUser.createdAt ?? firebaseUser.metadata.creationTime,
      );
    }
  } catch (e) {
    debugPrint('Error loading user data from Firestore: $e');
  }

  // Fall back to Firebase Auth data only
  debugPrint(
    '📊 Falling back to Firebase Auth data for user ${firebaseUser.uid}',
  );
  debugPrint('🖼️ Firebase photoURL: ${firebaseUser.photoURL}');
  return _firebaseUserToDomainUser(firebaseUser);
});

// Convert Firebase User to domain User
domain_user.User _firebaseUserToDomainUser(
  User firebaseUser, {
  String? googlePhotoUrl,
}) {
  return domain_user.User(
    id: firebaseUser.uid,
    email: firebaseUser.email ?? '',
    username:
        firebaseUser.displayName ??
        firebaseUser.email?.split('@').first ??
        'user',
    displayName:
        firebaseUser.displayName ??
        firebaseUser.email?.split('@').first ??
        'User',
    phoneNumber: firebaseUser.phoneNumber,
    profilePhotoUrl: firebaseUser.photoURL ?? googlePhotoUrl,
    createdAt: firebaseUser.metadata.creationTime,
  );
}

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final currentUser = ref.watch(currentUserProvider);

    // Sync user data when user signs in
    ref.listen(authStateProvider, (previous, next) async {
      final user = next.value;
      if (user != null &&
          (previous?.value == null || previous?.value?.uid != user.uid)) {
        // User just signed in, sync their data
        try {
          final userService = ref.read(userServiceProvider);
          final domainUser = _firebaseUserToDomainUser(user);
          await userService.createOrUpdateUser(domainUser);
          debugPrint('✅ User data auto-synced to Firestore');
        } catch (e) {
          debugPrint('❌ Failed to auto-sync user data: $e');
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: authState.when(
        data: (firebaseUser) => firebaseUser != null
            ? currentUser.when(
                data: (user) => user != null
                    ? _buildLoggedInProfile(context, ref, user)
                    : _buildLoggedOutProfile(context, ref),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) =>
                    Center(child: Text('Error loading user data: $error')),
              )
            : _buildLoggedOutProfile(context, ref),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildLoggedInProfile(
    BuildContext context,
    WidgetRef ref,
    domain_user.User user,
  ) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (firebaseUser) {
        if (firebaseUser == null) return _buildLoggedOutProfile(context, ref);

        final user = _firebaseUserToDomainUser(firebaseUser);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header Section
              const SizedBox(height: 20),
              _buildProfileHeader(
                context,
                user,
                isAnonymous: firebaseUser.isAnonymous,
              ),
              const SizedBox(height: 32),

              // Details Section
              _buildDetailsCard(context, user),

              // Account Actions
              const SizedBox(height: 32),
              if (firebaseUser.isAnonymous) ...[
                // Link Google Account Button for anonymous users
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      final authService = ref.read(authServiceProvider);
                      final signInResult = await authService
                          .signInOrLinkWithGoogle();

                      if (signInResult?.user != null && context.mounted) {
                        final linkedUser = signInResult!.user!;
                        final googlePhotoUrl = signInResult.googlePhotoUrl;

                        debugPrint('🔗 Account linked successfully!');
                        debugPrint('👤 Linked user ID: ${linkedUser.uid}');
                        debugPrint('📧 Linked user email: ${linkedUser.email}');
                        debugPrint(
                          '🖼️ Linked user photo URL: ${linkedUser.photoURL}',
                        );
                        debugPrint('🖼️ Google photo URL: $googlePhotoUrl');
                        debugPrint(
                          '🏷️ Linked user display name: ${linkedUser.displayName}',
                        );

                        // Sync user data to Firestore
                        try {
                          final userService = ref.read(userServiceProvider);
                          final domainUser = _firebaseUserToDomainUser(
                            linkedUser,
                            googlePhotoUrl: googlePhotoUrl,
                          );
                          debugPrint(
                            '🔄 Starting user data sync to Firestore for linked user: ${linkedUser.uid}',
                          );
                          debugPrint(
                            '🖼️ Domain user photo URL: ${domainUser.profilePhotoUrl}',
                          );
                          await userService.createOrUpdateUser(domainUser);
                          debugPrint(
                            '✅ User data synced to Firestore successfully',
                          );

                          // Force refresh of user data provider
                          ref.invalidate(currentUserProvider);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Successfully linked Google account!',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (syncError) {
                          debugPrint('❌ Failed to sync user data: $syncError');
                          debugPrint('Stack trace: ${StackTrace.current}');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Linked account, but failed to sync data: ${syncError.toString()}',
                              ),
                              backgroundColor: Colors.orange,
                              duration: const Duration(seconds: 5),
                            ),
                          );
                        }
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Account linking cancelled'),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to link Google account: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.link),
                  label: const Text('Link Google Account'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Sign Out Button
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    final authService = ref.read(authServiceProvider);
                    await authService.signOut();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Signed out successfully'),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error signing out: $e')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    domain_user.User user, {
    bool isAnonymous = false,
  }) {
    return Column(
      children: [
        // Profile Picture
        CircleAvatar(
          radius: 60,
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withOpacity(0.1),
          backgroundImage: user.profilePhotoUrl != null
              ? NetworkImage(user.profilePhotoUrl!)
              : null,
          child: user.profilePhotoUrl == null
              ? Icon(
                  Icons.person,
                  size: 60,
                  color: Theme.of(context).colorScheme.primary,
                )
              : null,
        ),
        const SizedBox(height: 16),

        // Display Name
        Text(
          user.displayName,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (isAnonymous) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Anonymous Account',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDetailsCard(BuildContext context, domain_user.User user) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDetailRow(
              context,
              icon: Icons.email,
              label: 'Email',
              value: user.email,
            ),
            _buildDetailRow(
              context,
              icon: Icons.person,
              label: 'Username',
              value: user.username,
            ),
            if (user.phoneNumber != null)
              _buildDetailRow(
                context,
                icon: Icons.phone,
                label: 'Phone',
                value: user.phoneNumber!,
              ),
            if (user.createdAt != null)
              _buildDetailRow(
                context,
                icon: Icons.calendar_today,
                label: 'Member Since',
                value: _formatDate(user.createdAt!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(value, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoggedOutProfile(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_circle,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'Sign In to Your Account',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Log in to save your data and sync across all your devices. Keep your expenses and income organized wherever you go.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () async {
              try {
                final authService = ref.read(authServiceProvider);
                final signInResult = await authService.signInOrLinkWithGoogle();

                if (signInResult?.user != null && context.mounted) {
                  final user = signInResult!.user!;
                  final googlePhotoUrl = signInResult.googlePhotoUrl;

                  // Sync user data to Firestore
                  try {
                    final userService = ref.read(userServiceProvider);
                    final domainUser = _firebaseUserToDomainUser(
                      user,
                      googlePhotoUrl: googlePhotoUrl,
                    );
                    debugPrint(
                      '🔄 Starting user data sync to Firestore for user: ${user.uid}',
                    );
                    await userService.createOrUpdateUser(domainUser);
                    debugPrint('✅ User data synced to Firestore successfully');

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Successfully signed in and synced!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (syncError) {
                    debugPrint('❌ Failed to sync user data: $syncError');
                    debugPrint('Stack trace: ${StackTrace.current}');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Signed in, but failed to sync data: ${syncError.toString()}',
                        ),
                        backgroundColor: Colors.orange,
                        duration: const Duration(seconds: 5),
                      ),
                    );
                  }
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sign in cancelled')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Sign in failed: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.login),
            label: const Text('Sign In with Google'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
