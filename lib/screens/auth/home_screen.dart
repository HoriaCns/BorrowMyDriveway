import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/appwrite_client.dart';
import '../../widgets/driveway_card.dart';
import '../list_driveway_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appwriteClient = context.read<AppwriteClient>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Driveways'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: appwriteClient.logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
          )
        ],
      ),
      // Use a StreamBuilder to listen for real-time updates from Appwrite
      body: StreamBuilder<RealtimeMessage>(
        stream: appwriteClient.realtime.subscribe([
          'databases.${AppwriteClient.databaseId}.collections.${AppwriteClient.drivewaysCollectionId}.documents'
        ]).stream,
        builder: (context, snapshot) {
          // This stream just tells us WHEN to refetch, not WHAT changed.
          // So we use a FutureBuilder inside to get the latest documents.
          return FutureBuilder<models.DocumentList>(
            future: appwriteClient.databases.listDocuments(
              databaseId: AppwriteClient.databaseId,
              collectionId: AppwriteClient.drivewaysCollectionId,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.documents.isEmpty) {
                return const Center(
                  child: Text(
                    'No driveways listed yet.\nBe the first to add one!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                );
              }
              final driveways = snapshot.data!.documents;
              return ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: driveways.length,
                itemBuilder: (context, index) {
                  final drivewayData = driveways[index].data;
                  // **UPDATED LOGIC**: Convert price from pence (int) to pounds (double)
                  final priceInPence = drivewayData['price'] as int? ?? 0;
                  final priceInPounds = priceInPence / 100.0;

                  return DrivewayCard(
                    address: drivewayData['address'] ?? 'No Address',
                    price: priceInPounds,
                    imageUrl: drivewayData['imageUrl'],
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ListDrivewayScreen()),
          );
        },
        label: const Text('List Your Driveway'),
        icon: const Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}