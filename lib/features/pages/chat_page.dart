import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/shared/widgets/common_app_bar.dart';
import 'package:kfon_subscriber/core/constant/app_assets.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';

class ChatPage extends StatefulWidget {
  final String pageHeading;

  const ChatPage({super.key, required this.pageHeading});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Widget _createChatWidget(String message, String name, bool isOwnMessage) {
    return Align(
      alignment: isOwnMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: ShapeDecoration(
          color: isOwnMessage ? AppColor.kPrimaryColor : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: isOwnMessage
                ? BorderRadius.circular(20)
                : const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: name.isEmpty ? 1 : 4,
          children: [
            name.isEmpty
                ? Container(width: 0)
                : Text(
                    name,
                    style: TextStyle(
                      color: isOwnMessage
                          ? AppColor.kLightSkyBlue
                          : AppColor.kStoneGrey,
                      fontSize: 12,
                      fontFamily: 'General Sans',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
            Text(
              message,
              style: TextStyle(
                color: isOwnMessage ? Colors.white : AppColor.kCharcoalDark,
                fontSize: 14,
                fontFamily: 'General Sans',
                fontWeight: FontWeight.w400,
                height: 1.43,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CommonAppBar(
      onBackPressed: () => Navigator.pop(context),
      title: widget.pageHeading,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ListView(
              children: <Widget>[
                _createChatWidget('Hey Lucas!', 'Brooke', false),
                _createChatWidget('How\'s your project going?', '', false),
                _createChatWidget('Hi Brooke!', 'Lucas', true),
                _createChatWidget(
                  'It\'s going well. Thanks for asking!',
                  '',
                  true,
                ),
                _createChatWidget(
                  'No worries. Let me know if you need any help 😉',
                  'Brooke',
                  false,
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 16.w,
                        height: 16.h,
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(),
                        child: Icon(
                          Icons.add,
                          size: 16.sp,
                          color: AppColor.kPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(
                      top: 8,
                      left: 16,
                      right: 6,
                      bottom: 8,
                    ),
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      color: AppColor.kGhostWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(71),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _messageController,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "You're the bes",
                                    hintStyle: TextStyle(
                                      color: AppColor.kCharcoalDark,
                                      fontSize: 14,
                                      fontFamily: 'General Sans',
                                      fontWeight: FontWeight.w400,
                                      height: 1.43,
                                    ),
                                    contentPadding: EdgeInsets.zero,
                                    isDense: true,
                                  ),
                                  style: TextStyle(
                                    color: AppColor.kCharcoalDark,
                                    fontSize: 14,
                                    fontFamily: 'General Sans',
                                    fontWeight: FontWeight.w400,
                                    height: 1.43,
                                  ),
                                  textAlignVertical: TextAlignVertical.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 32.w,
                          height: 32.h,
                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            color: AppColor.kPrimaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(38),
                            ),
                          ),
                          child: InkWell(
                            onTap: () {},
                            child: Center(
                              child: SvgPicture.asset(
                                AppAssets.chatSend,
                                width: 12.w,
                                height: 12.h,
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
