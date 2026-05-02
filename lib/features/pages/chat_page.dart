import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/shared/widgets/common_app_bar.dart';

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
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: ShapeDecoration(
          color: isOwnMessage ? AppColor.kPrimaryColor : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(isOwnMessage ? 0 : 20),
              bottomLeft: Radius.circular(isOwnMessage ? 20 : 0),
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: name.isEmpty ? 0 : 4,
          children: [
            name.isEmpty
                ? Container(width: 0)
                : Text(
                    name,
                    style: TextStyle(
                      color: isOwnMessage
                          ? const Color(0xFFB3DAFF)
                          : const Color(0xFF71727A),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
            Text(
              message,
              style: TextStyle(
                color: isOwnMessage ? Colors.white : AppColor.kCharcoalDark,
                fontSize: 14,
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
          Padding(
            padding: EdgeInsets.only(
              top: 16.0,
              left: 16.0,
              right: 16.0,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20.0,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.add),
                  iconSize: 20,
                  color: AppColor.kPrimaryColor,
                  padding: EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                  onPressed: () {},
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 6,
                      top: 8,
                      bottom: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FE),
                      borderRadius: BorderRadius.circular(71),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Enter a search term',
                              hintStyle: TextStyle(
                                color: AppColor.kCharcoalDark,
                                fontSize: 14,
                              ),
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                            style: const TextStyle(
                              color: AppColor.kCharcoalDark,
                              fontSize: 14,
                            ),
                            onChanged: (text) {},
                            textAlignVertical: TextAlignVertical.center,
                          ),
                        ),
                        const SizedBox(width: 12),
                        ClipOval(
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColor.kPrimaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {},
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/icons/chat_send.svg',
                                    width: 12,
                                    height: 12,
                                    colorFilter: const ColorFilter.mode(
                                      Colors.white,
                                      BlendMode.srcIn,
                                    ),
                                  ),
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
