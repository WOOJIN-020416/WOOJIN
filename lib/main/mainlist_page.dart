import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import '../GenericTestPage.dart';
import '../sub/question_page.dart';

class MainListPage extends StatefulWidget {
  const MainListPage({super.key});

  @override
  State<MainListPage> createState() => _MainListPageState();
}

class TestCard extends StatelessWidget {
  final String title;
  final String description;
  final String emoji;
  final VoidCallback onTap;

  const TestCard({
    super.key,
    required this.title,
    required this.description,
    required this.emoji,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 28)),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 18, color: Colors.grey[300]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MainListPageState extends State<MainListPage> {
  List<dynamic> _quizList = [];
  final List<String> _emojis = ['🧩', '💖', '🐶', '🤯', '☕', '🎨', '🎵'];

  @override
  void initState() {
    super.initState();
    _loadList();
  }

  Future<void> _loadList() async {
    String jsonString = await rootBundle.loadString('res/api/list.json');
    Map<String, dynamic> data = jsonDecode(jsonString);
    setState(() {
      _quizList = data['questions'];
    });
  }

  void _logout() async {
    try {
      await UserApi.instance.unlink();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    } catch (error) {
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE3F2FD),
        elevation: 0,
        centerTitle: false,
        title: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(
            '성격 유형 테스트',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w800,
              fontSize: 22,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black54),
            onPressed: _logout,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        itemCount: _quizList.length,
        itemBuilder: (context, index) {
          var item = _quizList[index];
          String fileName = item['file'];

          return TestCard(
            title: item['title'],
            description: item['desc'] ?? '터치해서 테스트를 시작해보세요!',
            emoji: _emojis[index % _emojis.length],
            onTap: () async {

              if (fileName == 'mbti') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GenericTestPage(
                      jsonPath: 'res/api/$fileName.json',
                      collectionName: '${fileName}_results',
                    ),
                  ),
                );
              } else {
                String jsonString = await rootBundle.loadString('res/api/$fileName.json');
                Map<String, dynamic> questionData = jsonDecode(jsonString);

                if (!mounted) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuestionPage(
                      question: questionData,
                      collectionName: '${fileName}_results',
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}