import 'package:flutter/material.dart';
import '../models/drama.dart';
import '../services/tmdb_service.dart';
import '../widgets/drama_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = TmdbService();
  late Future<List<List<Drama>>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = Future.wait([_api.popular(), _api.airingNow(), _api.topRated()]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('K-Dramas')),
      body: FutureBuilder<List<List<Drama>>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No se pudo cargar el catálogo'),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () => setState(_load),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          final s = snap.data!;
          return ListView(
            children: [
              _Section(title: 'Populares', dramas: s[0]),
              _Section(title: 'En emisión', dramas: s[1]),
              _Section(title: 'Mejor valorados', dramas: s[2]),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Drama> dramas;

  const _Section({required this.title, required this.dramas});

  @override
  Widget build(BuildContext context) {
    if (dramas.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        SizedBox(
          height: 240,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: dramas.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => DramaCard(drama: dramas[i], width: 130),
          ),
        ),
      ],
    );
  }
}
