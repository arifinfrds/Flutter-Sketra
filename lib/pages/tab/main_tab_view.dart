import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sketra/pages/favorites/favorites_page.dart';
import '../feed/feed_page_proxy.dart';
import '../favorites/favorites_view_model.dart';

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    final favoritesViewModel = context.read<FavoritesViewModel>();

    _pages = [
      const FeedPageProxy(title: 'Sketra'),
      FavoritesPage(viewModel: favoritesViewModel),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}
