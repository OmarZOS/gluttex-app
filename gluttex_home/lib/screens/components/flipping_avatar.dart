import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class FlippingAvatar extends StatefulWidget {
  final String? imageUrl;
  final String qrData;
  final double size;
  final Color borderColor;
  final Color backgroundColor;

  const FlippingAvatar({
    Key? key,
    required this.imageUrl,
    required this.qrData,
    this.size = 100,
    this.borderColor = Colors.blue,
    this.backgroundColor = Colors.white,
  }) : super(key: key);

  @override
  State<FlippingAvatar> createState() => _FlippingAvatarState();
}

class _FlippingAvatarState extends State<FlippingAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showFront = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  void _toggle() {
    if (_showFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      _showFront = !_showFront;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Stack(
            children: [
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001) // Perspective
                      ..rotateY(
                          _animation.value * 3.14159), // 180 degrees in radians
                    alignment: Alignment.center,
                    child: _showFront ? _buildFrontFace() : _buildBackFace(),
                  );
                },
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: GestureDetector(
                  onTap: _toggle,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      _showFront ? Icons.qr_code_2 : Icons.person,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              )
            ],
          )),
    );
  }

  Widget _buildFrontFace() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: widget.borderColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: widget.size,
        backgroundColor: widget.backgroundColor,
        child: widget.imageUrl != null
            ? ClipOval(
                child: Image.network(
                  widget.imageUrl!,
                  width: widget.size * 2,
                  height: widget.size * 2,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholder();
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: widget.size * 2,
                      height: widget.size * 2,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildBackFace() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: widget.borderColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: widget.size,
        backgroundColor: widget.backgroundColor,
        child: Padding(
          padding: EdgeInsets.all(widget.size * 0.1),
          child: QrImageView(
            data: widget.qrData,
            version: QrVersions.auto,
            size: widget.size * 1.5,
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: Colors.black,
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: Colors.black,
            ),
            // Add a scan animation overlay
            embeddedImage: const AssetImage('assets/images/scan_icon.png'),
            embeddedImageStyle: QrEmbeddedImageStyle(
              size: Size(widget.size * 0.3, widget.size * 0.3),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Icon(
      Icons.person,
      size: widget.size * 0.8,
      color: Colors.grey[600],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
