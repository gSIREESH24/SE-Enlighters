import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _darkModeKey = 'darkMode';
  static const _loggedInKey = 'isLoggedIn';
  static const _nameKey = 'name';
  static const _emailKey = 'email';
  static const _passwordKey = 'password';
  static const _recentKey = 'recent';
  static const _bookmarksKey = 'bookmarks';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Theme
  Future<void> setDarkMode(bool value) => _prefs.setBool(_darkModeKey, value);
  Future<bool> isDarkMode() async => _prefs.getBool(_darkModeKey) ?? false;

  // Auth
  Future<void> setLoggedIn(bool value) => _prefs.setBool(_loggedInKey, value);
  bool isLoggedIn() => _prefs.getBool(_loggedInKey) ?? false;

  Future<void> setUserName(String name) => _prefs.setString(_nameKey, name);
  String? getUserName() => _prefs.getString(_nameKey);

  Future<void> setUserEmail(String email) => _prefs.setString(_emailKey, email);
  String? getUserEmail() => _prefs.getString(_emailKey);

  Future<void> setUserPassword(String pass) => _prefs.setString(_passwordKey, pass);
  String? getUserPassword() => _prefs.getString(_passwordKey);

  // Searches & Bookmarks
  Future<void> setRecentSearches(List<String> searches) => _prefs.setStringList(_recentKey, searches);
  List<String> getRecentSearches() => _prefs.getStringList(_recentKey) ?? [];

  Future<void> setBookmarks(List<String> bookmarks) => _prefs.setStringList(_bookmarksKey, bookmarks);
  List<String> getBookmarks() => _prefs.getStringList(_bookmarksKey) ?? [];
}