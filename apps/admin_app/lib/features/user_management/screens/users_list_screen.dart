import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../routing/route_names.dart';
import '../../../shared/widgets/admin_scaffold.dart';
import '../providers/user_provider.dart';
import 'user_detail_screen.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({Key? key}) : super(key: key);

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _selectedRole;
  bool? _filterIsActive = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUsers();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      final provider = context.read<UserProvider>();
      if (provider.hasMore && !provider.isLoading) {
        provider.fetchAllUsers(
          page: provider.currentPage + 1,
          roleFilter: _selectedRole,
          isActive: _filterIsActive,
        );
      }
    }
  }

  Future<void> _loadUsers() async {
    try {
      await context.read<UserProvider>().fetchAllUsers(
        roleFilter: _selectedRole,
        isActive: _filterIsActive,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading users: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteUser(String userId, String userName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate User'),
        content: Text('Are you sure you want to deactivate "$userName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await context.read<UserProvider>().deleteUser(userId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User deactivated successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deactivating user: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'User Management',
      currentRoute: RouteNames.users,
      body: Column(
        children: [
          // Filter bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Role filter
                    Expanded(
                      child: DropdownButton<String?>(
                        isExpanded: true,
                        value: _selectedRole,
                        hint: const Text('All Roles'),
                        items: const [
                          DropdownMenuItem(
                            value: null,
                            child: Text('All Roles'),
                          ),
                          DropdownMenuItem(
                            value: 'CUSTOMER',
                            child: Text('Customer'),
                          ),
                          DropdownMenuItem(
                            value: 'ADMIN',
                            child: Text('Admin'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value;
                          });
                          _loadUsers();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Status filter
                    Expanded(
                      child: DropdownButton<bool?>(
                        isExpanded: true,
                        value: _filterIsActive,
                        hint: const Text('All Status'),
                        items: const [
                          DropdownMenuItem(
                            value: null,
                            child: Text('All Status'),
                          ),
                          DropdownMenuItem(value: true, child: Text('Active')),
                          DropdownMenuItem(
                            value: false,
                            child: Text('Inactive'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _filterIsActive = value;
                          });
                          _loadUsers();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Users list
          Expanded(
            child: Consumer<UserProvider>(
              builder: (context, userProvider, _) {
                if (userProvider.isLoading && userProvider.users.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (userProvider.error != null && userProvider.users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error: ${userProvider.error}',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadUsers,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (userProvider.users.isEmpty) {
                  return const Center(child: Text('No users found'));
                }

                return ListView.builder(
                  controller: _scrollController,
                  itemCount:
                      userProvider.users.length +
                      (userProvider.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == userProvider.users.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      );
                    }

                    final user = userProvider.users[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(user.name),
                        subtitle: Text(user.email),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: const Text('View Details'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        UserDetailScreen(userId: user.id),
                                  ),
                                );
                              },
                            ),
                            if (user.isActive)
                              PopupMenuItem(
                                child: const Text(
                                  'Deactivate',
                                  style: TextStyle(color: Colors.red),
                                ),
                                onTap: () {
                                  _deleteUser(user.id, user.name);
                                },
                              ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  UserDetailScreen(userId: user.id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
