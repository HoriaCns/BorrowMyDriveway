import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:borrow_my_driveway/constants.dart';
import 'package:borrow_my_driveway/providers/auth_provider.dart';
import 'package:borrow_my_driveway/screens/edit_driveway_screen.dart';
import 'package:borrow_my_driveway/screens/list_driveway_screen.dart';
import 'package:borrow_my_driveway/service_locator.dart';
import 'package:borrow_my_driveway/widgets/driveway_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  final Databases _databases = getIt<Databases>();
  Future<models.DocumentList>? _drivewaysFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadDriveways();
  }

  void _loadDriveways() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.$id;

    if (userId != null) {
      _drivewaysFuture = _databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.drivewaysCollectionId,
        queries: [
          Query.equal('ownerId', userId),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(user != null ? 'Welcome, ${user.name}' : 'My Driveways'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
            },
          ),
        ],
      ),
      body: FutureBuilder<models.DocumentList>(
        future: _drivewaysFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.documents.isEmpty) {
            return const Center(child: Text('You haven\'t listed any driveways yet.'));
          }

          final driveways = snapshot.data!.documents;

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _loadDriveways();
              });
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: driveways.length,
              itemBuilder: (context, index) {
                final drivewayDocument = driveways[index];
                return DrivewayCard(
                  address: drivewayDocument.data['address'],
                  price: drivewayDocument.data['price'],
                  imageUrl: drivewayDocument.data['imageUrl'],
                  onLongPress: () async {
                    // Navigate to the edit screen and wait for a result
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditDrivewayScreen(drivewayDocument: drivewayDocument),
                      ),
                    );
                    // If the result is true, it means a change was made, so refresh the list
                    if (result == true) {
                      setState(() {
                        _loadDriveways();
                      });
                    }
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (context) => const ListDrivewayScreen()),
          );
          if (result == true) {
            setState(() {
              _loadDriveways();
            });
          }
        },
        tooltip: 'List a new driveway',
        child: const Icon(Icons.add),
      ),
    );
  }
}
