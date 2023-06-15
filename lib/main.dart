import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:usage_stats/usage_stats.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HuwyHomePage(),
    );
  }
}

class HuwyHomePage extends StatefulWidget {
  @override
  _HuwyHomePageState createState() => _HuwyHomePageState();
}


class YouTubeAPI {
  static const String apiKey = 'AIzaSyAlghT05EMmyvvr_7rGcN7dRGHKg8fU8lM';

  static Future<List<Map<String, dynamic>>> fetchPlaylistsFromUser() async {
    var url = 'https://www.googleapis.com/youtube/v3/playlists?' +
        'part=snippet,id&maxResults=30&' +
        'key=$apiKey&' +
        'channelId=UCFfALXX0DOx7zv6VeR5U_Bg';

    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var items = jsonData['items'] as List<dynamic>;
      return items.map<Map<String, dynamic>>((item) => item).toList();
    } else {
      throw Exception('Failed to load playlists');
    }
  }
}



class _HuwyHomePageState extends State<HuwyHomePage> {

  List<UsageInfo> usageInfoList = []; // 사용량 정보를 저장할 리스트

  var _combineUsage;


  late Future<List<Map<String, dynamic>>> _videoListFuture;

  List<String> displayedSentences = [];

  @override
  void initState() {
    super.initState();


    refreshSentences();

    _videoListFuture = YouTubeAPI.fetchPlaylistsFromUser();
  }

  Future<void> refreshSentences() async {
    await Future.delayed(Duration(seconds: 1)); // 새로고침 지연 시간 설정
    await initUsage();

    List<String> sentences = [
      '읽을 수 있었던 책${(_combineUsage/300).round()}권',
      '벌 수 있는 돈 ${(_combineUsage/60 * 9620).round()}원',
      '런닝을 했다면 ${(_combineUsage/60 * 13).round()}KM',
      '유튜브 시청중 호흡 수 ${(_combineUsage*12).round()}회',
      '연애 0회',
      '축구 연습했을 때 넣을 수 있었을 골 수 ${(_combineUsage/105 *2.53).round()}개',
      '이동한 회전초밥 거리 ${(_combineUsage/4).round()}바퀴',
      '청소 횟수 ${(_combineUsage/84).round()}번',
      '롤을 했다면 ${(_combineUsage/28).round()}판',
      '휴대폰 풀 충전 횟수 ${(_combineUsage/90).round()}번',
      '받을 수 있는 택배 수 ${(_combineUsage/2880).round()}번',
      '끓인 컵라면 수 ${(_combineUsage/3).round()}개',
      '강아지 산책 횟수 ${(_combineUsage/60).round()}번',
    ];

    setState(() {
      displayedSentences.clear();

      // 문장 목록에서 무작위로 4개 선택
      sentences.shuffle();
      displayedSentences = sentences.sublist(0, 5);
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
        _combineUsage = (totalForegroundTime / 1000 / 60).round();
      });
    } catch (err) {
      print(err);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      backgroundColor: Color(0xFF7F7F7F),
      body: Column(
        children: [
          Container(
            height: 49,
          ),
          Row(

            children:[Container(
              height: 39,
              width: 107,
              margin: EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.red, // 배경색 설정
                borderRadius: BorderRadius.circular(10.0), // 테두리 모서리를 둥글게 설정
              ),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "HUWY",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 35.0, // 폰트 크기 조절
                    fontWeight: FontWeight.bold, // 폰트 두껍게 설정 (선택사항)
                  ),
                ),
              ),
            ),
              Expanded(
                child: Container(
                  height: 39,

                ),
              ),
              Container(
                height: 39,
                margin: EdgeInsets.symmetric(horizontal: 16.0),
                child: IconButton(
                  onPressed: UsageStats.grantUsagePermission,
                  icon: Icon(Icons.settings),
                ),
              ),

            ]
          ),
          Container(
            height: 750,
          margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: Colors.black,
              width: 0.1
              ,
            ),
          ),
          child: RefreshIndicator(
            onRefresh: refreshSentences,
            child: ListView(
              padding: EdgeInsets.only(top: 6.0),
              children: [
                Container(
                    margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 3.0),
                    height: 80,
                    decoration: BoxDecoration(
                      color: Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: ListTile(
                      title: Align(
                        alignment: Alignment.center,
                        child: Text("지난 1년간 핸드폰으로 유튜브를 본 시간\n ${_combineUsage/60/24}일 ${_combineUsage/60%24}시간 ${_combineUsage%60}분",textAlign: TextAlign.center,style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),)
                      ),
                    ),
                ),
                Container(
                  height: 2.0,
                  margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: Color(0xFFF2F2F2),
                    borderRadius: BorderRadius.circular(20.0),
                  ), // 회색 선의 색상 설정
                ),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 0.0),
                  title: Container(
                    margin: EdgeInsets.symmetric(horizontal: 16.0),
                    padding: EdgeInsets.symmetric(vertical: 0.0), // 상하 여백을 없애기 위한 설정
                    child: Text(
                      "당신이 놓친 것들",
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                for (var sentence in displayedSentences)
                  Container(
                    height: 49,
                    margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
                    decoration: BoxDecoration(
                      color: Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: ListTile(
                      title: Text(sentence,textAlign: TextAlign.center,
                        style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),),
                    ),
                  ),
                Container(
                  height: 2.0,
                  margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: Color(0xFFF2F2F2),
                    borderRadius: BorderRadius.circular(20.0),
                  ), // 회색 선의 색상 설정
                ),
                ListTile(
                  title: Text("추천영상",
                    style: TextStyle(
                      fontSize: 20.0, // 폰트 크기 조절
                      fontWeight: FontWeight.bold, // 폰트 두껍게 설정 (선택사항)
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: _videoListFuture,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          var videos = snapshot.data!;
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: videos.map((video) {
                                var thumbnailUrl = video['snippet']['thumbnails']['default']['url'];
                                var title = video['snippet']['title']; // 동영상의 ID를 가져옴
                                var playlistId = video['id']; // 재생목록 ID를 가져옴

                                return InkWell(
                                  onTap: () {
                                    var youtubeUrl = 'https://www.youtube.com/playlist?list=$playlistId';
                                    launch(youtubeUrl); // YouTube 재생목록 링크 열기
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(horizontal: 2.5, vertical: 5.0),
                                    width: 200.0,
                                    height: 200.0,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Image.network(thumbnailUrl),
                                        SizedBox(height: 8.0),
                                        Text("\n"),
                                        Text(
                                          title,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 4.0),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Failed to load videos'),
                          );
                        }
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        ],
      ),
    );
  }
}