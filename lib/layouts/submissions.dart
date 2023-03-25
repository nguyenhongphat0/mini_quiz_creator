import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mini_quiz_creator/main.dart';
import 'package:mini_quiz_creator/state/creator.dart';
import 'package:mini_quiz_creator/utils.dart';
import 'package:mini_quiz_creator/widgets/question_detail.dart';
import 'package:provider/provider.dart';

class SubmissionsScreen extends StatefulWidget {
  @override
  State<SubmissionsScreen> createState() => _SubmissionsScreenState();
}

class _SubmissionsScreenState extends State<SubmissionsScreen> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        children: [
          FutureBuilder(
              future: supabase
                  .from('gmat_quizzes')
                  .select()
                  .order('created_at', ascending: false),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }
                return Row(
                  children: [
                    SizedBox(
                        width: 240, child: QuizSidebar(quizzes: snapshot.data)),
                    Expanded(child: SubmissionPreview()),
                    SizedBox(
                      width: 200,
                      child: Card(
                        clipBehavior: Clip.hardEdge,
                        margin: EdgeInsets.all(0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.0),
                            bottomLeft: Radius.circular(20.0),
                          ),
                        ),
                        child: NavigationDrawer(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(28, 16, 16, 10),
                              child: Text(
                                "Submissions",
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                            NavigationDrawerDestination(
                                icon: Icon(Icons.pets), label: Text("Teddy"))
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                child:
                    Consumer<CreatorState>(builder: (context, creator, child) {
                  return StatefulBuilder(builder: (context, setState) {
                    return FloatingActionButton.extended(
                      label: Text("Copy Quiz Link"),
                      icon: Icon(Icons.copy),
                      onPressed: () async {},
                    );
                  });
                }),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class SubmissionPreview extends StatelessWidget {
  SubmissionPreview({
    super.key,
  });

  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Consumer<CreatorState>(
      builder: (context, creator, child) => creator.submissionLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                  ...creator.dbQuestionIds.map(
                    (id) {
                      return Container(
                        key: ValueKey(id),
                        margin: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 8.0),
                              child: CircleAvatar(
                                child: Text(
                                    "${creator.dbQuestionIds.indexOf(id) + 1}"),
                              ),
                            ),
                            Expanded(
                              child: creator.questions.containsKey(id)
                                  ? QuestionDetail(
                                      question: creator.questions[id]!,
                                    )
                                  : FutureBuilder(
                                      future: creator.loadQuestion(id),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Center(
                                              child:
                                                  CircularProgressIndicator());
                                        } else if (snapshot.hasError) {
                                          return Center(
                                              child: Text(
                                                  'Error: ${snapshot.error}'));
                                        } else {
                                          final question = snapshot.data!;
                                          WidgetsBinding.instance
                                              .addPostFrameCallback(
                                                  (timeStamp) {
                                            scrollController.animateTo(
                                              scrollController
                                                  .position.maxScrollExtent,
                                              duration:
                                                  Duration(milliseconds: 500),
                                              curve: Curves.easeOut,
                                            );
                                          });
                                          return QuestionDetail(
                                            question: question,
                                          );
                                        }
                                      },
                                    ),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
    );
  }
}

class QuizSidebar extends StatefulWidget {
  final List<dynamic> quizzes;

  const QuizSidebar({super.key, required this.quizzes});

  @override
  State<QuizSidebar> createState() => _QuizSidebarState();
}

class _QuizSidebarState extends State<QuizSidebar> {
  int _selectedQuizIndex = 0;

  get quizQuestions {
    return (jsonDecode(widget.quizzes[_selectedQuizIndex]['question_ids'])
            as List)
        .map((id) => "$id")
        .toList();
  }

  @override
  void initState() {
    super.initState();
    Provider.of<CreatorState>(context, listen: false)
        .replaceQuestionList(quizQuestions);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CreatorState>(builder: (context, creator, child) {
      return NavigationDrawer(
          selectedIndex: _selectedQuizIndex,
          onDestinationSelected: (value) {
            setState(() {
              _selectedQuizIndex = value;
            });
            creator.replaceQuestionList(quizQuestions);
          },
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
              child: Text(
                "Quizzes",
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            ...widget.quizzes.map((quiz) => NavigationDrawerDestination(
                icon: Tooltip(
                  message:
                      "${(jsonDecode(quiz['question_ids']) as List).length} questions, created by ${quiz['author']}",
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.timer_outlined),
                      Container(
                        margin: EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(100)),
                        child: SizedBox(
                          width: 14,
                          height: 14,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "${quiz['duration']}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                label: SizedBox(
                  width: 160,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            quiz['name'],
                            maxLines: 1,
                          )),
                      Text(
                        getDaysAgo(quiz['created_at']),
                        maxLines: 1,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ))),
          ]);
    });
  }
}
