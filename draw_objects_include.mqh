#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict
#include <my_custom_indicator_includes\main_indicator_include.mqh>
#include <my_custom_indicator_includes\indicator_helper.mqh>
string Name;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateLine(datetime PassedStartTime, double PassedStartPrice, color UseColor,string line_name)
  {
   datetime startPoint = PassedStartTime;
   double endPrice = Bid;
   datetime endPoint = TimeLocal();
   ObjectCreate(line_name, OBJ_TREND, 0, startPoint, PassedStartPrice, endPoint, endPrice);
   ObjectSetInteger(0, line_name, OBJPROP_COLOR, UseColor);
   ObjectSetInteger(0, line_name, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, line_name, OBJPROP_RAY, false);
   ObjectSetInteger(0, line_name, OBJPROP_STYLE,2);
   return;
}
//+------------------------------------------------------------------+
string assignName(int nameNumber){
Name = "Line number ";
Name = Name + IntegerToString(nameNumber);
return Name;
}
//+------------------------------------------------------------------+
 color DecideColor()
  {

   if(isGreen == true)
     {
      TrueColor = clrYellow;
     }
   else
      if(isRed == true)
        {
         TrueColor = clrRed;
        }
   return TrueColor;
   }
//+------------------------------------------------------------------+
int calculate_pin_bar(double digits_for_this_currency, double high, double low, double open, double close){

// Вычисляет размер всей свечи
double size_of_candle = NormalizeDouble(((high - low)/digits_for_this_currency),_Digits); 
// Вычисляет размер тела свечи
double size_of_body_of_candle = MathAbs(NormalizeDouble(((open-close)/digits_for_this_currency),_Digits));
// Вычислят размер нижней тени свечи
double bottom_shadow = NormalizeDouble(((open - low)/digits_for_this_currency),_Digits);
//Вычисляет размер верхней тени свечи
double upper_shadow = NormalizeDouble(((high-open)/digits_for_this_currency),_Digits);
//Вычисляет процентное соотношение размера тени к размеру тела свечи
double bottom_shadow_to_size_of_canlde_percent = NormalizeDouble((bottom_shadow / size_of_candle) * 100,_Digits);
//Вычисляет процентное соотношение тела свечи к размеру всей свечи
double size_of_body_of_candle_to_size_of_candle_percent = NormalizeDouble((size_of_body_of_candle/size_of_candle)*100,_Digits);
//Вычисляет процентное соотношение верхней тени к размеру всей свечи
double upper_shadow_to_size_of_candle_percent = NormalizeDouble((upper_shadow/size_of_candle)*100,_Digits);
//Проверяем является ли последняя свеча пин баром на покупку
if(bottom_shadow_to_size_of_canlde_percent > 55 && size_of_body_of_candle_to_size_of_candle_percent <35 && upper_shadow_to_size_of_candle_percent < 30)
  {
   return 1;
   //Проверяем является ли последняя свеча пин баром на продажу
  }else if(bottom_shadow_to_size_of_canlde_percent < 30 && size_of_body_of_candle_to_size_of_candle_percent <35 && upper_shadow_to_size_of_candle_percent > 55)
          {
     return 0;       
          }
return 2;
}
//+------------------------------------------------------------------+
void Create_high_low_line(color UseColor, string line_name,double low_or_high)
  {
   ObjectCreate(line_name,OBJ_HLINE,0,TimeLocal(),low_or_high);
   ObjectSetInteger(0, line_name, OBJPROP_COLOR, UseColor);
   ObjectSetInteger(0, line_name, OBJPROP_WIDTH, 2);
   //ObjectSetInteger(0, line_name, OBJPROP_RAY, false);
   //ObjectSetInteger(0, line_name, OBJPROP_STYLE,2);
   return;
}