import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/drama.dart';
import '../services/tmdb_service.dart';
import '../widgets/where_to_watch.dart';

class DetailScreen extends StatefulWidget {
  final Drama drama;

  const DetailScreen({super.key, required this.drama});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late final Future<DramaDetail> _future =
      TmdbService().detail(widget.drama.id);

  @override
  Widget build(BuildContext context) {
    final d = widget.drama;
    final theme = Theme.of(context);
    final image = d.backdropUrl ?? d.posterUrl;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(d.name, style: const TextStyle(fontSize: 16)),
              background: image == null
                  ? null
                  : CachedNetworkImage(imageUrl: image, fit: BoxFit.cover),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(d.rating.toStringAsFixed(1)),
                      const SizedBox(width: 12),
                      Text(d.year),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(d.overview.isEmpty
                      ? 'Sin sinopsis en español.'
                      : d.overview),
                  const SizedBox(height: 16),
                  WhereToWatch(dramaId: d.id),
                  const SizedBox(height: 16),
                  FutureBuilder<DramaDetail>(
                    future: _future,
                    builder: (context, snap) {
                      if (snap.connectionState != ConnectionState.done) {
                        return const LinearProgressIndicator();
                      }
                      if (!snap.hasData) return const SizedBox.shrink();
                      final det = snap.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (det.genres.isNotEmpty)
                            Wrap(
                              spacing: 8,
                              children: det.genres
                                  .map((g) => Chip(label: Text(g)))
                                  .toList(),
                            ),
                          if (det.episodes != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              '${det.episodes} episodios'
                              '${det.seasons != null ? ' · ${det.seasons} temporada(s)' : ''}',
                            ),
                          ],
                          if (det.cast.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text('Reparto', style: theme.textTheme.titleMedium),
                            const SizedBox(height: 4),
                            Text(det.cast.join(', ')),
                          ],
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
