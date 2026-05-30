import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tirta/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:tirta/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:tirta/features/auth/domain/repositories/auth_repository.dart';
import 'package:tirta/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:tirta/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:tirta/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:tirta/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:tirta/shared/services/supabase_service.dart';

// --- State ---

class AuthState {
  final bool isLoading;
  final String? error;
  final User? user;

  const AuthState({
    this.isLoading = false,
    this.error,
    this.user,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    User? user,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      user: user ?? this.user,
    );
  }

  factory AuthState.initial() => const AuthState();

  bool get isAuthenticated => user != null;
}

// --- Providers ---

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  return AuthRemoteDatasourceImpl();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final datasource = ref.watch(authRemoteDatasourceProvider);
  return AuthRepositoryImpl(remoteDatasource: datasource);
});

final signInUsecaseProvider = Provider<SignInUsecase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignInUsecase(repository: repository);
});

final signUpUsecaseProvider = Provider<SignUpUsecase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignUpUsecase(repository: repository);
});

final signOutUsecaseProvider = Provider<SignOutUsecase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignOutUsecase(repository: repository);
});

final resetPasswordUsecaseProvider = Provider<ResetPasswordUsecase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return ResetPasswordUsecase(repository: repository);
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  return SupabaseService.client.auth.onAuthStateChange.map((event) {
    return AuthState(user: event.session?.user);
  });
});

// --- Notifier ---

final authNotifierProvider = NotifierProvider<AuthStateNotifier, AuthState>(() {
  return AuthStateNotifier();
});

class AuthStateNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Initialize with the current user from Supabase
    final currentUser = SupabaseService.currentUser;
    return AuthState(user: currentUser);
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final usecase = ref.read(signInUsecaseProvider);
      final user = await usecase(email: email, password: password);
      state = state.copyWith(isLoading: false, user: user);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final usecase = ref.read(signUpUsecaseProvider);
      final user = await usecase(
        email: email,
        password: password,
        fullName: fullName,
      );
      state = state.copyWith(isLoading: false, user: user);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final usecase = ref.read(signOutUsecaseProvider);
      await usecase();
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> resetPassword({required String email}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final usecase = ref.read(resetPasswordUsecaseProvider);
      await usecase(email: email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
