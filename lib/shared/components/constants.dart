import 'package:shop_app_moh_api/modules/login/login_screen.dart';
import 'package:shop_app_moh_api/shared/network/local/cache_helper.dart';

import 'components.dart';

void signOut(context) {
  CacheHelper.removeData(
    key: 'token',
  ).then((value) {
    if (value) {
      navigateAndFinish(
        context,
        ShopLoginScreen(),
      );
    }
  });
}

void printFullText(String text) {
  final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern.allMatches(text).forEach((match) => print(match.group(0)));
}

String? token = '';

String priceFix(String price) {
  if (price.length == 7) {
    return '${price.substring(0, 1)},${price.substring(1, price.length)} L.E';
  } else if (price.length == 6) {
    return '${price.substring(0, 3)},${price.substring(3, price.length)} L.E';
  } else if (price.length == 5) {
    return '${price.substring(0, 2)},${price.substring(2, price.length)} L.E';
  } else if (price.length == 4) {
    return '${price.substring(0, 1)},${price.substring(1, price.length)} L.E';
  } else {
    return '$price  L.E';
  }
}
