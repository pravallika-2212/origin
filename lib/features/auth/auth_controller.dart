import 'package:flutter/material.dart';
import '../../core/riverpod.dart';
import '../../data/models/app_user.dart';
import 'auth_dialog.dart';

class AuthState {
  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  final AppUser? user;
  final bool isLoading;
  final String? errorMessage;

  bool get isSignedIn => user != null;
  bool get isAdmin => user?.isAdmin ?? false;
  UserRole get role => user?.role ?? UserRole.guest;
}

class AuthController extends StateNotifier<AuthState> {
  AuthController() : super(const AuthState());

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String phone = '',
    String country = 'United States',
  }) async {
    state = AuthState(user: state.user, isLoading: true);
    await Future.delayed(const Duration(milliseconds: 500));

    if (password.length < 6) {
      state = AuthState(
        user: state.user,
        isLoading: false,
        errorMessage: 'Password must be at least 6 characters.',
      );
      return false;
    }

    if (email.isEmpty || !email.contains('@')) {
      state = AuthState(
        user: state.user,
        isLoading: false,
        errorMessage: 'Please enter a valid email address.',
      );
      return false;
    }

    final newUser = AppUser(
      uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim().isEmpty ? 'Royal Patron' : name.trim(),
      email: email.trim(),
      phone: phone.trim(),
      country: country.trim(),
      role: UserRole.member,
      createdAt: DateTime.now(),
    );

    state = AuthState(user: newUser, isLoading: false);
    return true;
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = AuthState(user: state.user, isLoading: true);
    await Future.delayed(const Duration(milliseconds: 500));

    if (email.isEmpty || password.isEmpty) {
      state = AuthState(
        user: state.user,
        isLoading: false,
        errorMessage: 'Please enter your email and password.',
      );
      return false;
    }

    // Check if logging in as admin
    final isAdmin = email.toLowerCase().contains('admin');

    final loggedInUser = AppUser(
      uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: isAdmin ? 'Imperial Curator' : (email.split('@').first.toUpperCase()),
      email: email.trim(),
      role: isAdmin ? UserRole.admin : UserRole.member,
      createdAt: DateTime.now(),
    );

    state = AuthState(user: loggedInUser, isLoading: false);
    return true;
  }

  Future<bool> loginWithGoogle() async {
    state = AuthState(user: state.user, isLoading: true);
    await Future.delayed(const Duration(milliseconds: 400));

    final googleUser = AppUser(
      uid: 'user_google_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Lady Eleanor Vance',
      email: 'eleanor.vance@gmail.com',
      role: UserRole.member,
      createdAt: DateTime.now(),
    );

    state = AuthState(user: googleUser, isLoading: false);
    return true;
  }

  void logout() {
    state = const AuthState();
  }

  void switchToAdminDemo() {
    state = AuthState(
      user: AppUser(
        uid: 'admin_origin_001',
        name: 'Lord Henry Kensington (Curator)',
        email: 'curator@origin-heritage.com',
        role: UserRole.admin,
        createdAt: DateTime.now(),
      ),
    );
  }

  void switchToMemberDemo() {
    state = AuthState(
      user: AppUser(
        uid: 'member_demo_001',
        name: 'Princess Sophia of Bavaria',
        email: 'sophia.bavaria@royalhouse.org',
        role: UserRole.member,
        createdAt: DateTime.now(),
      ),
    );
  }

  void switchToGuest() {
    logout();
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController();
});

/// Login gate for actions (the core browse-first rule) from PRD Section 11.2
Future<bool> requireAuth(
  BuildContext context,
  WidgetRef ref,
  String action,
) async {
  if (ref.read(authControllerProvider).isSignedIn) return true;
  final ok = await showAuthDialog(
    context,
    reason: 'Please register or log in to $action.',
  );
  return ok == true;
}
