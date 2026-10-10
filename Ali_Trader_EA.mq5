//+------------------------------------------------------------------+
//|                                                Ali_Trader_EA.mq5 |
//|      Ali Trader EA v2.00 - بوت التداول التلقائي المستقل 100%     |
//+------------------------------------------------------------------+
//|  v2.00 (مستقل): محركا الإشارات مدمجان داخل البوت نفسه:           |
//|   - محرك SMC: كسر الهيكل + أوردرك بلوكس + FVG + سحب سيولة        |
//|   - استراتيجية علي ماستر v6: اختراق 3 شموع + أهداف ATR           |
//|   - كل الفلاتر: اتجاه EMA + جلسات + حجم + ATR + أخبار + DXY      |
//|     + دايفرجنس RSI + ADX + سحب آسيا + توافق الفريمات             |
//|   لا يحتاج مؤشر Ali Trader إطلاقاً - ملف واحد فقط Compile مرة    |
//|   واحدة وتشتغل، وإشارات البوت مطابقة 100% لمؤشر Ali Trader.      |
//|                                                                  |
//|  إدارة التداول:                                                  |
//|   - لوت ثابت أو نسبة مخاطرة % من الرصيد                          |
//|   - فلتر سبريد + حد أقصى للصفقات + صفقة واحدة لكل شمعة           |
//|   - رقم سحري لتمييز صفقات البوت عن صفقاتك اليدوية                |
//|   - ستوب وأهداف من مستويات الإشارة أو ثابتة بالنقاط              |
//|   - نقل للتعادل + تريلينج ستوب + إغلاق جزئي                      |
//|   - إغلاق الصفقة عند إشارة معاكسة                                |
//|   - إشعارات موبايل عند الفتح والإغلاق (MetaQuotes ID)            |
//|                                                                  |
//|  التركيب (أسهل من أي نسخة قبلها - ملف واحد فقط):                 |
//|   1) من المنصة اضغط F4 لفتح MetaEditor                           |
//|   2) انسخ هذا الملف إلى مجلد: MQL5\Experts                       |
//|   3) افتح الملف واضغط Compile (F7) - لن توجد أخطاء               |
//|   4) اسحب Ali Trader EA من نافذة Navigator على شارت XAUUSD       |
//|   5) فعّل زر "التداول الآلي" الأخضر من الشريط العلوي             |
//|   6) راقب لوحة الحالة أسفل يسار الشارت - تظهر فيها كل الحالة     |
//|                                                                  |
//|  ملاحظات مهمة:                                                   |
//|   - الإشارة تُحسب على آخر شمعة مغلقة فقط (Non-Repaint)           |
//|   - كل إعدادات المؤشر الأصلية موجودة هنا بنفس أسمائها            |
//|   - فلتر الأخبار يحتاج اتصال حي بالتقويم (في الباك تست يعطل     |
//|     تلقائياً - سلوك آمن)                                        |
//|                                                                  |
//|  تحذير: التداول الآلي بمخاطرة حقيقية - ابدأ على حساب تجريبي     |
//|  وحجم صغير، واختبر في الـ Strategy Tester أولاً.                 |
//+------------------------------------------------------------------+
#property copyright   "Ali Trader EA - بوت التداول التلقائي المستقل"
#property link        ""
#property version     "2.00"
#property description "بوت مستقل 100%: محركا SMC + علي ماستر مدمجان داخله - لا يحتاج أي مؤشر خارجي"
#property description "ملف واحد Compile مرة واحدة - إشارات مطابقة لمؤشر Ali Trader v1.47"
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
   EA_SL_IND   = 0,   // من مستويات الإشارة (ATR تلقائي)
   EA_SL_FIXED = 1,   // ثابت بالنقاط
   EA_SL_NONE  = 2    // بدون ستوب (غير موصى به)
  };

//--- مصدر الهدف
enum ENUM_EA_TP
  {
   EA_TP_IND1  = 0,   // الهدف الأول TP1 من الإشارة
   EA_TP_IND2  = 1,   // الهدف الثاني TP2 من الإشارة
   EA_TP_IND3  = 2,   // الهدف الثالث TP3 من الإشارة
   EA_TP_FIXED = 3    // ثابت بالنقاط
  };

//--- وضع استراتيجية علي ماستر (مثل المؤشر)
enum ENUM_ALI_MODE
  {
   ALI_MODE_OFF    = 0,  // معطل
   ALI_MODE_STAND  = 1,  // إشارات مستقلة
   ALI_MODE_FILTER = 2   // فلتر تأكيد للإشارات الرئيسية
  };

//+------------------------------------------------------------------+
//| مدخلات البوت (التداول والإدارة)                                  |
//+------------------------------------------------------------------+
input group "=== إعدادات البوت ==="
input long            InpMagic        = 452158;              // الرقم السحري (تمييز صفقات البوت)
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
//| مدخلات محرك الإشارات (مطابقة لمؤشر Ali Trader v1.47)             |
//+------------------------------------------------------------------+
input group "=== إعدادات المحرك: العامة ==="
input ENUM_TIMEFRAMES InpTrendTF     = PERIOD_CURRENT;  // فريم الاتجاه (تلقائي لو Current)
input int             InpMaxBars     = 1500;            // أقصى عدد شموع للحساب

input group "=== إعدادات المحرك: مدرسة SMC ==="
input int             InpSwingLen    = 3;               // قوة السوينج (شموع كل جهة)
input int             InpStructLook  = 150;             // نطاق البحث عن الهيكل (شموع)
input int             InpStructFresh = 40;              // أقصى عمر لكسر الهيكل (شموع)
input bool            InpUseOB       = true;            // تفعيل أوردرك بلوكس
input bool            InpUseFVG      = true;            // تفعيل فجوات FVG
input bool            InpUseSweep    = true;            // تفعيل سحب السيولة
input int             InpFVGMinPts   = 30;              // أقل حجم للفجوة (نقاط)
input int             InpOBValidBars = 200;             // أقصى عمر للمنطقة (شموع)
input bool            InpMTFZones    = true;            // مكافأة مناطق فريم أعلى (+1)

input group "=== إعدادات المحرك: الفلاتر الإلزامية ==="
input bool            InpUseTrend    = true;            // فلتر الاتجاه من فريم أعلى
input bool            InpUseSession  = true;            // فلتر الجلسات
input int             InpLondonStart = 10;              // لندن: بداية (توقيت السيرفر)
input int             InpLondonEnd   = 18;              // لندن: نهاية
input int             InpNYStart     = 15;              // نيويورك: بداية
input int             InpNYEnd       = 22;              // نيويورك: نهاية
input bool            InpUseVolume   = true;            // فلتر الحجم
input double          InpVolMult     = 1.15;            // مضاعف الحجم فوق المتوسط
input int             InpVolPeriod   = 20;              // فترة متوسط الحجم
input bool            InpUseATRFlt   = true;            // فلتر التذبذب ATR
input int             InpATRPeriod   = 14;              // فترة ATR
input double          InpMinATRPts   = 60;              // أقل تذبذب مسموح (نقاط)
input double          InpMaxATRPts   = 900;             // أقصى تذبذب مسموح (نقاط)
input bool            InpUsePD       = true;            // فلتر Premium/Discount (شراء رخيص/بيع غالي)
input bool            InpUseNews     = true;            // فلتر الأخبار الحمراء (تقويم MT5)
input int             InpNewsMin     = 30;              // دقائق الإيقاف قبل/بعد الخبر

input group "=== إعدادات المحرك: قوة الإشارة ==="
input int             InpMinScore      = 6;             // أقل درجة للإشارة المؤكدة (أساس 10 + مكافآت)

input group "=== إعدادات المحرك: ستوب وأهداف SMC (ATR) ==="
input double          InpSL_ATR      = 1.6;             // مسافة الستوب = ATR ×
input double          InpTP1_R       = 1.0;             // الهدف الأول (مضاعف المخاطرة R)
input double          InpTP2_R       = 2.0;             // الهدف الثاني (مضاعف المخاطرة R)
input double          InpTP3_R       = 3.0;             // الهدف الثالث (مضاعف المخاطرة R)

input group "=== إعدادات المحرك: استراتيجية علي ماستر v6 ==="
input ENUM_ALI_MODE   InpAliMode   = ALI_MODE_STAND;    // وضع الاستراتيجية
input bool            InpAliUseATR = true;              // استخدام ATR للستوب والأهداف
input int             InpAliAtrLen = 14;                // فترة ATR الخاصة بالاستراتيجية
input double          InpAliTP1Pts = 1000;              // هدف أول عند تعطيل ATR = 10 دولار (1000 نقطة)
input double          InpAliTP2Pts = 2000;              // هدف ثاني عند تعطيل ATR = 20 دولار (2000 نقطة)
input double          InpAliTP3Pts = 3000;              // هدف ثالث عند تعطيل ATR = 30 دولار (3000 نقطة)
input double          InpAliSLPts  = 1000;              // ستوب عند تعطيل ATR = 10 دولار (1000 نقطة)

input group "=== إعدادات المحرك: تعزيزات الذكاء (v1.43) ==="
input bool            InpUseDXY     = true;    // فلتر الدولار DXY (علاقة عكسية: +1 توافق)
input string          InpDXYSymbol  = "DXY";   // رمز الدولار لدى بروكرك (DXY/USDX/USDIDX...)
input int             InpDXYEMA     = 50;      // فترة EMA للدولار (على فريم الاتجاه)
input bool            InpDXYBlock   = false;   // حظر الإشارة عند تعارض صريح مع الدولار
input bool            InpUseDiv     = true;    // دايفرجنس RSI (+2 نقطة)
input int             InpDivLook    = 60;      // نطاق البحث عن الدايفرجنس (شموع)
input bool            InpUseADX     = true;    // جودة الترند ADX (+1 ترند صحي / -1 عرضي)
input int             InpADXLen     = 14;      // فترة ADX
input double          InpADXMin     = 20.0;    // فوقه ترند صحي (+1)
input double          InpADXFlat    = 15.0;    // تحته سوق عرضي (-1)
input bool            InpUseAsia    = true;    // سحب النطاق الآسيوي (+2 نقطة)
input int             InpAsiaStart  = 2;       // بداية جلسة آسيا (توقيت السيرفر)
input int             InpAsiaEnd    = 9;       // نهاية جلسة آسيا (يجب أن تكون أكبر من البداية)

input group "=== إعدادات المحرك: حماية الانعكاس والدخول الذهبي (v1.44) ==="
input int             InpRevWaitMin  = 10;     // انتظار قبل الإشارة المعاكسة (دقائق - 0 = تعطيل)
input bool            InpGoldenEntry = true;   // الدخول من المنطقة الذهبية فقط (فيبو 0.5-0.618)

input group "=== إعدادات المحرك: فلتر اتجاه الفريمات الأعلى ==="
input bool            InpUseMTFAlign   = true;         // فلتر توافق الفريمات الأعلى (+2 توافق)
input ENUM_TIMEFRAMES InpMTFAlignTF1   = PERIOD_M15;   // فريم توافق أول (يفضل أعلى من الشارت)
input ENUM_TIMEFRAMES InpMTFAlignTF2   = PERIOD_H1;    // فريم توافق ثاني (يفضل أعلى من الشارت)
input int             InpMTFAlignEMA   = 50;           // فترة EMA لقياس اتجاه الفريم
input bool            InpMTFStrict     = true;         // الوضع الصارم: مفيش إشارة غير لما فريمي التوافق يتفقوا مع الاتجاه (v1.46)
input bool            InpMTFAlignBlock = true;         // حظر الإشارة المعاكسة للفريمين معاً

//+------------------------------------------------------------------+
//| الثوابت والمتغيرات العامة                                        |
//+------------------------------------------------------------------+
#define EA_TITLE     "Ali Trader EA v2.00"
#define MAXZ     80
#define MAXMZ    40

CTrade    trade;

//--- حالة التداول للبوت
datetime  gLastBarTime = 0;          // وقت آخر شمعة (كشف شمعة جديدة)
bool      gFirstCall  = true;        // أول تيك بعد الإرفاق (تجاهل شمعة قديمة)
datetime  gLastTradeBar = 0;         // آخر شمعة فتحنا فيها صفقة
bool      gPartialActive = false;    // الإغلاق الجزئي مفعّل (يتطلب التعادل)
string    gLastSignalTxt = "لسه مفيش"; // نص آخر إشارة للوحة الحالة
datetime  gTodayDay = 0;             // كاش عداد صفقات اليوم
int       gTodayCnt = 0;
bool      gTodayDirty = true;

//--- حالة محرك الإشارات (مدمج من المؤشر)
int      hATR = INVALID_HANDLE, hRSI = INVALID_HANDLE;
int      hATRA = INVALID_HANDLE;      // ATR خاص باستراتيجية علي ماستر
int      hEMAF = INVALID_HANDLE, hEMAS = INVALID_HANDLE;
int      hADX = INVALID_HANDLE;         // v1.43+: ADX جودة الترند
int      hDXY = INVALID_HANDLE;         // v1.43+: EMA الدولار (DXY)
int      hMTF1 = INVALID_HANDLE, hMTF2 = INVALID_HANDLE;   // v1.45: EMA فريمي التوافق
string   gDXYUsed = "";                 // v1.43+: رمز الدولار الذي نجح الربط معه
ENUM_TIMEFRAMES gTF = PERIOD_H4;        // فريم الاتجاه الفعلي
double   gNP   = 0.01;                 // النقطة المعادلة (بعد تعادل الخانات)
int      gSecBar = 900;                // ثواني الشمعة الحالية
double   gATR[], gRSI[];               // نسخ مؤشرات مساعدة (سلسلة)
double   gATRA[];                      // نسخة ATR استراتيجية علي ماستر
double   gADX[];                       // v1.43+: نسخ ADX (سلسلة)
datetime gTime[];                      // نسخ شموع الشارت (سلسلة)
double   gOpen[], gHigh[], gLow[], gClose[];
long     gVol[];
bool     gCalcReady = false;           // المحرك جاهز (حساب كامل تم)
bool     gDataWarned = false;          // تحذير واحد: بيانات لم تجهز
datetime gLastProcBar = 0;             // آخر شمعة مغلقة عولجت (كل الشموع الأحدث عولجت)

//--- سجل المناطق (OB / FVG)
datetime zBorn[];  double zTop[], zBot[];
int      zDirA[], zKindA[];             // الاتجاه: 1-1 | النوع: 0=OB 1=FVG
bool     zMitA[];
int      zCount = 0;

//--- مناطق MTF (من فريم الاتجاه الأعلى)
datetime mzBorn[];  double mzTop[], mzBot[];
int      mzDirA[], mzKindA[];
bool     mzMitA[];
int      mzCount = 0;

//--- كاش الأخبار الحمراء
datetime gNewsT[];                     // أوقات الأخبار الحمراء المخزنة
int      gNewsCnt = 0;
datetime gNewsLastLoad = 0;
int      gTsUse = -1;                  // كاش حالة الاتجاه (يُصفّر عند الحساب الكامل)
int      gTsSt  = 0;
datetime gLastSigT = 0;                // v1.44: وقت آخر إشارة مؤكدة (المحرك الرئيسي) - منع الانعكاس
int      gLastSigDir = 0;              // v1.44: اتجاه آخر إشارة مؤكدة (المحرك الرئيسي)
datetime gAliLastSigT = 0;             // v1.44: وقت آخر إشارة علي - منع الانعكاس
int      gAliLastSigDir = 0;           // v1.44: اتجاه آخر إشارة علي
int      gScoreMax = 10;               // v1.43+: سقف الدرجة حسب الميزات المفعلة (10-16)

//--- إشارة آخر شمعة مغلقة (خرج المحرك لكل شمعة)
int      gMainDir = 0;                          // إشارة المحرك الرئيسي للشمعة المعالجة
double   gMainEntry = 0, gMainSL = 0, gMainT1 = 0, gMainT2 = 0, gMainT3 = 0;
int      gAliDirSig = 0;                        // إشارة علي ماستر للشمعة المعالجة
double   gAliEntryS = 0, gAliSLs = 0, gAliT1 = 0, gAliT2 = 0, gAliT3 = 0;

//--- حالة علي ماستر المستمرة
int      gAliDir = 0;                  // 1 شراء / -1 بيع / 0 محايد
datetime gAliLastT = 0;                // وقت آخر شمعة أطلقت إشارة (حماية تكرار)
double   gAliEntry = 0, gAliSL = 0, gAliTP1 = 0, gAliTP2 = 0, gAliTP3 = 0;

//--- هيكل نتيجة التقييم
struct EvalOut
  {
   int    dir;          // 1 شراء / -1 بيع / 0 لا شيء
   int    score;        // الدرجة النهائية
   int    bull;         // درجة السيناريو الصاعد
   int    bear;         // درجة السيناريو الهابط
   bool   bullBreak;    // كسر هيكل صاعد عند هذه الشمعة (لميلاد OB)
   bool   bearBreak;    // كسر هيكل هابط عند هذه الشمعة
   int    bias;         // انحياز الهيكل
   int    bBar;         // شمعة آخر كسر
   int    bType;        // نوع الكسر
  };

//--- نطاق التداول الحالي (للفلتر Premium/Discount + الدخول الذهبي)
struct DealRange
  {
   bool     valid;
   int      dir;        // 1 = الموجة صاعدة (قاع ثم قمة) | -1 هابطة
   double   hi, lo;
   datetime hiT, loT;
   double   eq;         // مستوى التوازن 50%
  };
//+==================================================================+
//| محرك الإشارات المدمج - منقول حرفياً من مؤشر Ali Trader v1.47     |
//| (نفس الحسابات بالضبط: نفس الشروط ونفس المدخلات الافتراضية)       |
//+==================================================================+
string TFToStr(const ENUM_TIMEFRAMES tf)
  {
   string s = EnumToString(tf);
   StringReplace(s, "PERIOD_", "");
   return(s);
  }

//--- هل الشمعة p قمة سوينج؟ (ببيانات متاحة فقط - بدون مستقبل)
bool IsPivotHigh(const int p, const double &high[], const int total)
  {
   if(p - InpSwingLen < 0 || p + InpSwingLen > total - 1)
      return(false);
   for(int k = 1; k <= InpSwingLen; k++)
      if(high[p] <= high[p - k] || high[p] <= high[p + k])
         return(false);
   return(true);
  }
//--- هل الشمعة p قاع سوينج؟
bool IsPivotLow(const int p, const double &low[], const int total)
  {
   if(p - InpSwingLen < 0 || p + InpSwingLen > total - 1)
      return(false);
   for(int k = 1; k <= InpSwingLen; k++)
      if(low[p] >= low[p - k] || low[p] >= low[p + k])
         return(false);
   return(true);
  }

//--- الجلسة الفعلية: 0=خارج 1=لندن 2=نيويورك 3=تداخل
int RawSession(const datetime t)
  {
   MqlDateTime dt;
   TimeToStruct(t, dt);
   int h = dt.hour;
   bool lon = (h >= InpLondonStart && h < InpLondonEnd);
   bool ny  = (h >= InpNYStart && h < InpNYEnd);
   if(lon && ny) return(3);
   if(lon) return(1);
   if(ny)  return(2);
   return(0);
  }

//--- حالة الاتجاه من فريم أعلى عند وقت معين (بآخر شمعة مغلقة HTF)
//--- النتيجة: 1 صاعد / -1 هابط / 0 عرضي
int TrendStateAt(const datetime t)
  {
   int htTotal = iBars(_Symbol, gTF);
   if(htTotal < 210) return(0);
   int sh = iBarShift(_Symbol, gTF, t, false);
   if(sh < 0) sh = 0;
   int use = sh + 1;                       // آخر شمعة مغلقة على فريم الاتجاه
   if(use > htTotal - 2) use = htTotal - 2;
   if(use < 1) return(0);

   if(use == gTsUse) return(gTsSt);      // كاش عام يُصفّر عند الحساب الكامل

   double f[1], s[1];
   if(CopyBuffer(hEMAF, 0, use, 1, f) < 1 ||
      CopyBuffer(hEMAS, 0, use, 1, s) < 1)
      return(0);
   double c = iClose(_Symbol, gTF, use);
   if(c <= 0) return(0);                   // بيانات غير جاهزة

   int st = 0;
   if(f[0] > s[0] && c > s[0])      st = 1;
   else if(f[0] < s[0] && c < s[0]) st = -1;

   gTsUse = use;
   gTsSt  = st;
   return(st);
  }

//--- اتجاه فريم معين عند وقت معين بإغلاق شمعة مغلقة فقط (Non-Repaint)
//--- العائد: 1 صاعد / -1 هابط / 0 بيانات غير جاهزة
int MTFTrendH(const int handle, const ENUM_TIMEFRAMES tf, const datetime t)
  {
   if(handle == INVALID_HANDLE) return(0);
   int tot = iBars(_Symbol, tf);
   if(tot < 5) return(0);
   int sh = iBarShift(_Symbol, tf, t, false);
   if(sh < 0) sh = 0;
   int use = sh + 1;                       // آخر شمعة مغلقة على الفريم
   if(use > tot - 2) use = tot - 2;
   if(use < 1) return(0);
   double em[1];
   if(CopyBuffer(handle, 0, use, 1, em) < 1) return(0);
   double c = iClose(_Symbol, tf, use);
   if(c <= 0) return(0);
   if(c > em[0]) return(1);
   if(c < em[0]) return(-1);
   return(0);
  }

//--- البوابة الموحدة للاتجاه - هل شراء/بيع مسموح الآن؟ (v1.46)
bool MTFAllow(const int dir, const datetime t)
  {
   if(!InpUseMTFAlign) return(true);
   int mtSum = MTFTrendH(hMTF1, InpMTFAlignTF1, t) +
               MTFTrendH(hMTF2, InpMTFAlignTF2, t);
   if(InpMTFStrict)
      return((dir > 0) ? (mtSum >= 2) : (mtSum <= -2));   // صارم: توافق كامل إلزامي
   if(mtSum >= 2)  return(dir > 0);                       // الفريمان صاعدان: شراء فقط
   if(mtSum <= -2) return(dir < 0);                       // الفريمان هابطان: بيع فقط
   return(true);                                          // تعارض/حياد: الاتجاهان مفتوحان
  }

//--- فلتر الدولار DXY - الذهب يتحرك عكس الدولار غالباً
//--- العائد: 1 توافق (+1) / 0 بيانات غير جاهزة / -1 تعارض صريح
int DXYBias(const int dir, const datetime t)
  {
   if(hDXY == INVALID_HANDLE || gDXYUsed == "") return(0);
   int ds = iBarShift(gDXYUsed, gTF, t, false);
   if(ds < 0) return(0);
   datetime bt = iTime(gDXYUsed, gTF, ds);
   //--- شمعة الدولار المغلقة فقط لحظة تقييم شمعة الذهب (ضمان Non-Repaint)
   if(bt > 0 && (long)bt + (long)PeriodSeconds(gTF) > (long)t + (long)gSecBar) ds++;
   double ema[1];
   if(CopyBuffer(hDXY, 0, ds, 1, ema) < 1) return(0);
   double c = iClose(gDXYUsed, gTF, ds);
   if(c <= 0 || ema[0] <= 0) return(0);
   int dxyDir = (c > ema[0]) ? 1 : (c < ema[0]) ? -1 : 0;
   if(dxyDir == 0) return(0);
   return(((dir > 0 && dxyDir < 0) || (dir < 0 && dxyDir > 0)) ? 1 : -1);
  }

//--- دايفرجنس RSI صاعد (+2) - سوينجان مؤكدان بلا أي بيانات مستقبلية
bool BullDivergence(const int base, const double &low[], const int total)
  {
   int p1 = -1, p2 = -1;
   int stop = base - InpDivLook;
   for(int k = base; k >= stop && p2 < 0; k--)
     {
      int p = k + InpSwingLen;             // السوينج يُعرف تماماً عند إغلاق k
      if(IsPivotLow(p, low, total))
        {
         if(p1 < 0) p1 = p;
         else       p2 = p;
        }
     }
   if(p1 < 0 || p2 < 0) return(false);
   if(p1 >= ArraySize(gRSI) || p2 >= ArraySize(gRSI)) return(false);
   return(low[p1] < low[p2] && gRSI[p1] > gRSI[p2] + 1.0);
  }

//--- دايفرجنس هابط: قمة سعرية أعلى مع RSI أدنى (+2 للبيع)
bool BearDivergence(const int base, const double &high[], const int total)
  {
   int p1 = -1, p2 = -1;
   int stop = base - InpDivLook;
   for(int k = base; k >= stop && p2 < 0; k--)
     {
      int p = k + InpSwingLen;
      if(IsPivotHigh(p, high, total))
        {
         if(p1 < 0) p1 = p;
         else       p2 = p;
        }
     }
   if(p1 < 0 || p2 < 0) return(false);
   if(p1 >= ArraySize(gRSI) || p2 >= ArraySize(gRSI)) return(false);
   return(high[p1] > high[p2] && gRSI[p1] < gRSI[p2] - 1.0);
  }

//--- سحب النطاق الآسيوي (+2) - سيت أب ذهبي كلاسيكي
//--- العائد: 1 يدعم الشراء (سحب القاع) / -1 يدعم البيع (سحب القمة)
int AsiaSweepDir(const int base, const int total, const datetime &time[],
                 const double &high[], const double &low[], const double &close[])
  {
   MqlDateTime dt;
   TimeToStruct(time[base], dt);
   if(dt.hour < InpAsiaEnd) return(0);            // آسيا لم تنتهِ بعد

   //--- نطاق آسيا لنفس يوم شمعة التقييم
   datetime day0 = time[base] - (dt.hour * 3600 + dt.min * 60 + dt.sec);
   datetime tA   = day0 + InpAsiaStart * 3600;
   datetime tB   = day0 + InpAsiaEnd   * 3600;

   int bA = iBarShift(_Symbol, _Period, tA, false);
   int bB = iBarShift(_Symbol, _Period, tB, false);
   if(bA < 0 || bB < 0 || bB > bA) return(0);     // لا شموع لآسيا (عطلة)

   int bEnd = (iTime(_Symbol, _Period, bB) == tB) ? bB + 1 : bB;   // آخر شمعة آسيا
   if(bEnd > bA) return(0);

   double aH = high[bA], aL = low[bA];            // حدود النطاق من شموع آسيا
   for(int k = bA - 1; k >= bEnd; k--)
     {
      if(high[k] > aH) aH = high[k];
      if(low[k]  < aL) aL = low[k];
     }

   bool up = false, dn = false;                   // سحب القمة / سحب القاع
   for(int k = bEnd - 1; k >= base; k--)
     {
      if(high[k] > aH) up = true;
      if(low[k]  < aL) dn = true;
     }
   if(up && dn) return(0);                        // كسران متضادان = تشويش
   if(up && close[base] < aH) return(-1);         // اصطياد فوق القمة وإغلاق تحته
   if(dn && close[base] > aL) return(1);          // اصطياد تحت القاع وإغلاق فوقه
   return(0);
  }

//--- سحب السيولة: 1 = كسر قيعان ثم إغلاق فوقها / -1 = كسر قمم ثم إغلاق تحتها
bool SweepDir(const int i, const int dir, const int total,
              const double &high[], const double &low[], const double &close[])
  {
   int st = i + 3, en = i + 3 + 50;
   if(en > total - 1) en = total - 1;
   if(st > en || st >= total) return(false);

   int jEnd = (i + 2 <= total - 1) ? i + 2 : total - 1;

   if(dir > 0)
     {
      double mn = low[st];
      for(int k = st + 1; k <= en; k++)
         if(low[k] < mn) mn = low[k];
      for(int j = jEnd; j >= i; j--)
         if(low[j] < mn && close[j] > mn) return(true);
     }
   else
     {
      double mx = high[st];
      for(int k = st + 1; k <= en; k++)
         if(high[k] > mx) mx = high[k];
      for(int j = jEnd; j >= i; j--)
         if(high[j] > mx && close[j] < mx) return(true);
     }
   return(false);
  }

//--- نموذج شمعة تأكيدي: 1 صاعد / -1 هابط / 0
int CandlePattern(const int i, const double &open[], const double &high[],
                  const double &low[], const double &close[])
  {
   if(i + 1 > ArraySize(close) - 1) return(0);
   double body = MathAbs(close[i] - open[i]);
   double rng  = high[i] - low[i];
   if(rng <= 0) return(0);
   double upW = high[i] - MathMax(open[i], close[i]);
   double dnW = MathMin(open[i], close[i]) - low[i];
   int p = i + 1;
   double bodyP = MathAbs(close[p] - open[p]);

   //--- إنجلف صاعد
   if(close[i] > open[i] && close[p] < open[p] &&
      close[i] > open[p] && open[i] <= close[p] && body > bodyP)
      return(1);
   //--- بين بار صاعد (ذيل سفلي طويل + رفض القيعان)
   if(dnW > body * 2.0 && dnW > upW * 2.0 && dnW > rng * 0.55 &&
      close[i] >= open[i])
      return(1);
   //--- إنجلف هابط
   if(close[i] < open[i] && close[p] > open[p] &&
      close[i] < open[p] && open[i] >= close[p] && body > bodyP)
      return(-1);
   //--- بين بار هابط (ذيل علوي طويل)
   if(upW > body * 2.0 && upW > dnW * 2.0 && upW > rng * 0.55 &&
      close[i] <= open[i])
      return(-1);
   return(0);
  }

//+------------------------------------------------------------------+
//| سجل المناطق: أوردرك بلوكس + فجوات FVG                            |
//+------------------------------------------------------------------+
void ZoneAdd(const datetime born, const double top, const double bot,
             const int dir, const int kind)
  {
   if(top - bot < 2.0 * gNP) return;

   //--- منع التكرار: نفس النوع والاتجاه ولد خلال 10 شموع
   for(int z = 0; z < zCount; z++)
      if(zDirA[z] == dir && zKindA[z] == kind && !zMitA[z])
         if(MathAbs((long)(zBorn[z] - born)) < (long)10 * gSecBar)
            return;

   if(zCount >= MAXZ)
     {
      ArrayRemove(zBorn, 0, 1);  ArrayRemove(zTop, 0, 1);
      ArrayRemove(zBot, 0, 1);   ArrayRemove(zDirA, 0, 1);
      ArrayRemove(zKindA, 0, 1); ArrayRemove(zMitA, 0, 1);
      zCount--;
     }

   int n = zCount;
   ArrayResize(zBorn, n + 1);  ArrayResize(zTop, n + 1);
   ArrayResize(zBot, n + 1);   ArrayResize(zDirA, n + 1);
   ArrayResize(zKindA, n + 1); ArrayResize(zMitA, n + 1);

   zBorn[n] = born;  zTop[n] = top;  zBot[n] = bot;
   zDirA[n] = dir;   zKindA[n] = kind;
   zMitA[n] = false;
   zCount++;
  }

//--- ميلاد فجوة FVG عند إغلاق الشمعة base (بيانات الشمعة نفسها فقط)
void FVGBirth(const int base, const int total, const datetime &time[],
              const double &high[], const double &low[])
  {
   if(!InpUseFVG) return;
   if(base + 2 > total - 1) return;
   double gapUp = low[base] - high[base + 2];
   double gapDn = low[base + 2] - high[base];
   if(gapUp > InpFVGMinPts * gNP)
      ZoneAdd(time[base], low[base], high[base + 2], 1, 1);
   else if(gapDn > InpFVGMinPts * gNP)
      ZoneAdd(time[base], low[base + 2], high[base], -1, 1);
  }

//--- ميلاد أوردرك بلوك عند حدوث كسر هيكل عند الشمعة base
void OBBirth(const int base, const int total, const datetime &time[],
             const double &open[], const double &high[],
             const double &low[], const double &close[], const int dir)
  {
   if(!InpUseOB) return;
   for(int k = base + 1; k <= base + 25 && k <= total - 1; k++)
     {
      if(dir > 0 && close[k] < open[k])      // آخر شمعة هابطة قبل الانفجار الصاعد
        { ZoneAdd(time[k], high[k], low[k], 1, 0); return; }
      if(dir < 0 && close[k] > open[k])      // آخر شمعة صاعدة قبل الانفجار الهابط
        { ZoneAdd(time[k], high[k], low[k], -1, 0); return; }
     }
  }

//--- تحديث حالة المناطق (لمس/إبطال) عند إغلاق الشمعة i
void ZonesUpdate(const int i, const datetime &time[], const double &high[],
                 const double &low[], const double &close[])
  {
   for(int z = 0; z < zCount; z++)
     {
      if(zMitA[z]) continue;
      if(time[i] <= zBorn[z]) continue;    // المنطقة لم تُولد بعد

      if(zDirA[z] > 0)
        {
         if(close[i] < zBot[z]) zMitA[z] = true;          // كسر المنطقة لأسفل
        }
      else
        {
         if(close[i] > zTop[z]) zMitA[z] = true;          // كسر المنطقة لأعلى
        }
     }
  }

//--- هل تفاعل السعر مع منطقة (kind) باتجاه (dir) في نافذة آخر 3 شموع؟
bool ZoneHit(const int base, const int total, const datetime &time[],
             const double &open[], const double &high[], const double &low[],
             const double &close[], const int dir, const int kind)
  {
   datetime tNow = time[base];
   long maxAge = (long)InpOBValidBars * (long)gSecBar;

   for(int z = 0; z < zCount; z++)
     {
      if(zDirA[z] != dir || zKindA[z] != kind || zMitA[z]) continue;
      if((long)(tNow - zBorn[z]) > maxAge) continue;

      int jEnd = (base + 2 <= total - 1) ? base + 2 : total - 1;
      for(int j = jEnd; j >= base; j--)
        {
         if(time[j] < zBorn[z]) continue;
         bool entered = (low[j] <= zTop[z] && high[j] >= zBot[z]);
         if(!entered) continue;
         if(dir > 0 && close[j] > zBot[z] && close[j] > open[j]) return(true);
         if(dir < 0 && close[j] < zTop[z] && close[j] < open[j]) return(true);
        }
     }
   return(false);
  }

//+------------------------------------------------------------------+
//| حساب مستويات الدخول والستوب والأهداف (محرك SMC)                  |
//+------------------------------------------------------------------+
void CalcLevels(const int dir, const double entry, const double atr,
                double &sl, double &tp1, double &tp2, double &tp3)
  {
   double risk = atr * InpSL_ATR;
   if(risk <= 0) risk = 10.0 * gNP;
   if(dir > 0)
     {
      sl  = entry - risk;
      tp1 = entry + risk * InpTP1_R;
      tp2 = entry + risk * InpTP2_R;
      tp3 = entry + risk * InpTP3_R;
     }
   else
     {
      sl  = entry + risk;
      tp1 = entry - risk * InpTP1_R;
      tp2 = entry - risk * InpTP2_R;
      tp3 = entry - risk * InpTP3_R;
     }
  }

//+------------------------------------------------------------------+
//| استراتيجية علي ماستر v6 (شرط اختراق 3 شموع)                      |
//+------------------------------------------------------------------+
double AliHH3(const int i, const double &high[])
  {
   double m = high[i + 1];
   if(high[i + 2] > m) m = high[i + 2];
   if(high[i + 3] > m) m = high[i + 3];
   return(m);
  }

double AliLL3(const int i, const double &low[])
  {
   double m = low[i + 1];
   if(low[i + 2] < m) m = low[i + 2];
   if(low[i + 3] < m) m = low[i + 3];
   return(m);
  }

bool AliBullCond(const int i, const double &open[], const double &high[],
                 const double &low[], const double &close[])
  {
   if(i + 3 > ArraySize(high) - 1) return(false);
   return(close[i] > open[i] && high[i] >= AliHH3(i, high));
  }

bool AliBearCond(const int i, const double &open[], const double &high[],
                 const double &low[], const double &close[])
  {
   if(i + 3 > ArraySize(low) - 1) return(false);
   return(close[i] < open[i] && low[i] <= AliLL3(i, low));
  }

//--- مستويات صفقة علي: TP1 = 1xATR ، TP2 = 2xATR ، TP3 = 3xATR ، SL = 1xATR (أو نقاط ثابتة)
void AliLevels(const int dir, const double entry, const double atr,
               double &sl, double &tp1, double &tp2, double &tp3)
  {
   if(InpAliUseATR && atr > 0)
     {
      tp1 = entry + dir * atr;
      tp2 = entry + dir * atr * 2.0;
      tp3 = entry + dir * atr * 3.0;
      sl  = entry - dir * atr;
     }
   else
     {
      tp1 = entry + dir * InpAliTP1Pts * gNP;
      tp2 = entry + dir * InpAliTP2Pts * gNP;
      tp3 = entry + dir * InpAliTP3Pts * gNP;
      sl  = entry - dir * InpAliSLPts  * gNP;
     }
  }

//--- منع الانعكاس السريع - هل الإشارة المعاكسة مسموحة الآن؟ (v1.44)
bool RevWaitOK(const int dir, const datetime tBar)
  {
   if(InpRevWaitMin <= 0 || gLastSigDir == 0) return(true);
   if(dir == gLastSigDir) return(true);                          // نفس الاتجاه مسموح
   return((long)(tBar - gLastSigT) >= (long)InpRevWaitMin * 60); // المعاكس بعد انتهاء الانتظار
  }

bool AliRevWaitOK(const int dir, const datetime tBar)
  {
   if(InpRevWaitMin <= 0 || gAliLastSigDir == 0) return(true);
   if(dir == gAliLastSigDir) return(true);
   return((long)(tBar - gAliLastSigT) >= (long)InpRevWaitMin * 60);
  }

//+------------------------------------------------------------------+
//| نطاق التداول الحالي (آخر سوينج قمة وقاع مؤكدين)                  |
//+------------------------------------------------------------------+
void GetDealingRange(const int base, const int total, const datetime &time[],
                     const double &high[], const double &low[], DealRange &dr)
  {
   dr.valid = false; dr.dir = 0; dr.hi = 0; dr.lo = 0;
   dr.hiT = 0; dr.loT = 0; dr.eq = 0;

   int jMax = base + 250;
   int jCap = total - 1 - 2 * InpSwingLen;
   if(jCap < 0) return;
   if(jMax > jCap) jMax = jCap;

   int hiP = -1, loP = -1;
   for(int j = base; j <= jMax; j++)
     {
      int p = j + InpSwingLen;
      if(hiP < 0 && IsPivotHigh(p, high, total)) hiP = p;
      if(loP < 0 && IsPivotLow(p, low, total))   loP = p;
      if(hiP >= 0 && loP >= 0) break;
     }
   if(hiP < 0 || loP < 0) return;

   dr.hi = high[hiP];  dr.lo = low[loP];
   dr.hiT = time[hiP]; dr.loT = time[loP];
   if(dr.hi <= dr.lo) return;
   dr.dir   = (dr.hiT > dr.loT) ? 1 : -1;
   dr.eq    = 0.5 * (dr.hi + dr.lo);
   dr.valid = true;
  }

//+------------------------------------------------------------------+
//| فلتر الأخبار الحمراء (تقويم MT5 الاقتصادي - عملات USD)           |
//+------------------------------------------------------------------+
void NewsLoadHistory()
  {
   datetime now = TimeCurrent();
   if(gNewsLastLoad > 0)
     {
      long age = (long)(now - gNewsLastLoad);
      if(gNewsCnt > 0 && age < 3600) return;    // كاش سليم: تحديث كل ساعة
      if(gNewsCnt == 0 && age < 300) return;    // فشل سابق: إعادة محاولة كل 5 دقائق
     }
   gNewsLastLoad = now;
   gNewsCnt = 0;
   ArrayResize(gNewsT, 0);

   datetime from = now - 30 * 86400;            // تغطية 30 يوماً ماضياً
   datetime to   = now + 2 * 86400;

   MqlCalendarValue vals[];
   if(!CalendarValueHistory(vals, from, to, NULL, "USD")) return;
   int n = ArraySize(vals);
   for(int k = 0; k < n; k++)
     {
      MqlCalendarEvent ev;
      if(!CalendarEventById(vals[k].event_id, ev)) continue;
      if(ev.importance != CALENDAR_IMPORTANCE_HIGH) continue;
      int m = gNewsCnt;
      ArrayResize(gNewsT, m + 1);
      gNewsT[m] = vals[k].time;
      gNewsCnt++;
     }
  }

//--- هل اللحظة t داخل نطاق حظر خبر أحمر؟ (لكل الشموع: تاريخية ولحظية)
bool NewsBlockedAt(const datetime t)
  {
   NewsLoadHistory();
   long tl = (long)t;
   for(int k = 0; k < gNewsCnt; k++)
     {
      long tk = (long)gNewsT[k];
      if(tl >= tk - (long)InpNewsMin * 60 && tl <= tk + (long)InpNewsMin * 60)
         return(true);
     }
   return(false);
  }

//+------------------------------------------------------------------+
//| مناطق MTF: مسح فريم الاتجاه الأعلى (OB + FVG) - إعادة بناء كاملة |
//+------------------------------------------------------------------+
void MTFPush(const int bi, const double top, const double bot, const int dir,
             const int kind, const MqlRates &r[], const long maxAge,
             const datetime nowT)
  {
   if(top - bot < 2.0 * gNP) return;
   if((long)(nowT - r[bi].time) > maxAge) return;

   //--- إبطال: إغلاق HTF عبر المنطقة بعد ميلادها
   for(int j = bi - 1; j >= 1; j--)
     {
      if(dir > 0 && r[j].close < bot) return;
      if(dir < 0 && r[j].close > top) return;
     }

   if(mzCount >= MAXMZ)
     {
      ArrayRemove(mzBorn, 0, 1);  ArrayRemove(mzTop, 0, 1);
      ArrayRemove(mzBot, 0, 1);   ArrayRemove(mzDirA, 0, 1);
      ArrayRemove(mzKindA, 0, 1); ArrayRemove(mzMitA, 0, 1);
      mzCount--;
     }
   int n = mzCount;
   ArrayResize(mzBorn, n + 1);  ArrayResize(mzTop, n + 1);
   ArrayResize(mzBot, n + 1);   ArrayResize(mzDirA, n + 1);
   ArrayResize(mzKindA, n + 1); ArrayResize(mzMitA, n + 1);
   mzBorn[n] = r[bi].time;  mzTop[n] = top;  mzBot[n] = bot;
   mzDirA[n] = dir;         mzKindA[n] = kind;
   mzMitA[n] = false;
   mzCount++;
  }

void MTFScan()
  {
   mzCount = 0;
   ArrayResize(mzBorn, 0); ArrayResize(mzTop, 0);  ArrayResize(mzBot, 0);
   ArrayResize(mzDirA, 0); ArrayResize(mzKindA, 0); ArrayResize(mzMitA, 0);

   int nb = iBars(_Symbol, gTF);
   if(nb < 220) return;
   int need = MathMin(nb, 500);
   MqlRates r[];
   ArraySetAsSeries(r, true);
   if(CopyRates(_Symbol, gTF, 0, need, r) < need) return;

   int  len = InpSwingLen;
   long maxAge = (long)InpOBValidBars * (long)PeriodSeconds(gTF);
   datetime nowT = TimeCurrent();

   //--- فحص الهيكل من القديم للجديد (مثل محرك الشارت المحلي)
   double sh = 0, sl = 0;
   for(int j = need - 2 * len - 1; j >= 1; j--)
     {
      int p = j + len;
      if(p + len > need - 1 || p - len < 0) continue;   // حارس مزدوج
      bool ph = true, pl = true;
      for(int k = 1; k <= len; k++)
        {
         if(r[p].high <= r[p - k].high || r[p].high <= r[p + k].high) ph = false;
         if(r[p].low  >= r[p - k].low  || r[p].low  >= r[p + k].low)  pl = false;
        }
      if(ph) sh = r[p].high;
      if(pl) sl = r[p].low;

      if(sh > 0 && r[j].close > sh)
        {
         for(int k2 = j + 1; k2 <= j + 25 && k2 < need; k2++)
            if(r[k2].close < r[k2].open)
              { MTFPush(k2, r[k2].high, r[k2].low, 1, 0, r, maxAge, nowT); break; }
         sh = 0;
        }
      else if(sl > 0 && r[j].close < sl)
        {
         for(int k2 = j + 1; k2 <= j + 25 && k2 < need; k2++)
            if(r[k2].close > r[k2].open)
              { MTFPush(k2, r[k2].high, r[k2].low, -1, 0, r, maxAge, nowT); break; }
         sl = 0;
        }

      //--- فجوات FVG على الفريم الأعلى
      if(j + 2 < need)
        {
         double gu = r[j].low - r[j + 2].high;
         double gd = r[j + 2].low - r[j].high;
         if(gu > InpFVGMinPts * gNP)
            MTFPush(j, r[j].low, r[j + 2].high, 1, 1, r, maxAge, nowT);
         else if(gd > InpFVGMinPts * gNP)
            MTFPush(j, r[j + 2].low, r[j].high, -1, 1, r, maxAge, nowT);
        }
     }
  }

//--- هل السعر داخل منطقة MTF نشطة بنفس الاتجاه؟
bool MTFZoneHit(const int dir, const double price)
  {
   for(int z = 0; z < mzCount; z++)
     {
      if(mzMitA[z] || mzDirA[z] != dir) continue;
      if(price >= mzBot[z] && price <= mzTop[z]) return(true);
     }
   return(false);
  }
//+==================================================================+
//| محرك التقييم: تقييم شمعة واحدة ببيانات متاحة حتى إغلاقها فقط     |
//| (أساس عدم إعادة الرسم - لا استخدام لأي بيانات مستقبلية)          |
//+==================================================================+
void Evaluate(const int base, const int total,
              const datetime &time[], const double &open[],
              const double &high[], const double &low[],
              const double &close[], const long &tvol[], EvalOut &e)
  {
   e.dir = 0; e.score = 0; e.bull = 0; e.bear = 0;
   e.bullBreak = false; e.bearBreak = false;
   e.bias = 0; e.bBar = -1; e.bType = 0;

   if(base < 60) return;
   if(base + InpSwingLen + InpStructLook > total - 2) return;
   if(base >= ArraySize(gATR) || base >= ArraySize(gRSI)) return;

   //--- 1) محرك الهيكل: سوينجات مؤكدة + كسر BOS/CHoCH
   int lo = base + InpStructLook;
   int bias = 0, bBar = -1, bType = 0;
   double sh = 0, sl = 0;
   for(int j = lo; j >= base; j--)
     {
      int p = j + InpSwingLen;              // سوينج يُعرف عند إغلاق j تماماً
      if(IsPivotHigh(p, high, total)) sh = high[p];
      if(IsPivotLow(p, low, total))   sl = low[p];
      if(sh > 0 && close[j] > sh)
        { bType = (bias == -1) ? 2 : 1; bias = 1; bBar = j; sh = 0; }
      else if(sl > 0 && close[j] < sl)
        { bType = (bias == 1) ? -2 : -1; bias = -1; bBar = j; sl = 0; }
     }
   e.bias = bias; e.bBar = bBar; e.bType = bType;
   e.bullBreak = (bBar == base && bType > 0);
   e.bearBreak = (bBar == base && bType < 0);

   //--- 2) بوابة الجلسة
   if(InpUseSession && RawSession(time[base]) == 0) return;

   //--- 3) بوابة الاتجاه
   int tr = TrendStateAt(time[base]);
   if(InpUseTrend && tr == 0) return;

   //--- 4) بوابة التذبذب ATR
   double atr = gATR[base];
   if(atr <= 0) return;
   double atrPts = atr / gNP;
   if(InpUseATRFlt && (atrPts < InpMinATRPts || atrPts > InpMaxATRPts)) return;

   //--- 5) الحجم
   bool volOK = false;
   if(base + InpVolPeriod <= total - 1)
     {
      double s = 0;
      for(int k = base + 1; k <= base + InpVolPeriod; k++)
         s += (double)tvol[k];
      double avg = s / (double)InpVolPeriod;
      if(avg > 0 && (double)tvol[base] >= avg * InpVolMult) volOK = true;
     }
   if(InpUseVolume && !volOK) return;

   //--- 5ب) بوابة الأخبار الحمراء (تاريخية + لحظية بنفس القاعدة)
   if(InpUseNews && NewsBlockedAt(time[base])) return;

   //--- 6) درجة السيناريو الصاعد
   int b = 0;
   if(bias == 1 && bBar >= 0 && (base - bBar) <= InpStructFresh) b += 2;
   if(InpUseSweep && SweepDir(base, 1, total, high, low, close))          b += 2;
   if(ZoneHit(base, total, time, open, high, low, close, 1, 0))           b += 2;
   if(ZoneHit(base, total, time, open, high, low, close, 1, 1))           b += 1;
   if(gRSI[base] > 52.0) b += 1;
   if(volOK)             b += 1;
   if(CandlePattern(base, open, high, low, close) == 1)                   b += 1;
   if(InpUseTrend && tr != 1) b = 0;
   e.bull = b;

   //--- 7) درجة السيناريو الهابط
   int s2 = 0;
   if(bias == -1 && bBar >= 0 && (base - bBar) <= InpStructFresh) s2 += 2;
   if(InpUseSweep && SweepDir(base, -1, total, high, low, close))         s2 += 2;
   if(ZoneHit(base, total, time, open, high, low, close, -1, 0))          s2 += 2;
   if(ZoneHit(base, total, time, open, high, low, close, -1, 1))          s2 += 1;
   if(gRSI[base] < 48.0) s2 += 1;
   if(volOK)             s2 += 1;
   if(CandlePattern(base, open, high, low, close) == -1)                  s2 += 1;
   if(InpUseTrend && tr != -1) s2 = 0;
   e.bear = s2;

   //--- 7ب) فلتر Premium/Discount + بوابة المنطقة الذهبية (v1.44)
   if((InpUsePD || InpGoldenEntry) && (b > 0 || s2 > 0))
     {
      DealRange dr;
      GetDealingRange(base, total, time, high, low, dr);
      if(InpUsePD && dr.valid)
        {
         double eq = 0.5 * (dr.hi + dr.lo);
         if(b > 0 && close[base] > eq)  b = 0;    // شراء في Premium = مرفوض
         if(s2 > 0 && close[base] < eq) s2 = 0;   // بيع في Discount = مرفوض
        }
      //--- الدخول من المنطقة الذهبية فقط (فيبو 0.5 - 0.618)
      if(InpGoldenEntry)
        {
         if(!dr.valid) { b = 0; s2 = 0; }         // لا نطاق واضح = لا دخول
         else
           {
            double grng = dr.hi - dr.lo;
            double gzLo, gzHi;
            if(dr.dir > 0) { gzLo = dr.hi - 0.618 * grng; gzHi = dr.hi - 0.500 * grng; }
            else           { gzLo = dr.lo + 0.500 * grng; gzHi = dr.lo + 0.618 * grng; }
            if(b  > 0 && (close[base] < gzLo || close[base] > gzHi)) b  = 0;
            if(s2 > 0 && (close[base] < gzLo || close[base] > gzHi)) s2 = 0;
           }
        }
     }

   //--- 7ج) مكافأة منطقة MTF (+1 إن كان السعر داخل منطقة فريم أعلى بالاتجاه)
   if(InpMTFZones)
     {
      if(b > 0 && MTFZoneHit(1, close[base]))   b = MathMin(10, b + 1);
      if(s2 > 0 && MTFZoneHit(-1, close[base])) s2 = MathMin(10, s2 + 1);
     }

   //--- 7د) مكافآت الذكاء (DXY + دايفرجنس + ADX + سحب آسيا)
   //--- تُضاف للجهات الحية فقط (b/s2 > 0) فلا تعيد إحياء جهة رفضها فلتر
   if(b > 0 || s2 > 0)
     {
      if(InpUseDXY && gDXYUsed != "")
        {
         int dxyB = DXYBias(1,  time[base]);    // شراء الذهب يتوافق مع دولار هابط
         int dxyS = DXYBias(-1, time[base]);    // بيع الذهب يتوافق مع دولار صاعد
         if(b  > 0 && dxyB > 0) b  += 1;
         if(s2 > 0 && dxyS > 0) s2 += 1;
         if(InpDXYBlock)
           {
            if(b  > 0 && dxyB < 0) b  = 0;      // تعارض صريح مع الدولار = حظر
            if(s2 > 0 && dxyS < 0) s2 = 0;
           }
        }
      if(InpUseDiv)
        {
         if(b  > 0 && BullDivergence(base, low,  total)) b  += 2;
         if(s2 > 0 && BearDivergence(base, high, total)) s2 += 2;
        }
      if(InpUseAsia)
        {
         int asw = AsiaSweepDir(base, total, time, high, low, close);
         if(b  > 0 && asw > 0) b  += 2;          // سحب قيعان آسيا = دعم الشراء
         if(s2 > 0 && asw < 0) s2 += 2;          // سحب قمم آسيا = دعم البيع
        }
      if(InpUseADX && base < ArraySize(gADX))
        {
         if(gADX[base] >= InpADXMin)
           {
            if(b  > 0) b  += 1;                  // ترند صحي: مكافأة الاتجاه
            if(s2 > 0) s2 += 1;
           }
         else if(gADX[base] > 0 && gADX[base] < InpADXFlat)
           {
            if(b  > 0) b  -= 1;                  // سوق عرضي: خصم من الدرجة
            if(s2 > 0) s2 -= 1;
           }
        }
      if(b  > gScoreMax) b  = gScoreMax;
      if(s2 > gScoreMax) s2 = gScoreMax;
      if(b  < 0) b  = 0;
      if(s2 < 0) s2 = 0;
     }

   //--- 7هـ) فلتر توافق الفريمات الأعلى (v1.45/1.46)
   if(InpUseMTFAlign && (b > 0 || s2 > 0))
     {
      int m1 = MTFTrendH(hMTF1, InpMTFAlignTF1, time[base]);
      int m2 = MTFTrendH(hMTF2, InpMTFAlignTF2, time[base]);
      int mtSum = m1 + m2;
      if(b > 0)
        {
         if(mtSum >= 2)                           b  += 2;   // توافق كامل مع الشراء
         else if(InpMTFStrict)                    b  = 0;    // صارم - بلا توافق كامل = رفض
         else if(mtSum <= -2 && InpMTFAlignBlock) b  = 0;    // حظر المعاكس فقط
        }
      if(s2 > 0)
        {
         if(mtSum <= -2)                           s2 += 2;  // توافق كامل مع البيع
         else if(InpMTFStrict)                     s2 = 0;   // صارم - بلا توافق كامل = رفض
         else if(mtSum >= 2 && InpMTFAlignBlock)   s2 = 0;   // حظر المعاكس فقط
        }
      if(b  > gScoreMax) b  = gScoreMax;
      if(s2 > gScoreMax) s2 = gScoreMax;
     }

   //--- 8) القرار (الشموع المغلقة دائماً = عتبة الإشارة المؤكدة)
   int need = InpMinScore;
   if(b >= need && b > s2)      { e.dir = 1;  e.score = b;  }
   else if(s2 >= need && s2 > b){ e.dir = -1; e.score = s2; }
   else                         { e.dir = 0;  e.score = MathMax(b, s2); }
  }

//+==================================================================+
//| حلقة معالجة الشموع المغلقة (نفس جسم حلقة OnCalculate في المؤشر)  |
//| تعالج من fromShift (الأقدم) إلى toShift=1 (الأحدث) - مغلق فقط    |
//| isLive=true فقط عند معالجة الشمعة الأخيرة = يسمح بتنفيذ الصفقة   |
//+==================================================================+
void EngLoop(const int fromShift, const int toShift)
  {
   int total = ArraySize(gTime);
   if(total < 100) return;

   for(int i = fromShift; i >= toShift && i >= 1; i--)
     {
      ZonesUpdate(i, gTime, gHigh, gLow, gClose);
      FVGBirth(i, total, gTime, gHigh, gLow);

      EvalOut e;
      Evaluate(i, total, gTime, gOpen, gHigh, gLow, gClose, gVol, e);

      //--- ميلاد أوردرك بلوك عند كسر هيكل حقيقي
      if(e.bullBreak) OBBirth(i, total, gTime, gOpen, gHigh, gLow, gClose, 1);
      if(e.bearBreak) OBBirth(i, total, gTime, gOpen, gHigh, gLow, gClose, -1);

      double atr = gATR[i];

      //--- بوابة علي ماستر (وضع الفلتر): اشتراط شرط اختراق 3 شموع
      bool aBuyOK = true, aSellOK = true;
      if(InpAliMode == ALI_MODE_FILTER)
        {
         aBuyOK  = AliBullCond(i, gOpen, gHigh, gLow, gClose);
         aSellOK = AliBearCond(i, gOpen, gHigh, gLow, gClose);
        }

      //--- إشارات المحرك الرئيسي (SMC) على الشموع المغلقة
      if(e.dir > 0 && aBuyOK)
        {
         if(e.score >= InpMinScore && RevWaitOK(1, gTime[i]))
           {
            double mSL = 0, mT1 = 0, mT2 = 0, mT3 = 0;
            CalcLevels(1, gClose[i], atr, mSL, mT1, mT2, mT3);
            gLastSigDir = 1; gLastSigT = gTime[i];     // عداد منع الانعكاس
            if(i == 1)
              {
               gMainDir = 1;
               gMainEntry = gClose[i];
               gMainSL = mSL; gMainT1 = mT1; gMainT2 = mT2; gMainT3 = mT3;
              }
           }
        }
      else if(e.dir < 0 && aSellOK)
        {
         if(e.score >= InpMinScore && RevWaitOK(-1, gTime[i]))
           {
            double mSL = 0, mT1 = 0, mT2 = 0, mT3 = 0;
            CalcLevels(-1, gClose[i], atr, mSL, mT1, mT2, mT3);
            gLastSigDir = -1; gLastSigT = gTime[i];
            if(i == 1)
              {
               gMainDir = -1;
               gMainEntry = gClose[i];
               gMainSL = mSL; gMainT1 = mT1; gMainT2 = mT2; gMainT3 = mT3;
              }
           }
        }

      //--- محرك علي ماستر: إشارات مستقلة على الشموع المغلقة (Non-Repaint)
      //--- شرط الشراء: شمعة صاعدة قمتها >= أعلى آخر 3 شموع (مع تبادل الاتجاه)
      if(InpAliMode == ALI_MODE_STAND && i + 3 <= total - 1 &&
         gTime[i] != gAliLastT)
        {
         if(AliBullCond(i, gOpen, gHigh, gLow, gClose) && gAliDir != 1 &&
            AliRevWaitOK(1, gTime[i]) &&
            MTFAllow(1, gTime[i]))
           {
            gAliDir = 1;  gAliLastT = gTime[i];
            gAliEntry = gClose[i];
            AliLevels(1, gClose[i], (i < ArraySize(gATRA) ? gATRA[i] : 0.0),
                      gAliSL, gAliTP1, gAliTP2, gAliTP3);
            gAliLastSigDir = 1; gAliLastSigT = gTime[i];
            if(i == 1)
              {
               gAliDirSig = 1;
               gAliEntryS = gClose[i];
               gAliSLs = gAliSL; gAliT1 = gAliTP1; gAliT2 = gAliTP2; gAliT3 = gAliTP3;
              }
           }
         else if(AliBearCond(i, gOpen, gHigh, gLow, gClose) && gAliDir != -1 &&
                 AliRevWaitOK(-1, gTime[i]) &&
                 MTFAllow(-1, gTime[i]))
           {
            gAliDir = -1;  gAliLastT = gTime[i];
            gAliEntry = gClose[i];
            AliLevels(-1, gClose[i], (i < ArraySize(gATRA) ? gATRA[i] : 0.0),
                      gAliSL, gAliTP1, gAliTP2, gAliTP3);
            gAliLastSigDir = -1; gAliLastSigT = gTime[i];
            if(i == 1)
              {
               gAliDirSig = -1;
               gAliEntryS = gClose[i];
               gAliSLs = gAliSL; gAliT1 = gAliTP1; gAliT2 = gAliTP2; gAliT3 = gAliTP3;
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| نسخ بيانات الشموع والمؤشرات المساعدة (سلسلة: 0 = أحدث شمعة)      |
//+------------------------------------------------------------------+
bool EngCopyData(const int cnt)
  {
   ArraySetAsSeries(gATR, true);
   ArraySetAsSeries(gRSI, true);
   ArraySetAsSeries(gATRA, true);
   ArraySetAsSeries(gADX, true);
   ArraySetAsSeries(gTime, true);
   ArraySetAsSeries(gOpen, true);
   ArraySetAsSeries(gHigh, true);
   ArraySetAsSeries(gLow, true);
   ArraySetAsSeries(gClose, true);
   ArraySetAsSeries(gVol, true);

   if(CopyBuffer(hATR,  0, 0, cnt, gATR)  < cnt) return(false);
   if(CopyBuffer(hRSI,  0, 0, cnt, gRSI)  < cnt) return(false);
   if(CopyBuffer(hATRA, 0, 0, cnt, gATRA) < cnt) return(false);
   if(InpUseADX && CopyBuffer(hADX, 0, 0, cnt, gADX) < cnt) return(false);
   if(CopyTime(_Symbol, _Period, 0, cnt, gTime)       < cnt) return(false);
   if(CopyOpen(_Symbol, _Period, 0, cnt, gOpen)       < cnt) return(false);
   if(CopyHigh(_Symbol, _Period, 0, cnt, gHigh)       < cnt) return(false);
   if(CopyLow(_Symbol, _Period, 0, cnt, gLow)         < cnt) return(false);
   if(CopyClose(_Symbol, _Period, 0, cnt, gClose)     < cnt) return(false);
   if(CopyTickVolume(_Symbol, _Period, 0, cnt, gVol)  < cnt) return(false);
   return(true);
  }

//+------------------------------------------------------------------+
//| الحساب الكامل للتاريخ (مثل أول حساب في المؤشر): بناء المناطق     |
//| والحالة بالكامل ثم مسح فريم الاتجاه الأعلى - بلا تنفيذ صفقات     |
//+------------------------------------------------------------------+
bool EngFullRebuild()
  {
   int rt = Bars(_Symbol, _Period);
   if(rt < 300) return(false);

   int cnt = MathMin(rt, InpMaxBars + 400);
   if(!EngCopyData(cnt)) return(false);

   //--- تصفير الحالة (مثل فرع الحساب الكامل في المؤشر)
   zCount = 0;
   ArrayResize(zBorn, 0); ArrayResize(zTop, 0); ArrayResize(zBot, 0);
   ArrayResize(zDirA, 0); ArrayResize(zKindA, 0); ArrayResize(zMitA, 0);
   mzCount = 0;
   gTsUse = -1; gTsSt = 0;
   gAliDir = 0; gAliLastT = 0;
   gAliEntry = 0; gAliSL = 0; gAliTP1 = 0; gAliTP2 = 0; gAliTP3 = 0;
   gLastSigT = 0; gLastSigDir = 0; gAliLastSigT = 0; gAliLastSigDir = 0;

   int limit = MathMin(rt - 60, InpMaxBars);
   if(limit > cnt - 160) limit = cnt - 160;   // هامش أمان حدود المصفوفات
   if(limit < 0) limit = 0;

   gMainDir = 0; gAliDirSig = 0;
   if(limit >= 1) EngLoop(limit, 1);

   //--- مسح مناطق فريم الاتجاه الأعلى (بعد الحلقة مثل المؤشر تماماً)
   if(InpMTFZones) MTFScan();

   gLastProcBar = iTime(_Symbol, _Period, 1);
   gCalcReady = true;
   return(true);
  }
//+==================================================================+
//| منطق البوت: التهيئة والتنفيذ وإدارة الصفقات                      |
//+==================================================================+
//| بداية اليوم بتوقيت السيرفر                                       |
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
      Print(EA_TITLE, ": الإغلاق الجزئي يحتاج نقل التعادل مفعلاً - تم تعطيل الإغلاق الجزئي");

   //--- تحقق من مدخلات التداول
   if(InpLots <= 0 && InpRiskPct <= 0)
     {
      Alert(EA_TITLE, ": حدد حجم لوت صحيح أو نسبة مخاطرة أكبر من صفر");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpRiskPct > 10)
      Print(EA_TITLE, ": تحذير - مخاطرة ", InpRiskPct, "% عالية جداً للذهب");

   //--- فريم الاتجاه: تلقائي حسب فريم الشارت (مثل المؤشر)
   if(InpTrendTF == PERIOD_CURRENT)
      gTF = (_Period <= PERIOD_M5) ? PERIOD_H1 : PERIOD_H4;
   else
      gTF = InpTrendTF;

   //--- تعادل النقاط حسب عدد الخانات (ذهب 2 أو 3 خانات)
   gNP = _Point * ((_Digits == 3) ? 10.0 : (_Digits == 1) ? 0.1 : 1.0);
   gSecBar = PeriodSeconds(_Period);
   if(gSecBar <= 0) gSecBar = 60;

   //--- سقف الدرجة الديناميكي حسب التعزيزات المفعلة (مثل المؤشر)
   gScoreMax = 10 + (InpUseDXY ? 1 : 0) + (InpUseADX ? 1 : 0) +
               (InpUseDiv ? 2 : 0) + (InpUseAsia ? 2 : 0) +
               (InpUseMTFAlign ? 2 : 0);

   //--- تحقق من مدخلات المحرك (مثل المؤشر تماماً)
   if(InpSwingLen < 1 || InpStructLook < 10 || InpVolPeriod < 2 ||
      InpSL_ATR <= 0.0 || InpATRPeriod < 2 || InpAliAtrLen < 2 ||
      InpMinScore < 1 || InpMinScore > gScoreMax ||
      InpMaxBars < 100 ||
      InpADXLen < 2 || InpDXYEMA < 2 || InpMTFAlignEMA < 2 || InpDivLook < 10 ||
      InpAsiaStart < 0 || InpAsiaStart > 23 ||
      InpAsiaEnd < 1 || InpAsiaEnd > 23 || InpAsiaEnd <= InpAsiaStart ||
      InpADXMin < InpADXFlat ||
      InpTP3_R <= 0.0 || InpAliTP3Pts < 0 ||
      InpRevWaitMin < 0 || InpRevWaitMin > 1440)
     {
      Alert(EA_TITLE, ": قيم مدخلات المحرك غير صالحة - راجع الإعدادات");
      return(INIT_PARAMETERS_INCORRECT);
     }

   //--- مقابض المؤشرات المساعدة (نفس مقابض المؤشر الأصلي)
   hATR  = iATR(_Symbol, _Period, InpATRPeriod);
   hRSI  = iRSI(_Symbol, _Period, 14, PRICE_CLOSE);
   hEMAF = iMA(_Symbol, gTF, 50, 0, MODE_EMA, PRICE_CLOSE);
   hEMAS = iMA(_Symbol, gTF, 200, 0, MODE_EMA, PRICE_CLOSE);
   hATRA = iATR(_Symbol, _Period, MathMax(2, InpAliAtrLen));
   hADX  = iADX(_Symbol, _Period, InpADXLen);

   if(InpUseMTFAlign)
     {
      hMTF1 = iMA(_Symbol, InpMTFAlignTF1, MathMax(2, InpMTFAlignEMA), 0, MODE_EMA, PRICE_CLOSE);
      hMTF2 = iMA(_Symbol, InpMTFAlignTF2, MathMax(2, InpMTFAlignEMA), 0, MODE_EMA, PRICE_CLOSE);
     }

   //--- ربط رمز الدولار (اسمه يختلف بين البروكرات - تجربة تلقائية)
   if(InpUseDXY)
     {
      string cands[7];
      cands[0] = InpDXYSymbol;
      cands[1] = "DXY";      cands[2] = "USDX";        cands[3] = "USDIDX";
      cands[4] = "USDOLLAR"; cands[5] = "DollarIndex"; cands[6] = "USDIndex";
      for(int k = 0; k < 7 && gDXYUsed == ""; k++)
        {
         if(StringLen(cands[k]) <= 0) continue;
         if(SymbolSelect(cands[k], true)) gDXYUsed = cands[k];
        }
      if(gDXYUsed != "")
         hDXY = iMA(gDXYUsed, gTF, InpDXYEMA, 0, MODE_EMA, PRICE_CLOSE);
      if(hDXY == INVALID_HANDLE) gDXYUsed = "";
     }

   if(hATR == INVALID_HANDLE || hRSI == INVALID_HANDLE ||
      hEMAF == INVALID_HANDLE || hEMAS == INVALID_HANDLE ||
      hATRA == INVALID_HANDLE || hADX == INVALID_HANDLE)
     {
      Alert(EA_TITLE, ": فشل إنشاء مقابض المؤشرات المساعدة");
      return(INIT_FAILED);
     }
   if(InpUseDXY && gDXYUsed == "")
      Print(EA_TITLE, ": تنبيه - رمز الدولار غير متوفر لدى البروكر، فلتر DXY معطل تلقائياً");

   gFirstCall = true;
   gLastBarTime = 0;
   gLastTradeBar = 0;
   gCalcReady = false;
   gLastProcBar = 0;

   Print(EA_TITLE, " جاهز ✓ - ", _Symbol, " digits=", _Digits,
         " | بوت مستقل 100% لا يحتاج أي مؤشر خارجي",
         " | DXY: ", ((gDXYUsed == "") ? "معطل" : gDXYUsed),
         " | سقف الدرجة: ", gScoreMax);
   Print(EA_TITLE, ": سيبدأ بفحص التاريخ لبناء الحالة (لحظات) ثم يتداول من أول شمعة جديدة");

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| إغلاق البوت                                                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(hATR  != INVALID_HANDLE) IndicatorRelease(hATR);
   if(hRSI  != INVALID_HANDLE) IndicatorRelease(hRSI);
   if(hEMAF != INVALID_HANDLE) IndicatorRelease(hEMAF);
   if(hEMAS != INVALID_HANDLE) IndicatorRelease(hEMAS);
   if(hATRA != INVALID_HANDLE) IndicatorRelease(hATRA);
   if(hADX  != INVALID_HANDLE) IndicatorRelease(hADX);
   if(hDXY  != INVALID_HANDLE) IndicatorRelease(hDXY);
   if(hMTF1 != INVALID_HANDLE) IndicatorRelease(hMTF1);
   if(hMTF2 != INVALID_HANDLE) IndicatorRelease(hMTF2);
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
   //--- إدارة الصفقات المفتوحة كل تيك (تعادل/تريلينج/جزئي)
   ManagePositions();

   //--- بناء حالة المحرك من التاريخ إن لم تكن جاهزة (لحظات قليلة)
   if(!gCalcReady)
     {
      if(!EngFullRebuild())
        {
         if(!gDataWarned)
           {
            Print(EA_TITLE, ": بيانات السوق لم تجهز بعد - جاري إعادة المحاولة تلقائياً...");
            gDataWarned = true;
           }
         UpdatePanel();
         return;
        }
      gDataWarned = false;
      Print(EA_TITLE, ": المحرك جاهز ✓ - تم فحص التاريخ وبناء كل الحالة");
     }

   UpdatePanel();

   //--- الإشارات تُعالج مرة واحدة عند فتح كل شمعة جديدة
   if(!IsNewBar()) return;

   //--- حماية: إعادة تحميل التاريخ (مزامنة/انقطاع) = إعادة بناء كاملة
   if(gLastProcBar > 0 && iBarShift(_Symbol, _Period, gLastProcBar, true) < 0)
     {
      gCalcReady = false;
      return;
     }

   //--- معالجة كل الشموع المغلقة منذ آخر معالجة (غالباً شمعة واحدة)
   int shLast = iBarShift(_Symbol, _Period, gLastProcBar, true);
   int nnew = shLast - 1;                 // عدد الشموع المغلقة الجديدة
   if(nnew > 0)
     {
      if(nnew > InpMaxBars) nnew = InpMaxBars;
      int cnt = MathMin(Bars(_Symbol, _Period), InpMaxBars + 400);
      if(!EngCopyData(cnt))
        {
         gCalcReady = false;             // بيانات لم تجهز - إعادة بناء كاملة
         return;
        }
      gMainDir = 0; gAliDirSig = 0;
      EngLoop(nnew, 1);
      if(InpMTFZones) MTFScan();          // مثل المؤشر: بعد الحلقة عند كل شمعة جديدة
      gLastProcBar = iTime(_Symbol, _Period, 1);
     }

   //--- تنفيذ الإشارة إن وجدت على آخر شمعة مغلقة
   TryExecute();
  }

//+------------------------------------------------------------------+
//| دمج إشارتي المحركين حسب مصدر الإشارة وتنفيذ الصفقة                |
//+------------------------------------------------------------------+
void TryExecute()
  {
   int    dir = 0, engine = -1;
   double sl = 0, tp1 = 0, tp2 = 0, tp3 = 0;

   bool mSig = (gMainDir != 0);
   bool aSig = (gAliDirSig != 0);

   if(InpSource != EA_SRC_ALI && mSig)
     {
      dir = gMainDir; engine = 0;
      sl = gMainSL; tp1 = gMainT1; tp2 = gMainT2; tp3 = gMainT3;
     }
   else if(InpSource != EA_SRC_MAIN && aSig)
     {
      dir = gAliDirSig; engine = 1;
      sl = gAliSLs; tp1 = gAliT1; tp2 = gAliT2; tp3 = gAliT3;
     }

   if(dir == 0)
     {
      gLastSignalTxt = "لا إشارة على آخر شمعة مغلقة";
      return;
     }

   //--- المحركان معاً وإشارتان متعارضتان على نفس الشمعة = تجاهل للأمان
   if(InpSource == EA_SRC_BOTH && dir != 0 &&
      ((mSig && gMainDir != dir) || (aSig && gAliDirSig != dir)))
     {
      Print(EA_TITLE, ": إشارتان متعارضتان على نفس الشمعة - للأمان لن نتداول");
      gLastSignalTxt = "إشارتان متعارضتان - تجاهل";
      return;
     }

   gLastSignalTxt = StringFormat("%s (%s) - شمعة %s",
                    (dir > 0 ? "شراء" : "بيع"),
                    (engine == 1 ? "علي ماستر" : "المحرك الرئيسي"),
                    TimeToString(iTime(_Symbol, _Period, 1), TIME_DATE | TIME_MINUTES));

   //--- فلاتر التنفيذ
   if(CountPositions() >= InpMaxPos)
     {
      Print(EA_TITLE, ": تخطي الإشارة - وصلنا للحد الأقصى من الصفقات (", InpMaxPos, ")");
      return;
     }
   if(InpOnePerBar && gLastTradeBar == iTime(_Symbol, _Period, 0)) return;
   if(InpMaxDayTrades > 0 && TodayTrades() >= InpMaxDayTrades)
     {
      Print(EA_TITLE, ": تخطي الإشارة - بلغنا حد صفقات اليوم (", InpMaxDayTrades, ")");
      return;
     }
   double spread = (double)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
   if(InpMaxSpread > 0 && spread > InpMaxSpread)
     {
      Print(EA_TITLE, ": تخطي الإشارة - السبريد ", DoubleToString(spread, 0),
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
      if(sl > 0 && sl > -1e100 && sl < 1e100)
         slPrice = sl;
      else
        {
         slPrice = entryRef - dir * InpFixedSLPts * pt;
         Print(EA_TITLE, ": مستوى SL من الإشارة غير متاح - استخدمت الستوب الاحتياطي ",
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
         Print(EA_TITLE, ": ستوب الإشارة قريب جداً - وسعته لـ ", DoubleToString(InpMinSLPts, 0), " نقطة");
        }
      else if(distPts > InpMaxSLPts)
        {
         slPrice = entryRef - dir * InpMaxSLPts * pt;
         Print(EA_TITLE, ": ستوب الإشارة بعيد جداً - قصرته لـ ", DoubleToString(InpMaxSLPts, 0), " نقطة");
        }
     }

   //--- الهدف
   double tpSrc = 0;
   if(InpTPMode == EA_TP_IND1)      tpSrc = tp1;
   else if(InpTPMode == EA_TP_IND2) tpSrc = tp2;
   else if(InpTPMode == EA_TP_IND3) tpSrc = tp3;

   if(InpTPMode == EA_TP_FIXED)
      tpPrice = entryRef + dir * InpFixedTPPts * pt;
   else if(tpSrc > 0 && tpSrc > -1e100 && tpSrc < 1e100)
      tpPrice = tpSrc;
   else
     {
      tpPrice = entryRef + dir * InpFixedTPPts * pt;
      Print(EA_TITLE, ": مستوى TP من الإشارة غير متاح - استخدمت الهدف الاحتياطي ",
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
      Print(EA_TITLE, ": حجم اللوت غير صالح - تخطي الإشارة");
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
      Print(EA_TITLE, ": فشل فتح الصفقة - كود ", rc, " (", trade.ResultRetcodeDescription(), ")");
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
      Print(EA_TITLE, ": إغلاق جزئي ", DoubleToString(part, 2), " لوت من الصفقة #", ticket);
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
            Print(EA_TITLE, ": إغلاق صفقة معاكسة #", tk, " قبل فتح الاتجاه الجديد");
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
   Print(EA_TITLE, ": مخاطرة ", DoubleToString(InpRiskPct, 1), "% من ", DoubleToString(bal, 2),
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
   string engState = (gCalcReady ? "شغال ✓ (مستقل - بلا مؤشر خارجي)" : "بجهز - بيفحص التاريخ...");
   string txt = EA_TITLE + " - " + _Symbol + ", " + TFToStr(_Period)
              + "\nالمحرك: " + engState
              + "\nالحالة: " + (autoOK ? "التداول الآلي شغال ✓" : "التداول الآلي مقفول - فعّل زر AutoTrading الأخضر")
              + "\nمصدر الإشارة: " + EnumToString(InpSource)
              + "\nالصفقات المفتوحة: " + IntegerToString(CountPositions()) + " / " + IntegerToString(InpMaxPos)
              + "\nصفقات اليوم: " + IntegerToString(TodayTrades())
              + (InpMaxDayTrades > 0 ? " / " + IntegerToString(InpMaxDayTrades) : "")
              + "\nالسبريد الآن: " + DoubleToString(spread, 0) + " نقطة"
              + "\nآخر شمعة مفحوصة: " + (gLastProcBar > 0 ? TimeToString(gLastProcBar, TIME_DATE | TIME_MINUTES) : "-")
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
      //--- صفقة جديدة فُتحت: إبطال كاش عداد اليوم
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
//+------------------------------------------------------------------+
