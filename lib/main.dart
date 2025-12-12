  import 'package:flutter/material.dart';
  import 'package:flutter/services.dart';
  import 'package:firebase_core/firebase_core.dart';
  import 'package:google_mobile_ads/google_mobile_ads.dart';
  import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
  import 'firebase_options.dart';
  import 'main/mainlist_page.dart';

  void main() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await MobileAds.instance.initialize();

    KakaoSdk.init(nativeAppKey: 'c55188c3ae999eb97a003f68eb18884d');

    runApp(const MyApp());
  }

  class MyApp extends StatelessWidget {
    const MyApp({super.key});

    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        title: 'PersonalityTest',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const LoginPage(),
      );
    }
  }

  class LoginPage extends StatefulWidget {
    const LoginPage({super.key});

    @override
    State<LoginPage> createState() => _LoginPageState();
  }

  class _LoginPageState extends State<LoginPage> {
    void _handleKakaoLogin() async {
      if (await AuthApi.instance.hasToken()) {
        try {
          await UserApi.instance.accessTokenInfo();

          if (!mounted) return;
          print('기존 토큰으로 자동 로그인 성공');
          _navigateToMain();
          return;
        } catch (error) {
          print('토큰 유효성 체크 실패(재로그인 필요): $error');
        }
      }

      try {
        bool isInstalled = await isKakaoTalkInstalled();
        OAuthToken token;

        if (isInstalled) {
          try {
            token = await UserApi.instance.loginWithKakaoTalk();
          } catch (error) {
            if (error is PlatformException && error.code == 'CANCELED') {
              return;
            }
            token = await UserApi.instance.loginWithKakaoAccount();
          }
        } else {
          token = await UserApi.instance.loginWithKakaoAccount();
        }

        print('로그인 성공 ${token.accessToken}');
        if (!mounted) return;
        _navigateToMain();

      } catch (error) {
        print('로그인 실패 $error');
      }
    }

    void _navigateToMain() {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainListPage()),
      );
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: const Color(0xFFE3F2FD),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.2),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Text("☁️", style: TextStyle(fontSize: 80)),
                    ),
                    const SizedBox(height: 40),

                    const Text(
                      "나만의 성격 테스트",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.blueAccent,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "MBTI부터 심리 테스트까지!",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 50),
                child: InkWell(
                  onTap: _handleKakaoLogin,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE500),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          offset: const Offset(0, 4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          'https://developers.kakao.com/assets/img/about/logos/kakaolink/kakaolink_btn_medium.png',
                          width: 24,
                          height: 24,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "카카오로 시작하기",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }