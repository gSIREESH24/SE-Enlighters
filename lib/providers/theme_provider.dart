import 'package:flutter/material.dart';
import '../../services/storage_service.dart';

class ThemeProvider with ChangeNotifier {
  final StorageService _storageService;
  bool _isDarkMode = false;

  ThemeProvider(this._storageService);

  bool get isDarkMode => _isDarkMode;

  Future<void> loadTheme() async {
    _isDarkMode = await _storageService.isDarkMode();
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _storageService.setDarkMode(_isDarkMode);
    notifyListeners();
  }
}