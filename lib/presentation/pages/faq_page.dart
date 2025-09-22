import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/common/bloc/faq/faq_page_cubit.dart';
import 'package:kfon_subscriber/common/bloc/faq/faq_page_state.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/data/faq/model/faq_question.dart';
import 'package:kfon_subscriber/domain/faq/usecases/faq_search_use_case.dart';
import 'package:kfon_subscriber/presentation/page_component/faq_tile.dart';
import 'package:kfon_subscriber/presentation/ui_component/shimmer_layout.dart';
import 'package:kfon_subscriber/service_locator.dart';
import 'package:kfon_subscriber/util/dialog_util.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  final DialogUtil _dialogUtil = DialogUtil();
  final FaqPageCubit _faqPageCubit = FaqPageCubit();
  final Color _blackColor = Color(0xFF272727);
  final Color _grayColor = Color(0xFFA2A2A2);
  final Color _blueColor = Color(0xFFDFF1FF);
  final Color _greenColor = Color(0xFFE8FFEB);
  final Color _redColor = Color(0xFFFFECEF);
  final TextEditingController _searchController = TextEditingController();
  final List<FaqQuestion> _topQuestions = [];
  bool _canExit = true;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _faqPageCubit.getQuestions(
      keyword: _searchController.text,
      useCase: sl<FaqSearchUseCase>(),
    );
  }

  @override
  void dispose() {
    _faqPageCubit.close();
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void doSearch() {
    if (_searchController.text.isEmpty) return;
    _searchFocusNode.unfocus();
    _faqPageCubit.getQuestions(
      keyword: _searchController.text,
      useCase: sl<FaqSearchUseCase>(),
    );
  }

  Widget _categoryWidget(String title, String icon, Color backgroundColor) {
    return Container(
      width: 150,
      margin: EdgeInsets.symmetric(horizontal: 5),
      child: Card(
        color: backgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/icons/$icon',
                height: 24,
                width: 24,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 15),
              Text(
                'Questions about',
                style: TextStyle(
                  color: Color(0xFF626262),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  color: _blackColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: BackButton(color: Colors.black),
        centerTitle: true,
        title: Text(
          'FAQ',
          style: TextStyle(
            color: _blackColor,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'How can we help you?',
            style: TextStyle(
              color: _blackColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 17.0,
              right: 30,
              left: 30,
              bottom: 30,
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.black, // Sets the text color to blue
              ),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: _grayColor,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: _grayColor),
                  borderRadius: BorderRadius.circular(6.0),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(6.0)),
                  borderSide: BorderSide(color: AppColor.kPrimaryColor),
                ),

                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => doSearch(),
                ),
              ),
              onSubmitted:
                  (value) => doSearch(), // Trigger search on keyboard "Done"
            ),
          ),
          Expanded(
            child: BlocConsumer<FaqPageCubit, FaqPageState>(
              bloc: _faqPageCubit,
              listenWhen:
                  (previousState, currentState) =>
                      currentState is GetQuestionsError ||
                      currentState is GetQuestionsSuccess,
              listener: (context, state) {
                if (state is GetQuestionsError) {
                  _dialogUtil.showMessage(state.errorMessage, context);
                } else if (state is GetQuestionsSuccess) {
                  _canExit = state.showCategory;
                  if (_topQuestions.isEmpty) {
                    _topQuestions.addAll(state.questions);
                  }
                }
              },
              builder: (context, state) {
                return PopScope(
                  canPop: false,
                  onPopInvokedWithResult: (didPop, result) {
                    if (didPop) {
                      return;
                    }
                    if (_canExit) {
                      Navigator.of(context).pop();
                    } else {
                      _searchController.clear();
                      _faqPageCubit.showInitialView(_topQuestions);
                    }
                  },
                  child: Column(
                    children: [
                      state is GetQuestionsSuccess && state.showCategory
                          ? Column(
                            children: [
                              SizedBox(
                                height: 120,
                                child: ListView(
                                  padding: EdgeInsets.only(left: 15),
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    _categoryWidget(
                                      'Getting Started',
                                      'notification_line.png',
                                      _blueColor,
                                    ),
                                    _categoryWidget(
                                      'How to Recharge',
                                      'settings_line.png',
                                      _greenColor,
                                    ),
                                    _categoryWidget(
                                      'Payment Meth…',
                                      'money_line.png',
                                      _redColor,
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 20,
                                  right: 20,
                                  left: 20,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Top Questions',
                                      style: TextStyle(
                                        color: _blackColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed:
                                          () =>
                                              _faqPageCubit.viewAllTopQuestions(
                                                _topQuestions,
                                              ),
                                      child: Text(
                                        'View all',
                                        style: TextStyle(
                                          color: Color(0xFFDF1525),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                          : Container(),
                      Expanded(
                        child: ListView.builder(
                          itemCount:
                              state is GetQuestionsSuccess
                                  ? state.questions.length
                                  : 10,
                          itemBuilder: (BuildContext context, int index) {
                            return state is GetQuestionsSuccess
                                ? FaqTile(
                                  question: state.questions[index].question!,
                                  answer: state.questions[index].answer!,
                                )
                                : state is QuestionLoading
                                ? ShimmerLayout(
                                  child: Container(
                                    height: 100,
                                    color: Colors.grey.shade300,
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                  ),
                                )
                                : Container();
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
