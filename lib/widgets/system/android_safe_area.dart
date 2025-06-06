import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget customizado para lidar com SafeArea no Android
/// Resolve problemas com insets do sistema (status bar, navigation bar, display cutout)
class AndroidSafeArea extends StatelessWidget {
  final Widget child;
  final bool maintainBottomViewPadding;
  final bool removeTop;
  final bool removeBottom;
  final bool removeLeft;
  final bool removeRight;
  final Color? backgroundColor;
  
  const AndroidSafeArea({
    super.key,
    required this.child,
    this.maintainBottomViewPadding = false,
    this.removeTop = false,
    this.removeBottom = false,
    this.removeLeft = false,
    this.removeRight = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    // Obtém os insets do sistema
    final EdgeInsets viewInsets = MediaQuery.of(context).viewInsets;
    final EdgeInsets viewPadding = MediaQuery.of(context).viewPadding;
    final EdgeInsets systemPadding = MediaQuery.of(context).padding;
    
    // Log dos insets para debug
    debugPrint('System Insets:');
    debugPrint('  viewInsets: $viewInsets');
    debugPrint('  viewPadding: $viewPadding');
    debugPrint('  systemPadding: $systemPadding');
    
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: backgroundColor ?? Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: SafeArea(
        top: !removeTop,
        bottom: !removeBottom,
        left: !removeLeft,
        right: !removeRight,
        maintainBottomViewPadding: maintainBottomViewPadding,
        child: MediaQuery(
          data: MediaQuery.of(context).removePadding(
            removeTop: removeTop,
            removeBottom: removeBottom,
            removeLeft: removeLeft,
            removeRight: removeRight,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Widget que ajusta automaticamente o padding baseado nos insets do sistema
class AdaptiveSafeArea extends StatelessWidget {
  final Widget child;
  final bool includeStatusBar;
  final bool includeNavigationBar;
  final EdgeInsets additionalPadding;
  
  const AdaptiveSafeArea({
    super.key,
    required this.child,
    this.includeStatusBar = true,
    this.includeNavigationBar = true,
    this.additionalPadding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaQuery = MediaQuery.of(context);
        final double statusBarHeight = includeStatusBar ? mediaQuery.padding.top : 0;
        final double navBarHeight = includeNavigationBar ? mediaQuery.padding.bottom : 0;
        
        // Detecta se há display cutout (notch)
        final bool hasNotch = mediaQuery.padding.top > 40;
        
        // Ajusta padding baseado no tipo de dispositivo
        EdgeInsets safePadding = EdgeInsets.only(
          top: statusBarHeight + additionalPadding.top,
          bottom: navBarHeight + additionalPadding.bottom,
          left: mediaQuery.padding.left + additionalPadding.left,
          right: mediaQuery.padding.right + additionalPadding.right,
        );
        
        // Adiciona padding extra para dispositivos com notch
        if (hasNotch) {
          safePadding = safePadding.copyWith(
            top: safePadding.top + 10, // Padding extra para notch
          );
        }
        
        return Container(
          padding: safePadding,
          child: child,
        );
      },
    );
  }
}
