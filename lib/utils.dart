extension StringExtension on String{
  String capitalize(){
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }

  String capitalizeWords({separator= ' '}){
    return split(separator).toList().map((word) => word.capitalize()).join(separator);
  }
}
