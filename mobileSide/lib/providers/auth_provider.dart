import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  User? _user;
  String? _token;
  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;
  final ApiService _apiService = ApiService.instance;

  User? get user => _user;
  String? get token => _token;
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated && _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isBarber => _user?.isBarber ?? false;

  Future<void> checkAuthStatus() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final isLoggedIn = await _apiService.isLoggedIn();
      if (isLoggedIn) {
        _user = await _apiService.getCurrentUser();
        if (_user != null && (_user!.isAdmin || _user!.isBarber)) {
          _status = AuthStatus.authenticated;
        } else {
          await _apiService.logout();
          _status = AuthStatus.unauthenticated;
          _errorMessage = 'Only Admin and Barber roles are allowed';
        }
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final authResponse = await _apiService.login(username, password);
      _user = authResponse.user;
      _token = authResponse.token;

      // Check if user has valid role
      if (!_user!.isAdmin && !_user!.isBarber) {
        await _apiService.logout();
        _status = AuthStatus.error;
        _errorMessage = 'Only Admin and Barber roles are allowed';
        notifyListeners();
        return false;
      }

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _apiService.logout();
    _user = null;
    _token = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
