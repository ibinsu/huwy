import 'package:flutter/material.dart';
import 'dart:async';
import 'package:usage_stats/usage_stats.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<EventUsageInfo> events = []; // 이벤트 정보를 저장할 리스트
  Map<String?, NetworkInfo?> _netInfoMap = Map(); // 네트워크 정보를 저장할 맵

  @override
  void initState() {
    super.initState();

    initUsage(); // 앱 실행 시 사용량 초기화 함수 호출
  }

  Future<void> initUsage() async {
    try {
      UsageStats.grantUsagePermission(); // 사용량 퍼미션 획득

      DateTime endDate = new DateTime.now();
      DateTime startDate = endDate.subtract(Duration(days: 1));

      List<EventUsageInfo> queryEvents =
      await UsageStats.queryEvents(startDate, endDate); // 이벤트 정보 쿼리
      List<NetworkInfo> networkInfos = await UsageStats.queryNetworkUsageStats(
        startDate,
        endDate,
        networkType: NetworkType.all,
      ); // 네트워크 사용량 정보 쿼리

      Map<String?, NetworkInfo?> netInfoMap = Map.fromIterable(networkInfos,
          key: (v) => v.packageName, value: (v) => v); // 네트워크 정보 맵 생성

      List<UsageInfo> t = await UsageStats.queryUsageStats(startDate, endDate); // 사용량 정보 쿼리

      for (var i in t) {
        if (i.packageName == "com.google.android.youtube") { // packageName이 "com.google.android.youtube"인 경우에만 출력
          if (double.parse(i.totalTimeInForeground!) > 0) {
            print(
                DateTime.fromMillisecondsSinceEpoch(int.parse(i.firstTimeStamp!))
                    .toIso8601String());

            print(DateTime.fromMillisecondsSinceEpoch(int.parse(i.lastTimeStamp!))
                .toIso8601String());

            print(i.packageName);
            print(DateTime.fromMillisecondsSinceEpoch(int.parse(i.lastTimeUsed!))
                .toIso8601String());
            print(int.parse(i.totalTimeInForeground!) / 1000 / 60);

            print('-----\n');
          }
        }
      }


      this.setState(() {
        events = queryEvents.reversed.toList(); // 이벤트 정보 리스트 업데이트
        _netInfoMap = netInfoMap; // 네트워크 정보 맵 업데이트
      });
    } catch (err) {
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Usage Stats"), actions: [
          IconButton(
            onPressed: UsageStats.grantUsagePermission, // 퍼미션 획득 버튼 클릭 시 퍼미션 획득 함수 호출
            icon: Icon(Icons.settings),
          )
        ]),
        body: Container(
          child: RefreshIndicator(
            onRefresh: initUsage, // 새로고침 시 사용량 초기화 함수 호출
            child: ListView.separated(
              itemBuilder: (context, index) {
                var event = events[index];
                var networkInfo = _netInfoMap[event.packageName];
                return ListTile(
                  title: Text(events[index].packageName!), // 앱 패키지 이름 출력
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          "Last time used: ${DateTime.fromMillisecondsSinceEpoch(int.parse(events[index].timeStamp!)).toIso8601String()}"), // 마지막 사용 시간 출력
                      networkInfo == null
                          ? Text("Unknown network usage") // 네트워크 정보가 없는 경우
                          : Text("Received bytes: ${networkInfo.rxTotalBytes}\n" +
                          "Transfered bytes : ${networkInfo.txTotalBytes}"), // 네트워크 정보 출력
                    ],
                  ),
                  trailing: Text(events[index].eventType!), // 이벤트 유형 출력
                );
              },
              separatorBuilder: (context, index) => Divider(),
              itemCount: events.length, // 리스트 아이템 개수
            ),
          ),
        ),
      ),
    );
  }
}

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
