//+------------------------------------------------------------------+
//|                                                       Ali Trader.mq5 |
//|   Ali Trader (علي تريدر) - مؤشر دخول ذهب هجين متعدد المدارس      |
//+------------------------------------------------------------------+
//|  نظام إشارات هجين يجمع أقوى المدارس الحديثة في محرك نقاط واحد:   |
//|                                                                  |
//|   1) SMC  : كسر الهيكل BOS/CHoCH + أوردرك بلوكس + فجوات FVG      |
//|   2) سيولة: سحب السيولة Liquidity Sweep (اصطياد الستوبات)        |
//|   3) اتجاه: فلتر EMA 50/200 من فريم أعلى (تلقائي H4/H1)          |
//|   4) جلسات: لندن ونيويورك فقط (أفضل سيولة للذهب)                 |
//|   5) حجم  : تأكيد Tick Volume فوق المتوسط                        |
//|   6) تذبذب: فلتر ATR + ستوب وأهداف تلقائية بالـ ATR              |
//|   7) احترافي: مناطق MTF + خطوط سيولة + Premium/Discount          |
//|      + فلتر الأخبار الحمراء + فيبو ذهبي + إدارة صفقة + إحصائيات  |
//|   8) علي ماستر v6: شرط اختراق 3 شموع + خطوط ENTRY/TP1..TP3/SL    |
//|      بامتداد يميني + مناطق سيولة 4H بقوة الحجم                   |
//|                                                                  |
//|  وضع هجين (Hybrid): إشارة لحظية أثناء تكوّن الشمعة، تتحول         |
//|  لإشارة مؤكدة ثابتة بعد الإغلاق - الإشارات المؤكدة لا تُعاد رسمها  |
//|  أبداً (Non-Repaint) لأن كل شمعة تُقيَّم مرة واحدة عند إغلاقها    |
//|  وببيانات متاحة حتى لحظة الإغلاق فقط.                            |
//|                                                                  |
//|  //|  محرك النقاط (أساس 10 + مكافآت v1.43 حتى 16):               |
//|   +2 هيكل صاعد/هابط حديث   +2 سحب سيولة مؤكد                     |
//|   +2 ارتداد من أوردرك بلوك +1 ارتداد من فجوة FVG                 |
//|   +1 زخم RSI               +1 حجم قوي                            |
//|   +1 نموذج شمعة (إنجلف/بين بار)                                   |
//|  بوابات إلزامية: الاتجاه + الجلسة + الحجم + نطاق ATR             |
//|  مكافآت v1.43: +1 توافق الدولار DXY   +2 دايفرجنس RSI       |
//|                 +1 ADX ترند صحي   +2 سحب النطاق الآسيوي     |
//|                                                                  |
//|  التركيب:                                                        |
//|   1) من المنصة اضغط F4 لفتح MetaEditor                           |
//|   2) انسخ الملف إلى مجلد: MQL5\Indicators                        |
//|   3) افتح الملف واضغط Compile (F7) - لن توجد أخطاء               |
//|   4) من نافذة Navigator ابحث عن اسم Ali Trader واسحبه على XAUUSD |
//|   5) v1.41 يحذف النسخ القديمة (Gold Sniper/ALI أقدم) تلقائياً    |
//|   6) v1.42 يخفف ألوان الشارت: مناطق أقل + ألوان هادئة + حد عمر   |
//|   7) v1.43: إصلاح سيولة 4H التاريخية (lookahead) + تنبيهات      |
//|      + فلتر أخبار تاريخي + تحقق مدخلات + تنظيف كود ميت          |
//|     8) v1.43+: تعزيزات ذكاء: DXY عكسي + دايفرجنس RSI + ADX|
//|        + سحب النطاق الآسيوي + سقف درجة ديناميكي + صفوف لوحة|
//|     9) v1.44: حماية الانعكاس (انتظار قبل الإشارة المعاكسة)   |
//|        + الدخول من المنطقة الذهبية إلزامي + هدف ثالث TP3      |
//|                                                                  |
//|  إعدادات مقترحة:                                                 |
//|   - سكالبينج M1-M5 : MinScore=6 ، FVGMinPts=15-20 ،              |
//|                      MinATRPts=25-40 ، الاتجاه تلقائي H1          |
//|   - انتراداي M15-H1: MinScore=6-7 ، FVGMinPts=30 ،               |
//|                      MinATRPts=60-120 ، الاتجاه تلقائي H4         |
//|   - سوينج H4      : MinScore=8 ، TrendTF=D1 ، MaxATRPts=1200     |
//|                                                                  |
//|  ملاحظات مهمة:                                                   |
//|   - أوقات الجلسات بتوقيت السيرفر (أغلب البروكرات GMT+2/+3):      |
//|     لندن 10-18 / نيويورك 15-22 - عدّلها حسب بروكرك               |
//|   - قيم النقاط مضبوطة للتسعير بخانتين (0.01) وتتعادل تلقائياً    |
//|     للبروكرات ذات 3 خانات                                        |
//|   - قراءة الشارت: كل مربع مكتوب عليه نوعه وسعره:                 |
//|     OB شراء/بيع = أوردرك بلوك ، FVG شراء/بيع = فجوة سيولة،       |
//|     MTF = منطقة من فريم أعلى ، الخطوط المنقطة = سيولة قمم/قيعان  |
//|     الخطوط الملونة = صفقة علي ماستر (دخول/أهداف/ستوب) مع اللوحة   |
//|   - لا يوجد مؤشر بلا خطأ 100% - التزام بإدارة رأس المال إلزامي   |
//+------------------------------------------------------------------+
#property copyright   "Ali Trader - نظام إشارات الذهب الهجين"
#property link        ""
#property version     "1.44"
#property description "مؤشر دخول ذهب هجين: SMC + سيولة + اتجاه + حجم + جلسات"
#property description "وضع هجين: إشارة لحظية تتحول لمؤكدة بعد الإغلاق (Non-Repaint)"
#property description "مدمج: استراتيجية علي ماستر v6 (خطوط صفقة + سيولة 4H - بلا أسهم)"
#property description "Ali Trader v1.44: منع الانعكاس السريع (انتظار 10 دقائق) + الدخول الذهبي + TP3"
#property description "v1.43: إصلاح سيولة 4H التاريخية + تنبيهات + فلتر أخبار موسع + تحقق مدخلات"
#property description "v1.43+: فلتر الدولار DXY + دايفرجنس RSI + ADX + سحب آسيا"
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   8

//--- Plot 0: إشارة شراء مؤكدة (v1.41: بلا سهم على الشارت - بيانات للإحصائيات فقط)
#property indicator_label1  "Buy Signal"
#property indicator_type1   DRAW_NONE
#property indicator_color1  clrLime
#property indicator_width1  3
//--- Plot 1: إشارة بيع مؤكدة (v1.41: بلا سهم على الشارت)
#property indicator_label2  "Sell Signal"
#property indicator_type2   DRAW_NONE
#property indicator_color2  clrOrangeRed
#property indicator_width2  3
//--- Plot 2: نقطة شراء لحظية (v1.41: بلا سهم على الشارت)
#property indicator_label3  "Buy Live"
#property indicator_type3   DRAW_NONE
#property indicator_color3  C'0,110,60'
#property indicator_width3  1
//--- Plot 3: نقطة بيع لحظية (v1.41: بلا سهم على الشارت)
#property indicator_label4  "Sell Live"
#property indicator_type4   DRAW_NONE
#property indicator_color4  C'150,45,45'
#property indicator_width4  1
//--- Plot 4: قوة الإشارة (نافذة البيانات)
#property indicator_label5  "Score (0-10)"
#property indicator_type5   DRAW_NONE
//--- Plot 5: الاتجاه (نافذة البيانات)
#property indicator_label6  "Direction"
#property indicator_type6   DRAW_NONE
//--- Plot 6: إشارة علي ماستر شراء (v1.41: بلا سهم على الشارت)
#property indicator_label7  "Ali Buy"
#property indicator_type7   DRAW_NONE
#property indicator_color7  clrDodgerBlue
#property indicator_width7  1
//--- Plot 7: إشارة علي ماستر بيع (v1.41: بلا سهم على الشارت)
#property indicator_label8  "Ali Sell"
#property indicator_type8   DRAW_NONE
#property indicator_color8  clrDarkOrange
#property indicator_width8  1

//+------------------------------------------------------------------+
//| المدخلات                                                         |
//+------------------------------------------------------------------+
input group "=== الإعدادات العامة ==="
input ENUM_TIMEFRAMES InpTrendTF     = PERIOD_CURRENT;  // فريم الاتجاه (تلقائي لو Current)
input int             InpMaxBars     = 1500;            // أقصى عدد شموع للحساب
input bool            InpProvisional = true;            // نقطة لحظية قبل الإغلاق (وضع هجين)

input group "=== مدرسة SMC ==="
input int             InpSwingLen    = 3;               // قوة السوينج (شموع كل جهة)
input int             InpStructLook  = 150;             // نطاق البحث عن الهيكل (شموع)
input int             InpStructFresh = 40;              // أقصى عمر لكسر الهيكل (شموع)
input bool            InpUseOB       = true;            // تفعيل أوردرك بلوكس
input bool            InpUseFVG      = true;            // تفعيل فجوات FVG
input bool            InpUseSweep    = true;            // تفعيل سحب السيولة
input int             InpFVGMinPts   = 30;              // أقل حجم للفجوة (نقاط)
input int             InpOBValidBars = 200;             // أقصى عمر للمنطقة (شموع)
input int             InpMaxZones    = 2;               // أقصى مناطق مرسومة على الشارت (v1.42: كانت 10 - تخفيف الألوان)

input group "=== الفلاتر الإلزامية ==="
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

input group "=== قوة الإشارة ==="
input int             InpMinScore      = 6;             // أقل درجة للإشارة المؤكدة (أساس 10 + مكافآت v1.43)
input int             InpMinScoreLive  = 6;             // أقل درجة للنقطة اللحظية

input group "=== إدارة الصفقة (ATR) ==="
input double          InpSL_ATR      = 1.6;             // مسافة الستوب = ATR ×
input double          InpTP1_R       = 1.0;             // الهدف الأول (مضاعف المخاطرة R)
input double          InpTP2_R       = 2.0;             // الهدف الثاني (مضاعف المخاطرة R)
input double          InpTP3_R       = 3.0;             // الهدف الثالث (مضاعف المخاطرة R) - v1.44
input int             InpLineLen     = 100;             // طول خطوط الدخول/الأهداف (شموع مثل extendBars)
input int             InpMaxLines    = 5;               // عدد آخر الصفقات المرسومة

enum ENUM_GSP_THEME
  {
   GSP_THEME_DARK  = 0,  // داكن
   GSP_THEME_NAVY  = 1,  // كحلي
   GSP_THEME_GLASS = 2   // شفاف
  };

input group "=== إضافات احترافية ==="
input bool            InpMTFZones  = true;    // مناطق OB/FVG من فريم الاتجاه الأعلى
input int             InpMTFMax    = 2;       // أقصى مناطق MTF مرسومة (v1.42: كانت 6)
input bool            InpLiqLines  = true;    // خطوط السيولة (قمم/قيعان)
input int             InpLiqMax    = 4;       // أقصى خطوط سيولة مرسومة (v1.42: كانت 8)
input bool            InpUsePD     = true;    // فلتر Premium/Discount (شراء رخيص/بيع غالي)
input bool            InpUseNews   = true;    // فلتر الأخبار الحمراء (تقويم MT5)
input int             InpNewsMin   = 30;      // دقائق الإيقاف قبل/بعد الخبر
input bool            InpShowFibo  = true;    // فيبوناتشي تلقائي + المنطقة الذهبية
input bool            InpTradeMgr  = true;    // إدارة الصفقة (تعادل بعد الهدف الأول)
input ENUM_GSP_THEME  InpTheme     = GSP_THEME_DARK; // ثيم اللوحة

enum ENUM_ALI_MODE
  {
   ALI_MODE_OFF    = 0,  // معطل
   ALI_MODE_STAND  = 1,  // إشارات مستقلة + خطوط صفقة
   ALI_MODE_FILTER = 2   // فلتر تأكيد للإشارات الرئيسية
  };

input group "=== استراتيجية علي ماستر v6 ==="
input ENUM_ALI_MODE  InpAliMode   = ALI_MODE_STAND; // وضع الاستراتيجية
input bool           InpAliUseATR = true;           // استخدام ATR للستوب والأهداف
input int            InpAliAtrLen = 14;             // فترة ATR الخاصة بالاستراتيجية
input double         InpAliTP1Pts = 1000;           // هدف أول عند تعطيل ATR = 10 دولار (1000 نقطة)
input double         InpAliTP2Pts = 2000;           // هدف ثاني عند تعطيل ATR = 20 دولار (2000 نقطة)
input double         InpAliTP3Pts = 3000;           // هدف ثالث عند تعطيل ATR = 30 دولار (3000 نقطة) - v1.44
input double         InpAliSLPts  = 1000;           // ستوب عند تعطيل ATR = 10 دولار (1000 نقطة)
input int            InpAliExt    = 100;            // امتداد الخطوط يميناً (شموع) مثل TradingView = 100
input int            InpAliWidth  = 2;              // سماكة خطوط الصفقة (1-5)
input bool           InpAliLiq    = true;           // مناطق سيولة فريم 4 ساعات
input int            InpLiqLook   = 20;             // شموع 4H لتحديد القمة/القاع
input double         InpLiqHeight = 500;            // ارتفاع منطقة السيولة = 5 دولار (500 نقطة)
input int            InpAliLiqMax = 2;              // عدد مناطق السيولة لكل موجة (1-5)

input group "=== المظهر ==="
input bool            InpShowZones   = true;            // رسم مناطق OB و FVG
input bool            InpZoneLabels  = true;            // كتابة نوع وسعر كل منطقة على الشارت
input bool            InpShowLines   = true;            // رسم خطوط دخول/ستوب/أهداف
input bool            InpShowDash    = true;            // لوحة المعلومات
input ENUM_BASE_CORNER InpPanelCorner = CORNER_LEFT_UPPER;  // ركن اللوحة (يسار الشاشة افتراضياً - بطلب علي)
input int             InpDashX       = 12;              // إزاحة أفقية
input int             InpDashY       = 28;              // إزاحة رأسية
input int             InpFontSize    = 9;               // حجم خط اللوحة
input color           InpColBuy      = clrLime;         // لون الشراء
input color           InpColSell     = clrOrangeRed;    // لون البيع
input bool            InpAliTheme    = true;            // v1.38: تطبيق قالب الشموع (خلفية سوداء + شموع خضراء/حمراء)
input bool            InpDebug       = false;           // v1.43: رسائل تشخيصية (تُفعل يدوياً عند الحاجة)

input group "=== التنبيهات والإحصائيات (v1.43) ==="
input bool            InpAlertPopup  = true;            // تنبيه منبثق عند تأكيد الإشارة
input bool            InpAlertSound  = true;            // صوت تنبيه
input bool            InpAlertPush   = false;           // إشعار جوال (يتطلب MetaQuotes ID)
input bool            InpAlertAli    = true;            // تنبيه إشارات علي ماستر أيضاً
input bool            InpAmbigAsLoss = true;            // شمعة لمست SL وTP1 معاً تحسب خسارة (تحفّطي)
input group "=== تعزيزات الذكاء (v1.43) ==="
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

input group "=== حماية الانعكاس والدخول الذهبي (v1.44) ==="
input int             InpRevWaitMin  = 10;     // انتظار قبل الإشارة المعاكسة (دقائق - 0 = تعطيل)
input bool            InpGoldenEntry = true;   // الدخول من المنطقة الذهبية فقط (فيبو 0.5-0.618)

//+------------------------------------------------------------------+
//| المتغيرات العامة                                                 |
//+------------------------------------------------------------------+
//--- إصلاح v1.37: بادئة كائنات فريدة لكل نسخة مؤشر بدل البادئة الثابتة،
//--- لأن لو اتسربت نسختان على نفس الشارت كانت كل نسخة تمسح كائنات
//--- الأخرى (ObjectsDeleteAll بالبادئة المشتركة) = الخطوط تظهر وتختفي
string   gPrefix = "";                        // تتولد فريدة في OnInit مرة واحدة
#define PREFIX   gPrefix
#define ALI_VER_MAJOR 1                       // v1.43: مقارنة إصدار عامة لتنظيف النسخ القديمة
#define ALI_VER_MINOR 44
#define ALI_TITLE "Ali Trader v1.44"          // v1.44: اسم المؤشر (اللوحة + Shortname + الرسائل)
#define MAXZ     80
#define MAXMZ    40
#define MAXLQ    24
#define MAXLQ4   10

double   BufBuy[], BufSell[], BufBuyL[], BufSellL[], BufScore[], BufDir[];
double   BufAliB[], BufAliS[];         // أسهم علي ماستر (شراء/بيع)

int      hATR = INVALID_HANDLE, hRSI = INVALID_HANDLE;
int      hATRA = INVALID_HANDLE;      // ATR خاص باستراتيجية علي ماستر
int      hEMAF = INVALID_HANDLE, hEMAS = INVALID_HANDLE;
int      hADX = INVALID_HANDLE;         // v1.43+: ADX جودة الترند
int      hDXY = INVALID_HANDLE;         // v1.43+: EMA الدولار (DXY)
string   gDXYUsed = "";                 // v1.43+: رمز الدولار الذي نجح الربط معه
ENUM_TIMEFRAMES gTF = PERIOD_H4;        // فريم الاتجاه الفعلي
double   gNP   = 0.01;                 // النقطة المعادلة (بعد تعادل الخانات)
int      gSecBar = 900;                // ثواني الشمعة الحالية
double   gATR[], gRSI[];               // نسخ مؤشرات مساعدة (سلسلة)
double   gATRA[];                      // نسخة ATR استراتيجية علي ماستر
double   gADX[];                       // v1.43+: نسخ ADX (سلسلة)

//--- سجل المناطق (OB / FVG)
datetime zBorn[];  double zTop[], zBot[];
int      zDirA[], zKindA[];             // الاتجاه: 1-1 | النوع: 0=OB 1=FVG
bool     zMitA[];                      // v1.43: حُذف zTouchA (كود ميت لم يُقرأ أبداً)
int      zCount = 0;

//--- مناطق MTF (من فريم الاتجاه الأعلى)
datetime mzBorn[];  double mzTop[], mzBot[];
int      mzDirA[], mzKindA[];
bool     mzMitA[];
int      mzCount = 0;

//--- خطوط السيولة
datetime lqT[];   double lqP[];
int      lqDirA[];               // 1 = سيولة فوق قمة ، -1 = تحت قاع
bool     lqSweptA[];
int      lqCount = 0;

//--- إحصائيات موسعة + حالة إدارة الصفقة + الأخبار
int      gSesW[4], gSesL[4];
int      gHrW[24], gHrL[24];
double   gRSum = 0;
int      gTradeState = 0;        // 0 قيد التداول | 1 انقل للتعادل | 2 اكتملت | -1 ستوب
string   gNewsTxt = "";
datetime gNewsBlockTo = 0;

//--- v1.43: كاش الأخبار الحمراء (تاريخي + قادم) + كاش الاتجاه + التنبيهات
datetime gNewsT[];                     // أوقات الأخبار الحمراء المخزنة
int      gNewsCnt = 0;
datetime gNewsLastLoad = 0;
int      gTsUse = -1;                  // كاش حالة الاتجاه (يُصفّر عند الحساب الكامل)
int      gTsSt  = 0;
datetime gLastAlertMain = 0;           // منع تكرار التنبيه لنفس الشمعة
datetime gLastAlertAli = 0;
datetime gLastSigT = 0;                // v1.44: وقت آخر إشارة مؤكدة (المحرك الرئيسي) - منع الانعكاس
int      gLastSigDir = 0;              // v1.44: اتجاه آخر إشارة مؤكدة (المحرك الرئيسي)
datetime gAliLastSigT = 0;             // v1.44: وقت آخر إشارة علي - منع الانعكاس
int      gAliLastSigDir = 0;           // v1.44: اتجاه آخر إشارة علي
int      gScoreMax = 10;               // v1.43+: سقف الدرجة حسب الميزات المفعلة (10-16)

//--- آخر إشارة مؤكدة
int      gLDir = 0;
double   gLPrice = 0, gLSL = 0, gLT1 = 0, gLT2 = 0, gLT3 = 0;   // v1.44: + هدف ثالث
datetime gLTime = 0;

//--- استراتيجية علي ماستر v6
int      gAliDir = 0;                  // 1 شراء / -1 بيع / 0 محايد
datetime gAliLastT = 0;                // وقت آخر شمعة أطلقت إشارة (حماية تكرار)
int      gAliSigDir = 0;               // آخر إشارة علي: 1 / -1
double   gAliEntry = 0, gAliSL = 0, gAliTP1 = 0, gAliTP2 = 0, gAliTP3 = 0;   // v1.44: + هدف ثالث
datetime gAliSigTime = 0;
int      gAliTot = 0, gAliBuy = 0, gAliSell = 0;

//--- مناطق سيولة 4H (لقطات علي ماستر)
datetime lq4T[];   double lq4L[];
int      lq4DirA[], lq4StrA[];         // الاتجاه: -1 قاع / 1 قمة ، القوة: 0/1/2
int      lq4Count = 0;
int      gLiqCnt = 0;                  // عداد مناطق الموجة الحالية (يُصفّر عند إشارة)
datetime gLq4LastH4T = 0;              // وقت آخر شمعة 4H عولجت (تسريع - منع تكرار الحساب)

//--- إحصائيات
int      gSTot = 0, gSWin = 0, gSLoss = 0, gSBuy = 0, gSSell = 0;
int      gSTP3 = 0;                    // v1.44: عدد الصفقات التي وصلت الهدف الثالث

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

//--- نطاق التداول الحالي (للفلتر Premium/Discount + الفيبو)
struct DealRange
  {
   bool     valid;
   int      dir;        // 1 = الموجة صاعدة (قاع ثم قمة) | -1 هابطة
   double   hi, lo;
   datetime hiT, loT;
   double   eq;         // مستوى التوازن 50%
  };

//+------------------------------------------------------------------+
//| تهيئة المؤشر                                                     |
//+------------------------------------------------------------------+
int OnInit()
  {
   //--- v1.38: توليد بادئة فريدة لهذه النسخة + مسح لمرة واحدة لبقايا النسخ القديمة
   if(StringLen(gPrefix) == 0)
     {
      gPrefix = "GSP_" + StringFormat("%X", (uint)GetTickCount()) + "_";
      ObjectsDeleteAll(0, "GSP_", 0);   // v1.43: حصر المسح في النافذة 0 فقط
     }

   //--- v1.38 إصلاح جذري: تطبيق قالب الشموع تلقائياً من داخل المؤشر نفسه
   //--- (خلفية سوداء + شموع خضراء/حمراء مثل تيمبلت علي) - لا تستخدم أي
   //--- تيمبلت خارجي بعد الآن: تطبيق أي تيمبلت يدوياً في MT5 يمسح كل
   //--- الكائنات من الشارت ويعيد تحميل المؤشرات = السبب الأكبر لاختفاء
   //--- خطوط الدخول/الستوب/الأهداف مع بقاء الأسهم
   ApplyAliTemplate();

   SetIndexBuffer(0, BufBuy,   INDICATOR_DATA);
   SetIndexBuffer(1, BufSell,  INDICATOR_DATA);
   SetIndexBuffer(2, BufBuyL,  INDICATOR_DATA);
   SetIndexBuffer(3, BufSellL, INDICATOR_DATA);
   SetIndexBuffer(4, BufScore, INDICATOR_DATA);
   SetIndexBuffer(5, BufDir,   INDICATOR_DATA);
   SetIndexBuffer(6, BufAliB,  INDICATOR_DATA);
   SetIndexBuffer(7, BufAliS,  INDICATOR_DATA);

   //--- إصلاح v1.35 الجذري: البافرات تُفهرس كسلسلة (0 = أحدث شمعة)
   //--- لتطابق اتجاه الحلقة الرئيسية والمصفوفات - بدون هذا ترسم الأسهم
   //--- معكوسة في التاريخ القديم بعيداً عن السعر الحالي ولا تظهر
   ArraySetAsSeries(BufBuy, true);    ArraySetAsSeries(BufSell, true);
   ArraySetAsSeries(BufBuyL, true);   ArraySetAsSeries(BufSellL, true);
   ArraySetAsSeries(BufScore, true);  ArraySetAsSeries(BufDir, true);
   ArraySetAsSeries(BufAliB, true);   ArraySetAsSeries(BufAliS, true);

   //--- v1.41: الأسهم محذوفة من الشارت (كل الـ plots DRAW_NONE) - البافرات
   //--- تُملأ فقط كمصدر بيانات لإحصائيات اللوحة، فإعدادات PLOT_ARROW لاغية الآن
   PlotIndexSetInteger(0, PLOT_ARROW, 233);
   PlotIndexSetInteger(1, PLOT_ARROW, 234);
   PlotIndexSetInteger(2, PLOT_ARROW, 159);
   PlotIndexSetInteger(3, PLOT_ARROW, 159);
   PlotIndexSetInteger(6, PLOT_ARROW, 241);   // سهم علوي صغير (علي ماستر)
   PlotIndexSetInteger(7, PLOT_ARROW, 242);   // سهم سفلي صغير (علي ماستر)

   for(int p = 0; p < 8; p++)
     {
      PlotIndexSetDouble(p, PLOT_EMPTY_VALUE, EMPTY_VALUE);
      PlotIndexSetInteger(p, PLOT_DRAW_BEGIN, 60);
     }

   //--- فريم الاتجاه: تلقائي حسب فريم الشارت
   if(InpTrendTF == PERIOD_CURRENT)
      gTF = (_Period <= PERIOD_M5) ? PERIOD_H1 : PERIOD_H4;
   else
      gTF = InpTrendTF;

   //--- تعادل النقاط حسب عدد الخانات (ذهب 2 أو 3 خانات)
   gNP = _Point * ((_Digits == 3) ? 10.0 : (_Digits == 1) ? 0.1 : 1.0);
   gSecBar = PeriodSeconds(_Period);
   if(gSecBar <= 0) gSecBar = 60;

   //--- v1.43+: سقف الدرجة الديناميكي حسب التعزيزات المفعلة (أساس 10 + مكافآت)
   gScoreMax = 10 + (InpUseDXY ? 1 : 0) + (InpUseADX ? 1 : 0) +
               (InpUseDiv ? 2 : 0) + (InpUseAsia ? 2 : 0);

   //--- v1.43: التحقق من صحة المدخلات (القيم المتطرفة تجعل المحرك بلا معنى)
   if(InpSwingLen < 1 || InpStructLook < 10 || InpVolPeriod < 2 ||
      InpSL_ATR <= 0.0 || InpATRPeriod < 2 || InpAliAtrLen < 2 ||
      InpMinScore < 1 || InpMinScore > gScoreMax ||
      InpMinScoreLive < 1 || InpMinScoreLive > gScoreMax ||
      InpMaxBars < 100 ||
      InpADXLen < 2 || InpDXYEMA < 2 || InpDivLook < 10 ||
      InpAsiaStart < 0 || InpAsiaStart > 23 ||
      InpAsiaEnd < 1 || InpAsiaEnd > 23 || InpAsiaEnd <= InpAsiaStart ||
      InpADXMin < InpADXFlat ||
      InpTP3_R <= 0.0 || InpAliTP3Pts < 0 ||        // v1.44: تحقق الأهداف الجديدة
      InpRevWaitMin < 0 || InpRevWaitMin > 1440)
     {
      Print(ALI_TITLE, ": قيم مدخلات غير صالحة - راجع الإعدادات");
      return(INIT_PARAMETERS_INCORRECT);
     }

   hATR  = iATR(_Symbol, _Period, InpATRPeriod);
   hRSI  = iRSI(_Symbol, _Period, 14, PRICE_CLOSE);
   hEMAF = iMA(_Symbol, gTF, 50, 0, MODE_EMA, PRICE_CLOSE);
   hEMAS = iMA(_Symbol, gTF, 200, 0, MODE_EMA, PRICE_CLOSE);
   hATRA = iATR(_Symbol, _Period, MathMax(2, InpAliAtrLen));
   hADX  = iADX(_Symbol, _Period, InpADXLen);

   //--- v1.43+: ربط رمز الدولار (اسمه يختلف بين البروكرات - تجربة تلقائية)
   //--- إذا لم يتوفر أي رمز مناسب يتوقف الفلتر تلقائياً بسلاسة
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
      Print(ALI_TITLE, ": فشل إنشاء مقابض المؤشرات المساعدة");
      return(INIT_FAILED);
     }
   if(InpUseDXY && gDXYUsed == "")
      Print(ALI_TITLE, ": تنبيه - رمز الدولار غير متوفر لدى البروكر، فلتر DXY معطل تلقائياً");

   ArraySetAsSeries(gATR, true);
   ArraySetAsSeries(gRSI, true);
   ArraySetAsSeries(gATRA, true);
   ArraySetAsSeries(gADX, true);    // v1.43+

   Print(ALI_TITLE, " جاهز ✓ - ", _Symbol, " digits=", _Digits,
         " - بادئة فريدة: ", gPrefix,
         " | الرسم كل تيك + مؤقت أمان كل 3 ثوان | قالب الشموع مدمج + تنظيف النسخ القديمة",
         " | DXY: ", ((gDXYUsed == "") ? "معطل" : gDXYUsed),
         " | سقف الدرجة: ", gScoreMax);

   IndicatorSetString(INDICATOR_SHORTNAME, ALI_TITLE);
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

   //--- v1.39: حذف أي نسخة قديمة متبقية على نفس الشارت (Gold Sniper Pro / ALI أقدم)
   //--- يُستدعى بعد ضبط الاسم القصير حتى لا نحذف أنفسنا
   CleanupOldInstances();

   //--- v1.38: مؤقت أمان يعيد الرسم كل 3 ثوان حتى بدون تيك أو بعد أي
   //--- مسح خارجي للكائنات (مزامنة تاريخ / قوالب / سكربتات أخرى)
   EventSetTimer(3);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| إلغاء التهيئة                                                    |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   ObjectsDeleteAll(0, PREFIX);
   if(hATR  != INVALID_HANDLE) IndicatorRelease(hATR);
   if(hRSI  != INVALID_HANDLE) IndicatorRelease(hRSI);
   if(hEMAF != INVALID_HANDLE) IndicatorRelease(hEMAF);
   if(hEMAS != INVALID_HANDLE) IndicatorRelease(hEMAS);
   if(hATRA != INVALID_HANDLE) IndicatorRelease(hATRA);
   if(hADX  != INVALID_HANDLE) IndicatorRelease(hADX);   // v1.43+
   if(hDXY  != INVALID_HANDLE) IndicatorRelease(hDXY);   // v1.43+
   ChartRedraw();
  }
//+------------------------------------------------------------------+
//| v1.38: تطبيق قالب الشموع المدمج (نفس ألوان التيمبلت المرفق)      |
//| خلفية سوداء + شموع صاعدة خضراء + هابطة قرمزية - بدون تيمبلت خارجي|
//+------------------------------------------------------------------+
void ApplyAliTemplate()
  {
   if(!InpAliTheme) return;
   ChartSetInteger(0, CHART_MODE, CHART_CANDLES);                // شموع
   ChartSetInteger(0, CHART_SCALEFIX, false);                    // v1.39: فتح المقياس الثابت - التيمبلت القديم يقفله (scale_fix=1) فتخرج الكائنات عن الشاشة
   ChartSetInteger(0, CHART_FOREGROUND, false);                  // v1.39: الشارت خلف الكائنات دائماً - لا يخفيها
   ChartSetInteger(0, CHART_COLOR_BACKGROUND, clrBlack);         // خلفية سوداء
   ChartSetInteger(0, CHART_COLOR_FOREGROUND, clrWhite);         // نصوص بيضاء
   ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, C'60,179,113');   // شمعة صاعدة SeaGreen
   ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, C'220,20,60');    // شمعة هابطة Crimson
   ChartSetInteger(0, CHART_COLOR_CHART_UP,   clrLime);          // بار صاعد
   ChartSetInteger(0, CHART_COLOR_CHART_DOWN, C'220,20,60');     // بار هابط
   ChartSetInteger(0, CHART_COLOR_CHART_LINE, clrLime);          // خط الشارت
   ChartSetInteger(0, CHART_COLOR_GRID, clrNONE);                // بدون شبكة
   ChartSetInteger(0, CHART_SHOW_GRID, false);
   ChartSetInteger(0, CHART_SHOW_VOLUMES, CHART_VOLUME_HIDE);    // بدون فوليوم
   ChartSetInteger(0, CHART_COLOR_BID, C'119,136,153');          // خط السعر الحالي
   ChartSetInteger(0, CHART_SHOW_BID_LINE, true);
   ChartRedraw();
  }
//+------------------------------------------------------------------+
//| v1.39: حذف تلقائي للنسخ القديمة المتبقية على نفس الشارت          |
//| نسخة قديمة (Gold Sniper Pro أو ALI أقدم) على شارت الذهب تظل تعمل |
//| بكود قديم فيه علة الاختفاء - هذا كان الفرق بين الذهب والأزواج    |
//| v1.43: المقارنة صارت عامة عبر ALI_VER_MAJOR/MINOR - حدّثهما دائماً|
//+------------------------------------------------------------------+
void CleanupOldInstances()
  {
   int total = ChartIndicatorsTotal(0, 0);
   for(int i = total - 1; i >= 0; i--)
     {
      string nm = ChartIndicatorName(0, 0, i);
      if(StringLen(nm) <= 0) continue;
      if(nm == ALI_TITLE) continue;                 // نفسنا - لا نلمس
      bool del = false;
      if(StringFind(nm, "Gold Sniper Pro") == 0)    // كل نسخ ما قبل إعادة التسمية
         del = true;
      else if(StringFind(nm, "ALI v") == 0)         // v1.43: مقارنة إصدار عامة (تدعم أي إصدار مستقبلي)
        {
         string vs = StringSubstr(nm, 5);
         int dot = StringFind(vs, ".");
         if(dot > 0)
           {
            int vmaj = (int)StringToInteger(StringSubstr(vs, 0, dot));
            int vmin = (int)StringToInteger(StringSubstr(vs, dot + 1));
            if(vmaj > 0 || vmin > 0)
               if(vmaj < ALI_VER_MAJOR ||
                  (vmaj == ALI_VER_MAJOR && vmin < ALI_VER_MINOR))
                  del = true;
           }
        }
      else if(StringFind(nm, "Ali Trader v") == 0)  // نسخ Ali Trader أقدم تُحذف تلقائياً
        {
         string vt = StringSubstr(nm, 12);
         int dotT = StringFind(vt, ".");
         if(dotT > 0)
           {
            int vmajT = (int)StringToInteger(StringSubstr(vt, 0, dotT));
            int vminT = (int)StringToInteger(StringSubstr(vt, dotT + 1));
            if(vmajT > 0 || vminT > 0)
               if(vmajT < ALI_VER_MAJOR ||
                  (vmajT == ALI_VER_MAJOR && vminT < ALI_VER_MINOR))
                  del = true;
           }
        }
      if(del)
        {
         if(ChartIndicatorDelete(0, 0, nm))
            Print("ALI CLEANUP: removed old instance -> ", nm);
         else
            Print("ALI CLEANUP: failed to remove -> ", nm);
        }
     }
  }
//+------------------------------------------------------------------+
//| v1.38: شبكة أمان - إعادة رسم كل 3 ثوان حتى بدون تيك              |
//| تشفى الكائنات بعد أي مسح خارجي (مزامنة تاريخ/قالب/سعر متجمد)     |
//| + رسائل تشخيصية دورية في سجل الخبراء لتتبع حالة الرسم            |
//+------------------------------------------------------------------+
void OnTimer()
  {
   datetime t[];
   double   h[], l[], c[];
   ArraySetAsSeries(t, true);
   ArraySetAsSeries(h, true);
   ArraySetAsSeries(l, true);
   ArraySetAsSeries(c, true);

   int n = (int)MathMin(Bars(_Symbol, _Period), 300);
   if(n < 60) return;
   if(CopyTime(_Symbol, _Period, 0, n, t)  < n) return;
   if(CopyHigh(_Symbol, _Period, 0, n, h)  < n) return;
   if(CopyLow(_Symbol, _Period, 0, n, l)   < n) return;
   if(CopyClose(_Symbol, _Period, 0, n, c) < n) return;

   //--- نفس قائمة رسم OnCalculate بالكامل (كل دالة تنظف بادئتها نفسها)
   if(InpShowZones) DrawZones(t, n);
   if(InpMTFZones)  DrawMTFZones(t);
   if(InpLiqLines)  DrawLiq(t, n);
   if(InpShowFibo)  DrawFibo(t, h, l, n);
   if(InpShowLines) DrawLastSignals(t, h, l, c, n);
   if(InpAliMode == ALI_MODE_STAND)             AliDrawSignal();
   if(InpAliMode != ALI_MODE_OFF && InpAliLiq)  AliDrawLiqZones(t);
   if(InpShowDash)  DrawDash(t, h, l, c, n);
   ChartRedraw();

   //--- رسالة تشخيصية كل 15 ثانية: عدد الكائنات الفعلي على الشارت
   //--- (نص لاتيني صريح + IntegerToString لكومبايل نظيف بلا أي تحذير تحويل)
   static uint lastDbg = 0;
   if(InpDebug && GetTickCount() - lastDbg > 15000)
     {
      lastDbg = GetTickCount();
      int objAll = ObjectsTotal(0);   // كل كائنات الشارت (بلا معاملات غامضة)
      Print("ALI DBG: chart_objects=", objAll,
            " | prefix=", gPrefix,
            " | ali_sig=", gAliSigDir,
            " | zones=", zCount + mzCount,
            " | liq=", lqCount + lq4Count);
     }
  }
//+------------------------------------------------------------------+
//| أدوات مساعدة عامة                                                |
//+------------------------------------------------------------------+
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

   if(use == gTsUse) return(gTsSt);      // v1.43: كاش عام يُصفّر عند الحساب الكامل

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

//+------------------------------------------------------------------+
//| v1.43+: فلتر الدولار DXY - الذهب يتحرك عكس الدولار غالباً        |
//| dir=1 (شراء ذهب) يتوافق مع دولار هابط / dir=-1 مع دولار صاعد     |
//| العائد: 1 توافق (+1) / 0 بيانات غير جاهزة / -1 تعارض صريح        |
//+------------------------------------------------------------------+
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

//--- اتجاه الدولار الآن (لعرضه في اللوحة): 1 صاعد / -1 هابط / 0 غير جاهز
int DXYDirNow()
  {
   if(hDXY == INVALID_HANDLE || gDXYUsed == "") return(0);
   double ema[1];
   if(CopyBuffer(hDXY, 0, 0, 1, ema) < 1) return(0);
   double c = iClose(gDXYUsed, gTF, 0);
   if(c <= 0 || ema[0] <= 0) return(0);
   return((c > ema[0]) ? 1 : (c < ema[0]) ? -1 : 0);
  }

//+------------------------------------------------------------------+
//| v1.43+: دايفرجنس RSI (+2) - سوينجان مؤكدان بلا أي بيانات مستقبلية|
//| صاعد: قاع سعري أدنى مع RSI أعلى / هابط: قمة أعلى مع RSI أدنى     |
//+------------------------------------------------------------------+
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

//+------------------------------------------------------------------+
//| v1.43+: سحب النطاق الآسيوي (+2) - سيت أب ذهبي كلاسيكي            |
//| كسر قمة/قاع نطاق آسيا ثم إغلاق العودة داخله = اصطياد سيولة       |
//| العائد: 1 يدعم الشراء (سحب القاع) / -1 يدعم البيع (سحب القمة)    |
//+------------------------------------------------------------------+
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
   if(i + 1 > ArraySize(close) - 1) return(0);   // v1.41: حماية من وصول خارج الحدود
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
//| محرك التقييم: تقييم شمعة واحدة ببيانات متاحة حتى إغلاقها فقط     |
//| (أساس عدم إعادة الرسم - لا استخدام لأي بيانات مستقبلية)          |
//+------------------------------------------------------------------+
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

   //--- 5ب) بوابة الأخبار الحمراء
   //--- v1.43: تُطبق على كل الشموع ضمن تغطية التقويم التاريخي (30 يوماً)
   //--- = إحصائيات اللوحة مطابقة للسلوك اللحظي (كانت لحظية فقط قبل v1.43)
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
   //--- النطاق يُحسب مرة واحدة ويُستخدم للفلترين معاً (توفير حساب)
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
      //--- v1.44: الدخول من المنطقة الذهبية فقط (فيبو 0.5 - 0.618)
      //--- إغلاق شمعة الإشارة يجب أن يكون داخل منطقة التصحيح الذهبية تماماً
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

   //--- 7د) v1.43+: مكافآت الذكاء الأربعة (DXY + دايفرجنس + ADX + سحب آسيا)
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

   //--- 8) القرار
   int need = (base == 0) ? InpMinScoreLive : InpMinScore;
   if(b >= need && b > s2)      { e.dir = 1;  e.score = b;  }
   else if(s2 >= need && s2 > b){ e.dir = -1; e.score = s2; }
   else                         { e.dir = 0;  e.score = MathMax(b, s2); }
  }

//+------------------------------------------------------------------+
//| حساب مستويات الدخول والستوب والأهداف                             |
//+------------------------------------------------------------------+
void CalcLevels(const int dir, const double entry, const double atr,
                double &sl, double &tp1, double &tp2, double &tp3)   // v1.44: + هدف ثالث
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
//| استراتيجية علي ماستر v6 (من TradingView - مدمجة)             |
//| شمعة صاعدة قمتها >= أعلى آخر 3 شموع = شرط شراء                    |
//| شمعة هابطة قاعها <= أدنى آخر 3 شموع = شرط بيع                     |
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
               double &sl, double &tp1, double &tp2, double &tp3)   // v1.44: + هدف ثالث
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

//+------------------------------------------------------------------+
//| v1.44: منع الانعكاس السريع - هل الإشارة المعاكسة مسموحة الآن؟    |
//| تعتمد وقت شمعة الإشارة لا TimeCurrent => ثابتة تاريخياً بلا إعادة رسم |
//+------------------------------------------------------------------+
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

//--- الشرط اللحظي على الشمعة الحالية (للعرض في اللوحة فقط)
bool AliLiveBull()
  {
   double hh = MathMax(iHigh(_Symbol, _Period, 1),
               MathMax(iHigh(_Symbol, _Period, 2), iHigh(_Symbol, _Period, 3)));
   return(iClose(_Symbol, _Period, 0) > iOpen(_Symbol, _Period, 0) &&
          iHigh(_Symbol, _Period, 0) >= hh);
  }

bool AliLiveBear()
  {
   double ll = MathMin(iLow(_Symbol, _Period, 1),
               MathMin(iLow(_Symbol, _Period, 2), iLow(_Symbol, _Period, 3)));
   return(iClose(_Symbol, _Period, 0) < iOpen(_Symbol, _Period, 0) &&
          iLow(_Symbol, _Period, 0) <= ll);
  }

//+------------------------------------------------------------------+
//| خط صفقة علي ماستر (امتداد يميني مثل extend.right في TradingView) |
//+------------------------------------------------------------------+
void AliLine(const string nm, const datetime t1, const double p,
             const datetime t2, const color c, const int w, const string txt)
  {
   ObjectCreate(0, nm, OBJ_TREND, 0, t1, p, t2, p);
   ObjectSetInteger(0, nm, OBJPROP_COLOR, c);
   ObjectSetInteger(0, nm, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, nm, OBJPROP_WIDTH, w);
   ObjectSetInteger(0, nm, OBJPROP_RAY_RIGHT, true);
   ObjectSetInteger(0, nm, OBJPROP_RAY_LEFT, false);
   ObjectSetInteger(0, nm, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, nm, OBJPROP_HIDDEN, true);

   string tn = nm + "X";
   ObjectCreate(0, tn, OBJ_TEXT, 0, t1, p);
   ObjectSetString(0, tn, OBJPROP_TEXT, txt);
   ObjectSetInteger(0, tn, OBJPROP_COLOR, c);
   ObjectSetInteger(0, tn, OBJPROP_FONTSIZE, 8);
   ObjectSetString(0, tn, OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, tn, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);   // v1.40: النص أعلى الخط بدل متشابك معه
   ObjectSetInteger(0, tn, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, tn, OBJPROP_HIDDEN, true);
  }

//+------------------------------------------------------------------+
//| خطوط آخر صفقة علي ماستر: ENTRY + TP1 + TP2 + SL مع التسميات    |
//| (كل إشارة جديدة تحذف خطوط السابقة - مثل deleteTradeLines)        |
//+------------------------------------------------------------------+
void AliDrawSignal()
  {
   ObjectsDeleteAll(0, PREFIX + "A");
   if(InpAliMode != ALI_MODE_STAND || gAliSigDir == 0 || gAliSigTime <= 0) return;

   bool     buy = (gAliSigDir > 0);
   color    eC  = buy ? clrDodgerBlue : clrDarkOrange;
   int      w   = MathMax(1, MathMin(5, InpAliWidth));
   datetime t2  = (datetime)((long)gAliSigTime + (long)MathMax(1, InpAliExt) * (long)gSecBar);
   if(t2 <= gAliSigTime) t2 = (datetime)((long)gAliSigTime + (long)gSecBar);   // حماية من الخط المنكسر

   AliLine(PREFIX + "AE", gAliSigTime, gAliEntry, t2, eC, w,
           (buy ? "ENTRY BUY " : "ENTRY SELL ") + DoubleToString(gAliEntry, _Digits));
   AliLine(PREFIX + "A1", gAliSigTime, gAliTP1, t2, clrGreen,  w,
           "TP1 " + DoubleToString(gAliTP1, _Digits));
   AliLine(PREFIX + "A2", gAliSigTime, gAliTP2, t2, clrRed,    w,
           "TP2 " + DoubleToString(gAliTP2, _Digits));
   AliLine(PREFIX + "A3", gAliSigTime, gAliTP3, t2, clrLimeGreen, w,   // v1.44
           "TP3 " + DoubleToString(gAliTP3, _Digits));
   AliLine(PREFIX + "AS", gAliSigTime, gAliSL,  t2, clrYellow, w,
           "SL " + DoubleToString(gAliSL, _Digits));
  }

//+------------------------------------------------------------------+
//| إضافة لقطة منطقة سيولة 4H                                          |
//| قاع 4H = منطقة شراء خضراء تحت السعر / قمة 4H = منطقة بيع حمراء    |
//| القوة: حجم 4H مقابل متوسطه (قوية > 1.5x / متوسطة > 0.8x)           |
//+------------------------------------------------------------------+
void AliLiqAdd(const int i, const int zdir, const datetime &time[])
  {
   int h4 = iBarShift(_Symbol, PERIOD_H4, time[i], false);
   if(h4 < 0) return;

   //--- تسريع: شمعة 4H تغطي مئات شموع الشارت - تعالج مرة واحدة فقط
   //--- (بيانات 4H ثابتة خلال نفس الحساب فالنتيجة مطابقة تماماً)
   datetime h4T = iTime(_Symbol, PERIOD_H4, h4);
   if(h4T == gLq4LastH4T) return;
   gLq4LastH4T = h4T;

   //--- v1.43 إصلاح lookahead: آخر شمعة H4 مغلقة (h4+1) بدل الشمعة قيد التكوين
   //--- في التاريخ كانت الشمعة h4 مكتملة (بيانات مستقبلية لحظة time[i])
   //--- ولايف كانت جزئية ولم تُحدّث لاحقاً = الشارت التاريخي لا يطابق اللايف
   int ih = iHighest(_Symbol, PERIOD_H4, MODE_HIGH, InpLiqLook, h4 + 1);
   int il = iLowest (_Symbol, PERIOD_H4, MODE_LOW,  InpLiqLook, h4 + 1);
   if(ih < 0 || il < 0) return;

   double level = (zdir < 0) ? iLow(_Symbol, PERIOD_H4, il)
                             : iHigh(_Symbol, PERIOD_H4, ih);
   if(level <= 0) return;

   //--- منع تكرار نفس المستوى إذا كان مرسوماً بالفعل
   for(int z = 0; z < lq4Count; z++)
      if(lq4DirA[z] == zdir && MathAbs(lq4L[z] - level) < 3.0 * gNP) return;

   //--- قوة السيولة من حجم 4H الحالي مقابل متوسطه
   int nb4  = iBars(_Symbol, PERIOD_H4);
   int kEnd = h4 + 1 + MathMax(1, InpLiqLook);   // v1.43: من الشمعة المغلقة h4+1
   if(kEnd > nb4) kEnd = nb4;
   double v0 = (double)iVolume(_Symbol, PERIOD_H4, h4 + 1);   // v1.43: الشمعة المغلقة
   double s  = 0;
   int    kc = 0;
   for(int k = h4 + 1; k < kEnd; k++) { s += (double)iVolume(_Symbol, PERIOD_H4, k); kc++; }
   double avg = (kc > 0) ? s / (double)kc : 0.0;
   int stI = 2;                                    // 0 قوية / 1 متوسطة / 2 ضعيفة
   if(avg > 0)
     {
      if(v0 > avg * 1.5)      stI = 0;
      else if(v0 > avg * 0.8) stI = 1;
     }

   if(lq4Count >= MAXLQ4)
     {
      ArrayRemove(lq4T, 0, 1);    ArrayRemove(lq4L, 0, 1);
      ArrayRemove(lq4DirA, 0, 1); ArrayRemove(lq4StrA, 0, 1);
      lq4Count--;
     }
   int n = lq4Count;
   ArrayResize(lq4T, n + 1);    ArrayResize(lq4L, n + 1);
   ArrayResize(lq4DirA, n + 1); ArrayResize(lq4StrA, n + 1);
   lq4T[n] = time[i];  lq4L[n] = level;
   lq4DirA[n] = zdir;  lq4StrA[n] = stI;
   lq4Count++;
   gLiqCnt++;
  }

//+------------------------------------------------------------------+
//| رسم مناطق سيولة 4H (مربع 10 شموع + تسمية القوة مثل TradingView)  |
//+------------------------------------------------------------------+
void AliDrawLiqZones(const datetime &time[])
  {
   ObjectsDeleteAll(0, PREFIX + "Y");

   int    drawn = 0;
   double hz    = InpLiqHeight * gNP;

   for(int z = lq4Count - 1; z >= 0 && drawn < MathMax(1, InpAliLiqMax); z--)  // v1.42: حذف *3 - كانت ترسم 6 مناطق سيولة
     {
      long ageBars = (long)((time[0] - lq4T[z]) / gSecBar);
      if(ageBars > 500) continue;

      double top, bot;
      if(lq4DirA[z] < 0) { bot = lq4L[z]; top = lq4L[z] + hz; }   // قاع: دعم شراء
      else               { top = lq4L[z]; bot = lq4L[z] - hz; }   // قمة: مقاومة بيع

      color c  = (lq4DirA[z] < 0) ? C'0,57,30'    : C'90,18,18';   // v1.42: ألوان أهدأ
      color tc = (lq4DirA[z] < 0) ? C'60,230,130' : C'255,110,110';

      string nm = PREFIX + "Y" + IntegerToString(lq4DirA[z] > 0 ? 1 : 0) +
                  "_" + IntegerToString((long)lq4T[z]);
      datetime t2 = (datetime)((long)lq4T[z] + (long)10 * gSecBar);

      ObjectCreate(0, nm, OBJ_RECTANGLE, 0, lq4T[z], top, t2, bot);
      ObjectSetInteger(0, nm, OBJPROP_COLOR, c);
      ObjectSetInteger(0, nm, OBJPROP_FILL, true);
      ObjectSetInteger(0, nm, OBJPROP_BACK, true);
      ObjectSetInteger(0, nm, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, nm, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, nm, OBJPROP_HIDDEN, true);

      //--- تسمية قوة السيولة فوق/تحت المنطقة
      string stTxt = (lq4StrA[z] == 0) ? "قوية" :
                     (lq4StrA[z] == 1) ? "متوسطة" : "ضعيفة";
      string tn = nm + "X";
      ObjectCreate(0, tn, OBJ_TEXT, 0, lq4T[z], lq4L[z]);
      ObjectSetString(0, tn, OBJPROP_TEXT,
                      "سيولة 4H (" + stTxt + ") " + DoubleToString(lq4L[z], _Digits));
      ObjectSetString(0, tn, OBJPROP_FONT, "Arial");
      ObjectSetInteger(0, tn, OBJPROP_FONTSIZE, 8);
      ObjectSetInteger(0, tn, OBJPROP_COLOR, tc);
      ObjectSetInteger(0, tn, OBJPROP_ANCHOR,
                       (lq4DirA[z] < 0) ? ANCHOR_LEFT_UPPER : ANCHOR_LEFT_LOWER);
      ObjectSetInteger(0, tn, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, tn, OBJPROP_HIDDEN, true);
      drawn++;
     }
  }

//+------------------------------------------------------------------+
//| نقطة الدخول الرئيسية                                             |
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
   if(rates_total < 300) return(0);

   //--- تسلسل المصفوفات: 0 = أحدث شمعة
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(tick_volume, true);

   //--- v1.38 إصلاح جذري لعلة "أسهم فقط": فشل نسخ مؤشر مساعد لتيك واحد
   //--- كان يخرج من OnCalculate قبل قسم الرسم بـ return مبكر، فتبقى
   //--- الأسهم (بافرات آخر حساب ناجح) وتختفي كل الخطوط واللوحة.
   //--- الآن: لا خروج مبكر قبل الرسم أبداً - نفقد التيك فقط ونعيد
   //--- المحاولة بحساب كامل في التيك التالي.
   int cnt = MathMin(rates_total, InpMaxBars + 60);
   bool dataOK = (CopyBuffer(hATR, 0, 0, cnt, gATR) >= cnt &&
                  CopyBuffer(hRSI, 0, 0, cnt, gRSI) >= cnt &&
                  CopyBuffer(hATRA, 0, 0, cnt, gATRA) >= cnt &&
                  (!InpUseADX || CopyBuffer(hADX, 0, 0, cnt, gADX) >= cnt));

   bool full = (prev_calculated <= 0);
   int  limit = 0;

   if(full && dataOK)
     {
      ArrayInitialize(BufBuy,  EMPTY_VALUE);
      ArrayInitialize(BufSell, EMPTY_VALUE);
      ArrayInitialize(BufBuyL, EMPTY_VALUE);
      ArrayInitialize(BufSellL, EMPTY_VALUE);
      ArrayInitialize(BufScore, EMPTY_VALUE);
      ArrayInitialize(BufDir,  EMPTY_VALUE);
      ArrayInitialize(BufAliB, EMPTY_VALUE);
      ArrayInitialize(BufAliS, EMPTY_VALUE);
      //--- v1.37: أُلغي المسح الشامل هنا (كان آخر سبب لاختفاء كل الرسم عند
      //--- أي إعادة حساب) - كل دالة رسم تمسح بادئتها الخاصة فقط قبل إعادة البناء
      zCount = 0; mzCount = 0; lqCount = 0; gTradeState = 0;
      gTsUse = -1; gTsSt = 0;   // v1.43: تصفير كاش الاتجاه (ملاحظة: عدادات التنبيه لا تُصفّر هنا لمنع التكرار بعد أي إعادة حساب)
      gAliDir = 0; gAliLastT = 0; gAliSigDir = 0; gAliSigTime = 0;
      gAliEntry = 0; gAliSL = 0; gAliTP1 = 0; gAliTP2 = 0; gAliTP3 = 0;
      gAliTot = 0; gAliBuy = 0; gAliSell = 0;
      lq4Count = 0; gLiqCnt = 0; gLq4LastH4T = 0;
      gLastSigT = 0; gLastSigDir = 0; gAliLastSigT = 0; gAliLastSigDir = 0;   // v1.44
      gLDir = 0; gLTime = 0; gLPrice = 0; gLSL = 0; gLT1 = 0; gLT2 = 0; gLT3 = 0;
      gSTot = 0; gSWin = 0; gSLoss = 0; gSBuy = 0; gSSell = 0; gSTP3 = 0;
      limit = MathMin(rates_total - 60, InpMaxBars);
      //--- v1.38: حُذف الخروج المبكر (كان return(0) يمسح البافرات ثم يخرج
      //--- فيختفي كل شيء مع مدخلات MaxBars صغيرة) - كل دوال الحساب تتحقق
      //--- من الحدود داخلياً فالقيم الصغيرة آمنة
      if(limit < 0) limit = 0;
     }
   else
     {
      limit = rates_total - prev_calculated;
      if(limit < 0) limit = 0;
      if(limit > rates_total - 60) limit = rates_total - 60;
     }

   //--- الحلقة الرئيسية: من الأقدم للجديد (سلسلة: من limit إلى 0)
   //--- v1.38: تعمل فقط عند توفر بيانات المؤشرات المساعدة، لكن الرسم
   //--- بعدها يعمل في كل الأحوال بلا أي استثناء
   if(dataOK)
   for(int i = limit; i >= 0 && !IsStopped(); i--)
     {
      bool closed = (i > 0);

      BufBuy[i]  = EMPTY_VALUE;  BufSell[i]  = EMPTY_VALUE;
      BufBuyL[i] = EMPTY_VALUE;  BufSellL[i] = EMPTY_VALUE;
      BufAliB[i] = EMPTY_VALUE;  BufAliS[i]  = EMPTY_VALUE;

      if(closed)
        {
         ZonesUpdate(i, time, high, low, close);
         FVGBirth(i, rates_total, time, high, low);

         //--- خطوط السيولة: سوينج جديد + كشف الانسياب
         if(InpLiqLines)
           {
            int p = i + InpSwingLen;
            if(IsPivotHigh(p, high, rates_total)) LqAdd(time[p], high[p], 1);
            if(IsPivotLow(p, low, rates_total))   LqAdd(time[p], low[p], -1);
            LqSweep(i, high, low, close);
           }
        }

      EvalOut e;
      Evaluate(i, rates_total, time, open, high, low, close, tick_volume, e);

      BufScore[i] = (double)e.score;
      BufDir[i]   = (double)e.dir;

      //--- ميلاد أوردرك بلوك عند كسر هيكل حقيقي
      if(closed && e.bullBreak) OBBirth(i, rates_total, time, open, high, low, close, 1);
      if(closed && e.bearBreak) OBBirth(i, rates_total, time, open, high, low, close, -1);

      double atr = gATR[i];
      double off = (atr > 0 ? atr * 0.35 : 25.0 * gNP);

      //--- بوابة علي ماستر (وضع الفلتر): اشتراط شرط اختراق 3 شموع
      bool aBuyOK = true, aSellOK = true;
      if(InpAliMode == ALI_MODE_FILTER)
        {
         aBuyOK  = AliBullCond(i, open, high, low, close);
         aSellOK = AliBearCond(i, open, high, low, close);
        }

      if(e.dir > 0 && aBuyOK)
        {
         if(closed && e.score >= InpMinScore && RevWaitOK(1, time[i]))   // v1.44: لا انعكاس قبل انتهاء الانتظار
           {
            BufBuy[i] = low[i] - off;
            gLDir = 1; gLTime = time[i]; gLPrice = close[i];
            CalcLevels(1, close[i], atr, gLSL, gLT1, gLT2, gLT3);
            gLastSigDir = 1; gLastSigT = time[i];   // v1.44: تحديث عداد منع الانعكاس
            gSTot++; gSBuy++;
            if(i == 1) DoAlert(false, 1, close[i], gLSL, gLT1, gLT2, gLT3, time[i]);
           }
         else if(!closed && InpProvisional && e.score >= InpMinScoreLive)
            BufBuyL[i] = low[i] - off;
        }
      else if(e.dir < 0 && aSellOK)
        {
         if(closed && e.score >= InpMinScore && RevWaitOK(-1, time[i]))  // v1.44: لا انعكاس قبل انتهاء الانتظار
           {
            BufSell[i] = high[i] + off;
            gLDir = -1; gLTime = time[i]; gLPrice = close[i];
            CalcLevels(-1, close[i], atr, gLSL, gLT1, gLT2, gLT3);
            gLastSigDir = -1; gLastSigT = time[i];  // v1.44: تحديث عداد منع الانعكاس
            gSTot++; gSSell++;
            if(i == 1) DoAlert(false, -1, close[i], gLSL, gLT1, gLT2, gLT3, time[i]);
           }
         else if(!closed && InpProvisional && e.score >= InpMinScoreLive)
            BufSellL[i] = high[i] + off;
        }

      //--- محرك علي ماستر: إشارات مستقلة على الشموع المغلقة (Non-Repaint)
      //--- شرط الشراء: شمعة صاعدة قمتها >= أعلى آخر 3 شموع (مع تبادل الاتجاه)
      if(closed && InpAliMode == ALI_MODE_STAND && i + 3 <= rates_total - 1 &&
         time[i] != gAliLastT)
        {
         if(AliBullCond(i, open, high, low, close) && gAliDir != 1 &&
            AliRevWaitOK(1, time[i]))                     // v1.44: لا انعكاس قبل الانتظار
           {
            gAliDir = 1;  gAliLastT = time[i];
            BufAliB[i] = low[i] - (atr > 0 ? atr * 0.9 : 60.0 * gNP);
            gAliSigDir = 1;  gAliSigTime = time[i];  gAliEntry = close[i];
            AliLevels(1, close[i], (i < ArraySize(gATRA) ? gATRA[i] : 0.0),
                      gAliSL, gAliTP1, gAliTP2, gAliTP3);
            gAliLastSigDir = 1; gAliLastSigT = time[i];   // v1.44
            gAliTot++;  gAliBuy++;
            gLiqCnt = 0;
            if(i == 1) DoAlert(true, 1, close[i], gAliSL, gAliTP1, gAliTP2, gAliTP3, time[i]);
           }
         else if(AliBearCond(i, open, high, low, close) && gAliDir != -1 &&
                 AliRevWaitOK(-1, time[i]))               // v1.44: لا انعكاس قبل الانتظار
           {
            gAliDir = -1;  gAliLastT = time[i];
            BufAliS[i] = high[i] + (atr > 0 ? atr * 0.9 : 60.0 * gNP);
            gAliSigDir = -1;  gAliSigTime = time[i];  gAliEntry = close[i];
            AliLevels(-1, close[i], (i < ArraySize(gATRA) ? gATRA[i] : 0.0),
                      gAliSL, gAliTP1, gAliTP2, gAliTP3);
            gAliLastSigDir = -1; gAliLastSigT = time[i];  // v1.44
            gAliTot++;  gAliSell++;
            gLiqCnt = 0;
            if(i == 1) DoAlert(true, -1, close[i], gAliSL, gAliTP1, gAliTP2, gAliTP3, time[i]);
           }
        }

      //--- لقطات مناطق سيولة 4H أثناء الاتجاه المتصل (منطق علي ماستر)
      //--- هبوط متصل = منطقة خضراء عند قاع 4H ، صعود متصل = حمراء عند قمته
      if(closed && InpAliMode != ALI_MODE_OFF && InpAliLiq && i + 2 <= rates_total - 1)
        {
         bool dnT = (close[i] < close[i + 1] && close[i + 1] < close[i + 2]);
         bool upT = (close[i] > close[i + 1] && close[i + 1] > close[i + 2]);
         if(dnT && gLiqCnt < InpAliLiqMax)      AliLiqAdd(i, -1, time);
         else if(upT && gLiqCnt < InpAliLiqMax) AliLiqAdd(i, 1, time);
        }
     }

   //--- الأعمال الثقيلة فقط دورية عند شمعة جديدة (توفير موارد)
   static datetime lastBarTime = 0;
   if(full) lastBarTime = 0;
   if(time[0] != lastBarTime)
     {
      lastBarTime = time[0];
      if(InpMTFZones) MTFScan();
      UpdateStats(time, open, high, low, close, rates_total);   // v1.43: + open لقاعدة الشمعة الملتبسة
     }

   //--- إصلاح v1.36 + v1.38: كل الرسم يعاد في كل تيك (شفاء ذاتي فوري)
   //--- v1.38: هذا القسم يعمل دائماً بلا أي خروج مبكر قبله في أي حالة
   //--- (فشل بيانات / شمعة جديدة / مدخلات) فلا يمكن أن يبقى الشارت
   //--- فارغاً أبداً، والأسهم لا تظهر وحدها بعد اليوم
   if(InpShowZones) DrawZones(time, rates_total);
   if(InpMTFZones)  DrawMTFZones(time);
   if(InpLiqLines)  DrawLiq(time, rates_total);
   if(InpShowFibo)  DrawFibo(time, high, low, rates_total);
   if(InpShowLines) DrawLastSignals(time, high, low, close, rates_total);
   if(InpAliMode == ALI_MODE_STAND)             AliDrawSignal();
   if(InpAliMode != ALI_MODE_OFF && InpAliLiq)  AliDrawLiqZones(time);
   if(InpShowDash) DrawDash(time, high, low, close, rates_total);

   ChartRedraw();
   //--- v1.38: عند فشل بيانات المؤشرات المساعدة نعيد 0 ليعاد الحساب
   //--- الكامل في التيك التالي بدل ترك فجوة صامتة في البافرات
   return(dataOK ? rates_total : 0);
  }
//+------------------------------------------------------------------+
//| رسم المناطق النشطة (أوردرك بلوكس + FVG)                          |
//+------------------------------------------------------------------+
void DrawZones(const datetime &time[], const int total)
  {
   //--- إعادة بناء نظيفة: المناطق المكسورة تختفي تلقائياً
   ObjectsDeleteAll(0, PREFIX + "Z");

   int drawn = 0;
   for(int z = zCount - 1; z >= 0 && drawn < InpMaxZones; z--)
     {
      if(zMitA[z]) continue;
      long age = (long)(time[0] - zBorn[z]);
      if(age > (long)InpOBValidBars * (long)gSecBar) continue;

      int kf = (zKindA[z] == 0) ? 0 : 2;          // 0/1 = OB ، 2/3 = FVG
      int df = (zDirA[z] > 0) ? 0 : 1;
      color c, tc;                                 // c = تعبئة المربع ، tc = لون التسمية
      if(kf == 0)
        {
         c  = (df == 0) ? C'0,52,26'  : C'68,16,16';   // v1.42: ألوان أهدأ
         tc = (df == 0) ? C'0,220,120' : C'255,96,96';
        }
      else
        {
         c  = (df == 0) ? C'0,40,60'  : C'58,34,0';    // v1.42: ألوان أهدأ
         tc = (df == 0) ? C'80,190,255' : C'255,180,80';
        }

      string nm = PREFIX + "Z" + IntegerToString(kf) +
                  IntegerToString(df) + "_" + IntegerToString((long)zBorn[z]);
      datetime t2 = (datetime)((long)time[0] + (long)5 * gSecBar);

      ObjectCreate(0, nm, OBJ_RECTANGLE, 0, zBorn[z], zTop[z], t2, zBot[z]);
      ObjectSetInteger(0, nm, OBJPROP_COLOR, c);
      ObjectSetInteger(0, nm, OBJPROP_FILL, true);
      ObjectSetInteger(0, nm, OBJPROP_BACK, true);
      ObjectSetInteger(0, nm, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, nm, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, nm, OBJPROP_HIDDEN, true);

      //--- تسمية المنطقة: النوع + الاتجاه + نطاق السعر
      if(InpZoneLabels)
        {
         string tn = nm + "L";
         string ztxt = (zKindA[z] == 0 ? "OB " : "FVG ") +
                       (zDirA[z] > 0 ? "شراء" : "بيع") + " " +
                       TFToStr(_Period) + "  " +
                       DoubleToString(zBot[z], _Digits) + " - " +
                       DoubleToString(zTop[z], _Digits);
         ObjectCreate(0, tn, OBJ_TEXT, 0, zBorn[z], zTop[z]);
         ObjectSetString(0, tn, OBJPROP_TEXT, ztxt);
         ObjectSetString(0, tn, OBJPROP_FONT, "Arial");
         ObjectSetInteger(0, tn, OBJPROP_FONTSIZE, 8);
         ObjectSetInteger(0, tn, OBJPROP_COLOR, tc);
         ObjectSetInteger(0, tn, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
         ObjectSetInteger(0, tn, OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, tn, OBJPROP_HIDDEN, true);
        }
      drawn++;
     }
  }

//+------------------------------------------------------------------+
//| رسم خط مستوى (دخول/ستوب/هدف) مع تسمية                            |
//+------------------------------------------------------------------+
void DrawLevel(const string nm, const datetime t1, const double p1,
               const datetime t2, const double p2, const color c,
               const string txt)
  {
   if(ObjectFind(0, nm) < 0)
     {
      ObjectCreate(0, nm, OBJ_TREND, 0, t1, p1, t2, p2);
      ObjectSetInteger(0, nm, OBJPROP_COLOR, c);
      ObjectSetInteger(0, nm, OBJPROP_STYLE, STYLE_DOT);
      ObjectSetInteger(0, nm, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, nm, OBJPROP_RAY_RIGHT, false);
      ObjectSetInteger(0, nm, OBJPROP_RAY_LEFT, false);
      ObjectSetInteger(0, nm, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, nm, OBJPROP_HIDDEN, true);

      string tn = nm + "X";
      ObjectCreate(0, tn, OBJ_TEXT, 0, t2, p2);
      ObjectSetString(0, tn, OBJPROP_TEXT, txt);
      ObjectSetInteger(0, tn, OBJPROP_COLOR, c);
      ObjectSetInteger(0, tn, OBJPROP_FONTSIZE, 8);
      ObjectSetString(0, tn, OBJPROP_FONT, "Arial");
      ObjectSetInteger(0, tn, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);// v1.40: النص أعلى الخط بدل متشابك معه
      ObjectSetInteger(0, tn, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, tn, OBJPROP_HIDDEN, true);
     }
   else
     {
      ObjectMove(0, nm, 1, t2, p2);
      ObjectMove(0, nm + "X", 0, t2, p2);
     }
  }

//+------------------------------------------------------------------+
//| رسم خطوط آخر الصفقات (دخول + ستوب + هدفين)                       |
//+------------------------------------------------------------------+
void DrawLastSignals(const datetime &time[], const double &high[], const double &low[],
                     const double &close[], const int total)
  {
   ObjectsDeleteAll(0, PREFIX + "T");
   gTradeState = 0;
   int found = 0;
   int maxScan = MathMin(total - 5, InpMaxBars);

   for(int i = 1; i <= maxScan && found < InpMaxLines; i++)
     {
      int dir = 0;
      if(BufBuy[i]  != EMPTY_VALUE) dir = 1;
      else if(BufSell[i] != EMPTY_VALUE) dir = -1;
      if(dir == 0) continue;
      found++;

      double atr = gATR[i];
      if(atr <= 0) continue;
      double sl, tp1, tp2, tp3;
      CalcLevels(dir, close[i], atr, sl, tp1, tp2, tp3);

      //--- حالة إدارة الصفقة (لأحدث إشارة فقط)
      int st = 0;
      if(InpTradeMgr && found == 1)
        {
         for(int j = i - 1; j >= 0; j--)
           {
            bool slHit = (dir > 0) ? (low[j] <= sl)   : (high[j] >= sl);
            bool t2Hit = (dir > 0) ? (high[j] >= tp2) : (low[j] <= tp2);
            bool t3Hit = (dir > 0) ? (high[j] >= tp3) : (low[j] <= tp3);   // v1.44
            bool t1Hit = (dir > 0) ? (high[j] >= tp1) : (low[j] <= tp1);
            if(slHit) { st = -1; break; }
            if(t3Hit) { st = 3;  break; }   // v1.44: اكتملت عند الهدف الثالث
            if(t2Hit) { st = 2;  break; }
            if(t1Hit) { st = 1;  break; }
           }
         gTradeState = st;
        }

      datetime t0 = time[i];
      datetime tE = (datetime)((long)t0 + (long)InpLineLen * (long)gSecBar);
      string base = PREFIX + "T" + IntegerToString((long)t0);

      DrawLevel(base + "E", t0, close[i], tE, close[i], clrSilver,
                "ENTRY " + DoubleToString(close[i], _Digits));
      color  slC  = (st == 1) ? clrGold : clrRed;
      string slTx = (st == 1) ? ("SL => BE " + DoubleToString(sl, _Digits)) :
                    ("SL " + DoubleToString(sl, _Digits));
      DrawLevel(base + "S", t0, sl, tE, sl, slC, slTx);
      DrawLevel(base + "1", t0, tp1, tE, tp1, clrSpringGreen,
                "TP1 " + DoubleToString(tp1, _Digits));
      DrawLevel(base + "2", t0, tp2, tE, tp2, clrGreen,
                "TP2 " + DoubleToString(tp2, _Digits));
      DrawLevel(base + "3", t0, tp3, tE, tp3, clrLimeGreen,   // v1.44: خط الهدف الثالث
                "TP3 " + DoubleToString(tp3, _Digits));
     }
  }

//+------------------------------------------------------------------+
//| إحصائيات آخر 100 إشارة: وصول TP1 قبل SL؟                         |
//+------------------------------------------------------------------+
void UpdateStats(const datetime &time[], const double &open[],
                 const double &high[], const double &low[],
                 const double &close[], const int total)
  {
   gSTot = 0; gSWin = 0; gSLoss = 0; gSBuy = 0; gSSell = 0; gSTP3 = 0;   // v1.44
   gRSum = 0;
   ArrayInitialize(gSesW, 0); ArrayInitialize(gSesL, 0);
   ArrayInitialize(gHrW, 0);  ArrayInitialize(gHrL, 0);
   int maxScan = MathMin(total - 5, InpMaxBars);
   int counted = 0;

   for(int s = 1; s <= maxScan && counted < 100; s++)
     {
      int dir = 0;
      if(BufBuy[s]  != EMPTY_VALUE) dir = 1;
      else if(BufSell[s] != EMPTY_VALUE) dir = -1;
      if(dir == 0) continue;

      double atr = gATR[s];
      if(atr <= 0) continue;
      double sl, tp1, tp2, tp3;
      CalcLevels(dir, close[s], atr, sl, tp1, tp2, tp3);
      if(MathAbs(close[s] - sl) <= 0) continue;

      //--- v1.43: العدادات بعد اجتياز كل الفحوصات = أرقام اللوحة متوافقة دائماً
      counted++;
      gSTot++;
      if(dir > 0) gSBuy++; else gSSell++;

      MqlDateTime dt;
      TimeToStruct(time[s], dt);
      int ses = RawSession(time[s]);

      int jEnd = s - 1;
      int jStart = s - 300;
      if(jStart < 0) jStart = 0;

      //--- v1.44: النتيجة (TP1 أساس النجاح/الخسارة) + عداد وصول TP3
      bool win = false;
      for(int j = jEnd; j >= jStart; j--)
        {
         bool slHit  = (dir > 0) ? (low[j] <= sl)   : (high[j] >= sl);
         bool tp1Hit = (dir > 0) ? (high[j] >= tp1) : (low[j] <= tp1);
         bool t3Hit  = (dir > 0) ? (high[j] >= tp3) : (low[j] <= tp3);
         if(!win)
           {
            if(slHit && tp1Hit)                         // v1.43: شمعة ملتبسة قابلة للضبط
              {
               if(AmbigLoss(open[j], sl, tp1))
                 { gSLoss++; gRSum -= 1.0; gSesL[ses]++; gHrL[dt.hour]++; break; }
               win = true;
               gSWin++;  gRSum += InpTP1_R; gSesW[ses]++; gHrW[dt.hour]++;
              }
            else if(slHit)                              // ستوب قبل الهدف = خسارة
              {
               gSLoss++; gRSum -= 1.0; gSesL[ses]++; gHrL[dt.hour]++;
               break;
              }
            else if(tp1Hit)                             // الهدف الأول = نجاح
              {
               win = true;
               gSWin++; gRSum += InpTP1_R; gSesW[ses]++; gHrW[dt.hour]++;
              }
           }
         if(win && t3Hit) { gSTP3++; break; }           // v1.44: وصول الهدف الثالث
        }
     }
  }

//+------------------------------------------------------------------+
//| عنصر نص في لوحة المعلومات                                        |
//+------------------------------------------------------------------+
void DashLabel(const int idx, const int y, const string txt, const color c,
               const int fs, const ENUM_BASE_CORNER cr, const bool rightSide)
  {
   string nm = PREFIX + "L" + IntegerToString(idx);
   if(ObjectFind(0, nm) < 0)
     {
      ObjectCreate(0, nm, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, nm, OBJPROP_FONTSIZE, fs);
      ObjectSetString(0, nm, OBJPROP_FONT, "Arial");
      ObjectSetInteger(0, nm, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, nm, OBJPROP_HIDDEN, true);
     }
   ObjectSetInteger(0, nm, OBJPROP_CORNER, cr);
   ObjectSetInteger(0, nm, OBJPROP_XDISTANCE, InpDashX + 10);
   ObjectSetInteger(0, nm, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, nm, OBJPROP_ANCHOR, rightSide ? ANCHOR_RIGHT_UPPER : ANCHOR_LEFT_UPPER);
   ObjectSetString(0, nm, OBJPROP_TEXT, txt);
   ObjectSetInteger(0, nm, OBJPROP_COLOR, c);
  }

//+------------------------------------------------------------------+
//| لوحة المعلومات                                                   |
//+------------------------------------------------------------------+
void DrawDash(const datetime &time[], const double &high[], const double &low[],
              const double &close[], const int rates_total)
  {
   ENUM_BASE_CORNER cr = (InpPanelCorner == CORNER_RIGHT_UPPER ||
                          InpPanelCorner == CORNER_RIGHT_LOWER)
                         ? CORNER_RIGHT_UPPER : CORNER_LEFT_UPPER;
   bool rightSide = (cr == CORNER_RIGHT_UPPER);

   int rows = 27;                      // v1.44: + صف الدخول الذهبي + صف منع الانعكاس
   int fs   = InpFontSize;
   int lw   = MathMax(420, fs * 40);   // v1.43: عرض أوسع يمنع قطع أطول السطور
   int rh   = fs + 8;
   int bh   = rows * rh + 12;

   //--- ألوان الثيم المختار
   color bgC, brdC, baseC, dimC;
   ThemeColors(bgC, brdC, baseC, dimC);

   string bg = PREFIX + "BG";
   if(ObjectFind(0, bg) < 0)
     {
      ObjectCreate(0, bg, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, bg, OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, bg, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, bg, OBJPROP_HIDDEN, true);
     }
   // نقطة ارتكاز RECTANGLE_LABEL مثبتة دائماً في الزاوية العلوية اليسرى للكائن،
   // لذلك مع الزاوية اليمنى يجب أن تساوي الإزاحة (عرض اللوحة + الهامش) وإلا تخرج اللوحة عن الشاشة
   ObjectSetInteger(0, bg, OBJPROP_CORNER, cr);
   ObjectSetInteger(0, bg, OBJPROP_BGCOLOR, bgC);
   ObjectSetInteger(0, bg, OBJPROP_COLOR, brdC);
   ObjectSetInteger(0, bg, OBJPROP_BACK, (InpTheme == GSP_THEME_GLASS));
   ObjectSetInteger(0, bg, OBJPROP_XDISTANCE, rightSide ? (InpDashX + lw) : InpDashX);
   ObjectSetInteger(0, bg, OBJPROP_YDISTANCE, InpDashY - 6);
   ObjectSetInteger(0, bg, OBJPROP_XSIZE, lw);
   ObjectSetInteger(0, bg, OBJPROP_YSIZE, bh);

   //--- بيانات اللحظة
   int tr   = TrendStateAt(TimeCurrent());
   int sess = RawSession(TimeCurrent());

   double atr0   = (ArraySize(gATR) > 0 ? gATR[0] : 0);
   double atrPts = atr0 / gNP;
   string atrSt  = "طبيعي";
   color  atrC   = baseC;
   if(InpUseATRFlt && atrPts < InpMinATRPts) { atrSt = "ميت - لا دخول";  atrC = clrOrange; }
   else if(InpUseATRFlt && atrPts > InpMaxATRPts) { atrSt = "عالي - حذر"; atrC = clrOrange; }

   double v0 = 0, vAvg = 0;
   if(rates_total > InpVolPeriod + 2)
     {
      v0 = (double)iVolume(_Symbol, _Period, 0);
      double s = 0;
      for(int k = 1; k <= InpVolPeriod; k++)
         s += (double)iVolume(_Symbol, _Period, k);
      vAvg = s / (double)InpVolPeriod;
     }
   double volPct = (vAvg > 0 ? v0 / vAvg * 100.0 : 0.0);
   bool vSpike = (vAvg > 0 && v0 >= vAvg * InpVolMult);

   double liveScore = 0;
   if(rates_total > 0 && BufScore[0] != EMPTY_VALUE) liveScore = BufScore[0];

   //--- حالة الأخبار
   string nInfo  = "";
   bool   nBlock = false;
   if(InpUseNews) nBlock = NewsBlocked(nInfo);

   //--- موقع السعر داخل نطاق التداول (Premium/Discount)
   string pdTxt = "الموقع: لا نطاق واضح حالياً";
   color  pdC   = baseC;
   DealRange dr;
   GetDealingRange(0, rates_total, time, high, low, dr);
   if(dr.valid)
     {
      double rng = dr.hi - dr.lo;
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double pct = (rng > 0) ? (bid - dr.lo) / rng * 100.0 : 50.0;
      if(pct <= 45)      { pdTxt = "الموقع: Discount " + DoubleToString(pct, 0) + "% - منطقة شراء"; pdC = C'0,200,110'; }
      else if(pct >= 55) { pdTxt = "الموقع: Premium " + DoubleToString(pct, 0) + "% - منطقة بيع";   pdC = C'255,90,90';  }
      else                { pdTxt = "الموقع: توازن " + DoubleToString(pct, 0) + "%";                 pdC = baseC;          }
     }

   //--- الصفوف
   int y0 = InpDashY + 4;
   DashLabel(0, y0 + 0 * rh, ALI_TITLE + " | " + _Symbol + " " + TFToStr(_Period),
             clrGold, fs + 1, cr, rightSide);

   string trTxt = (tr == 1) ? "صاعد" : (tr == -1) ? "هابط" : "عرضي";
   color  trC   = (tr == 1) ? clrLime : (tr == -1) ? clrOrangeRed : baseC;
   DashLabel(1, y0 + 1 * rh, "الاتجاه " + TFToStr(gTF) + ": " + trTxt, trC, fs, cr, rightSide);

   string seTxt = (sess == 3) ? "لندن + نيويورك (ذروة)" : (sess == 1) ? "لندن" :
                  (sess == 2) ? "نيويورك" : "خارج الجلسات (آسيا)";
   color  seC   = (sess > 0) ? clrLime : clrGray;
   if(!InpUseSession) seTxt += " (الفلتر معطل)";
   DashLabel(2, y0 + 2 * rh, "الجلسة: " + seTxt, seC, fs, cr, rightSide);

   DashLabel(3, y0 + 3 * rh, "التوقيت: " + SessionCountdownText(sess), clrGold, fs, cr, rightSide);

   DashLabel(4, y0 + 4 * rh, "التذبذب: " + DoubleToString(atrPts, 0) + " نقطة (" + atrSt + ")",
             atrC, fs, cr, rightSide);

   string vTxt = "الحجم: " + DoubleToString(volPct, 0) + "% من المتوسط" +
                 (vSpike ? " - قوي" : "");
   DashLabel(5, y0 + 5 * rh, vTxt, vSpike ? clrLime : baseC, fs, cr, rightSide);

   color scC = (liveScore >= InpMinScoreLive) ? clrGold : baseC;
   DashLabel(6, y0 + 6 * rh, "قوة الإشارة الحالية: " + DoubleToString(liveScore, 0) +
             "/" + IntegerToString(gScoreMax) + " (مطلوب " + IntegerToString(InpMinScoreLive) + ")",
             scC, fs, cr, rightSide);

   string nTxt;
   color  nC;
   if(!InpUseNews) { nTxt = "الأخبار: الفلتر معطل";  nC = clrGray; }
   else if(nBlock) { nTxt = "أخبار مهمة: " + nInfo + " - لا دخول"; nC = clrOrange; }
   else            { nTxt = "الأخبار: هادئ - الدخول مسموح";        nC = C'0,190,100'; }
   DashLabel(7, y0 + 7 * rh, nTxt, nC, fs, cr, rightSide);

   DashLabel(8, y0 + 8 * rh, pdTxt, pdC, fs, cr, rightSide);

   //--- صفوف محرك علي ماستر v6
   string alTxt;
   color  alC;
   if(InpAliMode == ALI_MODE_OFF)
     { alTxt = "علي ماستر: معطل"; alC = clrGray; }
   else
     {
      string md = (InpAliMode == ALI_MODE_FILTER) ? "فلتر تأكيد" : "إشارات مستقلة";
      string ds = (gAliDir == 1) ? "اتجاه شراء" : (gAliDir == -1) ? "اتجاه بيع" : "محايد";
      string lv = "";
      if(InpAliMode == ALI_MODE_STAND)
        {
         if(AliLiveBull() && gAliDir != 1)       lv = " | شرط شراء متوفر الآن!";
         else if(AliLiveBear() && gAliDir != -1) lv = " | شرط بيع متوفر الآن!";
        }
      else
        {
         if(AliLiveBull())       lv = " | اشتراط الشراء متوفر";
         else if(AliLiveBear())  lv = " | اشتراط البيع متوفر";
        }
      alTxt = "علي ماستر [" + md + "]: " + ds + lv;
      alC   = baseC;
      if(gAliDir == 1)       alC = InpColBuy;
      else if(gAliDir == -1) alC = InpColSell;
      if(StringFind(lv, "الآن") >= 0) alC = clrGold;
     }
   DashLabel(9, y0 + 9 * rh, alTxt, alC, fs, cr, rightSide);

   if(InpAliMode != ALI_MODE_OFF && gAliSigDir != 0 && gAliSigTime > 0)
     {
      int ab = iBarShift(_Symbol, _Period, gAliSigTime, false);
      if(ab < 0) ab = 0;
      string adTxt = (gAliSigDir > 0) ? "شراء" : "بيع";
      color  adC   = (gAliSigDir > 0) ? clrDodgerBlue : clrDarkOrange;
      DashLabel(10, y0 + 10 * rh, "آخر إشارة علي: " + adTxt + " @ " +
                DoubleToString(gAliEntry, _Digits) + " (" + IntegerToString(ab) + " شمعة)",
                adC, fs, cr, rightSide);
      DashLabel(11, y0 + 11 * rh, "ستوب علي: " + DoubleToString(gAliSL, _Digits) +
                " | هدف1: " + DoubleToString(gAliTP1, _Digits) +
                " | هدف2: " + DoubleToString(gAliTP2, _Digits) +
                " | هدف3: " + DoubleToString(gAliTP3, _Digits),
                baseC, fs, cr, rightSide);
     }
   else
     {
      DashLabel(10, y0 + 10 * rh,
                (InpAliMode == ALI_MODE_FILTER) ? "علي ماستر: فلتر تأكيد فقط - بلا إشارات مستقلة"
                                                : "آخر إشارة علي: لا توجد بعد",
                clrGray, fs, cr, rightSide);
      DashLabel(11, y0 + 11 * rh, "ستوب علي: - | هدف1: - | هدف2: - | هدف3: -", clrGray, fs, cr, rightSide);
     }

   //--- سيولة فريم 4 ساعات (منطق علي ماستر)
   string lqTxt;
   color  lqC;
   if(InpAliMode == ALI_MODE_OFF || !InpAliLiq)
     { lqTxt = "سيولة 4H: معطلة"; lqC = clrGray; }
   else
     {
      int ih = iHighest(_Symbol, PERIOD_H4, MODE_HIGH, InpLiqLook, 0);
      int il = iLowest (_Symbol, PERIOD_H4, MODE_LOW,  InpLiqLook, 0);
      if(ih < 0 || il < 0)
        { lqTxt = "سيولة 4H: بيانات غير جاهزة"; lqC = clrGray; }
      else
        {
         double s4 = 0;
         for(int k4 = 0; k4 < MathMax(1, InpLiqLook); k4++)
            s4 += (double)iVolume(_Symbol, PERIOD_H4, k4);
         double a4 = s4 / (double)MathMax(1, InpLiqLook);
         double v4 = (double)iVolume(_Symbol, PERIOD_H4, 0);
         string st4 = (a4 > 0 && v4 > a4 * 1.5) ? "قوية" :
                      (a4 > 0 && v4 > a4 * 0.8) ? "متوسطة" : "ضعيفة";
         lqTxt = "سيولة 4H: قمة " + DoubleToString(iHigh(_Symbol, PERIOD_H4, ih), _Digits) +
                 " | قاع " + DoubleToString(iLow(_Symbol, PERIOD_H4, il), _Digits) +
                 " - حجم " + st4;
         lqC = baseC;
        }
     }
   DashLabel(12, y0 + 12 * rh, lqTxt, lqC, fs, cr, rightSide);

   if(gLDir != 0 && gLTime > 0)
     {
      int ba = iBarShift(_Symbol, _Period, gLTime, false);
      if(ba < 0) ba = 0;
      string dTxt = (gLDir > 0) ? "شراء" : "بيع";
      color  dC   = (gLDir > 0) ? InpColBuy : InpColSell;
      DashLabel(13, y0 + 13 * rh, "آخر إشارة: " + dTxt + " @ " + DoubleToString(gLPrice, _Digits) +
                " (" + IntegerToString(ba) + " شمعة)", dC, fs, cr, rightSide);
      DashLabel(14, y0 + 14 * rh, "ستوب: " + DoubleToString(gLSL, _Digits) +
                " | هدف1: " + DoubleToString(gLT1, _Digits) +
                " | هدف2: " + DoubleToString(gLT2, _Digits) +
                " | هدف3: " + DoubleToString(gLT3, _Digits),
                baseC, fs, cr, rightSide);
     }
   else
     {
      DashLabel(13, y0 + 13 * rh, "آخر إشارة: لا توجد بعد", clrGray, fs, cr, rightSide);
      DashLabel(14, y0 + 14 * rh, "ستوب: - | هدف1: - | هدف2: - | هدف3: -", clrGray, fs, cr, rightSide);
     }

   string mgTxt;
   color  mgC;
   if(gLDir == 0 || !InpTradeMgr) { mgTxt = "إدارة الصفقة: -"; mgC = clrGray; }
   else
     {
      switch(gTradeState)
        {
         case 1:   mgTxt = "إدارة: تحقق هدف1 - انقل الستوب للتعادل"; mgC = clrGold;      break;
         case 2:   mgTxt = "إدارة: اكتملت الأهداف - صفقة ناجحة";     mgC = clrLime;      break;
         case -1:  mgTxt = "إدارة: ضرب الستوب - صفقة خاسرة";         mgC = clrOrangeRed; break;
         default:  mgTxt = "إدارة: الصفقة قيد التداول";              mgC = baseC;        break;
        }
     }
   DashLabel(15, y0 + 15 * rh, mgTxt, mgC, fs, cr, rightSide);

   int wr = (gSWin + gSLoss > 0) ? gSWin * 100 / (gSWin + gSLoss) : 0;
   DashLabel(16, y0 + 16 * rh, "النتائج: " + IntegerToString(gSTot) +
             " إشارة | نجاح " + IntegerToString(wr) + "% | شراء " +
             IntegerToString(gSBuy) + " | بيع " + IntegerToString(gSSell) +
             " | TP3 " + IntegerToString(gSTP3),
             baseC, fs, cr, rightSide);

   double avgR = (gSWin + gSLoss > 0) ? gRSum / (double)(gSWin + gSLoss) : 0.0;
   DashLabel(17, y0 + 17 * rh, "متوسط الأداء (حتى TP1): " + StringFormat("%+.2fR", avgR) +
             " | أفضل جلسة: " + BestSessionTxt(),
             (avgR >= 0.0) ? C'0,200,110' : clrOrangeRed, fs, cr, rightSide);

   DashLabel(18, y0 + 18 * rh, "أفضل ساعة دخول: " + BestHourTxt(),
             baseC, fs, cr, rightSide);

   DashLabel(19, y0 + 19 * rh, "الإشارات: خطوط صفقة + لوحة معلومات | بلا أسهم على الشارت",
             dimC, fs - 1, cr, rightSide);

   //--- v1.43: إحصائيات محرك علي ماستر (كانت تُحتسب ولا تُعرض)
   string aStTxt;
   color  aStC;
   if(InpAliMode == ALI_MODE_OFF)
     { aStTxt = "إحصائيات علي: معطل"; aStC = clrGray; }
   else
     {
      aStTxt = "إحصائيات علي: " + IntegerToString(gAliTot) +
               " إشارة | شراء " + IntegerToString(gAliBuy) +
               " | بيع " + IntegerToString(gAliSell);
      aStC = baseC;
     }
   DashLabel(20, y0 + 20 * rh, aStTxt, aStC, fs, cr, rightSide);

   //--- v1.43+: صفوف التعزيزات الأربعة
   string dxyTxt; color dxyC;
   if(!InpUseDXY)          { dxyTxt = "الدولار DXY: الفلتر معطل";                   dxyC = clrGray; }
   else if(gDXYUsed == "") { dxyTxt = "الدولار DXY: رمز غير متوفر - معطل تلقائياً"; dxyC = clrGray; }
   else
     {
      int dd = DXYDirNow();
      if(dd == 0) { dxyTxt = "الدولار DXY (" + gDXYUsed + "): بيانات غير جاهزة"; dxyC = clrGray; }
      else
        {
         dxyTxt = "الدولار DXY (" + gDXYUsed + "): " +
                  ((dd > 0) ? "صاعد - يدعم بيع الذهب (+1)" : "هابط - يدعم شراء الذهب (+1)");
         dxyC = (dd > 0) ? C'255,90,90' : C'0,200,110';
        }
     }
   DashLabel(21, y0 + 21 * rh, dxyTxt, dxyC, fs, cr, rightSide);

   string adxTxt; color adxC;
   if(!InpUseADX) { adxTxt = "ADX: الفلتر معطل"; adxC = clrGray; }
   else if(ArraySize(gADX) <= 0 || gADX[0] <= 0)
                  { adxTxt = "ADX: بيانات غير جاهزة"; adxC = clrGray; }
   else
     {
      double av = gADX[0];
      if(av >= InpADXMin)      { adxTxt = "ADX: " + DoubleToString(av, 1) + " - ترند صحي (+1)"; adxC = C'0,200,110'; }
      else if(av < InpADXFlat) { adxTxt = "ADX: " + DoubleToString(av, 1) + " - سوق عرضي (-1)"; adxC = clrOrange;    }
      else                     { adxTxt = "ADX: " + DoubleToString(av, 1) + " - قوة متوسطة";    adxC = baseC;        }
     }
   DashLabel(22, y0 + 22 * rh, adxTxt, adxC, fs, cr, rightSide);

   string dvTxt; color dvC;
   if(!InpUseDiv) { dvTxt = "دايفرجنس RSI: معطل"; dvC = clrGray; }
   else if(rates_total <= 10)
                  { dvTxt = "دايفرجنس RSI: بيانات غير كافية"; dvC = clrGray; }
   else
     {
      bool dB = BullDivergence(1, low, rates_total);
      bool dS = BearDivergence(1, high, rates_total);
      if(dB)      { dvTxt = "دايفرجنس RSI: صاعد الآن (+2 للشراء)"; dvC = InpColBuy;  }
      else if(dS) { dvTxt = "دايفرجنس RSI: هابط الآن (+2 للبيع)";  dvC = InpColSell; }
      else        { dvTxt = "دايفرجنس RSI: لا يوجد حالياً";         dvC = baseC;      }
     }
   DashLabel(23, y0 + 23 * rh, dvTxt, dvC, fs, cr, rightSide);

   string asTxt; color asC;
   if(!InpUseAsia) { asTxt = "النطاق الآسيوي: معطل"; asC = clrGray; }
   else if(rates_total <= 60)
                   { asTxt = "النطاق الآسيوي: بيانات غير كافية"; asC = clrGray; }
   else
     {
      int asw = AsiaSweepDir(1, rates_total, time, high, low, close);
      if(asw > 0)      { asTxt = "النطاق الآسيوي: سحب القيعان - يدعم الشراء (+2)"; asC = InpColBuy;  }
      else if(asw < 0) { asTxt = "النطاق الآسيوي: سحب القمم - يدعم البيع (+2)";    asC = InpColSell; }
      else             { asTxt = "النطاق الآسيوي: لا سحب مؤكد حالياً";              asC = baseC;      }
     }
   DashLabel(24, y0 + 24 * rh, asTxt, asC, fs, cr, rightSide);

   //--- v1.44: حالة الدخول الذهبي
   string gzTxt; color gzC;
   if(!InpGoldenEntry) { gzTxt = "الدخول الذهبي: معطل - أي إشارة مؤكدة";       gzC = clrGray; }
   else                { gzTxt = "الدخول الذهبي: مفعّل - إشارة داخل فيبو 0.5-0.618 فقط"; gzC = clrGoldenrod; }
   DashLabel(25, y0 + 25 * rh, gzTxt, gzC, fs, cr, rightSide);

   //--- v1.44: حالة منع الانعكاس السريع (الوقت المتبقي)
   string rwTxt; color rwC;
   if(InpRevWaitMin <= 0) { rwTxt = "منع الانعكاس: معطل"; rwC = clrGray; }
   else
     {
      datetime ltT = (gLastSigT >= gAliLastSigT) ? gLastSigT : gAliLastSigT;
      int      ltD = (gLastSigT >= gAliLastSigT) ? gLastSigDir : gAliLastSigDir;
      long rem = 0;
      if(ltD != 0 && ltT > 0)
        {
         long el   = (long)(TimeCurrent() - ltT);
         long need = (long)InpRevWaitMin * 60;
         if(el >= 0 && el < need) rem = need - el;
        }
      if(rem > 0)
        { rwTxt = "منع الانعكاس: انتظر " + IntegerToString((int)((rem + 59) / 60)) + " دقيقة قبل الإشارة المعاكسة"; rwC = clrOrange; }
      else
        { rwTxt = "منع الانعكاس: مفعّل - بعد " + IntegerToString(InpRevWaitMin) + " دقيقة من آخر إشارة"; rwC = C'0,200,110'; }
     }
   DashLabel(26, y0 + 26 * rh, rwTxt, rwC, fs, cr, rightSide);
  }

//+------------------------------------------------------------------+
//| ألوان الثيم                                                      |
//+------------------------------------------------------------------+
void ThemeColors(color &bgC, color &brdC, color &baseC, color &dimC)
  {
   if(InpTheme == GSP_THEME_NAVY)
     {
      bgC   = C'8,24,52';    brdC = C'80,120,190';
      baseC = C'205,220,245'; dimC = C'110,130,165';
     }
   else if(InpTheme == GSP_THEME_GLASS)
     {
      bgC   = C'0,0,0';      brdC = C'120,120,120';
      baseC = C'235,235,235'; dimC = C'130,130,130';
     }
   else
     {
      bgC   = C'12,16,24';   brdC = C'70,90,120';
      baseC = C'190,200,215'; dimC = C'90,100,115';
     }
  }

//+------------------------------------------------------------------+
//| أدوات العد التنازلي للجلسات                                      |
//+------------------------------------------------------------------+
//--- v1.43: ثوانٍ حتى افتتاح الساعة h مع تخطي عطلة نهاية الأسبوع (السبت/الأحد)
int SecsToHour(const int h, const MqlDateTime &dt)
  {
   datetime now = TimeCurrent();
   MqlDateTime tgt = dt;
   tgt.hour = h; tgt.min = 0; tgt.sec = 0;
   datetime t = StructToTime(tgt);
   if(t <= now) t += 86400;
   for(int k = 0; k < 3; k++)
     {
      MqlDateTime d2;
      TimeToStruct(t, d2);
      if(d2.day_of_week == 6)      t += 2 * 86400;   // السبت ← الاثنين
      else if(d2.day_of_week == 0) t += 86400;       // الأحد ← الاثنين
      else break;
     }
   return((int)(t - now));
  }

string FmtHMS(const int secs)
  {
   int s = secs % 60, m = (secs / 60) % 60, h = secs / 3600;
   return(StringFormat("%02d:%02d:%02d", h, m, s));
  }

string SessionCountdownText(const int sess)
  {
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   if(sess == 3) return("ذروة الآن - لندن + نيويورك");
   if(sess == 1) return("افتتاح نيويورك بعد " + FmtHMS(SecsToHour(InpNYStart, dt)));
   if(sess == 2) return("إغلاق نيويورك بعد " + FmtHMS(SecsToHour(InpNYEnd, dt)));
   return("افتتاح لندن بعد " + FmtHMS(SecsToHour(InpLondonStart, dt)));
  }

//+------------------------------------------------------------------+
//| نطاق التداول الحالي: آخر قمة وقاع سوينج مؤكدين                   |
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

   dr.hi = high[hiP];  dr.lo = low[loP];   // v1.44: إصلاح خطأ تركيبي كان يمنع الترجمة
   dr.hiT = time[hiP]; dr.loT = time[loP];
   if(dr.hi <= dr.lo) return;
   dr.dir   = (dr.hiT > dr.loT) ? 1 : -1;
   dr.eq    = 0.5 * (dr.hi + dr.lo);
   dr.valid = true;
  }

//+------------------------------------------------------------------+
//| فلتر الأخبار الحمراء (تقويم MT5 الاقتصادي - عملات USD)           |
//+------------------------------------------------------------------+
void NewsScan()
  {
   gNewsTxt = "";
   gNewsBlockTo = 0;

   datetime now  = TimeCurrent();
   datetime from = now - (InpNewsMin + 5) * 60;
   datetime to   = now + (InpNewsMin + 60) * 60;

   MqlCalendarValue vals[];
   if(!CalendarValueHistory(vals, from, to, NULL, "USD")) return;
   int n = ArraySize(vals);

   for(int k = 0; k < n; k++)
     {
      MqlCalendarEvent ev;
      if(!CalendarEventById(vals[k].event_id, ev)) continue;
      if(ev.importance != CALENDAR_IMPORTANCE_HIGH) continue;
      datetime t = vals[k].time;
      if(now >= t - InpNewsMin * 60 && now <= t + InpNewsMin * 60)
        {
         gNewsTxt     = ev.name;
         gNewsBlockTo = t + InpNewsMin * 60;
         return;
        }
     }
  }

bool NewsBlocked(string &info)
  {
   static datetime lastScan = 0;
   datetime now = TimeCurrent();
   if(lastScan == 0 || now - lastScan >= 60)
     {
      lastScan = now;
      NewsScan();
     }
   info = gNewsTxt;
   return(gNewsBlockTo > 0 && now <= gNewsBlockTo);
  }

//+------------------------------------------------------------------+
//| v1.43: تحميل كاش الأخبار الحمراء (تاريخي + قادم) مرة كل ساعة     |
//| يتيح تطبيق فلتر الأخبار على الإشارات التاريخية = إحصائيات اللوحة |
//| مطابقة للسلوك اللحظي. في Strategy Tester التقويم غير متاح =      |
//| الكاش فارغ = لا إيقاف (سلوك آمن)                                |
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

//--- v1.43: هل اللحظة t داخل نطاق حظر خبر أحمر؟ (لكل الشموع: تاريخية ولحظية)
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
//| v1.43: تنبيه موحد للإشارات المؤكدة (مرة واحدة لكل شمعة)          |
//| يُستدعى فقط عند معالجة الشمعة المغلقة الأخيرة (i==1) فلا إزعاج   |
//| أثناء تحميل التاريخ، وحماية barTime تمنع التكرار في كل الحالات  |
//+------------------------------------------------------------------+
void DoAlert(const bool isAli, const int dir, const double price,
             const double sl, const double tp1, const double tp2, const double tp3,
             const datetime barTime)   // v1.44: + هدف ثالث
  {
   if(isAli)
     {
      if(!InpAlertAli) return;
      if(barTime == gLastAlertAli) return;
      gLastAlertAli = barTime;
     }
   else
     {
      if(barTime == gLastAlertMain) return;
      gLastAlertMain = barTime;
     }

   string msg = StringFormat("%s %s %s %s: %s | SL %s | TP1 %s | TP2 %s | TP3 %s",
                             (isAli ? "علي ماستر" : "Ali Trader"),
                             _Symbol, TFToStr(_Period),
                             (dir > 0 ? "شراء" : "بيع"),
                             DoubleToString(price, _Digits),
                             DoubleToString(sl, _Digits),
                             DoubleToString(tp1, _Digits),
                             DoubleToString(tp2, _Digits),
                             DoubleToString(tp3, _Digits));
   if(InpAlertPopup) Alert(msg);
   if(InpAlertSound) PlaySound("alert.wav");
   if(InpAlertPush)  SendNotification(msg);
   Print(ALI_TITLE, " ALERT: ", msg);
  }

//+------------------------------------------------------------------+
//| v1.43: قاعدة الشمعة الملتبسة (لمست SL وTP1 في نفس الشمعة)        |
//+------------------------------------------------------------------+
bool AmbigLoss(const double op, const double sl, const double tp)
  {
   if(InpAmbigAsLoss) return(true);                 // القاعدة المحافظة الافتراضية
   return(MathAbs(op - sl) <= MathAbs(op - tp));    // الأقرب للافتتاح يحدد النتيجة
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
   //--- v1.41 إصلاح انهيار حرج (سبب "أسهم فقط"): الحد القديم need - len - 2
   //--- كان يصل إلى r[p + k] بفهرس need / need+1 خارج حدود المصفوفة = array
   //--- out of range = توقف المؤشر نهائياً (الأسهم تتجمد وكل الكائنات تختفي)
   //--- الحد الآمن: j <= need - 2*len - 1 يجعل أقصى وصول p + len = need - 1
   for(int j = need - 2 * len - 1; j >= 1; j--)
     {
      int p = j + len;
      if(p + len > need - 1 || p - len < 0) continue;   // v1.41: حارس مزدوج
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

//+------------------------------------------------------------------+
//| رسم مناطق MTF (حدود متقطعة + تسمية بأسم الفريم الأعلى)           |
//+------------------------------------------------------------------+
void DrawMTFZones(const datetime &time[])
  {
   ObjectsDeleteAll(0, PREFIX + "M");
   int drawn = 0;
   for(int z = mzCount - 1; z >= 0 && drawn < InpMTFMax; z--)
     {
      if(mzMitA[z]) continue;
      long ageBars = (long)((time[0] - mzBorn[z]) / gSecBar);
      if(ageBars > (long)InpOBValidBars * 2) continue;   // v1.42: مناطق MTF القديمة العملاقة لا ترسم

      int kf = (mzKindA[z] == 0) ? 0 : 2;
      int df = (mzDirA[z] > 0) ? 0 : 1;
      color c, tc;
      if(kf == 0)
        { c = (df == 0) ? C'0,52,26' : C'68,16,16';   tc = (df == 0) ? C'60,255,150' : C'255,110,140'; }  // v1.42: نفس ألوان مناطق الشارت
      else
        { c = (df == 0) ? C'0,40,60' : C'58,34,0';    tc = (df == 0) ? C'110,210,255': C'255,200,110'; }  // v1.42: توحيد اللوحة اللونية

      string nm = PREFIX + "M" + IntegerToString(kf) +
                  IntegerToString(df) + "_" + IntegerToString((long)mzBorn[z]);
      datetime t2 = (datetime)((long)time[0] + (long)5 * gSecBar);

      ObjectCreate(0, nm, OBJ_RECTANGLE, 0, mzBorn[z], mzTop[z], t2, mzBot[z]);
      ObjectSetInteger(0, nm, OBJPROP_COLOR, c);
      ObjectSetInteger(0, nm, OBJPROP_STYLE, STYLE_DASH);
      ObjectSetInteger(0, nm, OBJPROP_FILL, true);
      ObjectSetInteger(0, nm, OBJPROP_BACK, true);
      ObjectSetInteger(0, nm, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, nm, OBJPROP_HIDDEN, true);

      if(InpZoneLabels)
        {
         string tn = nm + "L";
         string ztxt = "MTF " + (mzKindA[z] == 0 ? "OB " : "FVG ") +
                       (mzDirA[z] > 0 ? "شراء" : "بيع") + " " + TFToStr(gTF) + "  " +
                       DoubleToString(mzBot[z], _Digits) + " - " +
                       DoubleToString(mzTop[z], _Digits);
         ObjectCreate(0, tn, OBJ_TEXT, 0, mzBorn[z], mzTop[z]);
         ObjectSetString(0, tn, OBJPROP_TEXT, ztxt);
         ObjectSetString(0, tn, OBJPROP_FONT, "Arial");
         ObjectSetInteger(0, tn, OBJPROP_FONTSIZE, 8);
         ObjectSetInteger(0, tn, OBJPROP_COLOR, tc);
         ObjectSetInteger(0, tn, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
         ObjectSetInteger(0, tn, OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, tn, OBJPROP_HIDDEN, true);
        }
      drawn++;
     }
  }

//+------------------------------------------------------------------+
//| خطوط السيولة: قمم/قيعان سوينج تُحذف عند الانسياب                 |
//+------------------------------------------------------------------+
void LqAdd(const datetime t, const double p, const int dir)
  {
   for(int z = 0; z < lqCount; z++)
      if(lqDirA[z] == dir && !lqSweptA[z] && MathAbs(lqP[z] - p) < 5.0 * gNP)
         return;
   if(lqCount >= MAXLQ)
     {
      ArrayRemove(lqT, 0, 1);    ArrayRemove(lqP, 0, 1);
      ArrayRemove(lqDirA, 0, 1); ArrayRemove(lqSweptA, 0, 1);
      lqCount--;
     }
   int n = lqCount;
   ArrayResize(lqT, n + 1);    ArrayResize(lqP, n + 1);
   ArrayResize(lqDirA, n + 1); ArrayResize(lqSweptA, n + 1);
   lqT[n] = t;  lqP[n] = p;
   lqDirA[n] = dir;  lqSweptA[n] = false;
   lqCount++;
  }

void LqSweep(const int i, const double &high[], const double &low[], const double &close[])
  {
   for(int z = 0; z < lqCount; z++)
     {
      if(lqSweptA[z]) continue;
      if(lqDirA[z] > 0)
        {
         if((high[i] > lqP[z] && close[i] < lqP[z]) || close[i] > lqP[z])
            lqSweptA[z] = true;
        }
      else
        {
         if((low[i] < lqP[z] && close[i] > lqP[z]) || close[i] < lqP[z])
            lqSweptA[z] = true;
        }
     }
  }

void DrawLiq(const datetime &time[], const int total)
  {
   ObjectsDeleteAll(0, PREFIX + "Q");
   int drawn = 0;
   datetime t2 = (datetime)((long)time[0] + (long)3 * gSecBar);
   for(int z = lqCount - 1; z >= 0 && drawn < InpLiqMax; z--)
     {
      long ageBars = (long)((time[0] - lqT[z]) / gSecBar);
      if(ageBars > (long)3 * InpOBValidBars) continue;
      if(lqSweptA[z] && ageBars > 40) continue;

      color c = lqSweptA[z] ? clrDimGray :
                (lqDirA[z] > 0 ? C'168,85,247' : C'0,190,120');
      string nm = PREFIX + "Q" + IntegerToString(lqDirA[z] > 0 ? 1 : 0) +
                  "_" + IntegerToString((long)lqT[z]);

      ObjectCreate(0, nm, OBJ_TREND, 0, lqT[z], lqP[z], t2, lqP[z]);
      ObjectSetInteger(0, nm, OBJPROP_COLOR, c);
      ObjectSetInteger(0, nm, OBJPROP_STYLE, STYLE_DOT);
      ObjectSetInteger(0, nm, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, nm, OBJPROP_RAY_RIGHT, false);
      ObjectSetInteger(0, nm, OBJPROP_RAY_LEFT, false);
      ObjectSetInteger(0, nm, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, nm, OBJPROP_HIDDEN, true);

      string tn = nm + "X";
      string tx = lqSweptA[z] ? "سيولة مصطادة" : "سيولة";
      ObjectCreate(0, tn, OBJ_TEXT, 0, t2, lqP[z]);
      ObjectSetString(0, tn, OBJPROP_TEXT, tx);
      ObjectSetInteger(0, tn, OBJPROP_COLOR, c);
      ObjectSetInteger(0, tn, OBJPROP_FONTSIZE, 8);
      ObjectSetString(0, tn, OBJPROP_FONT, "Arial");
      ObjectSetInteger(0, tn, OBJPROP_ANCHOR, ANCHOR_LEFT);
      ObjectSetInteger(0, tn, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, tn, OBJPROP_HIDDEN, true);
      drawn++;
     }
  }

//+------------------------------------------------------------------+
//| فيبوناتشي تلقائي على نطاق التداول + المنطقة الذهبية 0.5-0.618    |
//+------------------------------------------------------------------+
void DrawFibo(const datetime &time[], const double &high[], const double &low[],
              const int total)
  {
   ObjectsDeleteAll(0, PREFIX + "F");

   DealRange dr;
   GetDealingRange(0, total, time, high, low, dr);
   if(!dr.valid) return;

   double rng = dr.hi - dr.lo;
   if(rng <= 0) return;

   string   nm = PREFIX + "FB";
   datetime t1 = (dr.dir > 0) ? dr.loT : dr.hiT;
   datetime t2 = (dr.dir > 0) ? dr.hiT : dr.loT;
   double   p1 = (dr.dir > 0) ? dr.lo  : dr.hi;
   double   p2 = (dr.dir > 0) ? dr.hi  : dr.lo;

   ObjectCreate(0, nm, OBJ_FIBO, 0, t1, p1, t2, p2);
   ObjectSetInteger(0, nm, OBJPROP_COLOR, clrGoldenrod);
   ObjectSetInteger(0, nm, OBJPROP_STYLE, STYLE_DOT);
   ObjectSetInteger(0, nm, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, nm, OBJPROP_RAY_RIGHT, false);
   ObjectSetInteger(0, nm, OBJPROP_RAY_LEFT, false);
   ObjectSetInteger(0, nm, OBJPROP_LEVELS, 5);
   double lv[5] = {0.0, 0.382, 0.5, 0.618, 1.0};
   string lt[5] = {"0.0", "0.382", "0.5", "0.618", "1.0"};
   for(int k = 0; k < 5; k++)
     {
      ObjectSetDouble(0, nm, OBJPROP_LEVELVALUE, k, lv[k]);
      ObjectSetString(0, nm, OBJPROP_LEVELTEXT, k, lt[k]);
      ObjectSetInteger(0, nm, OBJPROP_LEVELCOLOR, k, clrGoldenrod);
      ObjectSetInteger(0, nm, OBJPROP_LEVELSTYLE, k, STYLE_DOT);
      ObjectSetInteger(0, nm, OBJPROP_LEVELWIDTH, k, 1);
     }
   ObjectSetInteger(0, nm, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, nm, OBJPROP_HIDDEN, true);

   //--- المنطقة الذهبية بين مستويي 0.5 و 0.618
   double zA   = (dr.dir > 0) ? (dr.hi - 0.500 * rng) : (dr.lo + 0.500 * rng);
   double zB   = (dr.dir > 0) ? (dr.hi - 0.618 * rng) : (dr.lo + 0.618 * rng);
   double fzTop = MathMax(zA, zB), fzBot = MathMin(zA, zB);
   datetime zo = (dr.hiT < dr.loT) ? dr.hiT : dr.loT;   // أقدم نقطة
   datetime tE = (datetime)((long)time[0] + (long)5 * gSecBar);
   string fz = PREFIX + "FZ";
   ObjectCreate(0, fz, OBJ_RECTANGLE, 0, zo, fzTop, tE, fzBot);
   ObjectSetInteger(0, fz, OBJPROP_COLOR, C'88,64,14');   // v1.42: أهدأ
   ObjectSetInteger(0, fz, OBJPROP_FILL, true);
   ObjectSetInteger(0, fz, OBJPROP_BACK, true);
   ObjectSetInteger(0, fz, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, fz, OBJPROP_HIDDEN, true);
  }

//+------------------------------------------------------------------+
//| تقرير الأداء R: أفضل جلسة وأفضل ساعة                             |
//+------------------------------------------------------------------+
string BestSessionTxt()
  {
   string names[4] = {"خارج الجلسات", "لندن", "نيويورك", "لندن+نيويورك"};
   int best = -1;
   double bestV = -1.0;
   for(int k = 0; k < 4; k++)
     {
      int n = gSesW[k] + gSesL[k];
      if(n < 3) continue;
      double v = (double)gSesW[k] / (double)n;
      if(v > bestV) { bestV = v; best = k; }
     }
   if(best < 0) return("-");
   return(names[best] + " " + IntegerToString(gSesW[best]) + "/" +
          IntegerToString(gSesW[best] + gSesL[best]));
  }

string BestHourTxt()
  {
   int best = -1;
   double bestV = -1.0;
   for(int k = 0; k < 24; k++)
     {
      int n = gHrW[k] + gHrL[k];
      if(n < 2) continue;
      double v = (double)gHrW[k] / (double)n;
      if(v > bestV) { bestV = v; best = k; }
     }
   if(best < 0) return("-");
   return(StringFormat("%02d:00 (%d/%d)", best, gHrW[best], gHrW[best] + gHrL[best]));
  }
//+------------------------------------------------------------------+
