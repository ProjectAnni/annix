import 'package:annix/ui/page/page_wrapper.dart';
import 'package:flutter/material.dart';

abstract class AnnixPage extends StatelessWidget {
  abstract final String route;

  const AnnixPage({super.key});

  factory AnnixPage.wrap({
    required String route,
    required AnnixPageBuilder page,
  }) {
    return AnnixPageWrapper(route: route, page: page);
  }
}
