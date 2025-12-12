import 'package:flutter/material.dart';

/// Responsive breakpoints for consistent design
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  static const double wide = 1800;
}

/// Responsive utility class
class Responsive {
  final BuildContext context;
  final MediaQueryData mediaQuery;

  Responsive(this.context) : mediaQuery = MediaQuery.of(context);

  double get width => mediaQuery.size.width;
  double get height => mediaQuery.size.height;
  
  bool get isMobile => width < Breakpoints.mobile;
  bool get isTablet => width >= Breakpoints.mobile && width < Breakpoints.tablet;
  bool get isDesktop => width >= Breakpoints.tablet && width < Breakpoints.desktop;
  bool get isWide => width >= Breakpoints.desktop;
  
  bool get isMobileOrTablet => width < Breakpoints.tablet;
  bool get isDesktopOrWide => width >= Breakpoints.tablet;

  /// Get responsive padding
  EdgeInsets get screenPadding => EdgeInsets.symmetric(
    horizontal: isMobile ? 16 : isTablet ? 24 : 40,
    vertical: isMobile ? 16 : 24,
  );

  /// Get responsive font size
  double fontSize(double mobile, [double? tablet, double? desktop]) {
    if (isMobile) return mobile;
    if (isTablet) return tablet ?? mobile * 1.2;
    return desktop ?? mobile * 1.4;
  }

  /// Get responsive spacing
  double spacing(double mobile, [double? tablet, double? desktop]) {
    if (isMobile) return mobile;
    if (isTablet) return tablet ?? mobile * 1.5;
    return desktop ?? mobile * 2;
  }

  /// Get grid cross axis count
  int gridCrossAxisCount({
    int mobile = 1,
    int? tablet,
    int? desktop,
    int? wide,
  }) {
    if (isMobile) return mobile;
    if (isTablet) return tablet ?? 2;
    if (isDesktop) return desktop ?? 3;
    return wide ?? 4;
  }
}

/// Extension for easy access
extension ResponsiveExtension on BuildContext {
  Responsive get responsive => Responsive(this);
}

