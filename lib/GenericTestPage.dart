import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class GenericTestPage extends StatefulWidget {
  final String jsonPath;
  final String collectionName;

  const GenericTestPage({
    super.key,
    required this.jsonPath,
    required this.collectionName
  });

  @override
  State<GenericTestPage> createState() => _GenericTestPageState();
}

class _GenericTestPageState extends State<GenericTestPage> {
  List<dynamic> _questions = [];
  Map<String, dynamic> _results = {};
  List<Map<String, dynamic>> _answerLog = [];

  int _currentIndex = 0;
  final Map<String, int> _scores = {
    "E": 0, "I": 0, "S": 0, "N": 0, "T": 0, "F": 0, "J": 0, "P": 0
  };

  @override
  void initState() {
    super.initState();
    _loadJson();
  }

  Future<void> _loadJson() async {
    try {
      print("📂 파일 로딩 시작: ${widget.jsonPath}");

      String jsonString = await rootBundle.loadString(widget.jsonPath);
      print("📂 파일 내용 읽기 성공 (길이: ${jsonString.length})");

      Map<String, dynamic> data = jsonDecode(jsonString);
      print("📂 JSON 파싱 성공");

      setState(() {
        _questions = data['questions'];
        if (data.containsKey('results')) {
          _results = data['results'];
        }
      });
      print("✅ 데이터 적용 완료: 질문 ${_questions.length}개");

    } catch (e) {
      print("❌ 에러 발생: $e");
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("오류 발생"),
            content: Text("파일을 불러오지 못했어요.\n\n경로: ${widget.jsonPath}\n\n이유: $e"),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("확인")
              )
            ],
          ),
        );
      }
    }
  }

  void _onAnswerSelected(Map<String, dynamic> answer) {
    setState(() {
      String type = answer['type'];

      if (_scores.containsKey(type)) {
        _scores[type] = _scores[type]! + 1;
      } else {
        _scores[type] = 1;
      }

      _answerLog.add({
        "question": _questions[_currentIndex]['question'],
        "selected_answer": answer['text'],
        "type": type
      });

      if (_currentIndex < _questions.length - 1) {
        _currentIndex++;
      } else {
        _showResult();
      }
    });
  }

  void _showResult() {
    String resultKey = "";
    try {
      resultKey += (_scores["E"]! >= _scores["I"]!) ? "E" : "I";
      resultKey += (_scores["S"]! >= _scores["N"]!) ? "S" : "N";
      resultKey += (_scores["T"]! >= _scores["F"]!) ? "T" : "F";
      resultKey += (_scores["J"]! >= _scores["P"]!) ? "J" : "P";
    } catch (e) {
      var sortedKeys = _scores.keys.toList(growable: false)
        ..sort((k1, k2) => _scores[k2]!.compareTo(_scores[k1]!));
      if (sortedKeys.isNotEmpty) {
        resultKey = sortedKeys.first;
      }
    }

    Map<String, dynamic> resultData = _results[resultKey] ?? {
      "animal": "결과 없음",
      "description": "분석 결과가 없습니다.",
      "famous": []
    };
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => UniversalResultPage(
          testResult: resultKey,
          info: resultData,
          answerLog: _answerLog,
          collectionName: widget.collectionName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFFE3F2FD),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    var currentQ = _questions[_currentIndex];
    double progress = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: Stack(
        children: [
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black54),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.white,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                            minHeight: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        "${_currentIndex + 1}/${_questions.length}",
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),

                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                "Q.${_currentIndex + 1}",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.blue[100],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                currentQ['emoji'] ?? '🤔',
                                style: const TextStyle(fontSize: 60),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                currentQ['question'],
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        ...(currentQ['answers'] as List).asMap().entries.map((entry) {
                          var answer = entry.value;
                          String optionLabel = entry.key == 0 ? "A" : "B";
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: GestureDetector(
                              onTap: () => _onAnswerSelected(answer),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: Colors.blue[50],
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          optionLabel,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueAccent,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        answer['text'],
                                        style: const TextStyle(
                                          fontSize: 17,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: 20),
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
class UniversalResultPage extends StatefulWidget {
  final String testResult;
  final Map<String, dynamic> info;
  final List<Map<String, dynamic>> answerLog;
  final String collectionName;


  const UniversalResultPage({
    super.key,
    required this.testResult,
    required this.info,
    required this.answerLog,
    required this.collectionName,
  });

  @override
  State<UniversalResultPage> createState() => _UniversalResultPageState();
}

class _UniversalResultPageState extends State<UniversalResultPage> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _saveToFirestore();
    _loadAd();
  }

  Future<void> _saveToFirestore() async {
    print("🔥 [${widget.collectionName}] 저장 시작...");
    try {
      await FirebaseFirestore.instance.collection(widget.collectionName).add({
        'result': widget.testResult,
        'animal': widget.info['animal'],
        'answers_detail': widget.answerLog,
        'created_at': FieldValue.serverTimestamp(),
      });
      print("✅ 저장 성공! [${widget.collectionName}] 확인하세요.");
    } catch (e) {
      print("❌ 저장 실패: $e");
    }
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
      ),
    )..load();
  }

  void _shareKakao() async {
    final FeedTemplate defaultFeed = FeedTemplate(
      content: Content(
        title: '나의 테스트 결과는?',
        description: '당신은 ${widget.info['animal']} 유형인 ${widget.testResult} 입니다!',
        imageUrl: Uri.parse('https://cdn-icons-png.flaticon.com/512/1046/1046283.png'),
        link: Link(
            androidExecutionParams: {},
            iosExecutionParams: {}
        ),
      ),
      buttons: [
        Button(
          title: '결과 확인하기',
          link: Link(
            androidExecutionParams: {},
            iosExecutionParams: {},
          ),
        ),
      ],
    );

    try {
      if (await ShareClient.instance.isKakaoTalkSharingAvailable()) {
        await ShareClient.instance.shareDefault(template: defaultFeed);
      } else {
        Uri shareUrl = await WebSharerClient.instance.makeDefaultUrl(template: defaultFeed);
        await launchBrowserTab(shareUrl, popupOpen: true);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> famousPeople = widget.info['famous'] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE3F2FD),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "테스트 결과",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        leading: const SizedBox(),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black54),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      widget.testResult,
                      style: const TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.w900,
                        color: Colors.blueAccent,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blueAccent.withOpacity(0.3), width: 1),
                      ),
                      child: Text(
                        widget.info['animal'] ?? '',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "📝 성격 특징",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            widget.info['description'] ?? '',
                            style: const TextStyle(
                              fontSize: 17,
                              height: 1.6,
                              color: Color(0xFF444444),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                    if (famousPeople.isNotEmpty) ...[
                      const Text(
                        "같은 유형의 유명인 ✨",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      const SizedBox(height: 15),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: famousPeople.map((person) {
                          return Chip(
                            label: Text(person),
                            backgroundColor: Colors.white,
                            labelStyle: const TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold,
                            ),
                            side: BorderSide(color: Colors.blue.withOpacity(0.1)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            elevation: 0,
                          );
                        }).toList(),
                      ),
                    ],

                    const SizedBox(height: 50),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black54,
                              elevation: 0,
                              side: const BorderSide(color: Colors.grey),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text("홈으로"),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _shareKakao,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFEE500),
                              foregroundColor: Colors.black87,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chat_bubble, size: 18),
                                SizedBox(width: 8),
                                Text("공유하기", style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
            if (_isLoaded)
              Container(
                alignment: Alignment.center,
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
          ],
        ),
      ),
    );
  }
}