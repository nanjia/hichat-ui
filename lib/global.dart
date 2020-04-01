import 'dart:io';
import 'models/account.dart';
import 'models/contact.dart';
import 'models/dialogue.dart';
import 'models/activity.dart';
import 'utils.dart';
class Globals{
  static String name = "adfasdf";
  static WebSocket socket;
  static HttpClient client = new HttpClient();
  static AccountProvider accountProvider;
  static ContactProvider contactProvider;
  static DialogueProvider dialogueProvider;
  static ActivityProvider activityProvider;
  static EventBus bus;
  static Account myInfo;
  static String myAvatar;
  static String avatarPath;
  static int navBarSelectedIndex=0;
  static List<Dialogue> recentDialogues = List<Dialogue>();
  static List<Activity> recentActivities = List<Activity>();
  static List<Contact> contacts = List<Contact>();
  }