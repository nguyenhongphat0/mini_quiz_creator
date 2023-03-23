import 'package:flutter/material.dart';

final List<NavigationDestination> appBarDestinations = [
  NavigationDestination(
    tooltip: '',
    icon: Icon(Icons.generating_tokens_outlined),
    label: 'Build test',
    selectedIcon: Icon(Icons.generating_tokens),
  ),
  NavigationDestination(
    tooltip: '',
    icon: Icon(Icons.view_list_outlined),
    label: 'View submission',
    selectedIcon: Icon(Icons.view_list),
  ),
];
