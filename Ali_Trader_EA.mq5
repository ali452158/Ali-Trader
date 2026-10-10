//+------------------------------------------------------------------+
//|                                                Ali_Trader_EA.mq5 |
//|        Ali Trader EA - بوت التداول التلقائي لمؤشر Ali Trader     |
//+------------------------------------------------------------------+
//|  يقرأ إشارات مؤشر Ali Trader v1.47 عبر iCustom ويفتح الصفقات     |
//|  تلقائياً مع إدارة كاملة:                                        |
//|   - لوت ثابت أو نسبة مخاطرة % من الرصيد                          |
//|   - فلتر سبريد + حد أقصى للصفقات + صفقة واحدة لكل شمعة           |
//|   - رقم سحري لتمييز صفقات البوت عن صفقاتك اليدوية                |
//|   - ستوب وأهداف من بافرات المؤشر أو ثابتة بالنقاط                |
//|   - نقل للتعادل + تريلينج ستوب + إغلاق جزئي                      |
//|   - إغلاق الصفقة عند إشارة معاكسة                                |
//|   - إشعارات موبايل عند الفتح والإغلاق (MetaQuotes ID)            |
//|                                                                  |
//|  التركيب:                                                        |
//|   1) حمّل Ali_Trader_v1.47.mq5 واضغط Compile في MQL5\Indicators |
//|   2) حمّل هذا الملف واضغط Compile في MQL5\Experts                |
//|   3) اسحب Ali Trader EA على شارت XAUUSD (نفس فريم المؤشر)        |
//|   4) v1.01: اسحب مؤشر Ali Trader على نفس الشارت لرؤية خطوطه      |
//|      وإشاراته - البوت يقرأ المؤشر الظاهر على الشارت تلقائياً      |
//|      (لو مش موجود بيشتغل بخفاء ويعلّمك في لوحة الحالة)           |
//|   5) فعّل زر "التداول الآلي" الأخضر من الشريط العلوي             |
//|                                                                  |
//|  ملاحظات مهمة:                                                   |
//|   - البوت يستدعي المؤشر بإعداداته الافتراضية (الوضع الصارم مفعّل)|
//|     لتغيير إعدادات المؤشر: عدّل القيم الافتراضية داخل ملف المؤشر |
//|     نفسه ثم أعد Compile وأعد إرفاق البوت                         |
//|   - الإشارة تُقرأ من آخر شمعة مغلقة فقط (Non-Repaint)            |
//|   - الإغلاق الجزئي يعمل مع نقل التعادل (لمنع تكراره)             |
//|                                                                  |
//|  تحذير: التداول الآلي بمخاطرة حقيقية - ابدأ على حساب تجريبي     |
//|  وحجم صغير، واختبر في الـ Strategy Tester أولاً.                 |
//+------------------------------------------------------------------+
#property copyright   "Ali Trader EA - بوت التداول التلقائي"
#property link        ""
#property version     "1.01"
#property description "بوت تداول تلقائي يقرأ إشارات مؤشر Ali Trader عبر iCustom"
#property description "v1.01: يقرأ المؤشر الظاهر على الشارت (ChartIndicatorGet) - اللي تشوفه هو اللي يتداول عليه"
#property description "لوت ثابت أو نسبة مخاطرة + فلتر سبريد + رقم سحري + تعادل + تريلينج"
#property description "إغلاق جزئي + إغلاق عند إشارة معاكسة + إشعارات موبايل"

#include <Trade\Trade.mqh>

//--- مصدر الإشارة
enum ENUM_EA_SOURCE
  {
   EA_SRC_ALI  = 0,   // إشارات علي ماستر فقط (موصى به)
   EA_SRC_MAIN = 1,   // إشارات المحرك الرئيسي (SMC) فقط
   EA_SRC_BOTH = 2    // المحركان معاً (الأسرع يعطي الإشارة)
  };

//--- مصدر الستوب
enum ENUM_EA_SL
  {
   EA_SL_IND   = 0,   // من المؤشر (بافر SL)
   EA_SL_FIXED = 1,   // ثابت بالنقاط
   EA_SL_NONE  = 2    // بدون ستوب (غير موصى به)
  };

//--- مصدر الهدف
enum ENUM_EA_TP
  {
   EA_TP_IND1  = 0,   // الهدف الأول TP1 من المؤشر
   EA_TP_IND2  = 1,   // الهدف الثاني TP2 من المؤشر
   EA_TP_IND3  = 2,   // الهدف الثالث TP3 من المؤشر
   EA_TP_FIXED = 3    // ثابت بالنقاط
  };

//+------------------------------------------------------------------+
//| المدخلات                                                         |
//+------------------------------------------------------------------+
input group "=== إعدادات البوت ==="
input long            InpMagic        = 452158;              // الرقم السحري (تمييز صفقات البوت)
input string          InpIndName      = "Ali_Trader_v1.47";  // اسم ملف المؤشر (بدون .ex5)
input ENUM_EA_SOURCE  InpSource       = EA_SRC_ALI;          // مصدر الإشارة
input string          InpTradeComment = "Ali EA";            // تعليق الصفقات

input group "=== حجم الصفقة ==="
input double          InpLots         = 0.01;   // حجم اللوت الثابت
input double          InpRiskPct      = 0.0;    // المخاطرة % من الرصيد (0 = لوت ثابت)
input int             InpMaxPos       = 1;      // أقصى عدد صفقات مفتوحة
input bool            InpOnePerBar    = true;   // صفقة واحدة فقط لكل شمعة
input bool            InpCloseOpp     = true;   // إغلاق الصفقة عند إشارة معاكسة
input int             InpMaxDayTrades = 0;      // أقصى صفقات في اليوم (0 = بلا حد)
input double          InpMaxSpread    = 350;    // أقصى سبريد مسموح (نقاط - 0 = بلا حد)

input group "=== الستوب والأهداف ==="
input ENUM_EA_SL      InpSLMode       = EA_SL_IND;     // مصدر الستوب
input double          InpFixedSLPts   = 1000;   // ستوب ثابت (نقاط) للوضع الثابت أو احتياطي
input double          InpMinSLPts     = 150;    // أقل مسافة ستوب مسموحة (نقاط)
input double          InpMaxSLPts     = 6000;   // أكبر مسافة ستوب مسموحة (نقاط)
input ENUM_EA_TP      InpTPMode       = EA_TP_IND1;    // مصدر الهدف
input double          InpFixedTPPts   = 2000;   // هدف ثابت (نقاط) للوضع الثابت أو احتياطي

input group "=== إدارة الصفقة ==="
input bool            InpUseBE        = true;   // نقل الستوب للتعادل
input double          InpBEAtR        = 1.0;    // التعادل بعد ربح = (أضعاف مسافة الستوب)
input int             InpBEOffsetPts  = 30;     // نقاط ربح فوق سعر الدخول عند التعادل
input bool            InpUseTrail     = false;  // تريلينج ستوب
input double          InpTrailStart   = 800;    // يبدأ التريلينج بعد ربح (نقاط)
input double          InpTrailDist    = 500;    // مسافة التريلينج خلف السعر (نقاط)
input bool            InpPartial      = false;  // إغلاق جزئي عند بلوغ الربح المحدد
input double          InpPartialPct   = 50.0;   // نسبة الإغلاق الجزئي %
input double          InpPartialAtR   = 1.0;    // الإغلاق الجزئي عند ربح = (أضعاف مسافة الستوب)

input group "=== التنبيهات ==="
input bool            InpNotifyOpen   = true;   // إشعار موبايل عند فتح صفقة
input bool            InpNotifyClose  = true;   // إشعار موبايل عند إغلاق صفقة
input bool            InpPopup        = false;  // تنبيه منبثق على الشاشة
input bool            InpShowInfo     = true;   // لوحة حالة على الشارت

//+------------------------------------------------------------------+
//| المتغيرات العامة                                                 |
//+------------------------------------------------------------------+
CTrade    trade;
int       hInd = INVALID_HANDLE;     // مقبض مؤشر Ali Trader
bool      gOwnHandle = false;        // صح = فتحناه بـ iCustom (نسخة خفية نملكها ونحررها)
bool      gHiddenCopy = false;       // صح = لا يوجد مؤشر ظاهر على الشارت
string    gVisName = "";             // اسم المؤشر الظاهر المتصل به
datetime  gLastBarTime = 0;          // وقت آخر شمعة (كشف شمعة جديدة)
bool      gFirstCall  = true;        // أول تيك بعد الإرفاق (تجاهل شمعة قديمة)
datetime  gLastTradeBar = 0;         // آخر شمعة فتحنا فيها صفقة
bool      gIndOldWarned = false;     // تحذير واحد: مؤشر قديم بلا بافرات
bool      gDataWarned = false;       // تحذير واحد: بيانات المؤشر لم تجهز
bool      gPartialActive = false;    // الإغلاق الجزئي مفعّل (يتطلب التعادل)
string    gLastSignalTxt = "لسه مفيش"; // نص آخر إشارة للوحة الحالة
datetime  gTodayDay = 0;             // كاش عداد صفقات اليوم
int       gTodayCnt = 0;
bool      gTodayDirty = true;

//--- أرقام بافرات المؤشر (v1.47)
#define BUF_BUY    0
#define BUF_SELL   1
#define BUF_AB     6
#define BUF_AS     7
#define BUF_SL     8
#define BUF_TP1    9
#define BUF_TP2    10
#define BUF_TP3    11

//+------------------------------------------------------------------+
//| هل قيمة البافر إشارة صحيحة؟ (ليست فارغة)                          |
//+------------------------------------------------------------------+
bool SigOK(const double v)
  {
   return(v != EMPTY_VALUE && v != 0.0 && v > -1e100 && v < 1e100);
  }

//+------------------------------------------------------------------+
//| بداية اليوم بتوقيت السيرفر                                        |
//+------------------------------------------------------------------+
datetime DayStart(datetime t)
  {
   MqlDateTime dt;
   TimeToStruct(t, dt);
   dt.hour = 0; dt.min = 0; dt.sec = 0;
   return(StructToTime(dt));
  }

//+------------------------------------------------------------------+
//| تهيئة البوت                                                      |
//+------------------------------------------------------------------+
int OnInit()
  {
   trade.SetExpertMagicNumber((ulong)InpMagic);
   trade.SetDeviationInPoints(50);
   trade.SetAsyncMode(false);

   //--- اختيار نوع التنفيذ المتاح لدى البروكر
   uint filling = (uint)SymbolInfoInteger(_Symbol, SYMBOL_FILLING_MODE);
   if((filling & SYMBOL_FILLING_FOK) != 0)      trade.SetTypeFilling(ORDER_FILLING_FOK);
   else if((filling & SYMBOL_FILLING_IOC) != 0) trade.SetTypeFilling(ORDER_FILLING_IOC);
   else                                         trade.SetTypeFilling(ORDER_FILLING_RETURN);

   //--- الإغلاق الجزئي يتطلب نقل التعادل (وإلا تكرر بلا نهاية)
   gPartialActive = (InpPartial && InpUseBE);
   if(InpPartial && !InpUseBE)
      Print("Ali Trader EA: الإغلاق الجزئي يحتاج نقل التعادل مفعلاً - تم تعطيل الإغلاق الجزئي");

   //--- تحقق من المدخلات
   if(InpLots <= 0 && InpRiskPct <= 0)
     {
      Alert("Ali Trader EA: حدد حجم لوت صحيح أو نسبة مخاطرة أكبر من صفر");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpRiskPct > 10)
      Print("Ali Trader EA: تحذير - مخاطرة ", InpRiskPct, "% عالية جداً للذهب");

   //--- v1.01: أولوية للمؤشر الظاهر على الشارت (اللي المستخدم شايفه بإعداداته)
   //--- لو مش موجود: نسخة خفية iCustom بالإعدادات الافتراضية
   string visName = FindChartAli();
   if(visName != "")
     {
      hInd = ChartIndicatorGet(0, 0, visName);
      gOwnHandle = false;
      gHiddenCopy = false;
      gVisName = visName;
      Print("Ali Trader EA: تم الربط بالمؤشر الظاهر على الشارت: ", visName);
     }
   else
     {
      hInd = iCustom(_Symbol, _Period, InpIndName);
      gOwnHandle = true;
      gHiddenCopy = true;
      gVisName = "";
      if(hInd == INVALID_HANDLE)
        {
         Alert("Ali Trader EA: فشل فتح المؤشر [", InpIndName,
               "] - حمّل Ali_Trader_v1.47.mq5 واضغط Compile في مجلد Indicators ثم أعد إرفاق البوت");
         return(INIT_FAILED);
        }
      Print("Ali Trader EA: لا يوجد مؤشر Ali Trader على الشارت - يعمل البوت بنسخة خفية بالإعدادات الافتراضية");
      Print("Ali Trader EA: نصيحة - اسحب مؤشر Ali Trader على نفس الشارت لرؤية الإشارات والخطوط (البوت سيقرأه تلقائياً)");
     }

   gFirstCall = true;
   gLastBarTime = 0;
   gLastTradeBar = 0;

   Print("Ali Trader EA جاهز - ", _Symbol, " فريم ", EnumToString(_Period),
         " | مصدر الإشارة: ", EnumToString(InpSource),
         " | الرقم السحري: ", InpMagic);
   if(gHiddenCopy)
      Print("Ali Trader EA: النسخة الخفية تعمل بإعدادات المؤشر الافتراضية - لتغييرها عدّل القيم الافتراضية داخل ملف المؤشر وأعد Compile");
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| إغلاق البوت                                                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   //--- نحرر المقبض فقط لو نسخة iCustom الخاصة بنا
   //--- (تحرير مقبض ChartIndicatorGet قد يزيل المؤشر الظاهر من الشارت)
   if(hInd != INVALID_HANDLE && gOwnHandle)
      IndicatorRelease(hInd);
   hInd = INVALID_HANDLE;
   Comment("");
  }

//+------------------------------------------------------------------+
//| كشف شمعة جديدة (نتجاهل أول تيك بعد الإرفاق)                       |
//+------------------------------------------------------------------+
bool IsNewBar()
  {
   datetime t = iTime(_Symbol, _Period, 0);
   if(gFirstCall)
     {
      gFirstCall = false;
      gLastBarTime = t;
      return(false);
     }
   if(t != gLastBarTime)
     {
      gLastBarTime = t;
      return(true);
     }
   return(false);
  }

//+------------------------------------------------------------------+
//| المحرك الرئيسي - كل تيك                                           |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(hInd == INVALID_HANDLE) return;

   //--- إدارة الصفقات المفتوحة كل تيك (تعادل/تريلينج/جزئي)
   ManagePositions();
   UpdatePanel();

   //--- الإشارات تُفحص مرة واحدة عند فتح كل شمعة جديدة
   if(!IsNewBar()) return;

   //--- v1.01: لو المستخدم سحب المؤشر على الشارت بعد تشغيل البوت - اربطه تلقائياً
   EnsureIndicatorMode();

   int    dir = 0, engine = -1;
   double sl = 0, tp1 = 0, tp2 = 0, tp3 = 0;
   if(!ReadSignal(dir, engine, sl, tp1, tp2, tp3)) return;
   if(dir == 0)
     {
      gLastSignalTxt = "لا إشارة على آخر شمعة مغلقة";
      return;
     }
   gLastSignalTxt = StringFormat("%s (%s) - شمعة %s",
                    (dir > 0 ? "شراء" : "بيع"),
                    (engine == 1 ? "علي ماستر" : "المحرك الرئيسي"),
                    TimeToString(iTime(_Symbol, _Period, 1), TIME_DATE | TIME_MINUTES));

   //--- فلاتر التنفيذ
   if(CountPositions() >= InpMaxPos)
     {
      Print("Ali EA: تخطي الإشارة - وصلنا للحد الأقصى من الصفقات (", InpMaxPos, ")");
      return;
     }
   if(InpOnePerBar && gLastTradeBar == iTime(_Symbol, _Period, 0)) return;
   if(InpMaxDayTrades > 0 && TodayTrades() >= InpMaxDayTrades)
     {
      Print("Ali EA: تخطي الإشارة - بلغنا حد صفقات اليوم (", InpMaxDayTrades, ")");
      return;
     }
   double spread = (double)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
   if(InpMaxSpread > 0 && spread > InpMaxSpread)
     {
      Print("Ali EA: تخطي الإشارة - السبريد ", DoubleToString(spread, 0),
            " أكبر من المسموح ", DoubleToString(InpMaxSpread, 0));
      return;
     }

   //--- إشارة معاكسة؟ نغلق صفقات الاتجاه القديم أولاً
   if(InpCloseOpp) CloseOpposite(dir);
   if(CountPositions() >= InpMaxPos) return;

   //--- حساب مستويات الستوب والهدف
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double pt  = _Point;
   double entryRef = (dir > 0 ? ask : bid);
   double slPrice = 0, tpPrice = 0;

   //--- الستوب
   if(InpSLMode == EA_SL_NONE)
      slPrice = 0;
   else if(InpSLMode == EA_SL_FIXED)
      slPrice = entryRef - dir * InpFixedSLPts * pt;
   else
     {
      if(SigOK(sl))
         slPrice = sl;
      else
        {
         slPrice = entryRef - dir * InpFixedSLPts * pt;
         Print("Ali EA: بافر SL من المؤشر غير متاح - استخدمت الستوب الاحتياطي ",
               DoubleToString(InpFixedSLPts, 0), " نقطة");
        }
     }
   //--- حدود مسافة الستوب (حماية من ATR صغير أو متضخم)
   if(slPrice != 0)
     {
      double distPts = MathAbs(entryRef - slPrice) / pt;
      if(distPts < InpMinSLPts)
        {
         slPrice = entryRef - dir * InpMinSLPts * pt;
         Print("Ali EA: ستوب المؤشر قريب جداً - وسعته لـ ", DoubleToString(InpMinSLPts, 0), " نقطة");
        }
      else if(distPts > InpMaxSLPts)
        {
         slPrice = entryRef - dir * InpMaxSLPts * pt;
         Print("Ali EA: ستوب المؤشر بعيد جداً - قصرته لـ ", DoubleToString(InpMaxSLPts, 0), " نقطة");
        }
     }

   //--- الهدف
   double tpSrc = 0;
   if(InpTPMode == EA_TP_IND1)      tpSrc = tp1;
   else if(InpTPMode == EA_TP_IND2) tpSrc = tp2;
   else if(InpTPMode == EA_TP_IND3) tpSrc = tp3;

   if(InpTPMode == EA_TP_FIXED)
      tpPrice = entryRef + dir * InpFixedTPPts * pt;
   else if(SigOK(tpSrc))
      tpPrice = tpSrc;
   else
     {
      tpPrice = entryRef + dir * InpFixedTPPts * pt;
      Print("Ali EA: بافر TP من المؤشر غير متاح - استخدمت الهدف الاحتياطي ",
            DoubleToString(InpFixedTPPts, 0), " نقطة");
     }

   AdjustStops(dir, slPrice, tpPrice);
   slPrice = (slPrice == 0 ? 0 : NormalizeDouble(slPrice, _Digits));
   tpPrice = (tpPrice == 0 ? 0 : NormalizeDouble(tpPrice, _Digits));

   //--- حجم الصفقة (نسبة مخاطرة أو لوت ثابت)
   double slDistPrice = (slPrice == 0 ? 0 : MathAbs(entryRef - slPrice));
   double lot = CalcLot(slDistPrice);
   if(lot <= 0)
     {
      Print("Ali EA: حجم اللوت غير صالح - تخطي الإشارة");
      return;
     }

   //--- تنفيذ الصفقة
   bool ok = (dir > 0)
             ? trade.Buy(lot, _Symbol, 0.0, slPrice, tpPrice, InpTradeComment)
             : trade.Sell(lot, _Symbol, 0.0, slPrice, tpPrice, InpTradeComment);
   uint rc = trade.ResultRetcode();
   if(ok && (rc == TRADE_RETCODE_DONE || rc == TRADE_RETCODE_DONE_PARTIAL || rc == TRADE_RETCODE_PLACED))
     {
      gLastTradeBar = iTime(_Symbol, _Period, 0);
      string msg = StringFormat("Ali Trader EA: فتح %s %.2f لوت على %s\nالدخول: %s\nالستوب: %s\nالهدف: %s",
                   (dir > 0 ? "شراء" : "بيع"), lot, _Symbol,
                   DoubleToString(trade.ResultPrice(), _Digits),
                   (slPrice == 0 ? "بدون" : DoubleToString(slPrice, _Digits)),
                   (tpPrice == 0 ? "بدون" : DoubleToString(tpPrice, _Digits)));
      Print(msg);
      if(InpNotifyOpen) SendNotification(msg);
      if(InpPopup)      Alert(msg);
     }
   else
      Print("Ali EA: فشل فتح الصفقة - كود ", rc, " (", trade.ResultRetcodeDescription(), ")");
  }
//+------------------------------------------------------------------+
//| v1.01: البحث عن مؤشر Ali Trader الظاهر على نافذة الشارت الرئيسية  |
//+------------------------------------------------------------------+
string FindChartAli()
  {
   int total = ChartIndicatorsTotal(0, 0);
   for(int i = 0; i < total; i++)
     {
      string nm = ChartIndicatorName(0, 0, i);
      if(StringFind(nm, "Ali Trader") == 0)
         return(nm);
     }
   return("");
  }

//+------------------------------------------------------------------+
//| v1.01: لو البوت يعمل بنسخة خفية وظهر المؤشر على الشارت - اربطه    |
//+------------------------------------------------------------------+
void EnsureIndicatorMode()
  {
   if(!gHiddenCopy || hInd == INVALID_HANDLE) return;
   string nm = FindChartAli();
   if(nm == "" || nm == gVisName) return;
   int h = ChartIndicatorGet(0, 0, nm);
   if(h == INVALID_HANDLE) return;
   IndicatorRelease(hInd);          // نسخة iCustom الخاصة بنا - نملكها ونحررها بأمان
   hInd = h;
   gOwnHandle = false;
   gHiddenCopy = false;
   gVisName = nm;
   gDataWarned = false;
   gIndOldWarned = false;
   Print("Ali Trader EA: تم الربط تلقائياً بالمؤشر الظاهر على الشارت: ", nm,
         " - اللي تشوفه هو اللي يتداول عليه ✓");
  }

//+------------------------------------------------------------------+
//| قراءة إشارة آخر شمعة مغلقة من بافرات المؤشر                       |
//+------------------------------------------------------------------+
bool ReadSignal(int &dir, int &engine, double &sl, double &tp1, double &tp2, double &tp3)
  {
   double bB[1], bS[1], aB[1], aS[1];
   if(CopyBuffer(hInd, BUF_BUY, 1, 1, bB) < 1 ||
      CopyBuffer(hInd, BUF_SELL, 1, 1, bS) < 1 ||
      CopyBuffer(hInd, BUF_AB, 1, 1, aB) < 1 ||
      CopyBuffer(hInd, BUF_AS, 1, 1, aS) < 1)
     {
      if(!gDataWarned)
        {
         Print("Ali EA: بيانات المؤشر لم تجهز بعد - سنعيد المحاولة على الشمعة القادمة (انتظر قليلاً بعد الفتح)");
         gDataWarned = true;
        }
      return(false);
     }

   //--- بافرات الستوب والأهداف (متوفرة من v1.47 فقط)
   double bSL[1], bT1[1], bT2[1], bT3[1];
   bool lvOK = (CopyBuffer(hInd, BUF_SL, 1, 1, bSL) >= 1 &&
                CopyBuffer(hInd, BUF_TP1, 1, 1, bT1) >= 1 &&
                CopyBuffer(hInd, BUF_TP2, 1, 1, bT2) >= 1 &&
                CopyBuffer(hInd, BUF_TP3, 1, 1, bT3) >= 1);
   if(!lvOK && !gIndOldWarned)
     {
      Print("Ali EA: تحذير - المؤشر ", InpIndName,
            " لا يملك بافرات SL/TP (نسخة أقدم من v1.47) - سيستخدم البوت الستوب والهدف الثابت");
      gIndOldWarned = true;
     }

   sl  = (lvOK ? bSL[0] : 0);
   tp1 = (lvOK ? bT1[0] : 0);
   tp2 = (lvOK ? bT2[0] : 0);
   tp3 = (lvOK ? bT3[0] : 0);

   bool mBuy = SigOK(bB[0]), mSell = SigOK(bS[0]);
   bool aBuy = SigOK(aB[0]), aSell = SigOK(aS[0]);

   dir = 0; engine = -1;
   if(InpSource != EA_SRC_ALI && (mBuy || mSell))
     {
      dir = (mBuy ? 1 : -1);
      engine = 0;
     }
   else if(InpSource != EA_SRC_MAIN && (aBuy || aSell))
     {
      dir = (aBuy ? 1 : -1);
      engine = 1;
     }

   //--- المحركان معاً وإشارتان متعارضتان على نفس الشمعة = تجاهل للأمان
   if(InpSource == EA_SRC_BOTH && dir != 0 &&
      ((mBuy && dir < 0) || (mSell && dir > 0) ||
       (aBuy && dir < 0) || (aSell && dir > 0)))
     {
      Print("Ali EA: إشارتان متعارضتان على نفس الشمعة - للأمان لن نتداول");
      dir = 0;
     }
   return(true);
  }

//+------------------------------------------------------------------+
//| إدارة الصفقات المفتوحة: إغلاق جزئي + تعادل + تريلينج              |
//+------------------------------------------------------------------+
void ManagePositions()
  {
   double pt   = _Point;
   double bid  = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask  = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   long   stopsLv = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   double minD = stopsLv * pt;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong tk = PositionGetTicket(i);
      if(tk == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if((long)PositionGetInteger(POSITION_MAGIC) != InpMagic) continue;

      long   type  = PositionGetInteger(POSITION_TYPE);
      double entry = PositionGetDouble(POSITION_PRICE_OPEN);
      double sl    = PositionGetDouble(POSITION_SL);
      double tp    = PositionGetDouble(POSITION_TP);
      double vol   = PositionGetDouble(POSITION_VOLUME);

      if(type == POSITION_TYPE_BUY)
        {
         double profitPts = (bid - entry) / pt;
         double risk      = (sl > 0 ? MathAbs(entry - sl) : 0);
         bool   beforeBE  = (sl > 0 && sl < entry);   // لم يصل التعادل بعد

         if(gPartialActive && beforeBE && risk > 0 &&
            profitPts >= InpPartialAtR * risk / pt)
            DoPartial(tk, vol);

         if(InpUseBE && beforeBE && risk > 0 &&
            profitPts >= InpBEAtR * risk / pt)
           {
            double newSL = NormalizeDouble(entry + InpBEOffsetPts * pt, _Digits);
            if(newSL > sl + pt && bid - newSL > minD)
               trade.PositionModify(tk, newSL, tp);
           }

         if(InpUseTrail && profitPts >= InpTrailStart)
           {
            double newSL = NormalizeDouble(bid - InpTrailDist * pt, _Digits);
            if(newSL > sl + pt && bid - newSL > minD)
               trade.PositionModify(tk, newSL, tp);
           }
        }
      else if(type == POSITION_TYPE_SELL)
        {
         double profitPts = (entry - ask) / pt;
         double risk      = (sl > 0 ? MathAbs(sl - entry) : 0);
         bool   beforeBE  = (sl == 0 || sl > entry);

         if(gPartialActive && beforeBE && risk > 0 &&
            profitPts >= InpPartialAtR * risk / pt)
            DoPartial(tk, vol);

         if(InpUseBE && beforeBE && risk > 0 &&
            profitPts >= InpBEAtR * risk / pt)
           {
            double newSL = NormalizeDouble(entry - InpBEOffsetPts * pt, _Digits);
            if((sl == 0 || newSL < sl - pt) && newSL - ask > minD)
               trade.PositionModify(tk, newSL, tp);
           }

         if(InpUseTrail && profitPts >= InpTrailStart)
           {
            double newSL = NormalizeDouble(ask + InpTrailDist * pt, _Digits);
            if((sl == 0 || newSL < sl - pt) && newSL - ask > minD)
               trade.PositionModify(tk, newSL, tp);
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| إغلاق جزئي لجزء من الصفقة                                        |
//+------------------------------------------------------------------+
void DoPartial(const ulong ticket, const double vol)
  {
   double minL = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   double part = vol * InpPartialPct / 100.0;
   if(step > 0) part = MathFloor(part / step) * step;
   double rest = vol - part;
   if(part < minL || rest < minL) return;   // الحجم صغير - لا يمكن التقسيم
   if(trade.PositionClosePartial(ticket, part))
      Print("Ali EA: إغلاق جزئي ", DoubleToString(part, 2), " لوت من الصفقة #", ticket);
  }

//+------------------------------------------------------------------+
//| إغلاق صفقات الاتجاه المعاكس قبل فتح الاتجاه الجديد               |
//+------------------------------------------------------------------+
void CloseOpposite(const int dir)
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong tk = PositionGetTicket(i);
      if(tk == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if((long)PositionGetInteger(POSITION_MAGIC) != InpMagic) continue;
      long t = PositionGetInteger(POSITION_TYPE);
      if((dir > 0 && t == POSITION_TYPE_SELL) || (dir < 0 && t == POSITION_TYPE_BUY))
        {
         if(trade.PositionClose(tk))
            Print("Ali EA: إغلاق صفقة معاكسة #", tk, " قبل فتح الاتجاه الجديد");
        }
     }
  }

//+------------------------------------------------------------------+
//| عدد صفقات البوت المفتوحة على هذا الرمز                            |
//+------------------------------------------------------------------+
int CountPositions()
  {
   int cnt = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong tk = PositionGetTicket(i);
      if(tk == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if((long)PositionGetInteger(POSITION_MAGIC) != InpMagic) continue;
      cnt++;
     }
   return(cnt);
  }

//+------------------------------------------------------------------+
//| إبطال كاش عداد صفقات اليوم                                        |
//+------------------------------------------------------------------+
void TodayTradesInvalidate()
  {
   gTodayDirty = true;
  }

//+------------------------------------------------------------------+
//| عدد صفقات اليوم (كاش - يُحدّث عند الصفقات واليوم الجديد)          |
//+------------------------------------------------------------------+
int TodayTrades()
  {
   datetime d = DayStart(TimeCurrent());
   if(!gTodayDirty && d == gTodayDay) return(gTodayCnt);
   gTodayDay = d; gTodayDirty = false; gTodayCnt = 0;

   if(HistorySelect(d, TimeCurrent() + 60))
     {
      for(int i = 0; i < HistoryDealsTotal(); i++)
        {
         ulong dk = HistoryDealGetTicket(i);
         if(dk == 0) continue;
         if(HistoryDealGetInteger(dk, DEAL_MAGIC) != InpMagic) continue;
         if(HistoryDealGetString(dk, DEAL_SYMBOL) != _Symbol) continue;
         if((ENUM_DEAL_ENTRY)HistoryDealGetInteger(dk, DEAL_ENTRY) == DEAL_ENTRY_IN)
            gTodayCnt++;
        }
     }
   return(gTodayCnt);
  }

//+------------------------------------------------------------------+
//| حساب حجم اللوت (نسبة مخاطرة من الرصيد أو ثابت)                    |
//+------------------------------------------------------------------+
double CalcLot(const double slDistPrice)
  {
   if(InpRiskPct <= 0 || slDistPrice <= 0)
      return(NormalizeLot(InpLots));

   double bal      = AccountInfoDouble(ACCOUNT_BALANCE);
   double riskMoney = bal * InpRiskPct / 100.0;
   double tickVal  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSz   = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   if(tickVal <= 0 || tickSz <= 0) return(NormalizeLot(InpLots));

   double lossPerLot = slDistPrice / tickSz * tickVal;
   if(lossPerLot <= 0) return(NormalizeLot(InpLots));

   double lot = NormalizeLot(riskMoney / lossPerLot);
   Print("Ali EA: مخاطرة ", DoubleToString(InpRiskPct, 1), "% من ", DoubleToString(bal, 2),
         " => لوت ", DoubleToString(lot, 2));
   return(lot);
  }

//+------------------------------------------------------------------+
//| توحيد حجم اللوت حسب حدود البروكر                                  |
//+------------------------------------------------------------------+
double NormalizeLot(double lot)
  {
   double minL = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxL = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   if(step > 0) lot = MathFloor(lot / step + 0.0000001) * step;
   if(lot < minL) lot = minL;
   if(lot > maxL) lot = maxL;
   return(lot);
  }

//+------------------------------------------------------------------+
//| ضبط الستوب والهدف على الحد الأدنى للبروكر (Stops Level)           |
//+------------------------------------------------------------------+
void AdjustStops(const int dir, double &sl, double &tp)
  {
   long   stopsLv = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   double minD    = stopsLv * _Point;
   double a = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double b = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   if(dir > 0)
     {
      if(sl > 0 && a - sl < minD) sl = a - minD;
      if(tp > 0 && tp - a < minD) tp = a + minD;
     }
   else
     {
      if(sl > 0 && sl - b < minD) sl = b + minD;
      if(tp > 0 && b - tp < minD) tp = b - minD;
     }
  }

//+------------------------------------------------------------------+
//| لوحة الحالة على الشارت                                            |
//+------------------------------------------------------------------+
void UpdatePanel()
  {
   if(!InpShowInfo) return;
   double spread = (double)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
   bool autoOK = (TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) != 0 &&
                  MQLInfoInteger(MQL_TRADE_ALLOWED) != 0);
   string txt = "Ali Trader EA v1.01 - " + _Symbol + ", " + EnumToString(_Period)
              + "\nالمؤشر: " + (gHiddenCopy
                 ? "شغال مخفي - اسحب مؤشر Ali Trader على الشارت عشان تشوف إشاراته وخطوطه"
                 : "ظاهر على الشارت ✓ (" + gVisName + ")")
              + "\nالحالة: " + (autoOK ? "التداول الآلي شغال ✓" : "التداول الآلي مقفول - فعّل زر AutoTrading الأخضر")
              + "\nالصفقات المفتوحة: " + IntegerToString(CountPositions()) + " / " + IntegerToString(InpMaxPos)
              + "\nصفقات اليوم: " + IntegerToString(TodayTrades())
              + (InpMaxDayTrades > 0 ? " / " + IntegerToString(InpMaxDayTrades) : "")
              + "\nالسبريد الآن: " + DoubleToString(spread, 0) + " نقطة"
              + "\nآخر إشارة: " + gLastSignalTxt;
   Comment(txt);
  }

//+------------------------------------------------------------------+
//| مراقبة الصفقات المغلقة (ستوب/هدف/إغلاق) + إشعارات الموبايل        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
   if(trans.type != TRADE_TRANSACTION_DEAL_ADD) return;
   ulong dk = trans.deal;
   if(dk == 0 || !HistoryDealSelect(dk)) return;
   if(HistoryDealGetInteger(dk, DEAL_MAGIC) != InpMagic) return;
   if(HistoryDealGetString(dk, DEAL_SYMBOL) != _Symbol) return;

   ENUM_DEAL_ENTRY de = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(dk, DEAL_ENTRY);
   if(de == DEAL_ENTRY_IN)
     {
      //--- صفقة جديدة فُتحت: صفّي كاش عداد اليوم
      //--- (TodayTrades يعيد الحساب تلقائياً لأن اليوم نفسه لكن نحتاج إبطال الكاش)
      TodayTradesInvalidate();
      return;
     }

   if(de == DEAL_ENTRY_OUT || de == DEAL_ENTRY_OUT_BY || de == DEAL_ENTRY_INOUT)
     {
      double profit = HistoryDealGetDouble(dk, DEAL_PROFIT)
                    + HistoryDealGetDouble(dk, DEAL_SWAP)
                    + HistoryDealGetDouble(dk, DEAL_COMMISSION);
      long reason = HistoryDealGetInteger(dk, DEAL_REASON);
      string why = "إغلاق";
      if(reason == DEAL_REASON_SL)      why = "ضرب الستوب";
      else if(reason == DEAL_REASON_TP) why = "حقق الهدف";
      else if(de == DEAL_ENTRY_INOUT)   why = "عكس الصفقة";

      string msg = StringFormat("Ali Trader EA: إغلاق صفقة على %s (%s)\nالنتيجة: %.2f %s",
                   _Symbol, why, profit, AccountInfoString(ACCOUNT_CURRENCY));
      Print(msg);
      if(InpNotifyClose) SendNotification(msg);
      if(InpPopup)       Alert(msg);
      TodayTradesInvalidate();
     }
  }
