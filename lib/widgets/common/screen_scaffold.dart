import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// A scaffold whose body sits on the app's subtle top-to-bottom green gradient.
class GradientScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool extendBody;
  final bool extendBodyBehindAppBar;

  const GradientScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.extendBody = true,
    this.extendBodyBehindAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppPalette.of(context).isDark;
    return Container(
      decoration: BoxDecoration(gradient: AppGradients.screen(isDark)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: appBar,
        extendBody: extendBody,
        extendBodyBehindAppBar: extendBodyBehindAppBar,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
        bottomNavigationBar: bottomNavigationBar,
        body: body,
      ),
    );
  }
}

/// A frosted glass app bar title row with optional leading/trailing.
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget> actions;
  final bool centerTitle;

  const GlassAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions = const [],
    this.centerTitle = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: centerTitle,
      backgroundColor: Colors.transparent,
      leading: leading,
      titleSpacing: leading == null ? 20 : 0,
      title: titleWidget ??
          (title == null
              ? null
              : Text(title!, style: AppText.heading(context, size: 20))),
      actions: actions,
    );
  }
}

/// A circular glass back button for detail screens.
class GlassBackButton extends StatelessWidget {
  final Color? iconColor;
  const GlassBackButton({super.key, this.iconColor});

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: GestureDetector(
        onTap: () => Navigator.of(context).maybePop(),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: palette.cardStrong,
            shape: BoxShape.circle,
            border: Border.all(color: palette.border),
          ),
          child: Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: iconColor ?? palette.textPrimary),
        ),
      ),
    );
  }
}
