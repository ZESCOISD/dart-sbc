HttpClient client = HttpClient();

Future<WebSocket> connect() async {
  // Random r = new Random();
  final int key = 758485960049485;
  // Random r = new Random();
  // String key = base64.encode(List<int>.generate(8, (_) => r.nextInt(256)));

  // HttpClient client = HttpClient(/* optional security context here */);
  // HttpClientRequest request = await client.get('echo.websocket.org', 80,
  // '/foo/ws?api_key=myapikey'); // form the correct url here
  // request.headers.add('Connection', 'upgrade');
  // request.headers.add('Upgrade', 'websocket');
  // request.headers.add('sec-websocket-version', '13'); // insert the correct version here
  // request.headers.add('sec-websocket-key', key);
  // request.headers.add('sec-websocket-protocol', 'sip');

  // HttpClientResponse response = await request.close();
  // // todo check the status code, key etc
  // Socket socket = await response.detachSocket();

  // WebSocket ws = WebSocket.fromUpgradedSocket(
  // socket,
  // serverSide: false,
  // );

  // HttpClient clientLearn = HttpClient(/* optional security context here */);
  // HttpClientRequest requestLearn = await clientLearn.get('echo.websocket.org', 80,
  // '/foo/ws?api_key=myapikey'); // form the correct url here
  //'wss://dev.zesco.co.zm:7070/ws'
  var uri = Uri(
    scheme: "http",
    userInfo: "",
    host: "10.100.54.54",
    port: 7070,
    path: "ws",
    //Iterable<String>? pathSegments,
    // query: "",
    // queryParameters: {
    // 'api_key': 'asterisk:asterisk',
    // 'app': 'hello',
    // 'subscribe_all': 'true'
    // }
    //String? fragment
  );

  HttpClientRequest request = await client.getUrl(uri);
  request.headers.add('connection', 'Upgrade');
  ////print('Hello');
  request.headers.add('upgrade', 'websocket');
  request.headers.add('Sec-WebSocket-Version', '13');
  //request.headers.add('WebSocket-Version', '13');
  request.headers.add('Sec-WebSocket-Key', key);
  //HttpClientResponse response = await request.close();
  HttpClientResponse response = await request.close();
  ////print(response);

  // Socket socket = await response.detachSocket();

  Socket socket = await response.detachSocket();

  WebSocket ws = WebSocket.fromUpgradedSocket(socket, serverSide: false);

  // ws.listen((event) {
  // var e = json.decode(event);
  // ////print(e['type']);

  // Function? func = app[e['type']];
  // func!.call(e);
  // });
  //ws.listen(onData(//), onMessage, onDone: connectonClosed);
  // void on("StasisStart") {
  // //print("Hello");
  // }
  // ws.listen((event) {
  // var e = json.decode(event);
  // on(app[e['type']]);
  // },onError: on);
  return ws;
}
