import 'package:flutter/material.dart';
import 'package:huwy/collecting_time.dart';
import 'dart:async';
import 'package:usage_stats/usage_stats.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {

  @override
  _MyAppState createState() => _MyAppState();
  Widget build(BuildContext context) {

    Future<Database> database = initDatabase();

    return MaterialApp(
      home: DatabaseApp(),
    );
  }
  Future<Database> initDatabase() async{
    return openDatabase(
      join(await getDatabasesPath(), 'collectingtime_database.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE (id INTEGER PRIMARY KEY AUTONCREMENT, "
              "title TEXT, content TEXT, active INTEGER)",
        );
      },
      version: 1,
    );
  }
}

class DatabaseApp extends StatefulWidget {

  final Future<Database> db;
  DatabaseApp(this.db);

  @override
  State<StatefulWidget> createState() => _DatabaseApp();
}

class _DatabaseApp extends State<DatabaseApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}

void thistime() {

}


void _insertTime(Collectingtime collectingtime) async {
  final Database database = await widget.db;
  await database.insert('collectingtimes', collectingtime.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace);
}

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
      DateTime startDate = endDate.subtract(Duration(days: 1));

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
          title: const Text("Usage Stats"),
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
                      Text("Total Usage Time: ${int.parse(usageInfo.totalTimeInForeground!) / 1000 / 60} minutes"), // 총 사용 시간 출력
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
