import 'package:dart_pbx/dart_pbx.dart' as dart_pbx;

import 'package:dart_pbx/sip_server.dart';
import 'dart:io';
import 'package:dart_pbx/ws_sip_server.dart';
//import 'signal_jsonrpc_impl.dart' as ion;
import 'package:dart_pbx/globals.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:math';

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
  //print('Hello');
  request.headers.add('upgrade', 'websocket');
  request.headers.add('Sec-WebSocket-Version', '13');
  //request.headers.add('WebSocket-Version', '13');
  request.headers.add('Sec-WebSocket-Key', key);
  //HttpClientResponse response = await request.close();
  HttpClientResponse response = await request.close();
  //print(response);

  // Socket socket = await response.detachSocket();

  Socket socket = await response.detachSocket();

  WebSocket ws = WebSocket.fromUpgradedSocket(socket, serverSide: false);

  // ws.listen((event) {
  // var e = json.decode(event);
  // //print(e['type']);

  // Function? func = app[e['type']];
  // func!.call(e);
  // });
  //ws.listen(onData(//), onMessage, onDone: connectonClosed);
  // void on("StasisStart") {
  // print("Hello");
  // }
  // ws.listen((event) {
  // var e = json.decode(event);
  // on(app[e['type']]);
  // },onError: on);
  return ws;
}

//Function(dynamic resp)
void main() async {
  // ignore: unused_local_variable
  // wsSipServer wsServer =
  //     wsSipServer("192.168.0.91", 8088, "192.168.0.91", 5080);
  //print("Connecting to Ion SFU");
  //var socket = connect();
  // socket.listen((event) {
  //   print(event);
  // });

  var offer = """v=0
o=- 3163544789 1 IN IP4 127.0.0.1
s=webrtc (chrome 22.0.1189.0) - Doubango Telecom (sipML5 r000)
t=0 0
m=audio 62359 RTP/SAVPF 103 104 0 8 106 105 13 126
c=IN IP4 80.39.43.34
a=rtpmap:105 CN/16000
a=rtcp:62359 IN IP4 80.39.43.34
a=candidate:4242042849 1 udp 2130714367 192.168.153.1 54521 typ host generation 0
a=candidate:4242042849 2 udp 2130714367 192.168.153.1 54521 typ host generation 0
a=candidate:3028854479 1 udp 2130714367 192.168.1.44 54522 typ host generation 0
a=candidate:3028854479 2 udp 2130714367 192.168.1.44 54522 typ host generation 0
a=candidate:3471623853 1 udp 2130714367 192.168.64.1 54523 typ host generation 0
a=candidate:3471623853 2 udp 2130714367 192.168.64.1 54523 typ host generation 0
a=candidate:1117314843 1 udp 1912610559 80.39.43.34 62359 typ srflx generation 0
a=candidate:1117314843 2 udp 1912610559 80.39.43.34 62359 typ srflx generation 0
a=candidate:2992345873 1 tcp 1694506751 192.168.153.1 54185 typ host generation 0
a=candidate:2992345873 2 tcp 1694506751 192.168.153.1 54185 typ host generation 0
a=candidate:4195047999 1 tcp 1694506751 192.168.1.44 54186 typ host generation 0
a=candidate:4195047999 2 tcp 1694506751 192.168.1.44 54186 typ host generation 0
a=candidate:2154773085 1 tcp 1694506751 192.168.64.1 54187 typ host generation 0
a=candidate:2154773085 2 tcp 1694506751 192.168.64.1 54187 typ host generation 0
a=ice-ufrag:2HMP+QEvuPxeZo3I
a=ice-pwd:RjRF5Wtaj7XMk5skkrJ6TP6k
a=sendrecv
a=mid:audio
a=rtcp-mux
a=crypto:1 AES_CM_128_HMAC_SHA1_80 inline:CoKH4lo5t34SYU0pqeJGwes2gJCEWKFmLUv/q0sN
a=rtpmap:103 ISAC/16000
a=rtpmap:104 ISAC/32000
a=rtpmap:0 PCMU/8000
a=rtpmap:8 PCMA/8000
a=rtpmap:106 CN/32000
a=rtpmap:13 CN/8000
a=rtpmap:126 telephone-event/8000
a=ssrc:4221941097 cname:61TRWZq6iadCKCYD
a=ssrc:4221941097 mslabel:HnAeVefwdG64baIr9EdbXNwEChe67aSRJFcW
a=ssrc:4221941097 label:HnAeVefwdG64baIr9EdbXNwEChe67aSRJFcW00
m=video 62359 RTP/SAVPF 100 101 102
c=IN IP4 80.39.43.34
a=rtcp:62359 IN IP4 80.39.43.34
a=candidate:4242042849 1 udp 2130714367 192.168.153.1 54521 typ host generation 0
a=candidate:4242042849 2 udp 2130714367 192.168.153.1 54521 typ host generation 0
a=candidate:3028854479 1 udp 2130714367 192.168.1.44 54522 typ host generation 0
a=candidate:3028854479 2 udp 2130714367 192.168.1.44 54522 typ host generation 0
a=candidate:3471623853 1 udp 2130714367 192.168.64.1 54523 typ host generation 0
a=candidate:3471623853 2 udp 2130714367 192.168.64.1 54523 typ host generation 0
a=candidate:1117314843 1 udp 1912610559 80.39.43.34 62359 typ srflx generation 0
a=candidate:1117314843 2 udp 1912610559 80.39.43.34 62359 typ srflx generation 0
a=candidate:2992345873 1 tcp 1694506751 192.168.153.1 54185 typ host generation 0
a=candidate:2992345873 2 tcp 1694506751 192.168.153.1 54185 typ host generation 0
a=candidate:4195047999 1 tcp 1694506751 192.168.1.44 54186 typ host generation 0
a=candidate:4195047999 2 tcp 1694506751 192.168.1.44 54186 typ host generation 0
a=candidate:2154773085 1 tcp 1694506751 192.168.64.1 54187 typ host generation 0
a=candidate:2154773085 2 tcp 1694506751 192.168.64.1 54187 typ host generation 0
a=ice-ufrag:2HMP+QEvuPxeZo3I
a=ice-pwd:RjRF5Wtaj7XMk5skkrJ6TP6k
a=sendrecv
a=mid:video
a=rtcp-mux
a=crypto:1 AES_CM_128_HMAC_SHA1_80 inline:CoKH4lo5t34SYU0pqeJGwes2gJCEWKFmLUv/q0sN
a=rtpmap:100 VP8/90000
a=rtpmap:101 red/90000
a=rtpmap:102 ulpfec/90000
a=ssrc:2432199953 cname:61TRWZq6iadCKCYD
a=ssrc:2432199953 mslabel:HnAeVefwdG64baIr9EdbXNwEChe67aSRJFcW
a=ssrc:2432199953 label:HnAeVefwdG64baIr9EdbXNwEChe67aSRJFcW10

""";

  offer = "v=0\r\n" +
      "o=alice 2890844526 2890844526 IN IP4 host.atlanta.example.com\r\n" +
      "s=\r\n" +
      "c=IN IP4 host.atlanta.example.com\r\n" +
      "t=0 0\r\n" +
      "m=audio 49170 RTP/AVP 0 8 97\r\n" +
      "a=rtpmap:0 PCMU/8000\r\n" +
      "a=rtpmap:8 PCMA/8000\r\n" +
      "a=rtpmap:97 iLBC/8000\r\n" +
      "m=video 51372 RTP/AVP 31 32\r\n" +
      "a=rtpmap:31 H261/90000\r\n" +
      "a=rtpmap:32 MPV/90000\r\n";

  offer = "v=0\r\n" +
      "o=Z 0 525320674 IN IP4 127.0.0.1\r\n" +
      "s=Z\r\n" +
      "c=IN IP4 127.0.0.1\r\n" +
      "t=0 0\r\n" +
      "m=audio 54141 RTP/AVP 106 9 98 101 0 8 3\r\n" +
      "a=rtpmap:106 opus/48000/2\r\n" +
      "a=fmtp:106 sprop-maxcapturerate=16000; minptime=20; useinbandfec=1\r\n" +
      "a=rtpmap:98 telephone-event/48000\r\n" +
      "a=fmtp:98 0-16\r\n" +
      "a=rtpmap:101 telephone-event/8000\r\n" +
      "a=fmtp:101 0-16\r\n" +
      "a=sendrecv\r\n" +
      "a=rtcp-mux\r\n";

  var url = //"wss://dev.zesco.co.zm:7881/ws";

      "ws://127.0.0.1:7000/ws";
  // var data = {
  //   "jsonrpc": "2.0",
  //   "method": "join",
  //   "params": {
  //     "sid": "defaultroom",
  //     "offer": {"type": "offer", "sdp": offer}
  //   },
  //   "id": 1
  // };

  //print("sending data");
//try {
  var r = Random();
  var key = base64.encode(List<int>.generate(8, (_) => r.nextInt(255)));
  var client = HttpClient(context: SecurityContext());
  client.badCertificateCallback =
      (X509Certificate cert, String host, int port) {
    // log.debug(
    //     'SimpleWebSocket: Allow self-signed certificate => $host:$port. ');
    return true;
  };

  var parsed_uri = Uri.parse(url);
  var uri =
      parsed_uri.replace(scheme: parsed_uri.scheme == 'wss' ? 'https' : 'http');

  var request = await client.getUrl(uri); // form the correct url here
  request.headers.add('Connection', 'Upgrade');
  request.headers.add('Upgrade', 'websocket');
  request.headers
      .add('Sec-WebSocket-Version', '13'); // insert the correct version here
  request.headers.add('Sec-WebSocket-Key', key.toLowerCase());

  var response = await request.close();
  // ignore: close_sinks
  var socket = await response.detachSocket();
  webSocket = WebSocket.fromUpgradedSocket(
    socket,
    protocol: 'signaling',
    serverSide: false,
  );
  print("listening for events from ION SFU");
  webSocket!.listen((event) {
    print("From SFU: $event");
  });

  print("send data to SFU");
  //webSocket.add(jsonEncode(data));
  // } catch (e) {
  //log.error(e);
  //  rethrow;
  //  }

  SipServer sipServer = SipServer("127.0.0.1", 5080);
  wsSipServer wsSever = wsSipServer("127.0.0.1", 8088, "127.0.0.1", 5080);
  // var ion_webscket = ion.SimpleWebSocket("wss://dev.zesco.co.zm:7881/ws");
  // await ion_webscket.connect();
}
