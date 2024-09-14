import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:mxc_ui/mxc_ui.dart';

class Tweet extends StatefulWidget {
  const Tweet(
      {super.key,
      required this.tweetId,
      required this.isDark,
      required this.height,
      required this.checkMaxHeight,
      required this.isFirstItem});

  final String tweetId;
  final bool isDark;
  final double height;
  final Function(double) checkMaxHeight;
  final bool isFirstItem;

  @override
  State<Tweet> createState() => _TweetState();
}

class _TweetState extends State<Tweet> {
  late bool isLoaded;

  @override
  void initState() {
    super.initState();
    isLoaded = false;
  }

  @override
  Widget build(BuildContext context) {
    double? height;
    return Container(
      margin: EdgeInsetsDirectional.only(
          start: widget.isFirstItem
              ? 0
              : MediaQuery.of(context).size.width > 600
                  ? 16
                  : Sizes.spaceXSmall),
      width: 320,
      height: widget.height,
      child: Stack(
        children: [
          Container(
            height: height,
            alignment: Alignment.topCenter,
            child: Theme(
              data: MxcTheme.of(context).toThemeData().copyWith(
                    visualDensity: VisualDensity.adaptivePlatformDensity,
                  ),
              child: InAppWebView(
                initialUrlRequest: URLRequest(
                    url: Uri.dataFromString(
                  getHtmlString(widget.tweetId, widget.isDark),
                  mimeType: 'text/html',
                  encoding: Encoding.getByName('utf-8'),
                )),
                onWebViewCreated: (controller) {
                  controller.addJavaScriptHandler(
                    handlerName: 'twitterHeightChannel',
                    callback: (args) {
                      setState(() {
                        isLoaded = true;
                        final previewHeight = double.parse(args[0].toString());
                        height = previewHeight;
                        widget.checkMaxHeight(height ?? 0);
                      });
                    },
                  );
                },
                initialOptions: InAppWebViewGroupOptions(
                    crossPlatform:
                        InAppWebViewOptions(transparentBackground: true)),
              ),
            ),
          ),
          SizedBox(
            height: widget.height * 0.5,
            width: 320,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(
                  milliseconds: 300,
                ),
                child: isLoaded
                    ? const SizedBox.shrink()
                    : Container(
                        height: double.maxFinite,
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                          color: ColorsTheme.of(context).layerSheetBackground,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                        ),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String getHtmlString(String tweetId, bool isDark) {
  final String theme = isDark ? 'dark' : 'light';
  return """
      <html>
      
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <style>
           
            *{box-sizing: border-box;margin:0px; padding:0px;}
              #container {
                        display: flex;
                        justify-content: top;
                        margin: 0 auto;
                        max-width: 100%;
                        max-height: 100%;
                    }      
          </style>
        </head>

        <body>

            <div id="container"></div>
                
        </body>

        <script id="twitter-wjs" type="text/javascript" async defer src="https://platform.twitter.com/widgets.js" onload="createMyTweet()"></script>

        <script>
        
       

      function  createMyTweet() {  

         var twtter = window.twttr;
  
         twttr.widgets.createTweet(
          '$tweetId',
          document.getElementById('container'),
          {
            theme: '$theme',
          }
        ).then( function( el ) {
            const widget = document.getElementById('container');
            if (window.flutter_inappwebview.callHandler) {
              window.flutter_inappwebview.callHandler("twitterHeightChannel", widget.clientHeight);
            }
        });
      }

        </script>
        
      </html>
    """;
}
