import 'package:flutter/material.dart';

const String GMAT_DATABASE_URL =
    "https://teddyfullstack.github.io/gmat-database";
const String GMAT_QUESTION_BANK_URL =
    "https://teddyfullstack.github.io/gmat_question_bank";

const double narrowScreenWidthThreshold = 450;
const double mediumWidthBreakpoint = 1000;
const double largeWidthBreakpoint = 1500;
const double transitionLength = 500;

enum ColorSeed {
  baseColor('Default', Colors.pink),
  indigo('Indigo', Colors.indigo),
  blue('Blue', Colors.blue),
  teal('Teal', Colors.teal),
  green('Green', Colors.green),
  yellow('Yellow', Colors.yellow),
  orange('Orange', Colors.deepOrange),
  deepOrange('Red', Colors.red),
  red('Purple', Color(0xff6750a4));

  const ColorSeed(this.label, this.color);
  final String label;
  final Color color;
}
