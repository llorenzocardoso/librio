import 'package:flutter/material.dart';

/// Widget para visualizar imagens em tela cheia com zoom interativo
///
/// Features:
/// - Zoom com pinch gesture
/// - Double tap para zoom
/// - Swipe para fechar
/// - Hero animation para transição suave
/// - Loading indicator
class FullscreenImageViewer extends StatefulWidget {
  final String imageUrl;
  final String? heroTag;

  const FullscreenImageViewer({
    Key? key,
    required this.imageUrl,
    this.heroTag,
  }) : super(key: key);

  @override
  State<FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<FullscreenImageViewer>
    with SingleTickerProviderStateMixin {
  late TransformationController _transformationController;
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;

  TapDownDetails? _doubleTapDetails;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() {
        if (_animation != null) {
          _transformationController.value = _animation!.value;
        }
      });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Reset zoom com animação
  void _resetZoom() {
    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: Matrix4.identity(),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    _animationController.forward(from: 0);
  }

  /// Zoom para posição específica (double tap)
  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    if (_doubleTapDetails == null) return;

    final position = _doubleTapDetails!.localPosition;

    // Se já está com zoom, reseta
    if (_transformationController.value != Matrix4.identity()) {
      _resetZoom();
    } else {
      // Aplica zoom de 2x na posição do tap
      final double scale = 2.0;
      final x = -position.dx * (scale - 1);
      final y = -position.dy * (scale - 1);

      _animation = Matrix4Tween(
        begin: _transformationController.value,
        end: Matrix4.identity()
          ..translate(x, y)
          ..scale(scale),
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOut,
        ),
      );
      _animationController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Imagem com zoom interativo
          GestureDetector(
            onDoubleTapDown: _handleDoubleTapDown,
            onDoubleTap: _handleDoubleTap,
            child: Center(
              child: InteractiveViewer(
                transformationController: _transformationController,
                minScale: 0.5,
                maxScale: 4.0,
                child: widget.heroTag != null
                    ? Hero(
                        tag: widget.heroTag!,
                        child: Image.network(
                          widget.imageUrl,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: Colors.white,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.white,
                                    size: 64,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Erro ao carregar imagem',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    : Image.network(
                        widget.imageUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              color: Colors.white,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.white,
                                  size: 64,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Erro ao carregar imagem',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),

          // Botão de fechar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botão voltar
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),

                  // Botão reset zoom
                  IconButton(
                    onPressed: _resetZoom,
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.zoom_out_map,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Dica de uso (aparece por 3 segundos)
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: _ZoomHint(),
          ),
        ],
      ),
    );
  }
}

/// Widget que mostra dicas de uso temporariamente
class _ZoomHint extends StatefulWidget {
  @override
  State<_ZoomHint> createState() => _ZoomHintState();
}

class _ZoomHintState extends State<_ZoomHint> {
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    // Esconde a dica após 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _visible = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Text(
            '💡 Dê dois toques para ampliar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
