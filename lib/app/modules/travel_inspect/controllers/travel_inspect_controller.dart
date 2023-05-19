import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../common/ui.dart';
import '../../../../main.dart';
import '../../../models/option_model.dart';
import 'package:http/http.dart' as http;

import '../../../routes/app_routes.dart';

class TravelInspectController extends GetxController {
  final currentSlide = 0.obs;
  final quantity = 1.obs;
  final description = ''.obs;
  final travelCard = {}.obs;
  final imageUrl = "".obs;
  final bookingStep = 0.obs;
  final elevation = 0.obs;
  final name = "".obs;
  final email = "".obs;
  final phone = "".obs;
  final address = "".obs;
  final selectUser = false.obs;
  final buttonPressed = false.obs;

  @override
  void onInit() async {
    var arguments = Get.arguments as Map<String, dynamic>;
    travelCard.value = arguments['travelCard'];
    if(travelCard['travel_type'] == "Air"){
      imageUrl.value = "https://images.unsplash.com/photo-1570710891163-6d3b5c47248b?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8NHx8Y2FyZ28lMjBwbGFuZXxlbnwwfHwwfHw%3D&auto=format&fit=crop&w=900&q=60";
    }else if(travelCard['travel_type'] == "Sea"){
      imageUrl.value = "https://media.istockphoto.com/id/591986620/fr/photo/porte-conteneurs-de-fret-générique-en-mer.jpg?b=1&s=170667a&w=0&k=20&c=gZmtr0Gv5JuonEeGmXDfss_yg0eQKNedwEzJHI-OCE8=";
    }else{
      imageUrl.value = "https://media.istockphoto.com/id/859916128/photo/truck-driving-on-the-asphalt-road-in-rural-landscape-at-sunset-with-dark-clouds.jpg?s=612x612&w=0&k=20&c=tGF2NgJP_Y_vVtp4RWvFbRUexfDeq5Qrkjc4YQlUdKc=";
    }
    super.onInit();
  }

  @override
  void onReady() async {
    await refreshEService();
    super.onReady();
  }

  Future refreshEService({bool showMessage = false}) async {
    if (showMessage) {
      //Get.showSnackbar(Ui.SuccessSnackBar(message: eService.value.name + " " + "page refreshed successfully".tr));
    }
  }

  deleteMyTravel(int id)async{
    final box = GetStorage();
    var session_id = box.read("session_id");
    var headers = {
      'Cookie': 'frontend_lang=en_US; $session_id'
    };
    var request = http.Request('DELETE', Uri.parse('${Domain.serverPort}/air/api/travel/delete/$id'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = await response.stream.bytesToString();
      if(json.decode(data)['status'] == 200){
        Get.showSnackbar(Ui.SuccessSnackBar(message: "${json.decode(data)['message']}".tr));
        Navigator.pop(Get.context);
      }else{
        Get.showSnackbar(Ui.ErrorSnackBar(message: "An error occured!".tr));
      }
    }
    else {
      print(response.reasonPhrase);
    }
  }

  Future getEService() async {

  }

  Future getReviews() async {

  }

  bookNow(int travelId)async{
    final box = GetStorage();
    var session_id = box.read('session_id');
    var headers = {
      'Content-Type': 'application/json',
      'Cookie': 'frontend_lang=en_US; $session_id'
    };
    var request = http.Request('POST', Uri.parse('${Domain.serverPort}/air/travel/booking/create'));
    if(selectUser.value) {
      request.body = json.encode({
        "jsonrpc": "2.0",
        "params": {
          "travel_id": travelId,
          "receiver_partner_id": 3,
          "type_of_luggage": description.value,
          "kilo_booked": quantity.value
        }
      });
    }else{
      request.body = json.encode({
        "jsonrpc": "2.0",
        "params": {
          "travel_id": travelId,
          "receiver_name": name.value,
          "receiver_email": email.value,
          "receiver_phone": phone.value,
          "receiver_address": address.value,
          "type_of_luggage": description.value,
          "kilo_booked": quantity.value
        }
      });
    }
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(
        "${name.value}, ${email.value}, ${phone.value} ${address.value} ${description.value} ${quantity.value}"
      );
      var data = await response.stream.bytesToString();
      print(data);
      if(json.decode(data)['result'] != null){
        Get.showSnackbar(Ui.SuccessSnackBar(message: "Book success ".tr));
        Get.toNamed(Routes.BOOKING);
      }else{
        Get.showSnackbar(Ui.ErrorSnackBar(message: "An error occured!".tr));
      }
    }
    else {
      var data = await response.stream.bytesToString();
      print(data);
      Get.showSnackbar(Ui.ErrorSnackBar(message: "An error occured!".tr));
    }
  }

  TextStyle getTitleTheme(Option option) {
    if (option.checked.value) {
      return Get.textTheme.bodyText2.merge(TextStyle(color: Get.theme.colorScheme.secondary));
    }
    return Get.textTheme.bodyText2;
  }

  TextStyle getSubTitleTheme(Option option) {
    if (option.checked.value) {
      return Get.textTheme.caption.merge(TextStyle(color: Get.theme.colorScheme.secondary));
    }
    return Get.textTheme.caption;
  }

  Color getColor(Option option) {
    if (option.checked.value) {
      return Get.theme.colorScheme.secondary.withOpacity(0.1);
    }
    return null;
  }

  void incrementQuantity() {
    quantity.value < 1000 ? quantity.value++ : null;
  }

  void decrementQuantity() {
    quantity.value > 1 ? quantity.value-- : null;
  }
}
