import 'dart:io';

class wssSipServer {
  wssSipServer(String ip, int port, String udpServerIp, int udpServerPort)
      : this.ip = ip,
        this.port = port,
        this.udpServerIp = udpServerIp,
        this.udpServerPort = udpServerPort {
    var file = File("C:/ssl/star_zesco_co_zm.crt");
    // var chain =
    //     Platform.script.resolve('./ssl/star_zesco_co_zm.crt').toFilePath();
    var chain = "C:/ssl/star_zesco_co_zm.crt";
    var key = 'C:/ssl/myserver.key';
    var context = SecurityContext()
      ..useCertificateChain(chain)
      ..usePrivateKey(key, password: 'dartdart');

    HttpServer.bindSecure(ip, port, context).then((server) async {
      //print('Listening on ws://${server.address.address}:${server.port}');

      await for (HttpRequest request in server) {
        request.response.headers.set("Sec-WebSocket-Protocol", "sip");
        if (WebSocketTransformer.isUpgradeRequest(request)) {
          WebSocketTransformer.upgrade(request).then(handleWebSocket);
        } else {
          request.response
            ..statusCode = HttpStatus.forbidden
            ..close();
        }
      }
    });
  }

  void handleWebSocket(WebSocket socket) async {
    RawDatagramSocket udpClient =
        await RawDatagramSocket.bind(InternetAddress(udpServerIp), 0);
    //   .then((RawDatagramSocket socket) {
    //print('UDP client ready to receive');
    //print('${udpClient.address.address}:${udpClient.port}');

    //handler = ReqHandler(socket.address.address, socket.port, socket);

    onNewMessageFromWS(String data) {
      // //print(data);
      udpClient.send(data.toString().codeUnits, InternetAddress(udpServerIp),
          udpServerPort);
    }

    onNewMessageFromSipServer(String data) {
      socket.add(data);
    }

    socket.listen(
      (data) {
        //print('Received: $data');
        onNewMessageFromWS(data);
        //socket.add('Echo: ${json.encode(resp)}');
      },
      onDone: () {
        //print('Connection closed');
      },
      onError: (error) {
        //print('Error: $error');
      },
    );

    udpClient.listen((RawSocketEvent e) {
      Datagram? d = udpClient.receive();
      if (d != null) {
        String message = String.fromCharCodes(d.data);
        ////print(
        //    'Datagram from ${d.address.address}:${d.port}: ${message.trim()}');

        onNewMessageFromSipServer(message);
      }
    });
  }

  String ip;
  int port;
  String udpServerIp;
  int udpServerPort;
}
