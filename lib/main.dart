import 'package:flutter/material.dart';
import 'dart:async';
import 'package:usage_stats/usage_stats.dart';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Huwy',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HuwyHomePage(),
    );
  }
}

class HuwyHomePage extends StatefulWidget {
  @override
  _HuwyHomePageState createState() => _HuwyHomePageState();
}

class _HuwyHomePageState extends State<HuwyHomePage> {

  List<UsageInfo> usageInfoList = []; // 사용량 정보를 저장할 리스트

  var _combineUsage;



  List<String> displayedSentences = [];

  @override
  void initState() {
    super.initState();

    refreshSentences();

  }

  Future<void> refreshSentences() async {
    await Future.delayed(Duration(seconds: 1)); // 새로고침 지연 시간 설정
    await initUsage();

    List<String> sentences = [
      '첫 번째 문장 ${_combineUsage}분',
      '두 번째 문장${_combineUsage}분',
      '세 번째 문장${_combineUsage}분',
      '네 번째 문장${_combineUsage}분',
      '다섯 번째 문장${_combineUsage}분',
      '여섯 번째 문장${_combineUsage}분',
      '일곱 번째 문장${_combineUsage}분',
      '여덟 번째 문장${_combineUsage}분',
      '아홉 번째 문장${_combineUsage}분',
      '열 번째 문장${_combineUsage}분',
    ];

    setState(() {
      displayedSentences.clear();

      // 문장 목록에서 무작위로 4개 선택
      sentences.shuffle();
      displayedSentences = sentences.sublist(0, 4);
    });
  }

  Future<void> initUsage() async {
    try {
      UsageStats.grantUsagePermission(); // 사용량 퍼미션 획득

      DateTime endDate = DateTime.now();
      DateTime startDate = DateTime(endDate.year - 1, endDate.month, endDate.day, 0, 0, 0);

      List<UsageInfo> queryUsageInfoList = await UsageStats.queryUsageStats(startDate, endDate);

      List<UsageInfo> filteredUsageInfoList = queryUsageInfoList
          .where((info) => info.packageName == "com.google.android.youtube")
          .toList();

      int totalForegroundTime = 0;

      for (var usageInfo in filteredUsageInfoList) {
        if (usageInfo.totalTimeInForeground != null) {
          totalForegroundTime += int.parse(usageInfo.totalTimeInForeground!) ;
        }
      }

      setState(() {
        usageInfoList = filteredUsageInfoList.reversed.toList();
        _combineUsage = totalForegroundTime / 1000 / 60;
      });
    } catch (err) {
      print(err);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Huwy'),
      ),
      body: RefreshIndicator(
        onRefresh: refreshSentences, // 새로고침 시 refreshSentences 함수 호출
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: ListView(
            children: [
              for (var sentence in displayedSentences)
                ListTile(
                  title: Text(sentence),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/*
class _MyAppState extends State<MyApp> {
  List<UsageInfo> usageInfoList = []; // 사용량 정보를 저장할 리스트

  @override
  void initState() {
    super.initState();
    initUsage(); // 앱 실행 시 사용량 초기화 함수 호출
  }

  Future<void> initUsage() async {
    try {
      UsageStats.grantUsagePermission(); // 사용량 퍼미션 획득

      DateTime endDate = DateTime.now();
      DateTime startDate = DateTime(2022, 4, 6, 0, 0, 0);


      List<UsageInfo> queryUsageInfoList =
      await UsageStats.queryUsageStats(startDate, endDate); // 사용량 정보 쿼리

      List<UsageInfo> filteredUsageInfoList = queryUsageInfoList
          .where((info) => info.packageName == "com.google.android.youtube")
          .toList(); // "com.google.android.youtube" 패키지 이름에 해당하는 사용량 정보 필터링

      this.setState(() {
        usageInfoList = filteredUsageInfoList.reversed.toList(); // 사용량 정보 리스트 업데이트
      });
    } catch (err) {
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: UsageStats.grantUsagePermission,
              icon: Icon(Icons.settings),
            )
          ],
        ),
        body: Container(
          child: RefreshIndicator(
            onRefresh: initUsage,
            child: ListView.separated(
              itemBuilder: (context, index) {
                var usageInfo = usageInfoList[index];
                return ListTile(
                  title: Text(usageInfo.packageName!), // 앱 패키지 이름 출력
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("firstTimeStamp:${DateTime.fromMillisecondsSinceEpoch(int.parse(usageInfo.firstTimeStamp!)).toIso8601String()}lastTimeStamp:${DateTime.fromMillisecondsSinceEpoch(int.parse(usageInfo.lastTimeStamp!)).toIso8601String()} Total Usage Time: ${int.parse(usageInfo.totalTimeInForeground!) / 1000 / 60} minutes"), // 총 사용 시간 출력
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) => Divider(),
              itemCount: usageInfoList.length, // 리스트 아이템 개수
            ),
          ),
        ),
      ),
    );
  }
}
*/
/*
final googleSignIn = GoogleSignIn(
  scopes: [
    'email',
    'https://www.googleapis.com/auth/youtube.readonly',
  ],
);

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Sign-In Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SignInScreen(),
    );
  }
}

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  youtube.YouTubeApi? _youtubeApi;
  GoogleSignInAccount? _googleSignInAccount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Sign-In Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text('Sign In with Google'),
              onPressed: () {
                _handleSignIn(context);
              },
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _handleSignIn(BuildContext context) async {
    try {
      _googleSignInAccount = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await _googleSignInAccount!.authentication;
      _fetchYoutubeVideos();
      final googleSignInAccount = googleSignIn.currentUser;
      if (googleSignInAccount != null) {
        final googleAuth = await googleSignInAccount.authentication;

      }

      _fetchYoutubePlaylist();

      // Google user information
      print('api: ${_youtubeApi}');
      print('Google User ID: ${_googleSignInAccount!.id}');
      print('Google User Email: ${_googleSignInAccount!.email}');

      // Navigate to the account info page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AccountInfoScreen(
            googleSignInAccount: _googleSignInAccount!,
          ),
        ),
      );
    } catch (error) {
      print('Error signing in with Google: $error');
    }
  }


  void _fetchYoutubePlaylist() async {
    if (_youtubeApi != null) {
      try {
        final response = await _youtubeApi!.playlists.list(
          ['snippet,contentDetails'],
          mine: true,
          maxResults: 10,
        );

        final playlists = response.items;
        playlists?.forEach((playlist) {
          print('Playlist ID: ${playlist.id}');
          print('Playlist Title: ${playlist.snippet?.title}');
        });
      } catch (error) {
        print('Error fetching YouTube playlists: $error');
      }
    }
  }

  void _fetchYoutubeVideos() async {
    final googleSignInAccount = googleSignIn.currentUser;
    if (googleSignInAccount != null) {
      final googleAuth = await googleSignInAccount.authentication;

      final client = http.Client();
      final credentialsJson = await rootBundle.loadString('assets/credentials.json');
      final credentials = auth_io.ServiceAccountCredentials.fromJson(json.decode(credentialsJson));
      final authClient = await auth_io.clientViaServiceAccount(
        credentials,
        ['https://www.googleapis.com/auth/youtube.readonly'],
        baseClient: client,
      );

      final youtubeApi = youtube.YouTubeApi(authClient);

      // Set the YouTube API instance to the state
      setState(() {
        _youtubeApi = youtubeApi;
      });
    }
  }


}

class AccountInfoScreen extends StatelessWidget {
  final GoogleSignInAccount googleSignInAccount;

  const AccountInfoScreen({required this.googleSignInAccount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account Information'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Google User ID: ${googleSignInAccount.id}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Google User Email: ${googleSignInAccount.email}',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
*/


/*

class CircleData {
  late double value;
  late Color color;
  late String label;

  CircleData(this.value, this.color, this.label);
}

class PieChart extends StatelessWidget {
  final List<CircleData> data;

  PieChart(this.data);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomPaint(
          size: Size.square(200.0),
          painter: PieChartPainter(data),
        ),
        SizedBox(height: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: data.map((circle) {
            return Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  color: circle.color,
                ),
                SizedBox(width: 4),
                Text('${circle.label}: ${circle.value}'),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

class PieChartPainter extends CustomPainter {
  final List<CircleData> data;

  PieChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    double total = 0;
    data.forEach((circle) => total += circle.value);

    double startRadian = 0;
    for (var circle in data) {
      double sweepRadian = (circle.value / total) * 2 * pi;

      final paint = Paint()
        ..color = circle.color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromLTWH(0, 0, size.width, size.height),
        startRadian,
        sweepRadian,
        true,
        paint,
      );

      startRadian += sweepRadian;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}


void main(){


  runApp(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: PieChart([
            CircleData(30, Colors.red, 'Red'),
            CircleData(50, Colors.green, 'Green'),
            CircleData(20, Colors.blue, 'Blue'),
          ]),
        ),
      ),
    ),
  );
}
*/