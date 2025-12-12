import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../detail/detail_page.dart';

class QuestionPage extends StatefulWidget {
  final Map<String, dynamic> question;
  final String collectionName; // 🔥 추가됨

  const QuestionPage({
    super.key,
    required this.question,
    required this.collectionName, // 필수값
  });

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  int? selectedOption;

  @override
  Widget build(BuildContext context) {
    // ... (기존 UI 코드 상단부는 동일) ...
    String title = widget.question['title'] ?? '제목 없음';
    String qText = widget.question['question'] ?? '질문 내용이 없습니다.';
    List<dynamic> selects = widget.question['selects'] ?? [];
    List<dynamic> answers = widget.question['answer'] ?? [];
    List<dynamic> images = widget.question['images'] ?? [];

    return Scaffold(
      // ... (Scaffold 속성 동일) ...
      appBar: AppBar(
        // ... (AppBar 동일) ...
        title: Text(title, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ... (질문 표시 컨테이너 동일) ...
              Container(
                // ... (기존 코드) ...
                child: Column(
                  children: [
                    const Text("Q.", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.blueAccent)),
                    const SizedBox(height: 16),
                    Text(qText, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF333333), height: 1.4), textAlign: TextAlign.center),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              Expanded(
                // ... (ListView.separated 동일) ...
                child: ListView.separated(
                  itemCount: selects.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final isSelected = selectedOption == index;
                    return GestureDetector(
                      onTap: () { setState(() { selectedOption = index; }); },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blueAccent : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isSelected ? Colors.blueAccent : Colors.transparent, width: 2),
                          boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: Row(
                          children: [
                            Expanded(child: Text(selects[index].toString(), style: TextStyle(fontSize: 16, color: isSelected ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500))),
                            if (isSelected) const Icon(Icons.check_circle, color: Colors.white, size: 20),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // 🔥 [버튼 부분 수정]
              ElevatedButton(
                onPressed: selectedOption == null
                    ? null
                    : () async {
                  try {
                    if (!mounted) return;

                    String resultAnswer = "";
                    String resultEmoji = "🍀";

                    if (selectedOption! < answers.length) {
                      resultAnswer = answers[selectedOption!];
                      if (selectedOption! < images.length) {
                        resultEmoji = images[selectedOption!];
                      }
                    }

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPage(
                          question: title,
                          answer: resultAnswer,
                          emoji: resultEmoji,
                          collectionName: widget.collectionName, // 🔥 방 이름 전달!
                        ),
                      ),
                    );
                  } catch (e) {
                    print('Error: $e');
                  }
                },
                // ... (버튼 스타일 동일) ...
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  disabledBackgroundColor: Colors.grey[300],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('결과 보기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}