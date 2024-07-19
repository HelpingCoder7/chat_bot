import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:record/record.dart';

class ChatPage extends StatefulWidget {
  static const routeName = '/chat';
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  void initState() {
    super.initState();
    _initilize();
  }

  Future<void> _initilize() async {
    var status = await Permission.microphone;

    if (await status.isGranted) {
      print("Access granted");
    } else {
      print("NO ACCESS TO AUDIO");
    }
  }

  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _chatHistory = [];
  bool isRecording = false;
  // final record = AudioRecorder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Chat",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          SizedBox(
            //get max height
            height: MediaQuery.of(context).size.height - 160,
            child: ListView.builder(
              itemCount: _chatHistory.length,
              shrinkWrap: false,
              controller: _scrollController,
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.only(
                      left: 14, right: 14, top: 10, bottom: 10),
                  child: Align(
                    alignment: (_chatHistory[index]["isSender"]
                        ? Alignment.topRight
                        : Alignment.topLeft),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        color: (_chatHistory[index]["isSender"]
                            ? const Color(0xFFF69170)
                            : Colors.white),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: _chatHistory[index]["isLoading"]
                          ? _startLoader()
                          : Text(_chatHistory[index]["message"],
                              style: TextStyle(
                                  fontSize: 15,
                                  color: _chatHistory[index]["isSender"]
                                      ? Colors.white
                                      : Colors.black)),
                    ),
                  ),
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              height: 60,
              width: double.infinity,
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        border: GradientBoxBorder(
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFF69170),
                                Color(0xFF7D96E6),
                              ]),
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(50.0)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: TextField(
                          onChanged: (value) {
                            setState(() {});
                          },
                          decoration: const InputDecoration(
                            hintText: "Type a message",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(8.0),
                          ),
                          controller: _chatController,
                          maxLines: null, // Allow multiple lines of input
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 4.0,
                  ),
                  GestureDetector(
                    onLongPress: () async {
                      if (_chatController.text.isEmpty) {
                        // Start recording audio

                        // if (await record.hasPermission()) {
                        //   // Start recording to file
                        //   // await record.start(const RecordConfig(),
                        //       // path: 'aFullPath/myFile.m4a');
                        //   // ... or to stream
                        //   // final stream =
                        //   //     await record.startStream(const RecordConfig());
                        // }
                        print("Recording audio...");
                      }
                    },
                    onLongPressEnd: (_) async {
                      if (_chatController.text.isEmpty) {
                        // Stop recording audio
                        // Implement your audio stop logic here
                        // Stop recording...
                        // final path = await record.stop();
                        // print("Stopped recording audio..." + path!);
                      }
                    },
                    child: GestureDetector(
                      onLongPressStart: (_) async {
                        if (_chatController.text.isEmpty) {
                          // Start recording audio
                          setState(() {
                            isRecording = true;
                          });

                          // Check and request permission if needed
                          // if (await record.hasPermission()) {
                          // Start recording to file
                          // await record.start(const RecordConfig(),
                          //     path: 'aFullPath/myFile.m4a');
                          // // ... or to stream
                          // final stream =
                          //     await record.startStream(const RecordConfig());
                          // }
                          print("Recording audio...");
                        }
                      },
                      onLongPressEnd: (_) async {
                        if (_chatController.text.isEmpty) {
                          // Stop recording audio
                          setState(() {
                            isRecording = false;
                          });
                          // Stop recording...
                          // final path = await record.stop();
                          // print("Stopped recording audio..." + path!);
                          print("Stopped recording audio...");
                        }
                      },
                      onHorizontalDragUpdate: (details) {
                        if (isRecording && details.delta.dx < 10) {
                          setState(() {
                            isRecording = false;
                          });
                          print("Stopped recording audio by sliding...");
                        }
                      },
                      child: MaterialButton(
                        onPressed: () {
                          setState(() {
                            if (_chatController.text.isNotEmpty) {
                              _chatHistory.add({
                                "time": DateTime.now(),
                                "message": _chatController.text,
                                "isSender": true,
                                "isLoading": false
                              });
                              _chatController.clear();
                              getAnswer();
                            }
                          });
                          _scrollController.jumpTo(
                            _scrollController.position.maxScrollExtent,
                          );
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(80.0)),
                        padding: const EdgeInsets.all(0.0),
                        child: Ink(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFF69170),
                                  Color(0xFF7D96E6),
                                ]),
                            borderRadius:
                                BorderRadius.all(Radius.circular(50.0)),
                          ),
                          child: Container(
                            constraints: const BoxConstraints(
                                minWidth: 88.0,
                                minHeight:
                                    36.0), // min sizes for Material buttons
                            alignment: Alignment.center,
                            child: Icon(
                              _chatController.text.isEmpty
                                  ? Icons.mic
                                  : Icons.send,
                              color: Colors.white,
                            ),
                          ),
                        ),
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

  void getAnswer() async {
    const url =
        "https://generativelanguage.googleapis.com/v1beta2/models/chat-bison-001:generateMessage?key=AIzaSyD5C-Lh-QkwvjHlpd6f7FiJYhlsOd2DLYA";
    final uri = Uri.parse(url);
    List<Map<String, String>> msg = [
      {'content': 'hi'},
      {'content': 'hello ,I am a chat bot how can i help you....'},
      {
        'content':
            'What makes Jessup Cellars unique compared to other tasting rooms in Yountville?'
      },{'content':'if question was asked out of the list'},
      {
        'content':
            'Jessup Cellars has a casual and inviting atmosphere and was the first tasting room opened in Yountville in 2003. You have the option of sitting inside our stunning art gallery or you may choose to enjoy the patio with giant umbrellas. We also have space available for private groups and special accommodations and snacks for your children. Our fine art is meticulously curated by our lead artist Jermaine Dante who exhibits his colorful creations in large formats in our spacious gallery where you can take in, or take home the inspiring art while imbibing your favorite Jessup wines.'
      },
      {'content': 'Are dogs allowed at Jessup Cellars?'},
      {
        'content':
            'Jessup Cellars welcomes your well-behaved dogs inside or outside and we have gluten-free dog treats available as well as water dishes.'
      },
      {'content': 'What makes Jessup Cellars wines special?'},
      {
        'content':
            'Jessup Cellars wines are carefully crafted with the help of our renowned consulting winemaker Rob Lloyd who famously crafted Chardonnay for Rombauer, La Crema, and Cakebread. Not only has Rob created one of the best Chardonnays in the Napa Valley with our 2022 vintage, but has also helped curate \'The Art of the Blend\' with our stellar red wines.'
      },
      {'content': 'What white wines does Jessup Cellars offer?'},
      {
        'content':
            'Our leading white wine is our Napa Valley Chardonnay from the Los Carneros region. The Truchard Vineyard is perfectly located in the hills above Highway 12 with the San Francisco Bay influences creating a cooler growing climate where the grapes ripen slowly and perfectly on the vine. The perfect weather combines with an ideal terroir to create the foundation for a well-balanced Chardonnay aged for 10 months in 40% new American Oak barrels. We also offer an annual harvest of Sauvignon Blanc which is sourced from North Coast vines outside of the Napa Valley. The tropical nature of our 2023 Sauvignon Blanc is decidedly different than the typical Sauvignon Blanc grown in the Valley and elsewhere in the World. Due to its limited supply this wine sells out quickly each year so be sure to give us a call before visiting our tasting room to check availability.'
      },
      {'content': 'Tell me about white wine?'},
      {
        'content':
            'Our leading white wine is our Napa Valley Chardonnay from the Los Carneros region. The Truchard Vineyard is perfectly located in the hills above Highway 12 with the San Francisco Bay influences creating a cooler growing climate where the grapes ripen slowly and perfectly on the vine. The perfect weather combines with an ideal terroir to create the foundation for a well-balanced Chardonnay aged for 10 months in 40% new American Oak barrels.'
      },
      {'content': 'Can you tell me more about your 2022 Chardonnay?'},
      {
        'content':
            'The Jessup Cellars 2022 Chardonnay is a white wine that comes across as very well balanced due to the aging being done in a combination of 40% new American and 60% neutral American Oak. This brings hints of oak to the wine while also offering a slightly creamy mouthfeel without being a butter bomb. Our Napa Valley Chardonnay is a member favorite while the non-member price of 55 is appreciated by enthusiasts of this quality wine crafted by Rob Lloyd. The alcohol content is 14.8% while the PH is 3.4.'
      },
      {'content': 'Tell me about your 2023 Sauvignon Blanc?'},
      {
        'content':
            'Our 2023 vintage is 100% Sauvignon Blanc sourced from North Coast vineyards aged in 100% stainless steel barrels which is typical for this varietal. The stainless steel seals out the oxygen and seals in the flavors of the fruit and is a hearty 15.1% alcohol content with a PH of 3.3. While it\'s nose and flavors hint at tropical delights, we would not consider this wine to be too fruit forward, but rather fruit balanced with hints of pineapple and mango. Our Sauvignon Blanc is the perfect hot tub wine or for those warm summer evenings after a long day in the hot summer Sun. You will feel refreshed after enjoying a glass or two of our Sauvignon Blanc, non-member price of 45!\n\nThe 2023 Sauvignon Blanc pairs wonderfully with a variety of dishes, enhancing the dining experience. For starters, it complements the flavors of Grilled Prawn Cocktail and Ceviche, accentuating the seafood\'s delicate taste and brightening the citrus elements in the dishes. The wine\'s fruity and floral notes beautifully complement the freshness of Tacos, making it an ideal match for this flavorful and versatile Mexican dish. Lastly, the wine\'s high acidity and fruit-forward character provide a delightful contrast to the creamy sweetness of a Peach & Burrata salad, creating a harmonious and memorable pairing.'
      },
      {'content': 'What does your white wine pair well with?'},
      {
        'content':
            'Our white wine pairs well with a variety of dishes, enhancing the dining experience. For starters, it complements the flavors of Grilled Prawn Cocktail and Ceviche, accentuating the seafood\'s delicate taste and brightening the citrus elements in the dishes.'
      },
      {'content': 'What white wines do you have?'},
      {
        'content':
            'We offer the following wines: The Jessup Cellars 2022 Chardonnay and the 2023 Sauvignon Blanc'
      },
      {'content': 'What red wines is Jessup Cellars offering in 2024?'},
      {
        'content':
            'Jessup Cellars offers a number of red wines across a range of varietals, from Pinot Noir and Merlot blends from the Truchard Vineyard, to blended Cabernet Sauvignon from both the Napa and Alexander Valleys, our Mendocino Rougette combining Grenache and Carignane varietals which we refer to as our \'Summer Red\', to the ultimate expression of the \'Art of the Blend" with our Juel and Table for Four Red Wines. We also offer 100% Zinfandel from 134 year old vines in the Mendocino region and our own 100% Petite Sirah grown in the Wooden Valley in Southeastern Napa County. We also offer some seasonal favorites, led by the popular whimsical Manny\'s Blend which should be released later in 2024 with a very special label.'
      },
      {
        'content':
            'Please tell me more about your consulting winemaker Rob Lloyd?'
      },
      {
        'content':
            'Rob Lloyd \nConsulting Winemaker\n\nBIOGRAPHY\nHometown: All of California\n\nFavorite Jessup Wine Pairing: Carneros Chardonnay with freshly caught Mahi-Mahi\n\nAbout: Rob’s foray into wine started directly after graduating college when he came to Napa to work in a tasting room for the summer – before getting a ‘real job’. He became fascinated with wine and the science of winemaking and began to learn everything he could about the process.\n\nWhile interviewing for that ‘real job’, the interviewer asked him what he had been doing with his time since graduation. After speaking passionately and at length about wine, the interviewer said, ‘You seem to love that so much. Why do you want this job?’ Rob realized he didn\'t want it, actually. He thanked the man, and thus began a career in the wine industry.\n\nRob has since earned his MS in Viticulture & Enology from the University of California Davis and worked for many prestigious wineries including Cakebread, Stag’s Leap Wine Cellars, and La Crema. Rob began crafting Jessup Cellars in the 2009 season and took the position of Director of Winemaking at Jessup Cellars in 2010. He now heads up our winemaking for the Good Life Wine Collective, which also includes Handwritten Wines.'
      },
      {'content': 'Tell me an interesting fact about Rob Llyod'},
      {
        'content':
            'While interviewing for that ‘real job’, the interviewer asked him what he had been doing with his time since graduation. After speaking passionately and at length about wine, the interviewer said, ‘You seem to love that so much. Why do you want this job?’ Rob realized he didn\'t want it, actually. He thanked the man, and thus began a career in the wine industry.'
      },
      {'content': 'Who is your winemaker at the winery in Napa?'},
      {
        'content':
            'Bernardo Munoz\nWinemaker\n\nBIOGRAPHY\nHometown: Campeche, Mex\n\nFavorite Jessup Wine Pairing: 2010 Manny’s Blend with Mongolian Pork Chops from Mustards Grill – richness paired with richness\n\nAbout: Bernardo began his career in the vineyards, learning the intricacies of grape growing and how to adjust to the'
      },
      // {
      //   "question":
      //       "What is different about your 2018 Rougette versus the 2019?",
      //   "answer":
      //       "This beautiful Jessup Cellars 2018 Rougette, comprised of our Mendocino Grenache and a touch of Carignane from the Dry Creek AVA in Sonoma County, showcases ripe red cherries, plums, cranberries, fig jam, and a hint of holiday baking spices. The palate is wonderfully dry with fresh acidity and balanced with fine-grained tannins that blend perfectly with the brambly fruit characteristics. This wine will age nicely for 5-7 years and will pair nicely with an array of dishes, especially those that grace our tables during the joyous holiday season including turkey, ham and all the fixings. Like our 2019 Rougette, this vintage is aged in used Chardonnay barrels and shares the same 14.9% alcohol content. It is priced at 70 for non-members."
      // },
      {
        'content':
            'remember all the chats and When asked a question, the model should be able to answer from the corpus as described above. And for any out of corpus questions, model should tell the users to contact the business directly. '
      },
      
    ];

    for (var i = 0; i < _chatHistory.length; i++) {
      msg.add({"content": _chatHistory[i]["message"]});
    }

    var safety_settings = [
      {"category": "HARM_CATEGORY_HARASSMENT", "threshold": "BLOCK_NONE"},
      {"category": "HARM_CATEGORY_HATE_SPEECH", "threshold": "BLOCK_NONE"},
      {
        "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
        "threshold": "BLOCK_NONE"
      },
      {
        "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
        "threshold": "BLOCK_NONE"
      },
    ];

    Map<String, dynamic> request = {
      "prompt": {
        "messages": msg,
      },
      "temperature": 0.25,
      "candidateCount": 1,
      "topP": 1,
      "topK": 1,
      // "safety_settings": safety_settings
    };
    _startLoader();
    _chatHistory.add({
      "time": DateTime.now(),
      "message": "",
      "isSender": false,
      "isLoading": true
    });
    final response = await http.post(uri, body: jsonEncode(request));
    // _hideLoader();
    print(response.body);
    _chatHistory.removeLast();
    setState(() {
      _chatHistory.add({
        "time": DateTime.now(),
        "message": json.decode(response.body)["candidates"][0]["content"],
        "isSender": false,
        "isLoading": false
      });
    });

    _scrollController.jumpTo(
      _scrollController.position.maxScrollExtent,
    );
  }

  _startLoader() {
    return LoadingAnimationWidget.waveDots(color: Colors.black, size: 25);
  }
}
