// import 'dart:io';
import 'package:intl/intl.dart';
// import 'package:webfeed/domain/media/description.dart';
import 'package:xml/xml.dart';
import 'package:flutter/material.dart';
import 'package:webfeed/webfeed.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
// import 'dart:developer';

void printXmlElement(XmlElement element, [String indent = '  ']) {
  print('$indent${element.name}: ${element.text.trim()}');

  for (var child in element.children) {
    if (child is XmlElement) {
      printXmlElement(child, '$indent  ');
    }
  }
}

class RSSDemo extends StatefulWidget {
  //
  RSSDemo() : super();

  final String title = 'RSS Feed Demo';

  @override
  RSSDemoState createState() => RSSDemoState();
}

class RSSDemoState extends State<RSSDemo> {
  //
  // static const String FEED_URL =
  //     'https://www.nasa.gov/rss/dyn/lg_image_of_the_day.rss';
  // final Uri FEED_URL =
  //     Uri.https('nasa.gov', 'rss/dyn/lg_image_of_the_day.rss', {'limit': '10'});
  // https://www.channelnewsasia.com/api/v1/rss-outbound-feed?_format=xml&category=6511
  final Uri FEED_URL = Uri.https('channelnewsasia.com',
      'api/v1/rss-outbound-feed?_format=xml&category=6511', {'limit': '10'});
  RssFeed _feed = RssFeed();
  String _title = "";
  static const String loadingFeedMsg = 'Loading Feed...';
  static const String feedLoadErrorMsg = 'Error Loading Feed.';
  static const String feedOpenErrorMsg = 'Error Opening Feed.';
  static const String placeholderImg = "https://placehold.co/600x400/png";
  late GlobalKey<RefreshIndicatorState> _refreshKey;

  updateTitle(title) {
    setState(() {
      if (_title != String) {
        _title = "Not found";
      }
      _title = title;
    });
  }

  updateFeed(feed) {
    setState(() {
      _feed = feed;
    });
  }

  Future<void> openFeed(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: true,
        forceWebView: false,
      );
      return;
    }
    updateTitle(feedOpenErrorMsg);
  }

  load() async {
    updateTitle(loadingFeedMsg);
    loadFeed().then((result) {
      if (result.toString().isEmpty) {
        updateTitle(feedLoadErrorMsg);
        return;
      }
      updateFeed(result);
      updateTitle(_feed.title);
    });
  }

  Future<RssFeed?> loadFeed() async {
    try {
      final client = http.Client();
      final response = await client.get(FEED_URL as Uri);
      // print(RssFeed.parse(response.body));
      final object = RssFeed.parse(response.body);
      // if (response.statusCode == 200) {
      //   final object = XmlDocument.parse(response.body);
      //   printXmlElement(object.rootElement!);
      // } else {
      //   print('Failed to fetch data: ${response.statusCode}');
      // }
      // sleep(Duration(seconds: 2));
      return object;
    } catch (e) {
      print(e);
      return RssFeed();
    }
  }

  @override
  void initState() {
    super.initState();
    _refreshKey = GlobalKey<RefreshIndicatorState>();
    updateTitle(widget.title);
    load();
  }

  title(title) {
    if (title == null) {
      return Text("Title not found");
    }
    return Text(
      title,
      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Description(description) {
    // if (description != String) {
    //   return Text("Subtitle not found");
    // }
    return Text(
      // description,
      DateFormat("yyyy-MM-dd hh:mm:ss").format(description),
      style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.w400),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  thumbnail(imageUrl) {
    if (imageUrl == null) {
      return Padding(
        padding: EdgeInsets.only(left: 15.0),
        child: CachedNetworkImage(
          placeholder: (context, url) => Image.network(placeholderImg),
          imageUrl: placeholderImg,
          height: 100,
          width: 90,
          alignment: Alignment.center,
          fit: BoxFit.fill,
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.only(left: 15.0),
        child: CachedNetworkImage(
          placeholder: (context, url) => Image.network(placeholderImg),
          imageUrl: imageUrl,
          height: 100,
          width: 90,
          alignment: Alignment.center,
          fit: BoxFit.fill,
        ),
      );
    }
  }

  rightIcon() {
    return Icon(
      Icons.keyboard_arrow_right,
      color: Colors.grey,
      size: 30.0,
    );
  }

  list() {
    return ListView.builder(
      itemCount: _feed.items?.length,
      itemBuilder: (BuildContext context, int index) {
        final item = _feed.items![index];
        return ListTile(
            title: title(item.title),
            subtitle: Description(item.pubDate),
            leading: thumbnail(item.media!.thumbnails!.first
                .url), // wtf man... why is this like this...
            trailing: rightIcon(),
            contentPadding: EdgeInsets.all(5.0),
            // onTap: () => openFeed(item.link!),
            onTap: () => {
                  showModalBottomSheet<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                          height: 200,
                          // color: Colors.amber,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const Text('Modal BottomSheet'),
                                ElevatedButton(
                                  child: const Text('Close BottomSheet'),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                          ),
                        );
                      })
                });
      },
    );
  }

  isFeedEmpty() {
    return null == _feed || null == _feed.items;
  }

  body() {
    return isFeedEmpty()
        ? Center(
            child: CircularProgressIndicator(),
          )
        : RefreshIndicator(
            key: _refreshKey,
            child: list(),
            onRefresh: () => load(),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
      ),
      body: body(),
    );
  }
}
