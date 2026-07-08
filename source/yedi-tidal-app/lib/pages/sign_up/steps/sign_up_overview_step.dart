import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/sign_up/bloc/pages/sign_up_pages_bloc.dart';
import 'package:yedi_app/modules/sign_up/bloc/pages/sign_up_pages_event.dart';
import 'package:yedi_app/modules/sign_up/bloc/pages/sign_up_pages_state.dart';
import 'package:yedi_app/pages/sign_up/steps/ui/step_page_title.dart';

class SignUpOverviewStep extends StatelessWidget {
  const SignUpOverviewStep({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.read<SignUpPagesBloc>().state;
    if (state is! SignUpPagesLoaded) {
      throw Exception("Unknown state: $state");
    }
    final currentPage = state.currentPage;

    return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            StepPageTitle(title: currentPage.title),
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: state.overviewPages.length,
              itemBuilder: (context, index) {
                final page = state.overviewPages[index];
                return ListTile(
                  title: Text(
                    page.title,
                    style: TextStyle(fontSize: 16),
                  ),
                  trailing: Text(
                    page.timeToComplete,
                    style: TextStyle(color: Color(0xFF606060), fontSize: 14),
                  ),
                  contentPadding: EdgeInsets.only(
                    top: 20,
                    bottom: 20,
                  ),
                );
              },
              separatorBuilder: (context, index) => Divider(
                color: Colors.black,
                height: 1,
              ),
            ),
            Row(
              children: [
                Expanded(
                    child: ElevatedButton(
                        onPressed: () {
                          context
                              .read<SignUpPagesBloc>()
                              .add(SignUpPagesOverviewCompleted());
                        },
                        child: Text("Next Step"))),
              ],
            )
          ],
        ));
  }
}
