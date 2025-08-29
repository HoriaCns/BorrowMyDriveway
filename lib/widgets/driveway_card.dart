import 'package:flutter/material.dart';

class DrivewayCard extends StatelessWidget {
  final String address;
  final String price;
  final String imageUrl;
  final VoidCallback? onLongPress; // Add this callback

  const DrivewayCard({
    super.key,
    required this.address,
    required this.price,
    required this.imageUrl,
    this.onLongPress, // Add to constructor
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector( // Wrap the Card with GestureDetector
      onLongPress: onLongPress,
      child: Card(
        color: Color(0xFFFFFBF5),
        elevation: 4.0,
        margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0),
              ),
              child: Image.network(
                imageUrl,
                height: 200,
                fit: BoxFit.cover,
                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 200,
                    color: Color(0xFFFFFBF5),
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                  return Container(
                    height: 200,
                    color: Color(0xFFFFFBF5),
                    child: const Center(
                      child: Icon(Icons.error_outline, color: Colors.red, size: 50),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address,
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Color(0xFF10B981),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
