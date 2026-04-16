import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:tcg_matchmaker/core/di/providers.dart';
import 'package:tcg_matchmaker/core/services/app_logger.dart';
import 'package:tcg_matchmaker/features/games/entities/game.dart';
import 'package:tcg_matchmaker/shared/widgets/loading_widget.dart';
import 'package:http/http.dart' as http;

class GameMap extends ConsumerStatefulWidget {
  final List<Game> games;
  final List<Game> myGames;
  final void Function(Game game)? onGameTap;
  final double distanceKm;

  const GameMap({
    super.key,
    required this.games,
    required this.distanceKm,
    this.onGameTap,
    this.myGames = const [],
  });

  @override
  ConsumerState<GameMap> createState() => _GameMapState();
}

class _GameMapState extends ConsumerState<GameMap> {
  MapboxMap? _mapboxMap;
  PointAnnotationManager? _annotationManager;
  final Map<String, Game> _annotationToGame = {};

  /// Convertit une distance en km vers un niveau de zoom Mapbox
  /// Formule logarithmique pour une correspondance plus précise
  double _distanceToZoom(double distanceKm) {
    // Mapbox zoom : chaque niveau divise la distance visible par 2
    // zoom 14 ≈ 1-2km visible, zoom 7 ≈ 150-200km visible
    // Formule : zoom = 14 - log2(distanceKm) avec ajustement
    final zoom = 14.5 - (math.log(distanceKm) / math.ln2) * 1.1;
    return zoom.clamp(6.0, 15.0);
  }

  @override
  void didUpdateWidget(GameMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_mapboxMap != null) {
      // Recharger les marqueurs si les games changent
      if (oldWidget.games != widget.games ||
          oldWidget.myGames != widget.myGames) {
        _loadMarkers();
      }

      // Mettre à jour le zoom si le rayon change
      if (oldWidget.distanceKm != widget.distanceKm) {
        _updateCameraForDistance();
      }
    }
  }

  /// Met à jour la caméra pour s'adapter au rayon de recherche
  Future<void> _updateCameraForDistance() async {
    final zoom = _distanceToZoom(widget.distanceKm);
    await _mapboxMap?.flyTo(
      CameraOptions(zoom: zoom, pitch: 45),
      MapAnimationOptions(duration: 500),
    );
  }

  void _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;

    // Vérifier si la géolocalisation est activée par l'utilisateur
    final locationEnabled = ref.read(locationEnabledProvider);

    // Activer la localisation de l'utilisateur seulement si autorisé
    await _mapboxMap?.location.updateSettings(
      LocationComponentSettings(
        enabled: locationEnabled,
        pulsingEnabled: locationEnabled,
        pulsingColor: Theme.of(context).colorScheme.primary.toARGB32(),
      ),
    );

    // Limiter le zoom minimum pour éviter la superposition des marqueurs
    await _mapboxMap?.setBounds(
      CameraBoundsOptions(minZoom: 9.0),
    );

    // Créer le gestionnaire de marqueurs
    _annotationManager =
        await _mapboxMap?.annotations.createPointAnnotationManager();

    // Écouter les clics sur les marqueurs
    // ignore: deprecated_member_use
    _annotationManager?.addOnPointAnnotationClickListener(
      _MarkerClickListener(
        annotationToGame: _annotationToGame,
        onGameTap: widget.onGameTap,
      ),
    );

    // Écouter les changements de position pour recentrer la map
    ref.listen(currentPositionProvider, (prev, next) {
      final position = next.valueOrNull;
      if (position != null && mounted) {
        _mapboxMap?.flyTo(
          CameraOptions(
            center: Point(
              coordinates: Position(position.longitude, position.latitude),
            ),
            zoom: _distanceToZoom(widget.distanceKm),
            pitch: 45,
          ),
          MapAnimationOptions(duration: 600),
        );
      }
    });

    _loadMarkers();
  }

  /// Regroupe les parties par coordonnées proches (même lieu ≈ rayon 5m)
  Map<String, List<Game>> _groupByLocation(List<Game> games) {
    const precision = 4; // ~11m de précision (5 décimales = ~1m, 4 = ~11m)
    final groups = <String, List<Game>>{};
    for (final game in games) {
      final key =
          '${game.latitude.toStringAsFixed(precision)},${game.longitude.toStringAsFixed(precision)}';
      groups.putIfAbsent(key, () => []).add(game);
    }
    return groups;
  }

  Future<void> _loadMarkers() async {
    if (_annotationManager == null || !mounted) return;

    // Supprimer les anciens marqueurs
    await _annotationManager?.deleteAll();
    _annotationToGame.clear();

    // myGames sert uniquement à identifier la bordure dorée,
    // widget.games (visibleGames) contient déjà tout, mergé et filtré.
    final myGameIds = widget.myGames.map((g) => g.id).toSet();

    if (widget.games.isEmpty) {
      return;
    }

    // Grouper par lieu pour détecter les superpositions
    final groups = _groupByLocation(widget.games);

    for (final entry in groups.entries) {
      final gamesAtLocation = entry.value;
      if (!mounted) return;
      if (gamesAtLocation.length == 1) {
        await _addMarkerForGame(gamesAtLocation.first, myGameIds: myGameIds);
      } else {
        // Décaler les marqueurs en cercle autour du point central
        const offsetDeg = 0.00018; // ~20m d'offset
        for (int i = 0; i < gamesAtLocation.length; i++) {
          if (!mounted) return;
          final angle = (2 * math.pi / gamesAtLocation.length) * i;
          final game = gamesAtLocation[i];
          final offsetLat = game.latitude + offsetDeg * math.sin(angle);
          final offsetLng = game.longitude + offsetDeg * math.cos(angle);
          await _addMarkerForGame(game,
              latOverride: offsetLat,
              lngOverride: offsetLng,
              myGameIds: myGameIds);
        }
      }
    }

  }

  Future<void> _addMarkerForGame(Game game,
      {double? latOverride,
      double? lngOverride,
      required Set<String> myGameIds}) async {
    if (!mounted) return;
    try {
      final isMyGame = myGameIds.contains(game.id);
      // Générer l'image du marqueur
      final markerImage = await _generateMarkerImage(game, isMyGame: isMyGame);
      if (!mounted || markerImage == null) return;

      final lat = latOverride ?? game.latitude;
      final lng = lngOverride ?? game.longitude;

      // Créer l'annotation
      final annotation = await _annotationManager?.create(
        PointAnnotationOptions(
          geometry: Point(coordinates: Position(lng, lat)),
          image: markerImage,
          iconSize: 1.0,
          iconAnchor: IconAnchor.CENTER,
        ),
      );

      if (annotation != null) {
        _annotationToGame[annotation.id] = game;
      }
    } catch (e) {
      AppLogger.e('GameMap', 'Erreur création marqueur pour ${game.id}', e);
    }
  }

  Future<Uint8List?> _generateMarkerImage(Game game,
      {bool isMyGame = false}) async {
    const double size = 60;
    const double borderWidth = 4;

    // Couleur de la bordure : dorée pour mes parties, sinon selon le statut
    final borderColor =
        isMyGame ? const Color(0xFFFFD700) : game.effectiveStatus.markerColor;

    try {
      // Télécharger l'image de profil
      final response = await http.get(Uri.parse(game.creator.avatar));
      if (response.statusCode != 200) {
        return _generatePlaceholderMarker(borderColor, size, borderWidth);
      }

      // Décoder l'image
      final codec = await ui.instantiateImageCodec(response.bodyBytes);
      final frame = await codec.getNextFrame();
      final avatarImage = frame.image;

      // Créer le canvas pour dessiner le marqueur
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Dessiner le cercle de fond (bordure)
      final borderPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        const Offset(size / 2, size / 2),
        size / 2,
        borderPaint,
      );

      // Dessiner l'ombre
      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(
        const Offset(size / 2, size / 2 + 2),
        size / 2 - borderWidth,
        shadowPaint,
      );

      // Clipper en cercle pour l'avatar
      final clipPath = Path()
        ..addOval(Rect.fromCircle(
          center: const Offset(size / 2, size / 2),
          radius: size / 2 - borderWidth,
        ));
      canvas.clipPath(clipPath);

      // Dessiner l'avatar
      final srcRect = Rect.fromLTWH(
        0,
        0,
        avatarImage.width.toDouble(),
        avatarImage.height.toDouble(),
      );
      final dstRect = Rect.fromCircle(
        center: const Offset(size / 2, size / 2),
        radius: size / 2 - borderWidth,
      );
      canvas.drawImageRect(avatarImage, srcRect, dstRect, Paint());

      // Finaliser l'image
      final picture = recorder.endRecording();
      final img = await picture.toImage(size.toInt(), size.toInt());
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

      return byteData?.buffer.asUint8List();
    } catch (e) {
      AppLogger.e('GameMap', 'Erreur génération image marqueur', e);
      return _generatePlaceholderMarker(borderColor, size, borderWidth);
    }
  }

  Future<Uint8List?> _generatePlaceholderMarker(
    Color borderColor,
    double size,
    double borderWidth,
  ) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Bordure
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2, borderPaint);

    // Fond gris
    final bgPaint = Paint()
      ..color = const Color(0xFF424242)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size / 2, size / 2),
      size / 2 - borderWidth,
      bgPaint,
    );

    // Icône personne simplifiée
    final iconPaint = Paint()
      ..color = Colors.white70
      ..style = PaintingStyle.fill;
    // Tête
    canvas.drawCircle(Offset(size / 2, size / 2 - 6), 8, iconPaint);
    // Corps
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size / 2, size / 2 + 12),
        width: 20,
        height: 16,
      ),
      iconPaint,
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    return byteData?.buffer.asUint8List();
  }

  Widget _buildLoadingPlaceholder() {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: const LoadingWidget(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final positionAsync = ref.watch(currentPositionProvider);

    return positionAsync.when(
      loading: () => _buildLoadingPlaceholder(),
      error: (_, __) => _buildMap(null),
      data: (position) => _buildMap(position),
    );
  }

  Widget _buildMap(dynamic position) {
    final initialZoom = _distanceToZoom(widget.distanceKm);
    final center = (position != null)
        ? Point(coordinates: Position(position.longitude, position.latitude))
        : Point(coordinates: Position(4.4445, 50.4108)); // fallback : Charleroi

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: MapWidget(
          onMapCreated: _onMapCreated,
          styleUri: MapboxStyles.DARK,
          cameraOptions: CameraOptions(
            center: center,
            zoom: initialZoom,
            pitch: 45,
          ),
        ),
      ),
    );
  }
}

/// Listener pour les clics sur les marqueurs
// ignore: deprecated_member_use
class _MarkerClickListener extends OnPointAnnotationClickListener {
  final Map<String, Game> annotationToGame;
  final void Function(Game game)? onGameTap;

  _MarkerClickListener({
    required this.annotationToGame,
    this.onGameTap,
  });

  @override
  void onPointAnnotationClick(PointAnnotation annotation) {
    final game = annotationToGame[annotation.id];
    if (game != null && onGameTap != null) {
      onGameTap!(game);
    }
  }
}
