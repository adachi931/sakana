//+------------------------------------------------------------------+
//|                                                       TOMATO.mq4 |
//|                                                    adachi daichi |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//--- input parameters
static int Histry = 0;
int   TF=1050;
//リピート間隔
double puls1 = 0.001;
static int Buy[20] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
//売り注文を格納する配列
static int Sell[20] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
extern int magic=2002;
input double lot=0.5;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(MarketInfo(Symbol(),MODE_SPREAD)<=20)
     {
      Entry();
     }
   Comment(AccountInfoDouble(ACCOUNT_MARGIN_LEVEL));
   PosClose();
  }
//+------------------------------------------------------------------+
//| リピート注文ロジック                                                        |
//+------------------------------------------------------------------+
void Entry()
  {
//売りゾーンのマックス価格
   double jouS3 = 1.110;
//売りゾーンのマックス価格ー０．０００１
   double jouS4 = 1.1099;
//買いゾーンのマックス価格
   double ge1  = 1.025;
//買いゾーンのミニマム価格
   double ge2  = 1.0251;
   for(int i =0; i<ArraySize(Sell); i++)
     {
      //買い注文
      buy(ge1,ge2,i);
      //売り注文
      sell(jouS3,jouS4,i);
      //売り価格に売り価格ー０．００１を代入する。
      jouS3=jouS3-puls1;
      //売り価格に売り価格ー０．００１を代入する。
      jouS4=jouS4-puls1;
      //売り価格に買い価格＋０．００１を代入する。
      ge1+=puls1;
      //売り価格に買い価格＋０．００１を代入する。
      ge2+=puls1;
     }
  }

//+------------------------------------------------------------------+
//| ポジション保有状態の買い注文ロジック                                     |
//+------------------------------------------------------------------+
void buy(double ge1,double ge2,int i)
  {
   if(Buy[i]==0&&ge1<Ask&&Ask<ge2)
     {
      Buy[i] = OrderSend(Symbol(),OP_BUY,lot,Ask,3,0,Ask+TF*Point,"BUY",magic,0,clrNONE);
     }
   else
      if(OrderSelect(Buy[i],SELECT_BY_TICKET,MODE_HISTORY)&&OrderType()==0&&OrderCloseTime()!=0)
        {
         Buy[i]=0;
        }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   double jouS3 = 1.110;
   double jouS4 = 1.1099;
   double ge1  = 1.025;
   double ge2  = 1.0251;
   for(int i =0; i<ArraySize(Sell); i++)
     {
      for(int x = OrdersTotal()-1; x>=0; x--)
        {
         if(OrderSelect(x,SELECT_BY_POS,MODE_TRADES==true))
           {
            if(OrderType()==0&&OrderOpenPrice()<ge1+0.0002&&OrderOpenPrice()>ge1-0.0002)
              {
               Buy[i]=OrderTicket();
              }
            else
               if(OrderType()==1&&OrderOpenPrice()<jouS3+0.0002&&OrderOpenPrice()>jouS3-0.0002)
                 {
                  Sell[i]=OrderTicket();
                 }
           }
        }
      jouS3=jouS3-puls1;
      jouS4=jouS4-puls1;
      ge1+=puls1;
      ge2+=puls1;
     }
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|    ポジション保有状態の売り注文ロジック                                  |
//+------------------------------------------------------------------+
void sell(double jouS3,double jouS4,int i)
  {
//もし、注文番号が０で売値がsellkakaku3とsellkakaku3の間だったら
   if(Sell[i]==0&&jouS3>Bid&&Bid>jouS4)
     {
      Sell[i] = OrderSend(Symbol(),OP_SELL,lot,Bid,3,0,Bid-TF*Point,"BUY",magic,0,clrNONE);
     }
   else
      if(OrderSelect(Sell[i],SELECT_BY_TICKET,MODE_HISTORY)&&OrderType()==1&&OrderCloseTime()!=0)
        {
         Sell[i]=0;
        }
  }
  input double ooo=0.002;
  input double eee=3;
//+------------------------------------------------------------------+
//|8カ月後に自動強制決済                                               |
//+------------------------------------------------------------------+
void PosClose()
  {
   for(int x = OrdersTotal()-1; x>=0; x--)
     {
      if(OrderSelect(x,SELECT_BY_POS,MODE_TRADES==true)&&OrderCloseTime()==0)
        {
         if(OrderMagicNumber()==magic)
           {
            if(TimeCurrent()-OrderOpenTime()>=60*60*24*44)
              {
               if(OrderType()==1&&OrderOpenPrice()>Bid&&Bid>OrderOpenPrice()-0.004)
                 {
                  OrderClose(OrderTicket(),OrderLots(),Bid,3000,clrNONE);
                 }
               else
                  if(OrderType()==0&&OrderOpenPrice()<Ask&&Ask<OrderOpenPrice()+0.002)
                    {
                     OrderClose(OrderTicket(),OrderLots(),Bid,3000,clrNONE);
                    }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
