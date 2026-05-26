import 'package:flutter/material.dart';
import '/core/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static final heading = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static final title = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static final subtitle = GoogleFonts.inter(
    fontSize: 15,
    color: AppColors.textSecondary,
  );

  static final cardTitle = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static final progressLabel = GoogleFonts.inter(
    fontSize: 14,
    color: AppColors.textSecondary,
  );
}
