import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_openai/model/diary_model.dart';
import 'package:table_calendar/table_calendar.dart';

import 'chat.dart';
import 'diary_storage.dart';

class Calendar extends StatefulWidget {
  const Calendar({Key? key}) : super(key: key);

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  late DiaryStorage _diaryStorage = DiaryStorage(dateTime: _selectedDay);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          focusedDay: _focusedDay,
          firstDay: DateTime(2022),
          lastDay: DateTime(2030),
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Chat(
                      diaryStorage:
                      DiaryStorage(dateTime: _selectedDay),
                    )));
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
        ),
        // Padding(
        //   padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        //   child: Card(
        //     elevation: 2.0,
        //     child: ListTile(
        //       title: Text(
        //         '${_selectedDay.year}.${_selectedDay.month}.${_selectedDay.day}',
        //         style: TextStyle(
        //           fontWeight: FontWeight.bold,
        //         ),
        //       ),
        //       subtitle: Text(''),
        //       onTap: () {
        //         Navigator.push(
        //             context,
        //             MaterialPageRoute(
        //                 builder: (context) => Chat(
        //                       diaryStorage:
        //                           DiaryStorage(dateTime: _selectedDay),
        //                     )));
        //       },
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
