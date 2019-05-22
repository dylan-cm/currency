class Currency{
  final String amount;
  final String prefix;
  final int cents;
  
  ///Construct Currency from number of hundredths of currency
  ///
  ///Must provide integer number of hundredths of currency such as
  ///cents, pence, CAD, AUS, etc...
  ///May provide a prefix suchas as `$`, `$ `, `CAD`, etc...
  Currency(this.cents, {this.prefix}) 
    : this.amount = _intToString(cents.toString());

  ///Construct Currency from String
  ///
  ///Amount can be in any format as long as the numerical digits, when stripped
  ///of their non numerical counterparts represent hundredths of currency
  ///EX: `$ 1,200.99` represents 120099 cents
  Currency.fromString(String amount, {this.prefix}) 
    : this.amount = _intToString(amount.replaceAllMapped(RegExp(r'[\D]'), (Match m){return '';})),
      this.cents = int.parse(amount.replaceAllMapped(RegExp(r'[\D]'), (Match m){return '';}));
  
  
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

  String spelledOut(){
	final String input = this.cents.toString();

  //Lists of names of numbers
  const List<String> units = ['', 'One ', 'Two ', 'Three ', 'Four ', 'Five ', 'Six ', 'Seven ', 'Eight ', 'Nine '];
  const List<String> teens = ['Ten ', 'Eleven ', 'Twelve ', 'Thirteen ', 'Fourteen ', 'Fifteen ', 'Sixteen ', 'Seventeen ', 'Eighteen ', 'Nineteen '];
  const List<String> tens = ['', '', 'Twenty ', 'Thirty ', 'Forty ', 'Fifty ', 'Sixty ', 'Seventy ', 'Eighty ', 'Ninety '];
  const List<String> thousands = [ '', 'Thousand ', 'Million ', 'Billion ', 'Trillion ', 'Quadrillion ','Quintillion ', 'Sextillion ', 'Septillion ', 'Octillion ','Nonillion ', 'Decillion ', 'Undecillion ', 'Duodecillion ','Tredecillion ', 'Quattuordecillion ', 'Sexdecillion ','Septendecillion ', 'Octodecillion ', 'Novemdecillion ', 'Vigintillion '];

  //Add 'And' and the hundreth's of currency over 100
  var result = input.replaceAllMapped(
    RegExp(r'(\d\d)$'), 
    (Match m){return 'And ${m[1]}/100';}
  );
  //Remove any padding of zeros as to ensure a correct match of thousands place
  result = result.replaceAllMapped(
    RegExp(r'^(0{2,})'), 
    (Match m){return '';}
  );
  
  //If the length of the input is more than 2 digits i.e. more than a dollar
  //Loop through the string i many times where i is the number of digits less 
  //the hundredth's divided by 3
  if(input.length>2) for(int i=0; i<((input.length-2)/3).ceil(); i++){
    //Add a thousands place delimiter based on how many times passed through the loop
    result = result.replaceAllMapped(
      RegExp(r'([1-9]\d{0,2})(?=[A-Z])'), 
      (Match m){return '${m[0]}${thousands[i]}';}
    );
    //Add back in one left padded zero, helps simplify regexp in next step
    result = result.replaceAllMapped(
      RegExp(r'(^\d)(?=\D)'), 
      (Match m){return '0${m[0]}';}
    );
    //Replace 1-99 with appropriate names listed in the arrays above
    result = result.replaceAllMapped(
      RegExp(r'(?=[0-9]{2}\w)(?!$|[0-9]{3})((\d)(\d))'),
      (Match m){
        if(int.parse(m[2])>1) return '${tens[int.parse(m[2])]}${units[int.parse(m[3])]}';
        else if(int.parse(m[2])>0) return '${teens[int.parse(m[3])]}';
        else return '${units[int.parse(m[3])]}';
      }
    );
    //Add a hundreds delimiter when the latest digit is not zero
    result = result.replaceAllMapped(
      RegExp(r'(\d)(?=\D{2,})'), 
      (Match m){
        if(m[0]!='0') return '${units[int.parse(m[0])]}Hundred ';
        else return '';
      }
    );
  }
  //If the length of the input is not more than 2 digits i.e. less than a dollar
  //Add 'Zero ' to the beginning of string
  else result = 'Zero ' + result;
  //Return the result
  return result;
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