import 'package:flutter/material.dart';

class FaqTile extends StatefulWidget {
  final String question;
  final String answer;

  const FaqTile({super.key, required this.question, required this.answer});

  @override
  State<FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<FaqTile> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
      ),
      child: ExpansionTile(
        shape: Border(),
        trailing: Icon(
          isExpanded ? Icons.remove : Icons.add,
          color: Colors.red,
          size: 22.0,
        ),
        onExpansionChanged:
            (value) => setState(() {
              isExpanded = value;
            }),
        tilePadding: EdgeInsets.only(left: 15, right: 15),
        childrenPadding: EdgeInsets.only(left: 15, right: 15, bottom: 15),
        title: Text(
          widget.question,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        children: [
          Text(
            widget.answer,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF626262),
            ),
          ),
        ],
      ),
    );
  }
}
