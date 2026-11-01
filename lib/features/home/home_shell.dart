import 'package:flutter/material.dart';

import 'package:koral/data/koral_repository.dart';
import 'package:koral/features/admin/admin_screen.dart';
import 'package:koral/features/projects/project_list_screen.dart';

/// Signed-in home. The Owner tab only appears for the owner account, and the
/// database refuses owner data to everyone else even if the tab were forced on.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final _repo = KoralRepository();
  int _index = 0;
  bool _isOwner = false;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    try {
      final owner = await _repo.isOwner();
      if (mounted) setState(() => _isOwner = owner);
    } catch (_) {
      // Stay a regular member: the Owner tab stays hidden.
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      ProjectListScreen(repo: _repo, isOwner: _isOwner),
      if (_isOwner) AdminScreen(repo: _repo),
    ];
    final index = _index < pages.length ? _index : 0;
    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: _isOwner
          ? NavigationBar(
              selectedIndex: index,
              onDestinationSelected: (value) => setState(() => _index = value),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.folder_open_outlined),
                  selectedIcon: Icon(Icons.folder_open),
                  label: 'Projects',
                ),
                NavigationDestination(
                  icon: Icon(Icons.insights_outlined),
                  selectedIcon: Icon(Icons.insights),
                  label: 'Owner',
                ),
              ],
            )
          : null,
    );
  }
}
