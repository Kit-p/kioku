/*
# COMP 4521    #  PANG, Kit        20606678          kpangaa@connect.ust.hk
# COMP 4521    #  TAM, Tsz Chung        20606173          tctam@connect.ust.hk
*/

import 'dart:typed_data';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:kioku/model/base.dart';
import 'package:kioku/service/database.dart';

class BookModel extends BaseModel {
  static const id = 'id';
  static const title = 'title';
  static const color = 'color';
  static const cover = 'cover';
  static const createTime = 'createTime';
  static const lastModifiedTime = 'lastModifiedTime';

  BookModel()
      : super(
            cols: DBCols([
          DBCol(name: id, type: DBType.rowId()),
          DBCol(name: title, type: DBType.text(notNull: true)),
          DBCol(name: color, type: DBType.int(notNull: true)),
          DBCol(name: cover, type: DBType.blob()),
          DBCol(name: createTime, type: DBType.int(notNull: true)),
          DBCol(name: lastModifiedTime, type: DBType.int(notNull: true)),
        ]));
}

class Book {
  static final colors = [
    Colors.blueGrey.shade800,
    Colors.indigo,
    Colors.cyan.shade700,
    Colors.lightBlueAccent.shade400,
    Colors.lightGreenAccent,
    Colors.limeAccent,
    Colors.yellow,
    Colors.orange,
    Colors.brown,
    Colors.red.shade800
  ];

  static int titleLengthLimit = 20;

  int? id; // id from database
  String title; // title
  Color color; // color of cover
  Uint8List? cover; // image of cover in bytes
  final DateTime createTime; // create time from database
  DateTime lastModifiedTime; // last modified time from database

  Book._internal(
      {this.id,
      required this.title,
      required this.color,
      this.cover,
      required this.createTime,
      required this.lastModifiedTime});

  factory Book({String title = 'Untitled', Color? color}) {
    final timestamp = DateTime.now();
    colors.shuffle();
    color ??= colors.first;
    return Book._internal(
        title: title,
        color: color,
        createTime: timestamp,
        lastModifiedTime: timestamp);
  }

  factory Book.fromJson(Map<String, Object?> json) {
    return Book._internal(
        id: json[BookModel.id] as int,
        title: json[BookModel.title] as String,
        color: Color(json[BookModel.color] as int),
        cover: json[BookModel.cover] as Uint8List?,
        createTime: DateTime.fromMillisecondsSinceEpoch(
            json[BookModel.createTime] as int),
        lastModifiedTime: DateTime.fromMillisecondsSinceEpoch(
            json[BookModel.lastModifiedTime] as int));
  }

  factory Book._copy({
    int? id,
    String? title,
    Color? color,
    Uint8List? cover,
    DateTime? createTime,
    DateTime? lastModifiedTime,
    required Book original,
  }) {
    return Book._internal(
        id: id ?? original.id,
        title: title ?? original.title,
        color: color ?? original.color,
        cover: cover ?? original.cover,
        createTime: createTime ?? original.createTime,
        lastModifiedTime: lastModifiedTime ?? original.lastModifiedTime);
  }

  Book copy({
    String? title,
    Color? color,
    Uint8List? cover,
    DateTime? lastModifiedTime,
  }) {
    return Book._copy(
        title: title,
        color: color,
        cover: cover,
        lastModifiedTime: lastModifiedTime,
        original: this);
  }

  Map<String, Object?> toJson() => {
        BookModel.id: id,
        BookModel.title: title,
        BookModel.color: color.value,
        BookModel.cover: cover,
        BookModel.createTime: createTime.millisecondsSinceEpoch,
        BookModel.lastModifiedTime: lastModifiedTime.millisecondsSinceEpoch,
      };

  @override
  bool operator ==(Object other) => other is Book && hashCode == other.hashCode;

  @override
  int get hashCode => const MapEquality().hash(toJson());
}
