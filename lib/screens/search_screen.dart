import 'dart:async';
import 'package:flutter/material.dart';
import '../models/drama.dart';
import '../services/tmdb_service.dart';
import '../widgets/drama_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _api = TmdbService();
  final _controller = TextEditingController();
  Timer? _debounce;
  List<Drama> _results = [];
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    _debounce?.cancel();
    if (text.trim().isEmpty) {
      setState(() {
        _results = [];
        _error = null;
        _loading = false;
      });
      return;
    }
    _debounce = Timer(
      const Duration(milliseconds: 500),
      () => _search(text.trim()),
    );
  }

  Future<void> _search(String q) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final r = await _api.search(q);
      if (!mounted) return;
      setState(() => _results = r);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'No se pudo buscar. Revisa tu conexión.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _body() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!));
    if (_controller.text.trim().isEmpty) {
      return const Center(child: Text('Escribe el nombre de un k-drama'));
    }
    if (_results.isEmpty) return const Center(child: Text('Sin resultados'));
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.52,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _results.length,
      itemBuilder: (_, i) => DramaCard(drama: _results[i]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          onChanged: _onChanged,
          decoration: const InputDecoration(
            hintText: 'Buscar k-dramas...',
            border: InputBorder.none,
          ),
        ),
      ),
      body: _body(),
    );
  }
}
