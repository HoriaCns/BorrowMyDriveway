import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as Models;
import 'package:borrow_my_driveway/constants.dart';
import 'package:borrow_my_driveway/providers/auth_provider.dart';
import 'package:borrow_my_driveway/screens/list_driveway_screen.dart';
import 'package:borrow_my_driveway/service_locator.dart';
import 'package:borrow_my_driveway/widgets/driveway_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final Databases _databases = getIt<Databases>();
  Future<Models.DocumentList>? _drivewaysFuture;

  @override
  void initState() {
    super.initState();
    _loadDriveways();
  }

  void _loadDriveways() {
    // Fetches all documents from the driveways collection
    _drivewaysFuture = _databases.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.drivewaysCollectionId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
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
      body: FutureBuilder<Models.DocumentList>(
        future: _drivewaysFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.documents.isEmpty) {
            return const Center(child: Text('No driveways listed yet. Be the first!'));
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
                final driveway = driveways[index].data;
                return DrivewayCard(
                  address: driveway['address'],
                  price: driveway['price'],
                  imageUrl: driveway['imageUrl'],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
