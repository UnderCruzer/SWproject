import 'package:flutter/material.dart';

class ToggleButtonsWidget extends StatefulWidget {
  final int initialSelection;

  const ToggleButtonsWidget({super.key, required this.initialSelection});

  @override
  State<ToggleButtonsWidget> createState() => _ToggleButtonsWidgetState();
}

class _ToggleButtonsWidgetState extends State<ToggleButtonsWidget> {
  // 각 버튼의 선택 상태를 관리하는 리스트
  late List<bool> _isSelected;

  @override
  void initState() {
    super.initState();
    // 초기 선택 상태 설정 (0: 전체, 1: 국내, 2: 해외)
    _isSelected = [
      widget.initialSelection == 0,
      widget.initialSelection == 1,
      widget.initialSelection == 2,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: ToggleButtons(
        isSelected: _isSelected,
        onPressed: (int index) {
          setState(() {
            // 버튼을 누르면, 해당 버튼만 선택되도록 상태 변경
            for (int i = 0; i < _isSelected.length; i++) {
              _isSelected[i] = (i == index);
            }
          });
        },
        borderRadius: BorderRadius.circular(30),
        borderWidth: 0,
        borderColor: Colors.transparent,
        selectedBorderColor: Colors.transparent,
        fillColor: Colors.white, // 선택된 버튼의 배경색
        selectedColor: Colors.black, // 선택된 버튼의 글자색
        color: Colors.grey, // 선택되지 않은 버튼의 글자색
        constraints: const BoxConstraints(minHeight: 40.0, minWidth: 100.0),
        children: const <Widget>[
          Text('전체'),
          Text('국내'),
          Text('해외'),
        ],
      ),
    );
  }
}
