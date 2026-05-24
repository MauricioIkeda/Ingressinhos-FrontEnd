import 'package:flutter/material.dart';

class IngressinhosScaffold extends StatelessWidget {
  const IngressinhosScaffold({
    super.key,
    this.appBar,
    this.drawer,
    this.backgroundColor,
    this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.resizeToAvoidBottomInset,
    this.safeAreaTop,
    this.safeAreaBottom = true,
  });

  final PreferredSizeWidget? appBar;
  final Widget? drawer;
  final Color? backgroundColor;
  final Widget? body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool? resizeToAvoidBottomInset;
  final bool? safeAreaTop;
  final bool safeAreaBottom;

  @override
  Widget build(BuildContext context) {
    final resolvedTop = safeAreaTop ?? appBar == null;

    return Scaffold(
      appBar: appBar,
      drawer: drawer,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      body: body == null
          ? null
          : SafeArea(
              top: resolvedTop,
              bottom: safeAreaBottom,
              child: body!,
            ),
    );
  }
}
