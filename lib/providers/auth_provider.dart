import 'package:flutter/foundation.dart';

import '../models/api_exception.dart';
import '../models/auth_models.dart';
import '../services/auth_api_service.dart';
import '../utils/debug_logger.dart';
import '../utils/token_storage.dart';

enum AuthStatus { unknown, unauthenticated, authenticated, onboardingRequired }

typedef OnboardingAnswers = List<OnboardingAnswerModel>;

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    AuthApiService? apiService,
    TokenStorage? storage,
  })  : _apiService = apiService ?? AuthApiService(),
        _tokenStorage = storage ?? TokenStorage.instance;

  final AuthApiService _apiService;
  final TokenStorage _tokenStorage;

  AuthStatus _status = AuthStatus.unknown;
  bool _isLoading = false;
  String? _error;
  AuthSessionTokens? _session;
  UserProfileModel? _user;
  bool _rememberMe = true;

  AuthStatus get status => _status;
  bool get isLoading => _isLoading;
  String? get error => _error;
  UserProfileModel? get user => _user;
  bool get rememberMe => _rememberMe;

  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get needsOnboarding => _status == AuthStatus.onboardingRequired;

  Future<void> bootstrap() async {
    _status = AuthStatus.unknown;
    notifyListeners();
    DebugLogger.log('Bootstrapping session from secure storage', category: 'AuthProvider');
    final storedTokens = await _tokenStorage.readTokens();
    if (storedTokens == null) {
      DebugLogger.log('No stored tokens found; user unauthenticated', category: 'AuthProvider');
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    _session = storedTokens;

    try {
      final profile = await _apiService.fetchCurrentUser(storedTokens.accessToken);
      _user = profile;
      _status = profile.onboardingCompleted
          ? AuthStatus.authenticated
          : AuthStatus.onboardingRequired;
      DebugLogger.log(
        'Bootstrap succeeded for user ${profile.id}. Onboarding completed: ${profile.onboardingCompleted}',
        category: 'AuthProvider',
      );
    } catch (error, stackTrace) {
      DebugLogger.log(
        'Auth bootstrap failed',
        category: 'AuthProvider',
        error: error,
        stackTrace: stackTrace,
      );
      await _tokenStorage.clear();
      _session = null;
      _user = null;
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> signIn({
    required String email,
    required String password,
    bool remember = true,
  }) async {
    await _executeAuthFlow(
      action: () => _apiService.signIn(identifier: email, password: password),
      remember: remember,
      operation: 'signIn',
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    String? fullName,
    bool remember = true,
  }) async {
    await _executeAuthFlow(
      action: () => _apiService.signUp(
        email: email,
        password: password,
        fullName: fullName,
      ),
      remember: remember,
      operation: 'signUp',
    );
  }

  Future<void> signOut({bool remote = true}) async {
    final token = _session?.accessToken;
    _session = null;
    _user = null;
    _status = AuthStatus.unauthenticated;
    _error = null;
    notifyListeners();

    if (remote && token != null) {
      try {
        await _apiService.signOut(token);
      } catch (error, stackTrace) {
        DebugLogger.log(
          'Remote sign out failed',
          category: 'AuthProvider',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
    await _tokenStorage.clear();
  }

  Future<void> refreshProfile() async {
    final token = _requireToken();
    final userId = _user?.id;
    if (userId == null) return;
    DebugLogger.log('Refreshing profile for $userId', category: 'AuthProvider');
    final profile = await _apiService.refreshUser(userId, token);
    _user = profile;
    _status = profile.onboardingCompleted
        ? AuthStatus.authenticated
        : AuthStatus.onboardingRequired;
    notifyListeners();
  }

  Future<UserProfileModel> updateProfile({
    String? fullName,
    String? avatarUrl,
    String? bio,
    Map<String, dynamic>? preferences,
  }) async {
    final token = _requireToken();
    final updated = await _apiService.updateProfile(
      token: token,
      fullName: fullName,
      avatarUrl: avatarUrl,
      bio: bio,
      preferences: preferences,
    );
    _user = updated;
    notifyListeners();
    return updated;
  }

  Future<UserProfileModel> submitOnboarding(OnboardingAnswers answers) async {
    final token = _requireToken();
    DebugLogger.log(
      'Submitting onboarding with ${answers.length} responses',
      category: 'AuthProvider',
    );
    final updated = await _apiService.submitOnboarding(
      token: token,
      responses: answers,
    );
    _user = updated;
    _status = AuthStatus.authenticated;
    DebugLogger.log(
      'Onboarding submission completed for user ${updated.id}',
      category: 'AuthProvider',
    );
    notifyListeners();
    return updated;
  }

  Future<void> skipOnboarding() async {
    DebugLogger.log(
      'Skipping onboarding at user request',
      category: 'AuthProvider',
    );
    _status = AuthStatus.authenticated;
    if (_user != null) {
      _user = _user!.copyWith(onboardingCompleted: true);
    }
    notifyListeners();
  }

  Future<AccountDeletionStatusModel> scheduleAccountDeletion() async {
    final token = _requireToken();
    final statusModel = await _apiService.scheduleAccountDeletion(token);
    _user = _user?.copyWith(pendingAccountDeletion: statusModel);
    notifyListeners();
    return statusModel;
  }

  Future<AccountDeletionStatusModel?> cancelAccountDeletion() async {
    final token = _requireToken();
    final statusModel = await _apiService.cancelAccountDeletion(token);
    _user = _user?.copyWith(pendingAccountDeletion: statusModel);
    notifyListeners();
    return statusModel;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> _executeAuthFlow({
    required Future<AuthResponseModel> Function() action,
    required bool remember,
    required String operation,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    DebugLogger.log('Starting $operation flow', category: 'AuthProvider');

    try {
      final response = await action();
      _session = response.session;
      _user = response.user;
      _rememberMe = remember;
      if (remember) {
        await _tokenStorage.persistTokens(response.session);
      } else {
        await _tokenStorage.clear();
      }
      _status = response.user.onboardingCompleted
          ? AuthStatus.authenticated
          : AuthStatus.onboardingRequired;
      DebugLogger.log(
        '$operation succeeded for user ${response.user.id}. Onboarding completed: ${response.user.onboardingCompleted}',
        category: 'AuthProvider',
      );
    } on ApiException catch (error) {
      _error = error.message;
      DebugLogger.log(
        '$operation failed with API error: ${error.message}',
        category: 'AuthProvider',
        error: error,
      );
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _requireToken() {
    final token = _session?.accessToken;
    if (token == null) {
      throw ApiException('No active session');
    }
    return token;
  }
}
