import 'dart:ui';
import 'package:flutter/foundation.dart';

/// Países de habla hispana (más EE. UU.) para consultar disponibilidad.
const Map<String, String> supportedCountries = {
  'AR': 'Argentina',
  'BO': 'Bolivia',
  'CL': 'Chile',
  'CO': 'Colombia',
  'CR': 'Costa Rica',
  'DO': 'Rep. Dominicana',
  'EC': 'Ecuador',
  'ES': 'España',
  'US': 'Estados Unidos',
  'GT': 'Guatemala',
  'HN': 'Honduras',
  'MX': 'México',
  'NI': 'Nicaragua',
  'PA': 'Panamá',
  'PY': 'Paraguay',
  'PE': 'Perú',
  'SV': 'El Salvador',
  'UY': 'Uruguay',
  'VE': 'Venezuela',
};

String _initialCountry() {
  final code = PlatformDispatcher.instance.locale.countryCode;
  return (code != null && supportedCountries.containsKey(code)) ? code : 'MX';
}

/// País elegido. Por defecto sale del idioma/región del teléfono.
final ValueNotifier<String> selectedCountry = ValueNotifier(_initialCountry());
