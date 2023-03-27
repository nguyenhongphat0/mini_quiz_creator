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
                      width: 240,
                      child: Card(
                        clipBehavior: Clip.hardEdge,
                        margin: EdgeInsets.all(0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.0),
                            bottomLeft: Radius.circular(20.0),
                          ),
                        ),
                        child: SubmissionList(
                          quizzes: snapshot.data,
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

class SubmissionList extends StatelessWidget {
  final List<dynamic> quizzes;

  const SubmissionList({
    super.key,
    required this.quizzes,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CreatorState>(builder: (context, creator, child) {
      return FutureBuilder(
          future: supabase.from("gmat_submissions").select<List<dynamic>>().eq(
              'quiz_id',
              quizzes[Provider.of<CreatorState>(context, listen: false)
                  .selectedQuizIndex]['id']),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                snapshot.data == null) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }
            return NavigationDrawer(
              selectedIndex: creator.selectedSubmissionIndex,
              onDestinationSelected: (value) {
                creator.selectedSubmissionIndex = value;
                creator.replaceAnswerList(snapshot.data![value]['answers']);
              },
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
                  child: Text(
                    "Submissions",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                ...snapshot.data!.map(
                  (submission) => NavigationDrawerDestination(
                    icon: CircleAvatar(
                        foregroundImage: NetworkImage(submission['avatar'])),
                    label: SizedBox(
                      width: 135,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(submission['display_name']),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                                "Score: ${submission['score']}/${submission['total_score']} | ${getMinutesDiff(submission)}"),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            );
          });
    });
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
                                child: QuestionDetail(
                              question: creator.questions[id]!,
                            )),
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
  get quizQuestions {
    final index =
        Provider.of<CreatorState>(context, listen: false).selectedQuizIndex;
    return (jsonDecode(widget.quizzes[index]['question_ids']) as List)
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
          selectedIndex: creator.selectedQuizIndex,
          onDestinationSelected: (value) {
            creator.selectedQuizIndex = value;
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
