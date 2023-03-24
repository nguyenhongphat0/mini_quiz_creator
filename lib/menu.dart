import 'package:flutter/material.dart';

final List<NavigationDestination> appBarDestinations = [
  NavigationDestination(
    tooltip: '',
    icon: Icon(Icons.generating_tokens_outlined),
    label: 'Build Quiz',
    selectedIcon: Icon(Icons.generating_tokens),
  ),
  NavigationDestination(
    tooltip: '',
    icon: Icon(Icons.view_list_outlined),
    label: 'View Submission',
    selectedIcon: Icon(Icons.view_list),
  ),
];
