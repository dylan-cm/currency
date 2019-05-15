class Currency{
  final String amount;
  final String prefix;
  final int cents;
  
  Currency(this.cents, {this.prefix}) 
    : amount = _intToString(cents.toString());
  
  
  static String _intToString(String s){
    final regPad = RegExp(r'(?<!\d)(?=(\d{1,2})(?!\d))');
    Function matchPad = (Match match) => '${match[0]}0';
    final regCom = RegExp(r'(?<=\d)(?=(\d{3})+(?!\d))');
    Function matchCom = (Match match) => '${match[0]},';
    final regDot = RegExp(r'(?<=\d)(?=(\d{2})(?!\d))');
    Function matchDot = (Match match) => '${match[0]}.';
    
    return s.replaceAllMapped(regPad, matchPad)
     .replaceAllMapped(regPad, matchPad)
     .replaceAllMapped(regDot, matchDot)
     .replaceAllMapped(regCom, matchCom);
  }

  ///The equality operator.
  ///
  ///If [object] type is int returns true if equivalent to [cents].
  ///If [object] type is double returns true if equvalent to [cents]/100.
  ///If [object] type is String returns true if equvalent to [amount].
  ///If [object] type is Currency returns true if [cents] and [prefix] match.
  ///Example:
  ///```
  /// var foo = Currency(100, prefix: '\$');
  /// var foo = Currency(100, prefix: '\$');
  /// print(foo == 1);             //false
  /// print(foo == 100);           //true
  /// print(foo == 1.0);           //true
  /// print(foo == 100.0);         //false
  /// print(foo == '1.00');        //true
  /// print(foo == '\$1.00');      //false
  /// print(foo == '1');           //false
  /// print(foo == Currency(100)); //false
  /// print(foo == foo);           //true
  /// ```
  bool operator ==(Object object){
    if(object.runtimeType==int) return cents==object;
    else if(object.runtimeType==String) return amount==object;
    else if(object.runtimeType==double){
      return object.toString().split('.')[1].length <= 2
        ? cents.toDouble()/100==object
        : false;
    } else return object.toString()==this.toString();
  }

  @override
  String toString()=>(prefix??'') + amount;
}