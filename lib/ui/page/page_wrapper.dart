import 'package:annix/ui/page/page.dart';
import 'package:flutter/material.dart';

typedef AnnixPageBuilder = Widget Function();

class AnnixPageWrapper extends AnnixPage {
  @override
  final String route;
  final AnnixPageBuilder page;

  const AnnixPageWrapper({super.key, required this.route, required this.page});

  @override
  Widget build(BuildContext context) {
    return page();
  }
}
