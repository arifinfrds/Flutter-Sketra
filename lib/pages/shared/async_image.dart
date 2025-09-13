import 'package:flutter/material.dart';

class AsyncImage extends StatelessWidget {
  final String url;

  const AsyncImage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: Colors.black12),
        Image.network(
          url,
          fit: BoxFit.cover, // 👈 crop center, maintain aspect ratio
          alignment: Alignment.center,
          loadingBuilder: (context, child, event) {
            if (event == null) {
              return child;
            } else {
              return Center(
                child: CircularProgressIndicator(
                  value: event.expectedTotalBytes != null
                      ? event.cumulativeBytesLoaded / event.expectedTotalBytes!
                      : null,
                ),
              );
            }
          },
        ),
      ],
    );
  }
}