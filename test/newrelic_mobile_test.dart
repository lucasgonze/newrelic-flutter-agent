/*
 * Copyright (c) 2022-present New Relic Corporation. All rights reserved.
 * SPDX-License-Identifier: Apache-2.0
 */

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:newrelic_mobile/config.dart';
import 'package:newrelic_mobile/newrelic_dt_trace.dart';
import 'package:newrelic_mobile/newrelic_mobile.dart';
import 'package:newrelic_mobile/newrelic_navigation_observer.dart';
import 'package:newrelic_mobile/utils/platform_manager.dart';

import 'newrelic_mobile_test.mocks.dart';

@GenerateMocks([
  PlatformManager,
])
void main() {
  PageRoute route(RouteSettings? settings) => PageRouteBuilder<void>(
        pageBuilder: (_, __, ___) => Container(),
        settings: settings,
      );

  const MethodChannel channel = MethodChannel('newrelic_mobile');
  const name = 'test';
  const value = 'val';
  const breadcrumb = 'button Pressed';
  const customEvent = 'custom Event';
  const eventName = 'eventName';
  const actionName = 'action';
  const interActionId = 'interActionId';
  const interActionName = 'interActionName';
  const url = 'https://www.google.com';
  const httpMethod = 'get';
  const statusCode = 200;
  const startTime = 0;
  const endTime = 200;
  const bytesSent = 200;
  const bytesReceived = 200;
  const responseBody = 'test';
  const traceData = {
    "id": "1",
    "guid": "2",
    "trace.id": "3",
    "newrelic": "yyyyyryyryr",
    "tracestate": "testtststst",
    "traceparent": "rereteutueyuyeuyeuye"
  };
  const dartError =
      '#0      Page2Screen.bar.<anonymous closure> (package:newrelic_mobile_example/main.dart:185:17)\n'
      '#1      new Future.<anonymous closure> (dart:async/future.dart:252:37)\n#2      _rootRun (dart:async/zone.dart:1418:47)\n#3      _CustomZone.run (dart:async/zone.dart:1328:19)\n#4      _CustomZone.runGuarded (dart:async/zone.dart:1236:7)\n#5      _CustomZone.bindCallbackGuarded.<anonymous closure> (dart:async/zone.dart:1276:23)';
  const obfuscateDartError =
      'Warning: This VM has been configured to produce stack traces that violate the Dart standard.\n'
      '*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***\n'
      'pid: 7240, tid: 7263, name 1.ui\n'
      'build_id: 8deece9b2984d05823bbe9244ff89140\nisolate_dso_base: 6f15a4b000, vm_dso_base: 6f15a4b000\nisolate_instructions: 6f15b277f0, vm_instructions: 6f15b23000\n  '
      '  #00 abs 0000006f15c3bd27 virt 00000000001f0d27 _kDartIsolateSnapshotInstructions+0x114537\n   '
      ' #01 abs 0000006f15d22a9b virt 00000000002d7a9b _kDartIsolateSnapshotInstructions+0x1fb2ab\n   '
      ' #02 abs 0000006f15d1b177 virt 00000000002d0177 _kDartIsolateSnapshotInstructions+0x1f3987\n   '
      ' #03 abs 0000006f15b2a817 virt 00000000000df817 _kDartIsolateSnapshotInstructions+0x3027\n   '
      ' #04 abs 0000006f15cd3ecf virt 0000000000288ecf _kDartIsolateSnapshotInstructions+0x1ac6df\n';

  const appToken = "123456";
  const currentRouteName = 'Current Route';
  const oldRouteName = 'Old Route';
  const nextRouteName = 'Next Route';
  NewRelicNavigationObserver navigationObserver = NewRelicNavigationObserver();

  const boolValue = false;
  final List<MethodCall> methodCalLogs = <MethodCall>[];

  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      methodCalLogs.add(methodCall);
      switch (methodCall.method) {
        case 'getTags':
          return <String>['tag1', 'tag2'];
        case 'setUserId':
          return true;
        case 'setAttribute':
          return true;
        case 'removeAttribute':
          return false;
        case 'getPlatformVersion':
          return '42';
        case 'startInteraction':
          return '42';
        case 'noticeDistributedTrace':
          Map<String, dynamic> map = {'test': 'test1', 'test1': 'test3'};
          return map;
        default:
          return true;
      }
    });
  });

  setUp(() {});

  tearDown(() {
    methodCalLogs.clear();
    // channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await NewrelicMobile.instance.platformVersion, '42');
  });

  test(
      'test setUserId should be called with a String argument and return a bool',
      () async {
    final result = await NewrelicMobile.instance.setUserId(name);
    final Map<String, dynamic> params = <String, dynamic>{
      'userId': name,
    };
    expect(methodCalLogs, <Matcher>[
      isMethodCall(
        'setUserId',
        arguments: params,
      )
    ]);
    expect(result, true);
  });

  test(
      'test setAttribute should be called with a String Attribute and return a bool',
      () async {
    final result = await NewrelicMobile.instance.setAttribute(name, value);
    final Map<String, dynamic> params = <String, dynamic>{
      'name': name,
      'value': value
    };
    expect(methodCalLogs, <Matcher>[
      isMethodCall(
        'setAttribute',
        arguments: params,
      )
    ]);
    expect(result, true);
  });

  test(
      'test setAttribute should be called with a Boolean Attribute and return a bool',
      () async {
    final result = await NewrelicMobile.instance.setAttribute(name, boolValue);
    final Map<String, dynamic> params = <String, dynamic>{
      'name': name,
      'value': boolValue
    };
    expect(methodCalLogs, <Matcher>[
      isMethodCall(
        'setAttribute',
        arguments: params,
      )
    ]);
    expect(result, true);
  });

  test(
      'test removeAttribute should be called with a String Arguments and return a bool',
      () async {
    final result = await NewrelicMobile.instance.removeAttribute(name);
    final Map<String, dynamic> params = <String, dynamic>{'name': name};
    expect(methodCalLogs, <Matcher>[
      isMethodCall(
        'removeAttribute',
        arguments: params,
      )
    ]);
    expect(result, false);
  });

  test(
      'test record BreadCrumb should be called with a Map Arguments and return a bool',
      () async {
    final Map<String, dynamic> eventAttributes = <String, dynamic>{
      'name': name,
      'value;': value
    };

    final result = await NewrelicMobile.instance
        .recordBreadcrumb(breadcrumb, eventAttributes: eventAttributes);
    final Map<String, dynamic> params = <String, dynamic>{
      'name': breadcrumb,
      'eventAttributes': eventAttributes
    };
    expect(methodCalLogs, <Matcher>[
      isMethodCall(
        'recordBreadcrumb',
        arguments: params,
      )
    ]);
    expect(result, true);
  });

  test(
      'test record CustomEvent should be called with a Map Arguments,eventType and return a bool',
      () async {
    final Map<String, dynamic> eventAttributes = <String, dynamic>{
      'name': name,
      'value;': value
    };

    final result = await NewrelicMobile.instance
        .recordCustomEvent(customEvent, eventAttributes: eventAttributes);
    final Map<String, dynamic> params = <String, dynamic>{
      'eventType': customEvent,
      'eventName': '',
      'eventAttributes': eventAttributes
    };
    expect(methodCalLogs, <Matcher>[
      isMethodCall(
        'recordCustomEvent',
        arguments: params,
      )
    ]);
    expect(result, true);
  });

  test(
      'test record CustomEvent should be called with a Map Arguments,eventType,eventName and return a bool',
      () async {
    final Map<String, dynamic> eventAttributes = <String, dynamic>{
      'name': name,
      'value;': value
    };

    final result = await NewrelicMobile.instance.recordCustomEvent(customEvent,
        eventName: eventName, eventAttributes: eventAttributes);
    final Map<String, dynamic> params = <String, dynamic>{
      'eventType': customEvent,
      'eventName': eventName,
      'eventAttributes': eventAttributes
    };
    expect(methodCalLogs, <Matcher>[
      isMethodCall(
        'recordCustomEvent',
        arguments: params,
      )
    ]);
    expect(result, true);
  });

  test(
      'test startInteraction should be called with a action Name and Return interactionId ',
      () async {
    final result = await NewrelicMobile.instance.startInteraction(actionName);
    final Map<String, dynamic> params = <String, dynamic>{
      'actionName': actionName,
    };
    expect(methodCalLogs, <Matcher>[
      isMethodCall(
        'startInteraction',
        arguments: params,
      )
    ]);
    expect(result, '42');
  });

  test(
      'test noticeDistributedTrace should be called and Return map with trace Attributes ',
      () async {
    final result = await NewrelicMobile.instance.noticeDistributedTrace({});
    expect(methodCalLogs, <Matcher>[
      isMethodCall(
        'noticeDistributedTrace',
        arguments: null,
      )
    ]);
    expect(result.keys.length, 2);
  });

  test('test endInteraction should be called with interActionId ', () async {
    NewrelicMobile.instance.endInteraction(interActionId);
    final Map<String, dynamic> params = <String, dynamic>{
      'interactionId': interActionId,
    };
    expect(methodCalLogs, <Matcher>[
      isMethodCall(
        'endInteraction',
        arguments: params,
      )
    ]);
  });

  test(
      'test interactionName should be called with interActionName on Android Platform ',
      () async {
    var platformManger = MockPlatformManager();
    PlatformManager.setPlatformInstance(platformManger);
    when(platformManger.isAndroid()).thenAnswer((realInvocation) => true);
    NewrelicMobile.instance.setInteractionName(interActionName);
    final Map<String, dynamic> params = <String, dynamic>{
      'interactionName': interActionName,
    };
    expect(methodCalLogs, <Matcher>[
      isMethodCall(
        'setInteractionName',
        arguments: params,
      )
    ]);
  });

  test('test interactionName should not be called on iOS Platform ', () async {
    var platformManger = MockPlatformManager();
    PlatformManager.setPlatformInstance(platformManger);
    when(platformManger.isAndroid()).thenAnswer((realInvocation) => false);
    NewrelicMobile.instance.setInteractionName(interActionName);

    expect(methodCalLogs, <Matcher>[]);
  });

  test('test noticeHttpTransaction should be called on Android Platform',
      () async {
    var platformManger = MockPlatformManager();
    PlatformManager.setPlatformInstance(platformManger);
    when(platformManger.isAndroid()).thenAnswer((realInvocation) => true);

    var traceAttributes = {
      DTTraceTags.id: traceData[DTTraceTags.id],
      DTTraceTags.guid: traceData[DTTraceTags.guid],
      DTTraceTags.traceId: traceData[DTTraceTags.traceId]
    };
    await NewrelicMobile.instance.noticeHttpTransaction(url, httpMethod,
        statusCode, startTime, endTime, bytesSent, bytesReceived, traceData,
        responseBody: responseBody);

    final Map<String, dynamic> params = <String, dynamic>{
      'url': url,
      'httpMethod': httpMethod,
      'statusCode': statusCode,
      'startTime': startTime,
      'endTime': endTime,
      'bytesSent': bytesSent,
      'bytesReceived': bytesReceived,
      'responseBody': responseBody,
      'traceAttributes': traceAttributes
    };
    expect(methodCalLogs, <Matcher>[
      isMethodCall(
        'noticeHttpTransaction',
        arguments: params,
      )
    ]);
  });

  test('test noticeHttpTransaction should be called on iOS Platform', () async {
    var platformManger = MockPlatformManager();
    PlatformManager.setPlatformInstance(platformManger);
    when(platformManger.isAndroid()).thenAnswer((realInvocation) => false);
    when(platformManger.isIOS()).thenAnswer((realInvocation) => true);

    var traceAttributes = {
      DTTraceTags.newrelic: traceData[DTTraceTags.newrelic],
      DTTraceTags.traceState: traceData[DTTraceTags.traceState],
      DTTraceTags.traceParent: traceData[DTTraceTags.traceParent]
    };
    await NewrelicMobile.instance.noticeHttpTransaction(url, httpMethod,
        statusCode, startTime, endTime, bytesSent, bytesReceived, traceData,
        responseBody: responseBody);

    final Map<String, dynamic> params = <String, dynamic>{
      'url': url,
      'httpMethod': httpMethod,
      'statusCode': statusCode,
      'startTime': startTime,
      'endTime': endTime,
      'bytesSent': bytesSent,
      'bytesReceived': bytesReceived,
      'responseBody': responseBody,
      'traceAttributes': traceAttributes
    };
    expect(methodCalLogs, <Matcher>[
      isMethodCall(
        'noticeHttpTransaction',
        arguments: params,
      )
    ]);
  });

  test('should return 6 elements', () {
    StackTrace stackTrace = StackTrace.fromString(dartError);

    List<Map<String, String>> elements =
        NewrelicMobile.getStackTraceElements(stackTrace);

    expect(6, elements.length);
  });

  test('obfuscate error should return 5 elements', () {
    StackTrace stackTrace = StackTrace.fromString(obfuscateDartError);

    List<Map<String, String>> elements =
        NewrelicMobile.getStackTraceElements(stackTrace);

    expect(11, elements.length);
  });

  test('agent should start with AppToken', () async {
    Config config = Config(accessToken: "test1234");
    await NewrelicMobile.instance.startAgent(config);

    final Map<String, dynamic> params = <String, dynamic>{
      'applicationToken': config.accessToken,
      'dartVersion': Platform.version,
      'webViewInstrumentation': true,
      'analyticsEventEnabled': true,
      'crashReportingEnabled': true,
      'interactionTracingEnabled': true,
      'networkRequestEnabled': true,
      'networkErrorRequestEnabled': true,
      'httpRequestBodyCaptureEnabled': true,
      'loggingEnabled': true
    };

    expect(methodCalLogs, <Matcher>[
      isMethodCall(
        'startAgent',
        arguments: params,
      )
    ]);
  });

  test('agent should start with AppToken with network disabled', () async {
    Config config = Config(
        accessToken: "test1234",
        networkRequestEnabled: false,
        networkErrorRequestEnabled: false);
    await NewrelicMobile.instance.startAgent(config);

    final Map<String, dynamic> params = <String, dynamic>{
      'applicationToken': config.accessToken,
      'dartVersion': Platform.version,
      'webViewInstrumentation': true,
      'analyticsEventEnabled': true,
      'crashReportingEnabled': true,
      'interactionTracingEnabled': true,
      'networkRequestEnabled': false,
      'networkErrorRequestEnabled': false,
      'httpRequestBodyCaptureEnabled': true,
      'loggingEnabled': true
    };

    expect(methodCalLogs, <Matcher>[
      isMethodCall(
        'startAgent',
        arguments: params,
      )
    ]);
  });

  test('agent should start with AppToken with analytics disabled', () async {
    Config config =
        Config(accessToken: "test1234", analyticsEventEnabled: false);
    await NewrelicMobile.instance.startAgent(config);

    final Map<String, dynamic> params = <String, dynamic>{
      'applicationToken': config.accessToken,
      'dartVersion': Platform.version,
      'webViewInstrumentation': true,
      'analyticsEventEnabled': false,
      'crashReportingEnabled': true,
      'interactionTracingEnabled': true,
      'networkRequestEnabled': true,
      'networkErrorRequestEnabled': true,
      'httpRequestBodyCaptureEnabled': true,
      'loggingEnabled': true
    };

    expect(methodCalLogs, <Matcher>[
      isMethodCall(
        'startAgent',
        arguments: params,
      )
    ]);
  });

  test('test RecordError should be called', () async {
    var error = Exception("test");

    StackTrace stackTrace = StackTrace.fromString(dartError);

    NewrelicMobile.instance.recordError(error, stackTrace);

    final Map<String, dynamic> params = <String, dynamic>{
      'exception': error.toString(),
      'reason': error.toString(),
      'stackTrace': stackTrace.toString(),
      'stackTraceElements': NewrelicMobile.getStackTraceElements(stackTrace),
      'fatal': false
    };

    final Map<String, dynamic> eventParams = Map<String, dynamic>.from(params);
    eventParams.remove('stackTraceElements');

    final Map<String, dynamic> customEventParams = <String, dynamic>{
      'eventType': 'Mobile Dart Errors',
      'eventName': '',
      'eventAttributes': eventParams
    };

    expect(methodCalLogs, <Matcher>[
      isMethodCall(
        'recordCustomEvent',
        arguments: customEventParams,
      ),
      isMethodCall(
        'recordError',
        arguments: params,
      )
    ]);
  });

  test('test Record DebugPrint method', () {
    Config config = Config(accessToken: appToken);
    NewrelicMobile.instance.startAgent(config);
    debugPrint(name);
    final Map<String, dynamic> params = <String, dynamic>{
      'name': name,
      'eventAttributes': null
    };

    final Map<String, dynamic> params1 = <String, dynamic>{
      'applicationToken': config.accessToken,
      'dartVersion': Platform.version,
      'webViewInstrumentation': true,
      'analyticsEventEnabled': true,
      'crashReportingEnabled': true,
      'interactionTracingEnabled': true,
      'networkRequestEnabled': true,
      'networkErrorRequestEnabled': true,
      'httpRequestBodyCaptureEnabled': true,
      'loggingEnabled': true
    };
    expect(methodCalLogs, <Matcher>[
      isMethodCall(
        'startAgent',
        arguments: params1,
      ),
      isMethodCall(
        'recordBreadcrumb',
        arguments: params,
      )
    ]);
  });

  test('test Start of Agent should also start method with logging disabled ',
      () async {
    Config config = Config(accessToken: appToken, loggingEnabled: false);

    Function fun = () {
      print('test');
    };

    await NewrelicMobile.instance.start(config, fun);

    final Map<String, dynamic> params = <String, dynamic>{
      'applicationToken': appToken,
      'dartVersion': Platform.version,
      'webViewInstrumentation': true,
      'analyticsEventEnabled': true,
      'crashReportingEnabled': true,
      'interactionTracingEnabled': true,
      'networkRequestEnabled': true,
      'networkErrorRequestEnabled': true,
      'httpRequestBodyCaptureEnabled': true,
      'loggingEnabled': false
    };

    final Map<String, String> eventParams = <String, String>{'message': 'test'};

    final Map<String, dynamic> customParams = <String, dynamic>{
      'eventType': 'Mobile Dart Console Events',
      'eventName': '',
      'eventAttributes': eventParams
    };

    final Map<String, dynamic> attributeParams = <String, dynamic>{
      'name': 'Flutter Agent Version',
      'value': '0.0.1-dev.5',
    };

    expect(methodCalLogs, <Matcher>[
      isMethodCall(
        'startAgent',
        arguments: params,
      ),
      isMethodCall(
        'recordCustomEvent',
        arguments: customParams,
      ),
      isMethodCall(
        'setAttribute',
        arguments: attributeParams,
      )
    ]);
  });

  test(
      'test Start of Agent should also start method and also record error if run app throw error ',
      () async {
    Config config = Config(accessToken: appToken);

    Function fun = () {
      print('test');
      throw Exception('test');
    };

    await NewrelicMobile.instance.start(config, fun);

    final Map<String, dynamic> params = <String, dynamic>{
      'applicationToken': appToken,
      'dartVersion': Platform.version,
      'webViewInstrumentation': true,
      'analyticsEventEnabled': true,
      'crashReportingEnabled': true,
      'interactionTracingEnabled': true,
      'networkRequestEnabled': true,
      'networkErrorRequestEnabled': true,
      'httpRequestBodyCaptureEnabled': true,
      'loggingEnabled': true
    };

    expect(
        methodCalLogs[0],
        isMethodCall(
          'startAgent',
          arguments: params,
        ));

    expect(methodCalLogs[1].method, 'recordCustomEvent');

    expect(methodCalLogs[2].method, 'recordCustomEvent');

    expect(methodCalLogs[3].method, 'recordError');
  });

  test('test onError should called record error and record error as Fatal', () {
    const exception = 'foo exception';
    const exceptionReason = 'bar reason';
    const exceptionLibrary = 'baz library';
    const exceptionFirstMessage = 'first message';
    const exceptionSecondMessage = 'second message';
    final stack = StackTrace.current;
    final FlutterErrorDetails details = FlutterErrorDetails(
      exception: exception,
      stack: stack,
      library: exceptionLibrary,
      informationCollector: () => <DiagnosticsNode>[
        DiagnosticsNode.message(exceptionFirstMessage),
        DiagnosticsNode.message(exceptionSecondMessage),
      ],
      context: ErrorDescription(exceptionReason),
    );

    NewrelicMobile.onError(details);

    final Map<String, dynamic> params = <String, dynamic>{
      'exception': exception,
      'reason': exception,
      'stackTrace': stack.toString(),
      'stackTraceElements': NewrelicMobile.getStackTraceElements(stack),
      'fatal': true
    };

    final Map<String, dynamic> eventParams = Map<String, dynamic>.from(params);
    eventParams.remove('stackTraceElements');

    final Map<String, dynamic> customEventParams = <String, dynamic>{
      'eventType': 'Mobile Dart Errors',
      'eventName': '',
      'eventAttributes': eventParams
    };

    expect(methodCalLogs, <Matcher>[
      isMethodCall('recordCustomEvent', arguments: customEventParams),
      isMethodCall('recordError', arguments: params)
    ]);
  });

  test("test navigation observer did pop method", () {
    final currentRoute = route(const RouteSettings(name: currentRouteName));
    final oldRoute = route(const RouteSettings(name: oldRouteName));

    navigationObserver.didPop(currentRoute, oldRoute);

    Map<String, String?> attributes = <String, String?>{
      'methodType': 'didPop',
      'from': oldRouteName,
      'to': currentRouteName
    };

    final Map<String, dynamic> params = <String, dynamic>{
      'name': breadCrumbName,
      'eventAttributes': attributes
    };

    expect(methodCalLogs,
        <Matcher>[isMethodCall('recordBreadcrumb', arguments: params)]);
  });

  test("test navigation observer did push method", () {
    final currentRoute = route(const RouteSettings(name: currentRouteName));
    final nextRoute = route(const RouteSettings(name: nextRouteName));

    navigationObserver.didPush(nextRoute, currentRoute);

    Map<String, String?> attributes = <String, String?>{
      'methodType': 'didPush',
      'from': currentRouteName,
      'to': nextRouteName
    };

    final Map<String, dynamic> params = <String, dynamic>{
      'name': breadCrumbName,
      'eventAttributes': attributes
    };

    expect(methodCalLogs,
        <Matcher>[isMethodCall('recordBreadcrumb', arguments: params)]);
  });

  test("test navigation observer did replace method", () {
    final currentRoute = route(const RouteSettings(name: currentRouteName));
    final nextRoute = route(const RouteSettings(name: nextRouteName));

    navigationObserver.didReplace(newRoute: nextRoute, oldRoute: currentRoute);

    Map<String, String?> attributes = <String, String?>{
      'methodType': 'didReplace',
      'from': currentRouteName,
      'to': nextRouteName
    };

    final Map<String, dynamic> params = <String, dynamic>{
      'name': breadCrumbName,
      'eventAttributes': attributes
    };

    expect(methodCalLogs,
        <Matcher>[isMethodCall('recordBreadcrumb', arguments: params)]);
  });

  test('test navigation observer from route null name', () {
    final currentRoute = route(const RouteSettings());
    final nextRoute = route(const RouteSettings(name: nextRouteName));

    navigationObserver.didReplace(newRoute: nextRoute, oldRoute: currentRoute);

    Map<String, String?> attributes = <String, String?>{
      'methodType': 'didReplace',
      'from': '/',
      'to': nextRouteName
    };

    final Map<String, dynamic> params = <String, dynamic>{
      'name': breadCrumbName,
      'eventAttributes': attributes
    };

    expect(methodCalLogs,
        <Matcher>[isMethodCall('recordBreadcrumb', arguments: params)]);
  });

  test('test navigation observer to route null name', () {
    final currentRoute = route(const RouteSettings(name: currentRouteName));
    final nextRoute = route(const RouteSettings(name: ''));

    navigationObserver.didReplace(newRoute: nextRoute, oldRoute: currentRoute);

    Map<String, String?> attributes = <String, String?>{
      'methodType': 'didReplace',
      'from': currentRouteName,
      'to': ''
    };

    final Map<String, dynamic> params = <String, dynamic>{
      'name': breadCrumbName,
      'eventAttributes': attributes
    };

    expect(methodCalLogs,
        <Matcher>[isMethodCall('recordBreadcrumb', arguments: params)]);
  });
}
