import 'category_constructor.dart';

List<CategoryConstructor> getCategories() {

  List<CategoryConstructor> _myCategories = [
    CategoryConstructor('BusinessNews', 'images/business_news.jpg'),
    CategoryConstructor('SuccessfulStories', 'images/successful_stories.jpg'),
    CategoryConstructor('LuxuryFood', 'images/luxury_food.jpg'),
    CategoryConstructor('LuxuryCars', 'images/luxury_cars.jpg'),
    CategoryConstructor('LuxuryHomes', 'images/luxury_homes.jpg'),
    CategoryConstructor('LuxuryVacation', 'images/luxury_vacation.jpg'),
    CategoryConstructor('LuxuryClothes', 'images/luxury_clothes.jpg'),
    CategoryConstructor('JewelleryAndArt', 'images/jewellery_art.jpg'),


  ];


  return _myCategories;
}
