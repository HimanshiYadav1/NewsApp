import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:newsapp/models/newsapp.dart';
import 'package:url_launcher/url_launcher.dart';


String API_KEY ='7a3ea0a3cd264f53b7eb72752afdf510';

Future<List<Article>> fetchArticleBySource(String source) async{
  final response = await http.get('https://newsapi.org/v2/top-headlines?sources=$source&apiKey=$API_KEY');

  if (response.statusCode==200){
    List articles=json.decode(response.body)['articles'];
    return articles.map((article)=>new Article.fromJson(article)).toList();
  }
  else{
    throw Exception('Failed to load source list');
  }

}


class ArticleScreen extends StatefulWidget {
  
  final Source source;

  ArticleScreen({Key key,this.source}):super(key: key);

  @override
State<StatefulWidget> createState()=>ArticleScreenState();

  
}

class ArticleScreenState extends State<ArticleScreen>{
  var list_articles;
  var refreshKey = GlobalKey<RefreshIndicatorState>();

@override
  void initState(){
    refreshListArticle();
  }

@override
Widget build(BuildContext context){
    return MaterialApp(
      title: 'NEWS',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: Scaffold(
        appBar: AppBar(title: Text(widget.source.name)),
        body: Center(
          child: RefreshIndicator(
            key: refreshKey,
            child: FutureBuilder<List<Article>>(
              future:list_articles,
              builder:(context,snapshot){
                if(snapshot.hasError){
                  return Text('Error:${snapshot.error}');
                }
                else if(snapshot.hasData){
                  List<Article>articles = snapshot.data;
                  return new ListView(
                    children: articles.map((article) => GestureDetector(
                      onTap: (){
                        _launchurl(article.url);
                      },
                      child: Card(
                        elevation: 1.0,
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 0.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 20.0,horizontal: 4.0),
                              width: 100.0,
                              height: 100.0,
                              child: article.urlToImage != Null ? Image.network(article.urlToImage):Image.asset('assets/news.png'),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Container(
                                          margin: const EdgeInsets.only(left: 10.0,top: 20.0,bottom: 10.0),
                                          child: Text('${article.title}',style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold),
                                                                                      
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(left: 8.0),
                                    child: Text('${article.description}',style: TextStyle(fontSize:16.0,fontWeight: FontWeight.bold,color: Colors.grey),),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(left: 8.0,top: 10.0,bottom: 10.0),
                                    child: Text('PublishedAt:${article.publishedAt}',style: TextStyle(fontSize:12.0,fontWeight: FontWeight.bold,color: Colors.black12),),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    )).toList()
                  );
                }
                return CircularProgressIndicator();
              } 
            ),
            onRefresh: refreshListArticle
        ),
      ),         
    ),
  );
    
}



Future<Null> refreshListArticle() async{
    refreshKey.currentState?.show(atTop: false);
    
    
    setState(() {
     list_articles = fetchArticleBySource(widget.source.id); 
    });

    return null;
  }
}


void _launchurl(String url) async {
  if(await canLaunch(url)){
    await launch(url);
  }
  else {
    throw('Couldnot launch $url');
  }
}
