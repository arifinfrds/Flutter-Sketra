import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sketra/models/MockWallpaperRepository.dart';
import 'package:sketra/pages/detail/FeedDetailViewModel.dart';

import '../shared/AsyncImage.dart';

class FeedDetailPageProxy extends StatelessWidget {
  final String wallpaperId;

  const FeedDetailPageProxy(this.wallpaperId, {super.key});

  Future<FeedDetailViewModel> _loadViewModel() async {
    final jsonString = await rootBundle.loadString('assets/mock_feed.json');
    final viewModel = FeedDetailViewModel(
      wallpaperId,
      MockWallpaperRepository.name(jsonString),
    );
    await viewModel.onLoad();
    return viewModel;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FeedDetailViewModel>(
      future: _loadViewModel(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return ChangeNotifierProvider<FeedDetailViewModel>.value(
          value: snapshot.data!,
          child: const FeedDetailPage(),
        );
      },
    );
  }
}

class FeedDetailPage extends StatefulWidget {
  const FeedDetailPage({super.key});

  @override
  State<FeedDetailPage> createState() => _FeedDetailPageState();
}

class _FeedDetailPageState extends State<FeedDetailPage> {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<FeedDetailViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(viewModel.wallpaper?.title ?? "Detail page"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _body(viewModel),
    );
  }

  Widget _body(FeedDetailViewModel viewModel) {
    if (viewModel.wallpaper == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return AsyncImage(url: viewModel.wallpaper!.url);
  }
}
