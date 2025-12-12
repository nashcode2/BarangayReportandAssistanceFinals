import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'constants.dart';

/// UI Helper utilities for consistent design across the app
class UIHelpers {
  /// Get responsive padding based on platform
  static EdgeInsets getScreenPadding(BuildContext context) {
    if (kIsWeb) {
      final width = MediaQuery.of(context).size.width;
      if (width > 1200) {
        return const EdgeInsets.symmetric(horizontal: 80, vertical: 40);
      } else if (width > 800) {
        return const EdgeInsets.symmetric(horizontal: 40, vertical: 32);
      }
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 24);
    }
    return const EdgeInsets.symmetric(horizontal: 20, vertical: 16);
  }

  /// Get max width constraint for web
  static BoxConstraints getMaxWidthConstraint() {
    return const BoxConstraints(maxWidth: 1400);
  }

  /// Get card elevation based on platform
  static double getCardElevation() {
    return kIsWeb ? 2.0 : 0.0;
  }

  /// Get border radius for cards
  static double getCardBorderRadius() {
    return 20.0;
  }

  /// Get section spacing
  static double getSectionSpacing() {
    return kIsWeb ? 40.0 : 24.0;
  }

  /// Build a loading widget with message
  static Widget buildLoadingWidget({String? message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build an empty state widget
  static Widget buildEmptyState({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textLight,
                ),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action,
            ],
          ],
        ),
      ),
    );
  }

  /// Build a section header
  static Widget buildSectionHeader({
    required String title,
    String? actionLabel,
    VoidCallback? onActionTap,
  }) {
    return Padding(
      padding: kIsWeb
          ? const EdgeInsets.symmetric(horizontal: 0, vertical: 8)
          : const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: kIsWeb ? 24 : 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          if (actionLabel != null && onActionTap != null)
            TextButton(
              onPressed: onActionTap,
              child: Text(
                actionLabel,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Build a polished card widget
  static Widget buildCard({
    required Widget child,
    EdgeInsets? padding,
    Color? backgroundColor,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: getCardElevation(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(getCardBorderRadius()),
      ),
      color: backgroundColor ?? Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(getCardBorderRadius()),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(20),
          child: child,
        ),
      ),
    );
  }

  /// Build a status chip
  static Widget buildStatusChip(String status) {
    Color color;
    switch (status) {
      case AppConstants.statusResolved:
        color = AppColors.success;
        break;
      case AppConstants.statusInProgress:
        color = AppColors.secondary;
        break;
      case AppConstants.statusPending:
      default:
        color = AppColors.warning;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

