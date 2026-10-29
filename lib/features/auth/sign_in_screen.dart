import 'package:flutter/material.dart';
import 'package:koral/app/theme.dart';
import 'package:koral/features/admin/admin_dashboard_screen.dart';
import 'package:koral/features/auth/sign_in_screen.dart';
import 'package:koral/features/briefs/brief_builder_screen.dart';
import 'package:koral/features/exports/export_center_screen.dart';
import 'package:koral/features/notifications/notifications_screen.dart';
import 'package:koral/features/projects/project_list_screen.dart';
import 'package:koral/features/studio/storyboard_screen.dart';
import 'package:koral/features/team/team_workspace_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _signedIn = true;

  void _handleSignIn() {
    setState(() {
      _signedIn = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_signedIn) {
      return SignInScreen(onSignIn: _handleSignIn);
    }

    return const KoralHomeShell();
  }
}

class KoralHomeShell extends StatefulWidget {
  const KoralHomeShell({super.key});

  @override
  State<KoralHomeShell> createState() => _KoralHomeShellState();
}

class _KoralHomeShellState extends State<KoralHomeShell> {
  int _index = 0;

  static const List<Widget> screens = [
    ProjectListScreen(),
    BriefBuilderScreen(),
    StoryboardScreen(),
    ExportCenterScreen(),
    AdminDashboardScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Koral Workspace'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.groups_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TeamWorkspaceScreen()),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.folder_open), label: 'Projects'),
          NavigationDestination(icon: Icon(Icons.edit_document), label: 'Briefs'),
          NavigationDestination(icon: Icon(Icons.movie_creation_outlined), label: 'Studio'),
          NavigationDestination(icon: Icon(Icons.download), label: 'Export'),
          NavigationDestination(icon: Icon(Icons.admin_panel_settings), label: 'Admin'),
        ],
      ),
    );
  }
}
