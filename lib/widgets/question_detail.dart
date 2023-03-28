import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mini_quiz_creator/state/creator.dart';
import 'package:mini_quiz_creator/state/database.dart';
import 'package:mini_quiz_creator/widgets/rich_content.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../models/question.dart';

class QuestionDetail extends StatefulWidget {
  QuestionDetail({super.key, required this.question, this.quizAnswer});

  final Question question;
  final dynamic quizAnswer;

  @override
  State<QuestionDetail> createState() => _QuestionDetailState();
}

class _QuestionDetailState extends State<QuestionDetail> {
  bool showExplanations = false;
  int selectedAnswerIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseState>(
      builder: (context, database, child) =>
          Consumer<CreatorState>(builder: (context, creator, child) {
        return Container(
          child: Container(
            child: FocusTraversalGroup(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        launchUrlString(widget.question.src);
                      },
                      child: RichContent(widget.question.question),
                    ),
                    if (widget.question.answers != null)
                      ListAnswer(
                        answers: widget.question.answers!,
                        value: creator.answers[widget.question.id],
                        quizAnswer: widget.quizAnswer,
                        onChange: (answer) {
                          creator.giveAnswer(widget.question.id, answer);
                        },
                      ),
                    if (widget.question.subQuestions != null)
                      Column(
                        children: List.generate(
                          widget.question.subQuestions?.length ?? 0,
                          (index) {
                            final answers = creator
                                            .answers[widget.question.id] !=
                                        null &&
                                    creator.answers[widget.question.id] != -1
                                ? creator.answers[widget.question.id]
                                : List.generate(
                                    widget.question.subQuestions?.length ?? 0,
                                    (index) => -1);
                            return Column(
                              children: [
                                RichContent(widget
                                    .question.subQuestions![index].question),
                                ListAnswer(
                                  answers: widget
                                      .question.subQuestions![index].answers,
                                  value: answers[index],
                                  quizAnswer: widget.quizAnswer?[index],
                                  onChange: (int subAnswer) {
                                    answers[index] = subAnswer;
                                    creator.giveAnswer(
                                        widget.question.id, answers);
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class ListAnswer extends StatelessWidget {
  ListAnswer(
      {super.key,
      required this.answers,
      required this.value,
      required this.onChange,
      this.quizAnswer});

  final List<String> answers;
  final int value;
  final void Function(int answer) onChange;
  final int? quizAnswer;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(answers.length, (int index) {
        return Card(
          color: quizAnswer == null
              ? (index == value
                  ? Theme.of(context).colorScheme.surfaceVariant
                  : null)
              : (index == quizAnswer
                  ? (index == value
                      ? Colors.green
                      : Theme.of(context).colorScheme.surfaceVariant)
                  : (index == value ? Colors.red : null)),
          child: InkWell(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            onTap: () {
              this.onChange(index);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    child: quizAnswer != null && index == value
                        ? Icon(value == quizAnswer ? Icons.check : Icons.close)
                        : Text(String.fromCharCode(65 + index)),
                  ),
                  SizedBox(
                    width: 8.0,
                  ),
                  Flexible(child: RichContent(answers[index])),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
