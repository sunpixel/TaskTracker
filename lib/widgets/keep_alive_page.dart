import 'package:flutter/widgets.dart';

/// Keeps [child] alive even when scrolled off-screen in a [PageView].
///
/// Without this, a [PageView] may dispose a page's subtree once it's far
/// enough from the viewport — which would reset each tab's nested
/// [Navigator] (its push stack) and any screen state whenever you switch
/// away and back.
class KeepAlivePage extends StatefulWidget {
  final Widget child;

  const KeepAlivePage({super.key, required this.child});

  @override
  State<KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // required by AutomaticKeepAliveClientMixin
    return widget.child;
  }
}
