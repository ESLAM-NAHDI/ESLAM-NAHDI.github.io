import 'package:flutter_riverpod/flutter_riverpod.dart';

// Navigation State Provider
final currentScreenIndexProvider = StateProvider<int>((ref) => 0);

// API Dashboard State Providers
final selectedPageProvider = StateProvider<String>((ref) => '');

// Nahdi Man Screen State Providers
final nahdiManLeftPanelWidthProvider = StateProvider<double>((ref) => 400.0);

// API Detail Page State Providers
final showNahdiManProvider = StateProvider<bool>((ref) => true);
final apiDetailLeftPanelWidthProvider = StateProvider<double>((ref) => 500.0);

// API Dashboard State Providers
final showScreenshotProvider = StateProvider<bool>((ref) => true);

// Nahdi Man Token Providers
final loginAccessTokenProvider = StateProvider<String?>((ref) => null);
final loginIdTokenProvider = StateProvider<String?>((ref) => null);
final useLoginTokenProvider = StateProvider<bool>((ref) => false);

