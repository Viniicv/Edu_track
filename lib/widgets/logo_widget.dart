import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class LogoWidget extends StatelessWidget {
  final double size;
  final bool showText;

  const LogoWidget({
    super.key,
    this.size = 80,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Imagem da logo
        Image.asset(
          'assets/images/logo.png',
          width: size,
          height: size,
          errorBuilder: (context, error, stackTrace) {
            // Caso a imagem não seja encontrada, mostra um ícone padrão
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(size * 0.2),
              ),
              child: Icon(
                Icons.school_rounded,
                size: size * 0.5,
                color: Colors.white,
              ),
            );
          },
        ),
        if (showText) ...[
          const SizedBox(height: 16),
          Text(
            'EDUTRACK',
            style: TextStyle(
              fontSize: size * 0.3,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 2,
            ),
          ),
        ],
      ],
    );
  }
}