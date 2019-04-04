import 'dart:convert';
import 'dart:io';

import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';

void main(List<String> arguments) async {
  await initiate();
}

String clearText(String source) => source != null ? source.trim().replaceAll('\\n', '') : source;

Future initiate() async {
  //  var client = Client();
  //  Response response = await client.get('https://nastachku.ru/schedule?selected_section=27-04-2019');
  //  final body = response.body;

  List<RoomDescription> rooms = [];
  final String body =
      File('/Users/andrey.smirnov/Desktop/Flutter Presentation/examples/stachka/nastachku-parser/bin/source.html')
          .readAsStringSync();

  var document = parse(body);
  final dateSelectors = const ['26-04-2019', '27-04-2019'];

  for (String dateSelector in dateSelectors) {
    print(
        '----------------------------------------- current date is $dateSelector ---------------------------------------------');

    final Element dateContent = document.querySelector('div#content_$dateSelector');
    final List<Element> roomHeaders =
        dateContent.querySelectorAll('div.program__header-wrapper > div.program__header-item');
    for (Element roomHeader in roomHeaders) {
      final roomLiter = clearText(roomHeader.nodes[1].text);
      final roomName = clearText(roomHeader.nodes[2].text);
      print('$roomLiter, $roomName');

      rooms.add(RoomDescription(roomLiter, roomName));
    }

    final List<Element> programColumns = dateContent.querySelectorAll('div.program__body > div.program__column');
    for (int index = 0; index < programColumns.length; index++) {
      final room = rooms[index];
      Element programColumn = programColumns[index];

      print(
          '----------------------------------------- lectures in $room ---------------------------------------------');
      //  events
      List<Element> eventNodes = programColumn.querySelectorAll('div.program__event');
      for (Element eventNode in eventNodes) {
        final eventTime = clearText(eventNode.querySelector('div.program__item-time')?.nodes?.first?.text);
        final eventName = clearText(eventNode.querySelector('div.program__item-name')?.text);

        if (eventTime != null && eventName != null) {
          print('event name: $eventName on time: $eventTime');
        } else if (eventTime == null && eventName != null) {
          print('event name: $eventName');
        }
      }

      //  lectures
      List<Element> lectureNodes = programColumn.querySelectorAll('a.program__item-lecture');
      for (Element lectureNode in lectureNodes) {
        final programTypeClassName =
            lectureNode.classes.firstWhere((className) => className.startsWith('program__type'), orElse: () => null);

        final lectureType = programTypeClassName == null ? 'unknown' : programTypeClassName.split('-')[1];
        final lectureTimeNode = lectureNode.querySelector('div.program__item-time').nodes[0];
        final lectureSpeakerNodes = lectureNode.querySelectorAll('div.program__item-name');
        final lectureSpeakerJobNodes = lectureNode.querySelectorAll('div.program__item-jobs');

        final lectureTime = clearText(lectureTimeNode.text);
        print('lectureType: $lectureType, lectureTime: $lectureTime');

        lectureSpeakerNodes.forEach((e) {
          final lectureSpeaker = clearText(e.text);

          print('speaker: $lectureSpeaker');
        });

        lectureSpeakerJobNodes.forEach((e) {
          final lectureSpeakerJob = clearText(e.text);

          print('speaker job: $lectureSpeakerJob');
        });

        final lectureDescription = clearText(lectureNode.querySelector('div.program__item-desc').text);
        print('lecture: $lectureDescription');
        print('\n');
      }
    }
  }
}

class RoomDescription {
  final String liter;
  final String name;

  RoomDescription(this.liter, this.name);

  @override
  String toString() => 'RoomDescription{liter: $liter, name: $name}';
}
