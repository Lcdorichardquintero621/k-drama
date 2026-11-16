import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../countries.dart';
import '../models/drama.dart';
import '../services/tmdb_service.dart';

class WhereToWatch extends StatefulWidget {
  final int dramaId;

  const WhereToWatch({super.key, required this.dramaId});

  @override
  State<WhereToWatch> createState() => _WhereToWatchState();
}

class _WhereToWatchState extends State<WhereToWatch> {
  late final Future<Map<String, WatchInfo>> _future =
      TmdbService().watchProviders(widget.dramaId);

  Future<void> _open(String link) async {
    var ok = false;
    try {
      ok = await launchUrl(Uri.parse(link),
          mode: LaunchMode.externalApplication);
    } catch (_) {}
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el enlace')),
      );
    }
  }

  Widget _providerTile(WatchProvider p) {
    return SizedBox(
      width: 64,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: p.logoUrl == null
                ? const SizedBox(width: 48, height: 48, child: Icon(Icons.tv))
                : CachedNetworkImage(
                    imageUrl: p.logoUrl!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(height: 4),
          Text(
            p.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _group(String title, List<WatchProvider> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: items.map(_providerTile).toList(),
          ),
        ],
      ),
    );
  }

  Widget _content(WatchInfo? info, String code) {
    if (info == null || info.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
            'Sin información de disponibilidad en ${supportedCountries[code]}.'),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _group('Gratis', info.free),
        _group('Suscripción', info.subscription),
        _group('Alquiler o compra', info.rentBuy),
        if (info.link != null) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _open(info.link!),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Ver opciones en JustWatch'),
          ),
        ],
        const SizedBox(height: 4),
        Text('Datos de disponibilidad: JustWatch',
            style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Dónde verlo',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            ValueListenableBuilder<String>(
              valueListenable: selectedCountry,
              builder: (_, code, __) => DropdownButton<String>(
                value: code,
                underline: const SizedBox.shrink(),
                items: supportedCountries.entries
                    .map((e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) selectedCountry.value = v;
                },
              ),
            ),
          ],
        ),
        FutureBuilder<Map<String, WatchInfo>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const LinearProgressIndicator();
            }
            if (snap.hasError || snap.data == null) {
              return const Text('No se pudo cargar la disponibilidad.');
            }
            return ValueListenableBuilder<String>(
              valueListenable: selectedCountry,
              builder: (_, code, __) => _content(snap.data![code], code),
            );
          },
        ),
      ],
    );
  }
}
