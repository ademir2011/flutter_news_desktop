import 'package:flutter_news/g1_content.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:http/http.dart' as http;
import 'package:webfeed/domain/rss_feed.dart';

void main() {
  runApp(const MyApp());
}

final String RSS_FEED_URL = 'https://g1.globo.com/rss/g1/';
final Map<String, String> data_regions = {
  'ac': 'acre',
  'al': 'alagoas',
  'ap': 'amapa',
  'am': 'amazonas',
  'ba': 'bahia',
  'ce': 'ceara',
  'df': 'distrito-federal',
  'es': 'espirito-santo',
  'go': 'goias',
  'ma': 'maranhao',
  'mt': 'mato-grosso',
  'ms': 'mato-grosso-do-sul',
  'mg': 'minas-gerais',
  'pa': 'para',
  'pb': 'paraiba',
  'pr': 'parana',
  'pe': 'pernambuco',
  'pi': 'piaui',
  'rj': 'rio-de-janeiro',
  'rn': 'rio-grande-do-norte',
  'rs': 'rio-grande-do-sul',
  'ro': 'rondonia',
  'rr': 'roraima',
  'sc': 'santa-catarina',
  'sp': 'sao-paulo',
  'se': 'sergipe',
  'to': 'tocantins',
};

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'MyApp',
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _currentIndex = 0;
  var isLoaded = false;
  List<G1content> data = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    print(getUrl(_currentIndex));
    loadData(url: getUrl(_currentIndex)).then((_) {
      setState(() {
        isLoaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      pane: NavigationPane(
        header: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(
                FluentIcons.update_restore,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () {
                print(getUrl(_currentIndex));
                setState(() {
                  isLoaded = false;
                });
                loadData(url: getUrl(_currentIndex)).then((_) {
                  setState(() {
                    isLoaded = true;
                  });
                });
              },
            )
          ],
        ),
        selected: _currentIndex,
        onChanged: (i) => setState(() {
          _currentIndex = i;
          print(getUrl(_currentIndex));
          loadData(url: getUrl(_currentIndex)).then((_) {
            setState(() {
              isLoaded = true;
            });
          });
        }),
        displayMode: PaneDisplayMode.auto,
        items: [
          PaneItemHeader(
              header: const Text(
            'Brasil',
            style: TextStyle(fontSize: 20),
          )),
          PaneItem(
            title: const Text('Notícias'),
            icon: const Icon(FluentIcons.news),
          ),
          PaneItemSeparator(),
          PaneItemHeader(
              header: const Text(
            'Minha região',
            style: TextStyle(fontSize: 15),
          )),
          ...data_regions.entries.map(((element) {
            return PaneItem(
              title: Text(element.value.toString().replaceAll('-', ' ')),
              icon: Text(
                element.key.toString().toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          })).toList(),
        ],
      ),
      content: NavigationBody(
        index: _currentIndex,
        children: [
          content(),
          for (var i in data_regions.entries) content(),
        ],
      ),
    );
  }

  Future<void> loadData({required String url}) async {
    data.clear();
    isLoaded = false;
    final response = await http.get(Uri.parse(url));

    final items = RssFeed.parse(response.body).items;

    if (items != null) {
      items.forEach((element) {
        if (element.description.toString().contains('<img src="')) {
          data.add(G1content(
            title: element.title.toString(),
            imgUrl: element.description.toString().split('<img src="')[1].split('" /><br />')[0],
            description: element.description.toString().split('" /><br />')[1],
          ));
        } else {
          data.add(
            G1content(
              title: element.title.toString(),
              imgUrl:
                  'https://www.camisetasdahora.com/franquia-on-line-plano-prosperidade/midia/portal-g1-globo-sem-teto-vira-empresario-de-sucesso/img/logo-g1.png',
              description: element.description.toString(),
            ),
          );
        }
      });
    }
  }

  String getUrl(int _currentIndex) {
    if (_currentIndex == 0) {
      return RSS_FEED_URL;
    } else {
      return '$RSS_FEED_URL${data_regions.keys.elementAt(_currentIndex - 1)}/${data_regions.values.elementAt(_currentIndex - 1)}';
    }
  }

  Widget content() {
    return Container(
      child: isLoaded
          ? Scrollbar(
              child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return Container(
                      height: 200,
                      child: ListTile(
                        leading: Image.network(
                          data[index].imgUrl,
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                        title: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Text(
                            data[index].title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        subtitle: Expanded(
                          child: Text(
                            '${data[index].description.length > 300 ? data[index].description.substring(0, 300) : data[index].description}...',
                            style: const TextStyle(),
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(10),
                      ),
                    );
                  }),
            )
          : const Center(child: ProgressRing()),
    );
  }
}
