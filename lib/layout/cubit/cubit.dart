import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_app_moh_api/layout/cubit/states.dart';
import 'package:shop_app_moh_api/models/categories_model.dart';
import 'package:shop_app_moh_api/models/change_favorites_model.dart';
import 'package:shop_app_moh_api/models/favorites_model.dart';
import 'package:shop_app_moh_api/models/get_cart.dart';
import 'package:shop_app_moh_api/models/home_model.dart';
import 'package:shop_app_moh_api/models/in_cart_product_model.dart';
import 'package:shop_app_moh_api/models/login_model.dart';
import 'package:shop_app_moh_api/models/product_details_model.dart';
import 'package:shop_app_moh_api/modules/cateogries/cateogries_screen.dart';
import 'package:shop_app_moh_api/modules/favorites/favorites_screen.dart';
import 'package:shop_app_moh_api/modules/products/products_screen.dart';
import 'package:shop_app_moh_api/modules/settings/settings_screen.dart';
import 'package:shop_app_moh_api/shared/components/constants.dart';
import 'package:shop_app_moh_api/shared/network/end_points.dart';
import 'package:shop_app_moh_api/shared/network/remote/dio_helper.dart';

class ShopCubit extends Cubit<ShopStates> {
  ShopCubit() : super(ShopInitialState());

  static ShopCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;

  List<Widget> bottomScreens = [
    ProductsScreen(),
    CategoriesScreen(),
    FavoritesScreen(),
    SettingsScreen(),
  ];

  void changeBottom(int index) {
    currentIndex = index;
    emit(ShopChangeBottomNavState());
  }

  HomeModel? homeModel;

  Map<int, bool> favorites = {};

  void getHomeData() {
    emit(ShopLoadingHomeDataState());

    DioHelper.getData(
      url: HOME,
      token: token,
    ).then((value) {
      homeModel = HomeModel.fromJson(value.data);

      //print(homeModel.data.banners[0].image);
      //print(homeModel.status);

      homeModel!.data!.products.forEach((element) {
        favorites.addAll({
          element.id!: element.inFavorites!,
        });
      });

      //print(favorites.toString());

      emit(ShopSuccessHomeDataState());
    }).catchError((error) {
      print(error.toString());
      emit(ShopErrorHomeDataState());
    });
  }

  CategoriesModel? categoriesModel;

  void getCategories() {
    DioHelper.getData(
      url: GET_CATEGORIES,
    ).then((value) {
      categoriesModel = CategoriesModel.fromJson(value.data);

      emit(ShopSuccessCategoriesState());
    }).catchError((error) {
      print(error.toString());
      emit(ShopErrorCategoriesState());
    });
  }

  ChangeFavoritesModel? changeFavoritesModel;

  void changeFavorites(int productId) {
    favorites[productId] = !favorites[productId]!;

    emit(ShopChangeFavoritesState());

    DioHelper.postData(
      url: FAVORITES,
      data: {
        'product_id': productId,
      },
      token: token,
    ).then((value) {
      changeFavoritesModel = ChangeFavoritesModel.fromJson(value.data);
      print(value.data);

      if (!changeFavoritesModel!.status!) {
        favorites[productId] = !favorites[productId]!;
      } else {
        getFavorites();
      }

      emit(ShopSuccessChangeFavoritesState(changeFavoritesModel!));
    }).catchError((error) {
      favorites[productId] = !favorites[productId]!;

      emit(ShopErrorChangeFavoritesState());
    });
  }

  FavoritesModel? favoritesModel;

  void getFavorites() {
    emit(ShopLoadingGetFavoritesState());

    DioHelper.getData(
      url: FAVORITES,
      token: token,
    ).then((value) {
      favoritesModel = FavoritesModel.fromJson(value.data);
      printFullText(value.data.toString());

      emit(ShopSuccessGetFavoritesState());
    }).catchError((error) {
      print('#########################');
      print(error.toString());

      emit(ShopErrorGetFavoritesState());
    });
  }

  ShopLoginModel? userModel;

  void getUserData() {
    emit(ShopLoadingUserDataState());

    DioHelper.getData(
      url: PROFILE,
      token: token,
    ).then((value) {
      userModel = ShopLoginModel.fromJson(value.data);
      printFullText(userModel!.data!.name!);

      emit(ShopSuccessUserDataState(userModel!));
    }).catchError((error) {
      print(error.toString());
      emit(ShopErrorUserDataState());
    });
  }

  void updateUserData({
    required String name,
    required String email,
    required String phone,
  }) {
    emit(ShopLoadingUpdateUserState());

    DioHelper.putData(
      url: UPDATE_PROFILE,
      token: token,
      data: {
        'name': name,
        'email': email,
        'phone': phone,
      },
    ).then((value) {
      userModel = ShopLoginModel.fromJson(value.data);
      printFullText(userModel!.data!.name!);

      emit(ShopSuccessUpdateUserState(userModel!));
    }).catchError((error) {
      print(error.toString());
      emit(ShopErrorUpdateUserState());
    });
  }

  ProductDetailsModel? productDetailsModel;

  void getProductDetails(int productID) {
    emit(ShopLoadingGetProductDetailsState());
    DioHelper.getData(
      url: 'products/$productID',
      token: token,
    ).then((value) {
      productDetailsModel = ProductDetailsModel.fromJson(value.data);
      emit(ShopSuccessGetProductDetailsState());
    }).catchError((error) {
      print(error.toString());
      emit(ShopErrorGetProductDetailsState());
    });
  }

  AddToCart? addToCart;

  void addProductToCart(int productID) {
    emit(ShopLoadingAddProductToCartState());

    DioHelper.postData(url: CART, token: token, data: {
      'product_id': '$productID',
    }).then((value) {
      addToCart = AddToCart.fromJson(value.data);
      print('${addToCart!.status}, Added Successfully.');
      emit(ShopSuccessAddProductToCartState());
    }).catchError((error) {
      print(error.toString());
      emit(ShopErrorAddProductToCartState());
    });
  }

  GetCart? getCart;

  void getInCartProducts() {
    emit(ShopLoadingGetCartState());
    DioHelper.getData(url: CART, token: token).then((value) {
      getCart = GetCart.fromJson(value.data);
      emit(ShopSuccessGetCartState());
    }).catchError((error) {
      print(error.toString());
      emit(ShopErrorGetCartState());
    });
  }



}
