import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sketra/pages/detail/FeedDetailPage.dart';
import 'package:sketra/pages/feed/FeedPageGridCell.dart';

import 'FeedViewModel.dart';
import '../../models/Wallpaper.dart';

class FeedPageProxy extends StatelessWidget {
  const FeedPageProxy({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FeedViewModel()..loadWallpapers(),
      child: FeedPage(title: title),
    );
  }
}

class FeedPage extends StatefulWidget {
  const FeedPage({super.key, required this.title});

  final String title;

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final FeedViewModel viewModel = FeedViewModel();

  @override
  void initState() {
    super.initState();
    viewModel.addListener(_onViewModelChanged);
    viewModel.loadWallpapers();
  }

  @override
  void dispose() {
    super.dispose();
    viewModel.removeListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _body(),
    );
  }

  Widget _body() {
    switch (viewModel.viewState) {
      case FeedViewState.loading:
        return const Center(child: CircularProgressIndicator());
      case FeedViewState.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 16,
            children: [
              const Text("Failed to load wallpapers"),
              Text("${viewModel.errorMessage}"),
              ElevatedButton(
                onPressed: () => {viewModel.onLoad()},
                child: const Text("Reload"),
              ),
            ],
          ),
        );
      case FeedViewState.empty:
        return const Center(child: Text("No wallpapers available"));
      case FeedViewState.loaded:
        return gridView(viewModel.wallpapers);
      default:
        return const SizedBox();
    }
  }

  GridView gridView(List<Wallpaper> wallpapers) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.7,
      ),
      padding: const EdgeInsets.all(8),
      itemCount: wallpapers.length,
      itemBuilder: (context, index) {
        final wallpaper = wallpapers[index];
        return FeedPageGridCell(
          wallpaper: wallpaper,
          onTap: () => {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => FeedDetailPage())),
          },
        );
      },
    );
  }
}
