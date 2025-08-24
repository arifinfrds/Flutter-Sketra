import 'package:flutter/material.dart';

class AsyncImage extends StatelessWidget {
  String url;

  AsyncImage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
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
    );
  }
}
