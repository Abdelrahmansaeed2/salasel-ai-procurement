import 'package:get/get.dart';

class WelcomePageController extends GetxController {
  RxInt currentIndex = 0.obs;

  void setIndex(int index) {
    currentIndex.value = index;
  }
}
