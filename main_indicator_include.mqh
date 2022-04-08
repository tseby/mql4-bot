#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict
#include <my_custom_indicator_includes\draw_objects_include.mqh>
#include <my_custom_indicator_includes\indicator_helper.mqh>

string order_open = "order_is_NOT_open";
//+----------------------------------------------------------------------------------------------------------------+ 
string scan_for_signals(double current_rsi_value, double BB_high, double BB_low){
string scan_for_signals_decider;
if( current_rsi_value < 30 && Low[1] < BB_low && order_open == "order_is_NOT_open" ) 
     {
      typeAction = "buy";
      StartPrice = Bid;
      OpenTime = TimeLocal();
      scan_for_signals_decider = "buy_signal"; 
      signal_confirmation_check = "ready_for_next_step";       
     }
   else
      if(current_rsi_value > 70 && High[1] > BB_high && order_open == "order_is_NOT_open" ) 
        {
         typeAction = "sell";
         StartPrice = Bid;
         OpenTime = TimeLocal();
         scan_for_signals_decider = "sell_signal";      
         signal_confirmation_check = "ready_for_next_step"; 
        }
//Print("order_open: ",order_open," ","  buffer_arrow: ",buffer_arrow_is_drawn);
return scan_for_signals_decider;
}
//+------------------------------------------------------------------------------------------------------------------+ 
// 300 = 5 minutes
// 600 = 10 minutes
// 900 = 15 minutes
// 1200 = 20 minutes
// 1500 = 25 minutes
// 1800 = 30 minutes
int signal_confirmation(){
if(TimeLocal() > OpenTime+900 && signal_confirmation_check == "ready_for_next_step" && buffer_arrow_is_drawn == true)
  {
   OverPrice = Bid;
   updateStats(StartPrice,OverPrice);  
   string nameNumber = assignName(NameNumber++);                                                                 
   CreateLine(OpenTime,StartPrice,DecideColor(),nameNumber);     
   totalSignals++;                                                                       
   toggle_reset();
   Print("Всего сигналов ",totalSignals, "  Прибыльных сигналов ",winWhenBuy+winWhenSell,"  Убыточных сигналов ",lossWhenBuy+lossWhenSell); //, "  %Побед ",((winWhenBuy+winWhenSell)/totalSignals)*100
  }else if(TimeLocal() > OpenTime+900 && signal_confirmation_check == "ready_for_next_step" && buffer_arrow_is_drawn == true)
          {
           OverPrice = Bid;
           updateStats(StartPrice,OverPrice); 
           string nameNumber = assignName(NameNumber++);
           CreateLine(OpenTime,StartPrice,DecideColor(),nameNumber);           
           totalSignals++;                                                            
           toggle_reset();          
           Print("Всего сигналов ",totalSignals, "  Прибыльных сигналов ",winWhenBuy+winWhenSell,"  Убыточных сигналов ",lossWhenBuy+lossWhenSell); //, "  %Побед ",((winWhenBuy+winWhenSell)/totalSignals)*100
          }
return totalSignals;
}
//+------------------------------------------------------------------+
void updateStats(double PassedStartPrice, double PassedOverPrice)
  {

   if(typeAction == "buy")
     {
      if(PassedStartPrice < PassedOverPrice)
        {
         winWhenBuy++;
         isGreen = true;
        }
      else
        {
         lossWhenBuy++;
         isRed = true;
         
        }
     }


   if(typeAction == "sell")
     {
      if(PassedStartPrice > PassedOverPrice)
        {
         winWhenSell++;
         isGreen = true;
         
        }
      else
        {
         lossWhenSell++;
         isRed = true;
         
        }
     }
    
  }