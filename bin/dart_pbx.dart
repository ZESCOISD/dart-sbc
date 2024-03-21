import 'package:dart_pbx/dart_pbx.dart' as dart_pbx;

import 'package:dart_pbx/sip_server.dart';
import 'dart:io';
import 'package:dart_pbx/ws_sip_server.dart';
//import 'signal_jsonrpc_impl.dart' as ion;
import 'package:dart_pbx/globals.dart';
import 'package:dart_pbx/wss_sip_server.dart';
import 'package:dart_sip_parser/sip.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dotenv/dotenv.dart';

import '../lib/config/dispartcher.dart';

//Function(dynamic resp)
void main() async {
  var env = DotEnv(includePlatformEnvironment: true)..load();

  String wsIp = env['WS_SERVER_ADDRESS']!;
  int wsPort = int.parse(env['WS_SERVER_PORT']!);

  String wssIp = env['WSS_SERVER_ADDRESS']!;
  int wssPort = int.parse(env['WSS_SERVER_PORT']!);

  String udpIp = env['UPD_SERVER_ADDRESS']!;
  int udpPort = int.parse(env['UDP_SERVER_PORT']!);

  initDispatcher();

  //SipServer sipServer =
  SipServer(udpIp, udpPort);
  //wsSipServer wsSever =
  wsSipServer(wsIp, wsPort, udpIp, udpPort);

  wssSipServer(wssIp, wssPort, udpIp, udpPort);
  // var ion_webscket = ion.SimpleWebSocket("wss://dev.zesco.co.zm:7881/ws");
  // await ion_webscket.connect();

  //dispatcherList=Dispatcher('1',sockaddr_in())
}
