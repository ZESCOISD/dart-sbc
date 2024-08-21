import 'package:dart_pbx/dart_pbx.dart' as dart_pbx;

import 'package:dart_pbx/transports/sip_server.dart';
import 'package:dart_pbx/transports/tls_server.dart';
import 'package:dart_pbx/transports/tcp_server.dart';
import 'dart:io';
import 'package:dart_pbx/transports/ws_sip_server.dart';
//import 'signal_jsonrpc_impl.dart' as ion;
import 'package:dart_pbx/globals.dart';
import 'package:dart_pbx/transports/wss_sip_server.dart';
import 'package:dart_pbx/sip_parser/sip.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dotenv/dotenv.dart';

import '../lib/config/dispartcher.dart';

//Function(dynamic resp)
void main() async {
  var env = DotEnv(includePlatformEnvironment: true)..load();

  String? udpIp = env['UPD_SERVER_ADDRESS'];
  int? udpPort = env['UDP_SERVER_PORT'] != null
      ? int.parse(env['UDP_SERVER_PORT']!)
      : null;

  String? wsIp = env['WS_SERVER_ADDRESS'];
  int? wsPort =
      env['WS_SERVER_PORT'] != null ? int.parse(env['WS_SERVER_PORT']!) : null;

  String? wssIp = env['WSS_SERVER_ADDRESS'];
  int? wssPort = env['WSS_SERVER_PORT'] != null
      ? int.parse(env['WSS_SERVER_PORT']!)
      : null;

  String? tcpIp = env['TCP_SERVER_ADDRESS'];
  int? tcpPort = env['TCP_SERVER_PORT'] != null
      ? int.parse(env['TCP_SERVER_PORT']!)
      : null;

  String? secureTcpIp = env['SEC_TCP_SERVER_ADDRESS'];
  int? secureTcpPort = env['SEC_TCP_SERVER_PORT'] != null
      ? int.parse(env['SEC_TCP_SERVER_PORT']!)
      : null;
  String? path_to_certificate_file = env['PATH_TO_CERTIFICATE_FILE_PEM'];
  String? path_to_private_key_file = env['PATH_TO_PRIVATE_KEY_FILE_PEM'];
  String? path_to_root_certificate = env['PATH_TO_ROOT_CERTIFICATE_FILE_PEM'];

  //SipServer sipServer =
  if (udpIp != null) {
    SipServer(udpIp, udpPort!);
  }
  //wsSipServer wsSever =
  if (wsIp != null) {
    WsSipServer(wsIp, wsPort!);
  }

  //wssSipServer(wssIp, wssPort, udpIp, udpPort);

  if (wssIp != null) {
    WssSipServer(wssIp, wssPort!, path_to_certificate_file!,
        path_to_private_key_file!, path_to_root_certificate!);
  }

  if (tcpIp != null) {
    TcpSipServer(tcpIp, tcpPort!, udpIp!, udpPort!);
  }

  if (secureTcpIp != null) {
    SecureTcpSipServer(
        secureTcpIp,
        secureTcpPort!,
        udpIp!,
        udpPort!,
        path_to_certificate_file!,
        path_to_private_key_file!,
        path_to_root_certificate!);
  }

  // if (secureTcpIp != null) {
  //   TlsSipServer(secureTcpIp, secureTcpPort!, path_to_certificate_file!,
  //       path_to_private_key_file!);
  // }
  // var ion_webscket = ion.SimpleWebSocket("wss://dev.zesco.co.zm:7881/ws");
  // await ion_webscket.connect();

  //dispatcherList=Dispatcher('1',sockaddr_in())
}
