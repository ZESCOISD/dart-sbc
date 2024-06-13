import 'dart:io';
import 'package:dart_pbx/handlers/requests_handlers.dart';
import 'package:dart_sip_parser/sip.dart';

WebSocket? webSocket;
typedef SipMessage = SipMsg;

RequestsHandler requestsHander=RequestsHandler();