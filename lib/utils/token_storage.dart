import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/auth_models.dart';

class TokenStorage {
  TokenStorage._() : _secureStorage = _buildSecureStorage();

  static final TokenStorage instance = TokenStorage._();

  final FlutterSecureStorage _secureStorage;

  static const String _accessTokenKey = 'auth_access_token';
  static const String _refreshTokenKey = 'auth_refresh_token';

  static FlutterSecureStorage _buildSecureStorage() {
    const aOptions = AndroidOptions(encryptedSharedPreferences: true);
    const iOptions = IOSOptions(accessibility: KeychainAccessibility.first_unlock);
    const mOptions = MacOsOptions(accessibility: KeychainAccessibility.first_unlock);
    const wOptions = WindowsOptions();

    return FlutterSecureStorage(
      aOptions: aOptions,
      iOptions: iOptions,
      mOptions: mOptions,
      wOptions: wOptions,
      webOptions: const WebOptions(),
    );
  }

  Future<void> persistTokens(AuthSessionTokens tokens) async {
    await _secureStorage.write(key: _accessTokenKey, value: tokens.accessToken);
    if (tokens.refreshToken != null) {
      await _secureStorage.write(key: _refreshTokenKey, value: tokens.refreshToken);
    } else {
      await _secureStorage.delete(key: _refreshTokenKey);
    }
  }

  Future<AuthSessionTokens?> readTokens() async {
    try {
      final accessToken = await _secureStorage.read(key: _accessTokenKey);
      if (accessToken == null || accessToken.isEmpty) {
        return null;
      }
      final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
      return AuthSessionTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    } catch (error) {
      debugPrint('Token read failed: $error');
      return null;
    }
  }

  Future<void> clear() async {
    await Future.wait([
      _secureStorage.delete(key: _accessTokenKey),
      _secureStorage.delete(key: _refreshTokenKey),
    ]);
  }
}
