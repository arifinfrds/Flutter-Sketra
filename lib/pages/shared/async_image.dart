import 'package:flutter/material.dart';

class AsyncImage extends StatefulWidget {
  final String url;

  const AsyncImage({super.key, required this.url});

  @override
  State<AsyncImage> createState() => _AsyncImageState();
}

class _AsyncImageState extends State<AsyncImage> {
  Key _imageKey = UniqueKey(); // force rebuild on retry

  void _retry() {
    setState(() {
      _imageKey = UniqueKey(); // triggers Image.network reload
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: Colors.black12),
        Image.network(
          widget.url,
          key: _imageKey,
          fit: BoxFit.cover,
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
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: IconButton(
                iconSize: 40,
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    Colors.black.withOpacity(0.3),
                  ),
                  shape: WidgetStateProperty.all(const CircleBorder()),
                ),
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _retry,
              ),
            );
          },
        ),
      ],
    );
  }
}
