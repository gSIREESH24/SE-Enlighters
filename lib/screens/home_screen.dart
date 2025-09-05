import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../services/storage_service.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _pickedIndex = -1;
  final String _welcomeMsg = "Ask Me?";
  late List<AnimationController> _ctrls;
  late List<Animation<double>> _fades;
  List<String> _recentSearches = [];

  final StorageService _storageService = StorageService();

  // ✅ Store last query directly
  String? _lastQuery;

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();

    _ctrls = List.generate(
      _welcomeMsg.length,
          (i) => AnimationController(vsync: this, duration: const Duration(seconds: 1)),
    );

    _fades = _ctrls
        .map((c) => Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: c, curve: Curves.easeInOut)))
        .toList();

    for (int i = 0; i < _ctrls.length; i++) {
      Future.delayed(Duration(milliseconds: i * 400), () {
        if (mounted) _ctrls[i].repeat(reverse: true);
      });
    }
  }

  Future<void> _loadRecentSearches() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final uid = auth.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      final data = doc.data();
      if (data != null && data.containsKey('recentSearches')) {
        setState(() {
          _recentSearches = List<String>.from(data['recentSearches']);
        });
      }
    }
  }

  Future<void> _addRecentSearch(String query) async {
    if (query.trim().isEmpty) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final uid = auth.uid;
    if (uid == null) return;

    setState(() {
      _recentSearches.remove(query);
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 10) {
        _recentSearches = _recentSearches.sublist(0, 10);
      }
      _lastQuery = query; // ✅ Save last query
    });

    await FirebaseFirestore.instance.collection('users').doc(uid).set(
      {'recentSearches': _recentSearches},
      SetOptions(merge: true),
    );
  }

  @override
  void dispose() {
    for (var c in _ctrls) c.dispose();
    super.dispose();
  }

  void _openSearch({String? initialQuestion}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchPage(
          initialQuestion: initialQuestion,
          onQuerySubmitted: (query) {
            _addRecentSearch(query);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final theme = Provider.of<ThemeProvider>(context);
    final isDarkMode = theme.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text("Enlightner",
            style: GoogleFonts.merriweather(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.brightness_6), onPressed: theme.toggleTheme)
        ],
      ),
      drawer: _buildDrawer(context, auth, isDarkMode),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [const Color(0xFF121212), Colors.brown.shade900]
                : [const Color(0xFFFFF7F1), Colors.brown.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 40),
            _buildWelcomeAnim(),
            const SizedBox(height: 20),
            _buildCategoryPyramid(isDarkMode),
            const Spacer(),
            if (_lastQuery != null) ...[
              Text("Last query: $_lastQuery",
                  style: GoogleFonts.merriweather(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
            ],
            _buildRecentSearchesSection(isDarkMode),
            const SizedBox(height: 10),
            _buildSearchBar(isDarkMode),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context, AuthProvider auth, bool isDarkMode) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [const Color(0xFF121212), Colors.brown.shade900]
                    : [const Color(0xFFFFF7F1), Colors.brown.shade100],
              ),
            ),
            accountName: Text(auth.userName,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color)),
            accountEmail: Text(auth.userEmail,
                style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color)),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: const Icon(Icons.person, color: Colors.white, size: 32),
            ),
          ),
          ..._recentSearches.map((item) => ListTile(
            leading: const Icon(Icons.history),
            title: Text(item),
            onTap: () {
              Navigator.pop(context);
              _openSearch(initialQuestion: item);
            },
          )),
          const Divider(),
          /*ListTile(
            leading: const Icon(Icons.bookmark),
            title: const Text("Bookmarks"),
            onTap: () async {
              Navigator.pop(context);
              final bookmarks = _storageService.getBookmarks();
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Bookmarks"),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: ListView(
                      children: bookmarks
                          .map((e) => ListTile(
                        title: Text(e),
                        onTap: () {
                          Navigator.pop(context);
                          _openSearch(initialQuestion: e);
                        },
                      ))
                          .toList(),
                    ),
                  ),
                ),
              );
            },
          ),*/
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Log out"),
            onTap: () async {
              await auth.logout();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                    (_) => false,
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildWelcomeAnim() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.temple_buddhist, size: 40, color: Colors.brown),
        const SizedBox(width: 12),
        Row(
          children: List.generate(_welcomeMsg.length, (i) {
            return AnimatedBuilder(
              animation: _fades[i],
              builder: (_, child) => Opacity(
                opacity: _fades[i].value,
                child: Text(_welcomeMsg[i],
                    style: GoogleFonts.merriweather(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2)),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCategoryPyramid(bool isDarkMode) {
    final categories = {
      "Life": Icons.favorite,
      "Love": Icons.favorite_border,
      "Faith": Icons.self_improvement,
      "Wisdom": Icons.psychology,
      "Peace": Icons.spa,
      "Hope": Icons.lightbulb,
      "Guidance": Icons.explore,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 12,
        children: categories.entries.map((entry) {
          final index = categories.keys.toList().indexOf(entry.key);
          final active = _pickedIndex == index;
          return ElevatedButton.icon(
            onPressed: () {
              setState(() => _pickedIndex = index);
              _openSearch(initialQuestion: entry.key);
            },
            icon: Icon(entry.value,
                size: 22,
                color: active
                    ? Colors.white
                    : Theme.of(context).iconTheme.color),
            label: Text(entry.key,
                style: GoogleFonts.merriweather(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: active
                        ? Colors.white
                        : Theme.of(context).textTheme.bodyLarge?.color)),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              elevation: 3,
              backgroundColor: active
                  ? (isDarkMode ? Colors.brown[800] : Colors.brown[400])
                  : (isDarkMode ? Colors.grey[850] : Colors.white),
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecentSearchesSection(bool isDarkMode) {
    if (_recentSearches.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text("Recent Searches",
              style: GoogleFonts.merriweather(
                  fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _recentSearches.length,
            itemBuilder: (_, index) {
              final item = _recentSearches[index];
              return GestureDetector(
                onTap: () => _openSearch(initialQuestion: item),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[800] : Colors.brown[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(child: Text(item)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => _openSearch(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[850] : Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              if (!isDarkMode)
                const BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2))
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.search,
                  color: isDarkMode ? Colors.white70 : Colors.black54),
              const SizedBox(width: 12),
              Text("Search...",
                  style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                      fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
