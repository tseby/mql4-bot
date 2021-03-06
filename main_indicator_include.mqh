//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict
#include <my_custom_indicator_includes\draw_objects_include.mqh>
#include <my_custom_indicator_includes\indicator_helper.mqh>

#define MULTIPLIER 1.7;


string order_open = "order_is_NOT_open";
//+----------------------------------------------------------------------------------------------------------------+
string scan_for_signals(double current_rsi_value, double BB_high, double BB_low, double hour_rsi, double mins30_rsi)
  {
   string scan_for_signals_decider;
   if(hour_rsi < 70 && current_rsi_value < 30 && Low[1] < BB_low && order_open == "order_is_NOT_open")
     {
      typeAction = "buy";
      StartPrice = Bid;
      OpenTime = TimeLocal();
      scan_for_signals_decider = "buy_signal";
      signal_confirmation_check = "ready_for_next_step";
     }
   else
      if(hour_rsi > 30 && current_rsi_value > 70 && High[1] > BB_high && order_open == "order_is_NOT_open")
        {
         typeAction = "sell";
         StartPrice = Bid;
         OpenTime = TimeLocal();
         scan_for_signals_decider = "sell_signal";
         signal_confirmation_check = "ready_for_next_step";
        }
   return scan_for_signals_decider;
  }
//+------------------------------------------------------------------------------------------------------------------+
// 300 = 5 minutes
// 600 = 10 minutes
// 900 = 15 minutes
// 1200 = 20 minutes
// 1500 = 25 minutes
// 1800 = 30 minutes
int signal_confirmation()
  {
   if(TimeLocal() > OpenTime + 1800 && signal_confirmation_check == "ready_for_next_step" && buffer_arrow_is_drawn)
     {
      OverPrice = Bid;
      updateStats(StartPrice, OverPrice);
      string nameNumber = assignName(NameNumber++);
      CreateLine(OpenTime, StartPrice, DecideColor(), nameNumber);
      totalSignals++;
      toggle_reset();
      Print("Signals Total ", totalSignals, "  Wins ", winWhenBuy + winWhenSell, "  Losses ", lossWhenBuy + lossWhenSell); //, "  %Побед ",((winWhenBuy+winWhenSell)/totalSignals)*100
     }
   else
      if(TimeLocal() > OpenTime + 1800 && signal_confirmation_check == "ready_for_next_step" && buffer_arrow_is_drawn)
        {
         OverPrice = Bid;
         updateStats(StartPrice, OverPrice);
         string nameNumber = assignName(NameNumber++);
         CreateLine(OpenTime, StartPrice, DecideColor(), nameNumber);
         totalSignals++;
         toggle_reset();
         Print("Signals Total ", totalSignals, "  Wins ", winWhenBuy + winWhenSell, "  Losses ", lossWhenBuy + lossWhenSell); //, "  %Побед ",((winWhenBuy+winWhenSell)/totalSignals)*100
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
         funds_flow(isGreen, isRed);
        }
      else
        {
         lossWhenBuy++;
         isRed = true;
         funds_flow(isGreen, isRed);
        }
     }


   if(typeAction == "sell")
     {
      if(PassedStartPrice > PassedOverPrice)
        {
         winWhenSell++;
         isGreen = true;
         funds_flow(isGreen, isRed);
        }
      else
        {
         lossWhenSell++;
         isRed = true;
         funds_flow(isGreen, isRed);
        }
     }

  }
//+------------------------------------------------------------------+
string define_high()
  {
   int i;
   color high_color = clrWhite;
   for(i = 2; i <= bars_to_iterate; i++)
     {
      if(High[1] > High[i])
        {
         if(i == bars_to_iterate)
           {
            ObjectDelete("new_high");
            double draw_line_at_high = High[1];
            Create_high_low_line(high_color, "new_high", draw_line_at_high);
            return "new_high_detected";
           }
        }
      else
        {
         return "no_new_high_detected";
        }
     }

   return "define_high_null_pointer";
  }
//+------------------------------------------------------------------+
string define_low()
  {
   int i;
   color low_color = clrRed;
   for(i = 2; i <= bars_to_iterate; i++)
     {
      if(Low[1] < Low[i])
        {
         if(i == bars_to_iterate)
           {
            ObjectDelete("new_low");
            double draw_line_at_low = Low[1];
            Create_high_low_line(low_color, "new_low", draw_line_at_low);
            return "new_low_detected";
           }
        }
      else
        {
         return "no_new_low_detected";
        }
     }

   return "define_low_null_pointer";
  }
//+------------------------------------------------------------------+
double funds_flow(color green, color red)
  {
double multiplier = 0.7;

   if(green)
     {
      earned = earned + (bet_size * multiplier);
      current_funds = current_funds + bet_size;

     } else if(red)
        {
         lost = lost + (bet_size* multiplier);
         current_funds = current_funds - bet_size;

        }
  

Print("Current funds: "+ current_funds +" Earned: " + earned + " Lost: " + lost);
   return current_funds;

  }
//+------------------------------------------------------------------+
