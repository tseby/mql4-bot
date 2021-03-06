//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#include <my_custom_indicator_includes\main_indicator_include.mqh>
#include <my_custom_indicator_includes\draw_objects_include.mqh>
#include <my_custom_indicator_includes\indicator_helper.mqh>
#property indicator_buffers 2
#property indicator_plots   2
//--- plot Pin_bar_down
#property indicator_label1  "Pin_bar_down"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Pin_bar_up
#property indicator_label2  "Pin_bar_up"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrChartreuse
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- indicator buffers
double         Pin_bar_downBuffer[];
double         Pin_bar_upBuffer[];

int limit;
int MA_period = 12;
int k_STH = 12;
int d_STH = 3;
int slowing_STH = 3;
int Ma_period = 12;
int RSIPeriod = 10;
int bbPeriod = 20;
double currency_pip_decider;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   Alert("Indicator activated on " + _Symbol);
//--- indicator buffers mapping
   SetIndexBuffer(0, Pin_bar_downBuffer);
   SetIndexBuffer(1, Pin_bar_upBuffer);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
//Хз для чего эти сет интеджеры, но они не работают для отрисовки объекта на чарте
   PlotIndexSetInteger(0, PLOT_ARROW, 242);
   PlotIndexSetInteger(1, PLOT_ARROW, 241);
//--- setting a code from the Wingdings charset that works (the above PlotIndexSetInt не работает)
//А вот эти работают для установки отрисовки объекта на чарте
   SetIndexArrow(0, 242);
   SetIndexArrow(1, 241);

   if(Point() == 0.0001 || Point() == 0.00001)
      currency_pip_decider = 0.0001;
   if(Point() == 0.01 || Point() == 0.001)
      currency_pip_decider = 0.01;
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
  double bandsHigh = iBands(NULL,0,bbPeriod,2,0,0,1,1);
  double bandsMid = iBands(NULL,0,bbPeriod,2,0,0,0,1);
  double bandsLow = iBands(NULL,0,bbPeriod,2,0,0,2,1);

  double OBV_1 = iOBV(NULL,0,PRICE_CLOSE,1);
  double OBV_2 = iOBV(NULL,0,PRICE_CLOSE,2);
  double OBV_3 = iOBV(NULL,0,PRICE_CLOSE,3);
double Moving_avarage = iMA(NULL,0,MA_period,0,MODE_SMA,PRICE_CLOSE,0);//совпадает с дефолтным MA
double Awesome_oscillator_0 = iAO(NULL,0,0);//совпадает с дефолтным AO
double Awesome_oscillator_1 = iAO(NULL,0,1);
double Stochastic = iStochastic(NULL,0,12,3,3,0,0,0,0);//совпадает с дефолтным стохастиком
//+------------------------------------------------------------------+
   double currentRSI = iRSI(NULL, 0, RSIPeriod, PRICE_CLOSE, 0);
   double an_hourRSI = iRSI(NULL,60, RSIPeriod, PRICE_CLOSE, 0);
   double mins30RSI = iRSI(NULL, 30, RSIPeriod, PRICE_CLOSE, 0);
   limit = rates_total - Bars;
   
  if(open[1] == close[1])return(rates_total);
  
   //i<5 от числа, с которым сравнивается i зависит количество обрабатываемых баров
   for(int i = 0; i < limit + 1; i++) 
     {
      if(calculate_pin_bar(currency_pip_decider, high[1], low[1], open[1], close[1]) == 1 && scan_for_signals(currentRSI, bandsHigh, bandsLow,an_hourRSI,mins30RSI) == "buy_signal" && define_low() == "new_low_detected")
        {    
           // i+1 == 1 здесь выступает как shift, индикатор проверят со смещением в 1 бар
            order_open = "";
            Pin_bar_upBuffer[i + 1] = close[i + 1]; 
            buffer_arrow_is_drawn = true; 
           
        }
       
      if(calculate_pin_bar(currency_pip_decider, high[1], low[1], open[1], close[1]) == 0 && scan_for_signals(currentRSI, bandsHigh, bandsLow,an_hourRSI,mins30RSI) == "sell_signal" && define_high() == "new_high_detected")
        {
            order_open = "";
            Pin_bar_downBuffer[i + 1] = close[i + 1];
            buffer_arrow_is_drawn = true; 
            
            
        }
     }
      signal_confirmation();
return(rates_total);
  }

//+------------------------------------------------------------------+
