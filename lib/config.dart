// La API key NO va en el código. Se pasa al ejecutar:
//   flutter run --dart-define=TMDB_API_KEY=tu_clave
// Consíguela gratis en https://www.themoviedb.org/settings/api
// (clave "API Key (v3 auth)").
const String tmdbApiKey = String.fromEnvironment('TMDB_API_KEY');
