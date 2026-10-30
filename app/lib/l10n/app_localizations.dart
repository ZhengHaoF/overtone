import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh'),
  ];

  /// No description provided for @fanYin.
  ///
  /// In zh, this message translates to:
  /// **'泛音'**
  String get fanYin;

  /// No description provided for @i3SpiWeiFanHuiBuvidXiLieZiDuan.
  ///
  /// In zh, this message translates to:
  /// **'I3 spi: 未返回 buvid 系列字段'**
  String get i3SpiWeiFanHuiBuvidXiLieZiDuan;

  /// No description provided for @i1NavXiangYingBuShiJsonDuiXiang.
  ///
  /// In zh, this message translates to:
  /// **'I1 nav: 响应不是 JSON 对象'**
  String get i1NavXiangYingBuShiJsonDuiXiang;

  /// No description provided for @i1NavQueShaoWbiImg.
  ///
  /// In zh, this message translates to:
  /// **'I1 nav: 缺少 wbi_img'**
  String get i1NavQueShaoWbiImg;

  /// No description provided for @i1NavWbiImgQueShaoImgUrlSubUrl.
  ///
  /// In zh, this message translates to:
  /// **'I1 nav: wbi_img 缺少 img_url/sub_url'**
  String get i1NavWbiImgQueShaoImgUrlSubUrl;

  /// No description provided for @bZhanXuYaoDengLu.
  ///
  /// In zh, this message translates to:
  /// **'B 站：需要登录'**
  String get bZhanXuYaoDengLu;

  /// No description provided for @bZhanXuYaoDengLuYanZhengMa.
  ///
  /// In zh, this message translates to:
  /// **'B 站：需要登录（验证码）'**
  String get bZhanXuYaoDengLuYanZhengMa;

  /// No description provided for @g1XiangYingQueShaoData.
  ///
  /// In zh, this message translates to:
  /// **'G1: 响应缺少 data'**
  String get g1XiangYingQueShaoData;

  /// No description provided for @g1XiangYingQueShaoQrcodeKeyUrl.
  ///
  /// In zh, this message translates to:
  /// **'G1: 响应缺少 qrcode_key/url'**
  String get g1XiangYingQueShaoQrcodeKeyUrl;

  /// No description provided for @anQuanCeLveZuZhiXiangBuAnQuanHuoFeiKuGouMuBiaoFa.
  ///
  /// In zh, this message translates to:
  /// **'安全策略阻止向不安全或非酷狗目标发送账号信息'**
  String get anQuanCeLveZuZhiXiangBuAnQuanHuoFeiKuGouMuBiaoFa;

  /// No description provided for @yunPanFanHuiLiaoBuAnQuanDeShangChuanMuBiaoYiTing.
  ///
  /// In zh, this message translates to:
  /// **'云盘返回了不安全的上传目标，已停止上传'**
  String get yunPanFanHuiLiaoBuAnQuanDeShangChuanMuBiaoYiTing;

  /// No description provided for @wangLuoWangGuanLanJieUrlGuoLvWuFaFangWenKuGouJie.
  ///
  /// In zh, this message translates to:
  /// **'网络网关拦截（URL过滤），无法访问酷狗接口'**
  String get wangLuoWangGuanLanJieUrlGuoLvWuFaFangWenKuGouJie;

  /// No description provided for @wangLuoQingQiuShiBai.
  ///
  /// In zh, this message translates to:
  /// **'网络请求失败'**
  String get wangLuoQingQiuShiBai;

  /// No description provided for @weiZhiGeQu.
  ///
  /// In zh, this message translates to:
  /// **'未知歌曲'**
  String get weiZhiGeQu;

  /// No description provided for @weiZhiGeShou.
  ///
  /// In zh, this message translates to:
  /// **'未知歌手'**
  String get weiZhiGeShou;

  /// No description provided for @geDan.
  ///
  /// In zh, this message translates to:
  /// **'歌单'**
  String get geDan;

  /// No description provided for @bangDan.
  ///
  /// In zh, this message translates to:
  /// **'榜单'**
  String get bangDan;

  /// No description provided for @kuGouGuanFang.
  ///
  /// In zh, this message translates to:
  /// **'酷狗官方'**
  String get kuGouGuanFang;

  /// No description provided for @zhuanJi.
  ///
  /// In zh, this message translates to:
  /// **'专辑'**
  String get zhuanJi;

  /// No description provided for @yunPanDaoRuShiBai.
  ///
  /// In zh, this message translates to:
  /// **'云盘导入失败'**
  String get yunPanDaoRuShiBai;

  /// No description provided for @saoMaHuiHuaYiShiXiao.
  ///
  /// In zh, this message translates to:
  /// **'扫码会话已失效'**
  String get saoMaHuiHuaYiShiXiao;

  /// No description provided for @quanBu.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get quanBu;

  /// No description provided for @souSuo.
  ///
  /// In zh, this message translates to:
  /// **'搜索'**
  String get souSuo;

  /// No description provided for @geDanSouSuo.
  ///
  /// In zh, this message translates to:
  /// **'歌单搜索'**
  String get geDanSouSuo;

  /// No description provided for @zhuanJiSouSuo.
  ///
  /// In zh, this message translates to:
  /// **'专辑搜索'**
  String get zhuanJiSouSuo;

  /// No description provided for @geShouSouSuo.
  ///
  /// In zh, this message translates to:
  /// **'歌手搜索'**
  String get geShouSouSuo;

  /// No description provided for @geDanXiangQing.
  ///
  /// In zh, this message translates to:
  /// **'歌单详情'**
  String get geDanXiangQing;

  /// No description provided for @zhuanJiXiangQing.
  ///
  /// In zh, this message translates to:
  /// **'专辑详情'**
  String get zhuanJiXiangQing;

  /// No description provided for @geShouXiangQing.
  ///
  /// In zh, this message translates to:
  /// **'歌手详情'**
  String get geShouXiangQing;

  /// No description provided for @geShouGeQu.
  ///
  /// In zh, this message translates to:
  /// **'歌手歌曲'**
  String get geShouGeQu;

  /// No description provided for @meiRiTuiJian.
  ///
  /// In zh, this message translates to:
  /// **'每日推荐'**
  String get meiRiTuiJian;

  /// No description provided for @siRenFm.
  ///
  /// In zh, this message translates to:
  /// **'私人 FM'**
  String get siRenFm;

  /// No description provided for @xinGeSuDi.
  ///
  /// In zh, this message translates to:
  /// **'新歌速递'**
  String get xinGeSuDi;

  /// No description provided for @fenLeiGeDan.
  ///
  /// In zh, this message translates to:
  /// **'分类歌单'**
  String get fenLeiGeDan;

  /// No description provided for @xinDieShangJia.
  ///
  /// In zh, this message translates to:
  /// **'新碟上架'**
  String get xinDieShangJia;

  /// No description provided for @geShouLieBiao.
  ///
  /// In zh, this message translates to:
  /// **'歌手列表'**
  String get geShouLieBiao;

  /// No description provided for @geDanBiaoQian.
  ///
  /// In zh, this message translates to:
  /// **'歌单标签'**
  String get geDanBiaoQian;

  /// No description provided for @tuiJian.
  ///
  /// In zh, this message translates to:
  /// **'推荐'**
  String get tuiJian;

  /// No description provided for @woXiHuan.
  ///
  /// In zh, this message translates to:
  /// **'我喜欢'**
  String get woXiHuan;

  /// No description provided for @geQuXiangQing.
  ///
  /// In zh, this message translates to:
  /// **'歌曲详情'**
  String get geQuXiangQing;

  /// No description provided for @yongHuGeDan.
  ///
  /// In zh, this message translates to:
  /// **'用户歌单'**
  String get yongHuGeDan;

  /// No description provided for @wangYiYunHuiHuaShiXiaoCode301.
  ///
  /// In zh, this message translates to:
  /// **'网易云会话失效 code=301'**
  String get wangYiYunHuiHuaShiXiaoCode301;

  /// No description provided for @boFangDiZhiWeiKong.
  ///
  /// In zh, this message translates to:
  /// **'播放地址为空'**
  String get boFangDiZhiWeiKong;

  /// No description provided for @mvXiangQing.
  ///
  /// In zh, this message translates to:
  /// **'MV 详情'**
  String get mvXiangQing;

  /// No description provided for @mvXiangQingWeiKong.
  ///
  /// In zh, this message translates to:
  /// **'MV 详情为空'**
  String get mvXiangQingWeiKong;

  /// No description provided for @mvBoFangDiZhiWeiKong.
  ///
  /// In zh, this message translates to:
  /// **'MV 播放地址为空'**
  String get mvBoFangDiZhiWeiKong;

  /// No description provided for @yongHuXiangQingCodeYiChang.
  ///
  /// In zh, this message translates to:
  /// **'用户详情 code 异常'**
  String get yongHuXiangQingCodeYiChang;

  /// No description provided for @vipXinXiCodeYiChang.
  ///
  /// In zh, this message translates to:
  /// **'VIP 信息 code 异常'**
  String get vipXinXiCodeYiChang;

  /// No description provided for @yongHuDengJiCodeYiChang.
  ///
  /// In zh, this message translates to:
  /// **'用户等级 code 异常'**
  String get yongHuDengJiCodeYiChang;

  /// No description provided for @yunPan.
  ///
  /// In zh, this message translates to:
  /// **'云盘'**
  String get yunPan;

  /// No description provided for @yunPanWenJianMeiYouQuLiuDiZhi.
  ///
  /// In zh, this message translates to:
  /// **'云盘文件没有取流地址'**
  String get yunPanWenJianMeiYouQuLiuDiZhi;

  /// No description provided for @yunPanXiangQing.
  ///
  /// In zh, this message translates to:
  /// **'云盘详情'**
  String get yunPanXiangQing;

  /// No description provided for @wangYiYunXiangYingBuShiJson.
  ///
  /// In zh, this message translates to:
  /// **'网易云响应不是 JSON'**
  String get wangYiYunXiangYingBuShiJson;

  /// No description provided for @zuiRe.
  ///
  /// In zh, this message translates to:
  /// **'最热'**
  String get zuiRe;

  /// No description provided for @zuiXin.
  ///
  /// In zh, this message translates to:
  /// **'最新'**
  String get zuiXin;

  /// No description provided for @pingLun.
  ///
  /// In zh, this message translates to:
  /// **'评论'**
  String get pingLun;

  /// No description provided for @reSou.
  ///
  /// In zh, this message translates to:
  /// **'热搜'**
  String get reSou;

  /// No description provided for @louCengPingLun.
  ///
  /// In zh, this message translates to:
  /// **'楼层评论'**
  String get louCengPingLun;

  /// No description provided for @yinYueRen.
  ///
  /// In zh, this message translates to:
  /// **'音乐人'**
  String get yinYueRen;

  /// No description provided for @zuoZheHuiFu.
  ///
  /// In zh, this message translates to:
  /// **'作者回复'**
  String get zuoZheHuiFu;

  /// No description provided for @wangLuoYiChangQingShaoHouChongShi.
  ///
  /// In zh, this message translates to:
  /// **'网络异常，请稍后重试'**
  String get wangLuoYiChangQingShaoHouChongShi;

  /// No description provided for @yuFuWuQiJianLiAnQuanLianJieShiBaiQingJianChaWang.
  ///
  /// In zh, this message translates to:
  /// **'与服务器建立安全连接失败，请检查网络或代理设置后重试'**
  String get yuFuWuQiJianLiAnQuanLianJieShiBaiQingJianChaWang;

  /// No description provided for @wangLuoLianJieShiBaiQingJianChaWangLuoHouChongSh.
  ///
  /// In zh, this message translates to:
  /// **'网络连接失败，请检查网络后重试'**
  String get wangLuoLianJieShiBaiQingJianChaWangLuoHouChongSh;

  /// No description provided for @wangLuoQingQiuChaoShiQingJianChaWangLuoHouChongS.
  ///
  /// In zh, this message translates to:
  /// **'网络请求超时，请检查网络后重试'**
  String get wangLuoQingQiuChaoShiQingJianChaWangLuoHouChongS;

  /// No description provided for @renZhengJieKouNeiRongYiShengLve.
  ///
  /// In zh, this message translates to:
  /// **'[认证接口内容已省略]'**
  String get renZhengJieKouNeiRongYiShengLve;

  /// No description provided for @wuFaAnQuanJieXiDeUrlYiShengLve.
  ///
  /// In zh, this message translates to:
  /// **'[无法安全解析的 URL 已省略]'**
  String get wuFaAnQuanJieXiDeUrlYiShengLve;

  /// No description provided for @qianTaoNeiRongYiShengLve.
  ///
  /// In zh, this message translates to:
  /// **'[嵌套内容已省略]'**
  String get qianTaoNeiRongYiShengLve;

  /// No description provided for @wuFaAnQuanJieXiDeBiaoDanYiShengLve.
  ///
  /// In zh, this message translates to:
  /// **'[无法安全解析的表单已省略]'**
  String get wuFaAnQuanJieXiDeBiaoDanYiShengLve;

  /// No description provided for @pingJuTouYiShengLve.
  ///
  /// In zh, this message translates to:
  /// **'[凭据头已省略]'**
  String get pingJuTouYiShengLve;

  /// No description provided for @qiDongFuWuXiangYingChaoShiRengZaiDengDaiDangQian.
  ///
  /// In zh, this message translates to:
  /// **'启动服务响应超时。仍在等待当前操作结束，避免重复初始化。'**
  String get qiDongFuWuXiangYingChaoShiRengZaiDengDaiDangQian;

  /// No description provided for @zhengZaiQiDongFanYin.
  ///
  /// In zh, this message translates to:
  /// **'正在启动泛音…'**
  String get zhengZaiQiDongFanYin;

  /// No description provided for @xiangXiJiLuJianYingYongMuLuCrashLog.
  ///
  /// In zh, this message translates to:
  /// **'详细记录见应用目录 crash.log。'**
  String get xiangXiJiLuJianYingYongMuLuCrashLog;

  /// No description provided for @chongShi.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get chongShi;

  /// No description provided for @guanBiTiShi.
  ///
  /// In zh, this message translates to:
  /// **'关闭提示'**
  String get guanBiTiShi;

  /// No description provided for @biaoZhun.
  ///
  /// In zh, this message translates to:
  /// **'标准'**
  String get biaoZhun;

  /// No description provided for @gaoPin.
  ///
  /// In zh, this message translates to:
  /// **'高品'**
  String get gaoPin;

  /// No description provided for @wuSun.
  ///
  /// In zh, this message translates to:
  /// **'无损'**
  String get wuSun;

  /// No description provided for @reMen.
  ///
  /// In zh, this message translates to:
  /// **'热门'**
  String get reMen;

  /// No description provided for @hongXin.
  ///
  /// In zh, this message translates to:
  /// **'红心'**
  String get hongXin;

  /// No description provided for @xiaoZhong.
  ///
  /// In zh, this message translates to:
  /// **'小众'**
  String get xiaoZhong;

  /// No description provided for @suLan.
  ///
  /// In zh, this message translates to:
  /// **'速览'**
  String get suLan;

  /// No description provided for @hongXinDianTai.
  ///
  /// In zh, this message translates to:
  /// **'红心电台'**
  String get hongXinDianTai;

  /// No description provided for @xiaoZhongDianTai.
  ///
  /// In zh, this message translates to:
  /// **'小众电台'**
  String get xiaoZhongDianTai;

  /// No description provided for @suLanDianTai.
  ///
  /// In zh, this message translates to:
  /// **'速览电台'**
  String get suLanDianTai;

  /// No description provided for @caiNiXiHuan.
  ///
  /// In zh, this message translates to:
  /// **'猜你喜欢'**
  String get caiNiXiHuan;

  /// No description provided for @xiaoZhongJingXuan.
  ///
  /// In zh, this message translates to:
  /// **'小众精选'**
  String get xiaoZhongJingXuan;

  /// No description provided for @duanQuSuLan.
  ///
  /// In zh, this message translates to:
  /// **'短曲速览'**
  String get duanQuSuLan;

  /// No description provided for @genJuKouWeiTuiJianXiangSiGeQu.
  ///
  /// In zh, this message translates to:
  /// **'根据口味推荐相似歌曲'**
  String get genJuKouWeiTuiJianXiangSiGeQu;

  /// No description provided for @genJuFengGeTuiJianXiangSiGeQu.
  ///
  /// In zh, this message translates to:
  /// **'根据风格推荐相似歌曲'**
  String get genJuFengGeTuiJianXiangSiGeQu;

  /// No description provided for @huaYuLiuXing.
  ///
  /// In zh, this message translates to:
  /// **'华语流行'**
  String get huaYuLiuXing;

  /// No description provided for @jingDian.
  ///
  /// In zh, this message translates to:
  /// **'经典'**
  String get jingDian;

  /// No description provided for @minYao.
  ///
  /// In zh, this message translates to:
  /// **'民谣'**
  String get minYao;

  /// No description provided for @dianZi.
  ///
  /// In zh, this message translates to:
  /// **'电子'**
  String get dianZi;

  /// No description provided for @qingYinYue.
  ///
  /// In zh, this message translates to:
  /// **'轻音乐'**
  String get qingYinYue;

  /// No description provided for @duLi.
  ///
  /// In zh, this message translates to:
  /// **'独立'**
  String get duLi;

  /// No description provided for @lengMen.
  ///
  /// In zh, this message translates to:
  /// **'冷门'**
  String get lengMen;

  /// No description provided for @jueShi.
  ///
  /// In zh, this message translates to:
  /// **'爵士'**
  String get jueShi;

  /// No description provided for @laiZiReMenHuaYuLiuXing.
  ///
  /// In zh, this message translates to:
  /// **'来自「热门 / 华语流行」'**
  String get laiZiReMenHuaYuLiuXing;

  /// No description provided for @laiZiMinYaoDianZi.
  ///
  /// In zh, this message translates to:
  /// **'来自「民谣 / 电子」'**
  String get laiZiMinYaoDianZi;

  /// No description provided for @laiZiDuLiJueShi.
  ///
  /// In zh, this message translates to:
  /// **'来自「独立 / 爵士」'**
  String get laiZiDuLiJueShi;

  /// No description provided for @diXia.
  ///
  /// In zh, this message translates to:
  /// **'地下'**
  String get diXia;

  /// No description provided for @baoZang.
  ///
  /// In zh, this message translates to:
  /// **'宝藏'**
  String get baoZang;

  /// No description provided for @geQu.
  ///
  /// In zh, this message translates to:
  /// **'歌曲'**
  String get geQu;

  /// No description provided for @geShou.
  ///
  /// In zh, this message translates to:
  /// **'歌手'**
  String get geShou;

  /// No description provided for @woXiHuanDeYinYue.
  ///
  /// In zh, this message translates to:
  /// **'我喜欢的音乐'**
  String get woXiHuanDeYinYue;

  /// No description provided for @xiHuan.
  ///
  /// In zh, this message translates to:
  /// **'喜欢'**
  String get xiHuan;

  /// No description provided for @moRenShouCang.
  ///
  /// In zh, this message translates to:
  /// **'默认收藏'**
  String get moRenShouCang;

  /// No description provided for @paiHangBang.
  ///
  /// In zh, this message translates to:
  /// **'排行榜'**
  String get paiHangBang;

  /// No description provided for @faXian.
  ///
  /// In zh, this message translates to:
  /// **'发现'**
  String get faXian;

  /// No description provided for @yinYueYunPan.
  ///
  /// In zh, this message translates to:
  /// **'音乐云盘'**
  String get yinYueYunPan;

  /// No description provided for @kuGou.
  ///
  /// In zh, this message translates to:
  /// **'酷狗'**
  String get kuGou;

  /// No description provided for @wangYiYun.
  ///
  /// In zh, this message translates to:
  /// **'网易云'**
  String get wangYiYun;

  /// No description provided for @biLiBiLi.
  ///
  /// In zh, this message translates to:
  /// **'哔哩哔哩'**
  String get biLiBiLi;

  /// No description provided for @xuYaoDengLu.
  ///
  /// In zh, this message translates to:
  /// **'需要登录'**
  String get xuYaoDengLu;

  /// No description provided for @meiYouBoFangQuanXian.
  ///
  /// In zh, this message translates to:
  /// **'没有播放权限'**
  String get meiYouBoFangQuanXian;

  /// No description provided for @weiZhaoDao.
  ///
  /// In zh, this message translates to:
  /// **'未找到'**
  String get weiZhaoDao;

  /// No description provided for @qingQiuGuoYuPinFan.
  ///
  /// In zh, this message translates to:
  /// **'请求过于频繁'**
  String get qingQiuGuoYuPinFan;

  /// No description provided for @shangYouXiangYingYiChang.
  ///
  /// In zh, this message translates to:
  /// **'上游响应异常'**
  String get shangYouXiangYingYiChang;

  /// No description provided for @moRen.
  ///
  /// In zh, this message translates to:
  /// **'默认'**
  String get moRen;

  /// No description provided for @biaoZhunShenQianZiShiYingYangShi.
  ///
  /// In zh, this message translates to:
  /// **'标准深浅自适应样式'**
  String get biaoZhunShenQianZiShiYingYangShi;

  /// No description provided for @ruiShiGuoJiPaiBan.
  ///
  /// In zh, this message translates to:
  /// **'瑞士国际排版'**
  String get ruiShiGuoJiPaiBan;

  /// No description provided for @zhiBaiMoHeiWuChenXianPaiBanXuanZhongHouQuanZhanQ.
  ///
  /// In zh, this message translates to:
  /// **'纸白墨黑无衬线排版，选中后全站切换为浅色'**
  String get zhiBaiMoHeiWuChenXianPaiBanXuanZhongHouQuanZhanQ;

  /// No description provided for @evaHong.
  ///
  /// In zh, this message translates to:
  /// **'EVA红'**
  String get evaHong;

  /// No description provided for @evaZhanShuChaoSuanHongHeiZhongDuanMingRiXiangAnS.
  ///
  /// In zh, this message translates to:
  /// **'EVA 战术超算红黑终端，明日香暗色警戒风格'**
  String get evaZhanShuChaoSuanHongHeiZhongDuanMingRiXiangAnS;

  /// No description provided for @evaLan.
  ///
  /// In zh, this message translates to:
  /// **'EVA蓝'**
  String get evaLan;

  /// No description provided for @evaLingHaoJiCiBaiBingLanLingBoLiLiangSeDangAnJie.
  ///
  /// In zh, this message translates to:
  /// **'EVA 零号机瓷白冰蓝，绫波丽亮色档案界面'**
  String get evaLingHaoJiCiBaiBingLanLingBoLiLiangSeDangAnJie;

  /// No description provided for @souSuoGeQuGeShouZhuanJi.
  ///
  /// In zh, this message translates to:
  /// **'搜索歌曲、歌手、专辑'**
  String get souSuoGeQuGeShouZhuanJi;

  /// No description provided for @qingLv.
  ///
  /// In zh, this message translates to:
  /// **'青绿'**
  String get qingLv;

  /// No description provided for @shanHu.
  ///
  /// In zh, this message translates to:
  /// **'珊瑚'**
  String get shanHu;

  /// No description provided for @dianLan.
  ///
  /// In zh, this message translates to:
  /// **'靛蓝'**
  String get dianLan;

  /// No description provided for @ziLuoLan.
  ///
  /// In zh, this message translates to:
  /// **'紫罗兰'**
  String get ziLuoLan;

  /// No description provided for @geMing.
  ///
  /// In zh, this message translates to:
  /// **'歌名'**
  String get geMing;

  /// No description provided for @shiChang.
  ///
  /// In zh, this message translates to:
  /// **'时长'**
  String get shiChang;

  /// No description provided for @weiDengLu.
  ///
  /// In zh, this message translates to:
  /// **'未登录'**
  String get weiDengLu;

  /// No description provided for @qingXianDengLuHouChaKanYunPan.
  ///
  /// In zh, this message translates to:
  /// **'请先登录后查看云盘'**
  String get qingXianDengLuHouChaKanYunPan;

  /// No description provided for @huoQuYunPanLieBiaoShiBai.
  ///
  /// In zh, this message translates to:
  /// **'获取云盘列表失败'**
  String get huoQuYunPanLieBiaoShiBai;

  /// No description provided for @queShaoYunPanWenJianHash.
  ///
  /// In zh, this message translates to:
  /// **'缺少云盘文件 hash'**
  String get queShaoYunPanWenJianHash;

  /// No description provided for @queShaoYunPanWenJianBiaoZhiWuFaBoFang.
  ///
  /// In zh, this message translates to:
  /// **'缺少云盘文件标识，无法播放'**
  String get queShaoYunPanWenJianBiaoZhiWuFaBoFang;

  /// No description provided for @wangLuoWangGuanLanJieUrlGuoLvWuFaFangWenKuGou.
  ///
  /// In zh, this message translates to:
  /// **'网络网关拦截（URL过滤），无法访问酷狗'**
  String get wangLuoWangGuanLanJieUrlGuoLvWuFaFangWenKuGou;

  /// No description provided for @yunPanBoFangDiZhiXiangYingWuFaJieXi.
  ///
  /// In zh, this message translates to:
  /// **'云盘播放地址响应无法解析'**
  String get yunPanBoFangDiZhiXiangYingWuFaJieXi;

  /// No description provided for @huoQuYunPanBoFangDiZhiShiBai.
  ///
  /// In zh, this message translates to:
  /// **'获取云盘播放地址失败'**
  String get huoQuYunPanBoFangDiZhiShiBai;

  /// No description provided for @yunPanWenJianZanWuBoFangDiZhi.
  ///
  /// In zh, this message translates to:
  /// **'云盘文件暂无播放地址'**
  String get yunPanWenJianZanWuBoFangDiZhi;

  /// No description provided for @qingXianDengLuHouCaoZuoYunPan.
  ///
  /// In zh, this message translates to:
  /// **'请先登录后操作云盘'**
  String get qingXianDengLuHouCaoZuoYunPan;

  /// No description provided for @queShaoYunPanWenJianBiaoZhiKvIdWuFaShanChu.
  ///
  /// In zh, this message translates to:
  /// **'缺少云盘文件标识（kv_id），无法删除'**
  String get queShaoYunPanWenJianBiaoZhiKvIdWuFaShanChu;

  /// No description provided for @queShaoYunPanWenJianBiaoZhiWuFaShanChu.
  ///
  /// In zh, this message translates to:
  /// **'缺少云盘文件标识，无法删除'**
  String get queShaoYunPanWenJianBiaoZhiWuFaShanChu;

  /// No description provided for @shanChuYunPanGeQuShiBai.
  ///
  /// In zh, this message translates to:
  /// **'删除云盘歌曲失败'**
  String get shanChuYunPanGeQuShiBai;

  /// No description provided for @qingXianDengLuHouShangChuanYunPan.
  ///
  /// In zh, this message translates to:
  /// **'请先登录后上传云盘'**
  String get qingXianDengLuHouShangChuanYunPan;

  /// No description provided for @wenJianWeiKong.
  ///
  /// In zh, this message translates to:
  /// **'文件为空'**
  String get wenJianWeiKong;

  /// No description provided for @wenJianWeiKongWuFaShangChuan.
  ///
  /// In zh, this message translates to:
  /// **'文件为空，无法上传'**
  String get wenJianWeiKongWuFaShangChuan;

  /// No description provided for @chuShiHuaShangChuanShiBai.
  ///
  /// In zh, this message translates to:
  /// **'初始化上传失败'**
  String get chuShiHuaShangChuanShiBai;

  /// No description provided for @huoQuShangChuanShouQuanShiBai.
  ///
  /// In zh, this message translates to:
  /// **'获取上传授权失败'**
  String get huoQuShangChuanShouQuanShiBai;

  /// No description provided for @chuShiHuaFenPianShangChuanShiBai.
  ///
  /// In zh, this message translates to:
  /// **'初始化分片上传失败'**
  String get chuShiHuaFenPianShangChuanShiBai;

  /// No description provided for @fenPianShangChuanShiBai.
  ///
  /// In zh, this message translates to:
  /// **'分片上传失败'**
  String get fenPianShangChuanShiBai;

  /// No description provided for @wanChengShangChuanShiBai.
  ///
  /// In zh, this message translates to:
  /// **'完成上传失败'**
  String get wanChengShangChuanShiBai;

  /// No description provided for @wangLuoQingQiuShiBaiQingShaoHouChongShi.
  ///
  /// In zh, this message translates to:
  /// **'网络请求失败，请稍后重试'**
  String get wangLuoQingQiuShiBaiQingShaoHouChongShi;

  /// No description provided for @yunPanFuWuXiangYingWeiKong.
  ///
  /// In zh, this message translates to:
  /// **'云盘服务响应为空'**
  String get yunPanFuWuXiangYingWeiKong;

  /// No description provided for @yunPanFuWuXiangYingWuFaJieXi.
  ///
  /// In zh, this message translates to:
  /// **'云盘服务响应无法解析'**
  String get yunPanFuWuXiangYingWuFaJieXi;

  /// No description provided for @queShaoGeQuId.
  ///
  /// In zh, this message translates to:
  /// **'缺少歌曲 ID'**
  String get queShaoGeQuId;

  /// No description provided for @queShaoZiYuanId.
  ///
  /// In zh, this message translates to:
  /// **'缺少资源 ID'**
  String get queShaoZiYuanId;

  /// No description provided for @louCengCanShuQueShiQingShuaXinPingLunHouChongShi.
  ///
  /// In zh, this message translates to:
  /// **'楼层参数缺失，请刷新评论后重试'**
  String get louCengCanShuQueShiQingShuaXinPingLunHouChongShi;

  /// No description provided for @pingLunChiWeiZhiQingShuaXinPingLunHouZaiShi.
  ///
  /// In zh, this message translates to:
  /// **'评论池未知，请刷新评论后再试'**
  String get pingLunChiWeiZhiQingShuaXinPingLunHouZaiShi;

  /// No description provided for @louCengXinXiBuWanZhengQingShuaXinPingLunHouZaiSh.
  ///
  /// In zh, this message translates to:
  /// **'楼层信息不完整，请刷新评论后再试'**
  String get louCengXinXiBuWanZhengQingShuaXinPingLunHouZaiSh;

  /// No description provided for @huiFuNeiRongBuNengWeiKong.
  ///
  /// In zh, this message translates to:
  /// **'回复内容不能为空'**
  String get huiFuNeiRongBuNengWeiKong;

  /// No description provided for @huiFu.
  ///
  /// In zh, this message translates to:
  /// **'回复'**
  String get huiFu;

  /// No description provided for @fenLeiCanShuQueShi.
  ///
  /// In zh, this message translates to:
  /// **'分类参数缺失'**
  String get fenLeiCanShuQueShi;

  /// No description provided for @reCiCanShuQueShi.
  ///
  /// In zh, this message translates to:
  /// **'热词参数缺失'**
  String get reCiCanShuQueShi;

  /// No description provided for @queShaoMvHashWuFaJiaZaiDanMu.
  ///
  /// In zh, this message translates to:
  /// **'缺少 MV hash，无法加载弹幕'**
  String get queShaoMvHashWuFaJiaZaiDanMu;

  /// No description provided for @queShaoMvHashWuFaFaSongDanMu.
  ///
  /// In zh, this message translates to:
  /// **'缺少 MV hash，无法发送弹幕'**
  String get queShaoMvHashWuFaFaSongDanMu;

  /// No description provided for @danMu.
  ///
  /// In zh, this message translates to:
  /// **'弹幕'**
  String get danMu;

  /// No description provided for @danMuNeiRongBuNengWeiKong.
  ///
  /// In zh, this message translates to:
  /// **'弹幕内容不能为空'**
  String get danMuNeiRongBuNengWeiKong;

  /// No description provided for @wangLuoCuoWuWuFaFaSong.
  ///
  /// In zh, this message translates to:
  /// **'网络错误，无法发送'**
  String get wangLuoCuoWuWuFaFaSong;

  /// No description provided for @wangLuoWangGuanLanJieWuFaFaSong.
  ///
  /// In zh, this message translates to:
  /// **'网络网关拦截，无法发送'**
  String get wangLuoWangGuanLanJieWuFaFaSong;

  /// No description provided for @pingLunXiangYingWuFaJieXi.
  ///
  /// In zh, this message translates to:
  /// **'评论响应无法解析'**
  String get pingLunXiangYingWuFaJieXi;

  /// No description provided for @xuYaoAnQuanJiaoYanQingXianZaiKuGouGuanFangKeHuDu.
  ///
  /// In zh, this message translates to:
  /// **'需要安全校验：请先在酷狗官方客户端完成一次验证，再回来重试'**
  String get xuYaoAnQuanJiaoYanQingXianZaiKuGouGuanFangKeHuDu;

  /// No description provided for @pingLunCanShuJiaoYanShiBai20006.
  ///
  /// In zh, this message translates to:
  /// **'评论参数校验失败（20006）'**
  String get pingLunCanShuJiaoYanShiBai20006;

  /// No description provided for @pingLunNeiRongChangDuBuHeGui10003.
  ///
  /// In zh, this message translates to:
  /// **'评论内容长度不合规（10003）'**
  String get pingLunNeiRongChangDuBuHeGui10003;

  /// No description provided for @dengLuHouCaiNengFaBiaoPingLun.
  ///
  /// In zh, this message translates to:
  /// **'登录后才能发表评论'**
  String get dengLuHouCaiNengFaBiaoPingLun;

  /// No description provided for @pingLunNeiRongBuNengWeiKong.
  ///
  /// In zh, this message translates to:
  /// **'评论内容不能为空'**
  String get pingLunNeiRongBuNengWeiKong;

  /// No description provided for @pingLunJieKouBeiJuJueAccessDeny.
  ///
  /// In zh, this message translates to:
  /// **'评论接口被拒绝（Access Deny）'**
  String get pingLunJieKouBeiJuJueAccessDeny;

  /// No description provided for @pingLunXiangYingWeiKong.
  ///
  /// In zh, this message translates to:
  /// **'评论响应为空'**
  String get pingLunXiangYingWeiKong;

  /// No description provided for @wangLuoCuoWuWuFaJiaZaiPingLun.
  ///
  /// In zh, this message translates to:
  /// **'网络错误，无法加载评论'**
  String get wangLuoCuoWuWuFaJiaZaiPingLun;

  /// No description provided for @dengLuTaiChuFaAnQuanJiaoYanSsa20028QingChongXinD.
  ///
  /// In zh, this message translates to:
  /// **'登录态触发安全校验（SSA 20028），请重新登录后再试'**
  String get dengLuTaiChuFaAnQuanJiaoYanSsa20028QingChongXinD;

  /// No description provided for @pingLunXuYaoAnQuanJiaoYanSsa20028.
  ///
  /// In zh, this message translates to:
  /// **'评论需要安全校验（SSA 20028）'**
  String get pingLunXuYaoAnQuanJiaoYanSsa20028;

  /// No description provided for @pingLunCanShuWuXiao.
  ///
  /// In zh, this message translates to:
  /// **'评论参数无效'**
  String get pingLunCanShuWuXiao;

  /// No description provided for @pingLunQianMingJiaoYanShiBai.
  ///
  /// In zh, this message translates to:
  /// **'评论签名校验失败'**
  String get pingLunQianMingJiaoYanShiBai;

  /// No description provided for @yongHu.
  ///
  /// In zh, this message translates to:
  /// **'用户'**
  String get yongHu;

  /// No description provided for @xueSheng.
  ///
  /// In zh, this message translates to:
  /// **'学生'**
  String get xueSheng;

  /// No description provided for @yanYuan.
  ///
  /// In zh, this message translates to:
  /// **'演员'**
  String get yanYuan;

  /// No description provided for @renZheng.
  ///
  /// In zh, this message translates to:
  /// **'认证'**
  String get renZheng;

  /// No description provided for @mingXing.
  ///
  /// In zh, this message translates to:
  /// **'明星'**
  String get mingXing;

  /// No description provided for @daRen.
  ///
  /// In zh, this message translates to:
  /// **'达人'**
  String get daRen;

  /// No description provided for @yanChangZhe.
  ///
  /// In zh, this message translates to:
  /// **'演唱者'**
  String get yanChangZhe;

  /// No description provided for @chaoJiVip.
  ///
  /// In zh, this message translates to:
  /// **'超级VIP'**
  String get chaoJiVip;

  /// No description provided for @gaiNianVip.
  ///
  /// In zh, this message translates to:
  /// **'概念VIP'**
  String get gaiNianVip;

  /// No description provided for @zhouKa.
  ///
  /// In zh, this message translates to:
  /// **'周卡'**
  String get zhouKa;

  /// No description provided for @changTingVip.
  ///
  /// In zh, this message translates to:
  /// **'畅听VIP'**
  String get changTingVip;

  /// No description provided for @jiKa.
  ///
  /// In zh, this message translates to:
  /// **'季卡'**
  String get jiKa;

  /// No description provided for @haoHuaVip.
  ///
  /// In zh, this message translates to:
  /// **'豪华VIP'**
  String get haoHuaVip;

  /// No description provided for @nianFeiYinYueBao.
  ///
  /// In zh, this message translates to:
  /// **'年费音乐包'**
  String get nianFeiYinYueBao;

  /// No description provided for @yinYueBao.
  ///
  /// In zh, this message translates to:
  /// **'音乐包'**
  String get yinYueBao;

  /// No description provided for @sheBeiZhuCeXiangYingWeiKong.
  ///
  /// In zh, this message translates to:
  /// **'设备注册响应为空'**
  String get sheBeiZhuCeXiangYingWeiKong;

  /// No description provided for @sheBeiZhuCeXiangYingWuFaJieXi.
  ///
  /// In zh, this message translates to:
  /// **'设备注册响应无法解析'**
  String get sheBeiZhuCeXiangYingWuFaJieXi;

  /// No description provided for @sheBeiZhuCeWeiFanHuiDfid.
  ///
  /// In zh, this message translates to:
  /// **'设备注册未返回 dfid'**
  String get sheBeiZhuCeWeiFanHuiDfid;

  /// No description provided for @sheBeiZhuCeWangLuoCuoWu.
  ///
  /// In zh, this message translates to:
  /// **'设备注册网络错误'**
  String get sheBeiZhuCeWangLuoCuoWu;

  /// No description provided for @sheBeiZhuCeYiChangQingShaoHouChongShi.
  ///
  /// In zh, this message translates to:
  /// **'设备注册异常，请稍后重试'**
  String get sheBeiZhuCeYiChangQingShaoHouChongShi;

  /// No description provided for @huaYu.
  ///
  /// In zh, this message translates to:
  /// **'华语'**
  String get huaYu;

  /// No description provided for @ouMei.
  ///
  /// In zh, this message translates to:
  /// **'欧美'**
  String get ouMei;

  /// No description provided for @riBen.
  ///
  /// In zh, this message translates to:
  /// **'日本'**
  String get riBen;

  /// No description provided for @hanGuo.
  ///
  /// In zh, this message translates to:
  /// **'韩国'**
  String get hanGuo;

  /// No description provided for @nan.
  ///
  /// In zh, this message translates to:
  /// **'男'**
  String get nan;

  /// No description provided for @nv.
  ///
  /// In zh, this message translates to:
  /// **'女'**
  String get nv;

  /// No description provided for @zuHe.
  ///
  /// In zh, this message translates to:
  /// **'组合'**
  String get zuHe;

  /// No description provided for @liuXing.
  ///
  /// In zh, this message translates to:
  /// **'流行'**
  String get liuXing;

  /// No description provided for @xiHa.
  ///
  /// In zh, this message translates to:
  /// **'嘻哈'**
  String get xiHa;

  /// No description provided for @yaoGun.
  ///
  /// In zh, this message translates to:
  /// **'摇滚'**
  String get yaoGun;

  /// No description provided for @guDian.
  ///
  /// In zh, this message translates to:
  /// **'古典'**
  String get guDian;

  /// No description provided for @geDanFenLei.
  ///
  /// In zh, this message translates to:
  /// **'歌单分类'**
  String get geDanFenLei;

  /// No description provided for @zanWuGeDanFenLei.
  ///
  /// In zh, this message translates to:
  /// **'暂无歌单分类'**
  String get zanWuGeDanFenLei;

  /// No description provided for @zanWuXinGe.
  ///
  /// In zh, this message translates to:
  /// **'暂无新歌'**
  String get zanWuXinGe;

  /// No description provided for @zanWuXinDie.
  ///
  /// In zh, this message translates to:
  /// **'暂无新碟'**
  String get zanWuXinDie;

  /// No description provided for @zanWuGeShou.
  ///
  /// In zh, this message translates to:
  /// **'暂无歌手'**
  String get zanWuGeShou;

  /// No description provided for @dangQianWangLuoBeiWangGuanLanJieUrlGuoLvWuFaFang.
  ///
  /// In zh, this message translates to:
  /// **'当前网络被网关拦截（URL过滤），无法访问酷狗'**
  String get dangQianWangLuoBeiWangGuanLanJieUrlGuoLvWuFaFang;

  /// No description provided for @tanSuoJieKou.
  ///
  /// In zh, this message translates to:
  /// **'探索接口'**
  String get tanSuoJieKou;

  /// No description provided for @dangQianWangLuoBeiWangGuanLanJieUrlGuoLvWuFaFang_2.
  ///
  /// In zh, this message translates to:
  /// **'当前网络被网关拦截（URL过滤），无法访问酷狗。\n请换手机热点后重试。'**
  String get dangQianWangLuoBeiWangGuanLanJieUrlGuoLvWuFaFang_2;

  /// No description provided for @siRenFmXuYaoDengLuHouChaKan.
  ///
  /// In zh, this message translates to:
  /// **'私人FM需要登录后查看'**
  String get siRenFmXuYaoDengLuHouChaKan;

  /// No description provided for @dengLuHouKeHuoQuSiRenFm.
  ///
  /// In zh, this message translates to:
  /// **'登录后可获取私人FM'**
  String get dengLuHouKeHuoQuSiRenFm;

  /// No description provided for @siRenFmZanWuKeBoFangGeQu.
  ///
  /// In zh, this message translates to:
  /// **'私人FM暂无可播放歌曲'**
  String get siRenFmZanWuKeBoFangGeQu;

  /// No description provided for @siRenFmWangLuoCuoWu.
  ///
  /// In zh, this message translates to:
  /// **'私人FM网络错误'**
  String get siRenFmWangLuoCuoWu;

  /// No description provided for @siRenFmYiChangQingShaoHouChongShi.
  ///
  /// In zh, this message translates to:
  /// **'私人FM异常，请稍后重试'**
  String get siRenFmYiChangQingShaoHouChongShi;

  /// No description provided for @huoQuErWeiMaShiBai.
  ///
  /// In zh, this message translates to:
  /// **'获取二维码失败'**
  String get huoQuErWeiMaShiBai;

  /// No description provided for @erWeiMaXiangYingYiChang.
  ///
  /// In zh, this message translates to:
  /// **'二维码响应异常'**
  String get erWeiMaXiangYingYiChang;

  /// No description provided for @erWeiMaKeyWeiKong.
  ///
  /// In zh, this message translates to:
  /// **'二维码 key 为空'**
  String get erWeiMaKeyWeiKong;

  /// No description provided for @faSongYanZhengMaShiBai.
  ///
  /// In zh, this message translates to:
  /// **'发送验证码失败'**
  String get faSongYanZhengMaShiBai;

  /// No description provided for @dengLuShiBai.
  ///
  /// In zh, this message translates to:
  /// **'登录失败'**
  String get dengLuShiBai;

  /// No description provided for @dengLuXiangYingYiChang.
  ///
  /// In zh, this message translates to:
  /// **'登录响应异常'**
  String get dengLuXiangYingYiChang;

  /// No description provided for @dengLuChengGongDanWeiFanHuiToken.
  ///
  /// In zh, this message translates to:
  /// **'登录成功但未返回 token'**
  String get dengLuChengGongDanWeiFanHuiToken;

  /// No description provided for @huoQuYongHuZiLiaoShiBai.
  ///
  /// In zh, this message translates to:
  /// **'获取用户资料失败'**
  String get huoQuYongHuZiLiaoShiBai;

  /// No description provided for @queShaoShiPinHash.
  ///
  /// In zh, this message translates to:
  /// **'缺少视频 hash'**
  String get queShaoShiPinHash;

  /// No description provided for @shiPinDiZhiWeiKong.
  ///
  /// In zh, this message translates to:
  /// **'视频地址为空'**
  String get shiPinDiZhiWeiKong;

  /// No description provided for @wuXiaoDeMvId.
  ///
  /// In zh, this message translates to:
  /// **'无效的 MV ID'**
  String get wuXiaoDeMvId;

  /// No description provided for @qingXianDengLu.
  ///
  /// In zh, this message translates to:
  /// **'请先登录'**
  String get qingXianDengLu;

  /// No description provided for @wangLuoCuoWu.
  ///
  /// In zh, this message translates to:
  /// **'网络错误'**
  String get wangLuoCuoWu;

  /// No description provided for @mvShouCangCaoZuoShiBai.
  ///
  /// In zh, this message translates to:
  /// **'MV 收藏操作失败'**
  String get mvShouCangCaoZuoShiBai;

  /// No description provided for @mvJieKouXiangYingWuFaJieXi.
  ///
  /// In zh, this message translates to:
  /// **'MV 接口响应无法解析'**
  String get mvJieKouXiangYingWuFaJieXi;

  /// No description provided for @xuYaoDengLuAnQuanYanZheng.
  ///
  /// In zh, this message translates to:
  /// **'需要登录/安全验证'**
  String get xuYaoDengLuAnQuanYanZheng;

  /// No description provided for @qianMingShiBai20006.
  ///
  /// In zh, this message translates to:
  /// **'签名失败（20006）'**
  String get qianMingShiBai20006;

  /// No description provided for @quMuQueShaoHash.
  ///
  /// In zh, this message translates to:
  /// **'曲目缺少 hash'**
  String get quMuQueShaoHash;

  /// No description provided for @boFangDiZhiXiangYingWuFaJieXi.
  ///
  /// In zh, this message translates to:
  /// **'播放地址响应无法解析'**
  String get boFangDiZhiXiangYingWuFaJieXi;

  /// No description provided for @chuFaAnQuanYanZhengSsa20028QingChongXinDengLuHou.
  ///
  /// In zh, this message translates to:
  /// **'触发安全验证（SSA 20028），请重新登录后再试'**
  String get chuFaAnQuanYanZhengSsa20028QingChongXinDengLuHou;

  /// No description provided for @boFangXuYaoDengLuAnQuanYanZhengYouKeTongDaoYiGua.
  ///
  /// In zh, this message translates to:
  /// **'播放需要登录/安全验证（游客通道已关闭）'**
  String get boFangXuYaoDengLuAnQuanYanZhengYouKeTongDaoYiGua;

  /// No description provided for @wuFaHuoQuBoFangDiZhi.
  ///
  /// In zh, this message translates to:
  /// **'无法获取播放地址'**
  String get wuFaHuoQuBoFangDiZhi;

  /// No description provided for @minYaoJingXuan.
  ///
  /// In zh, this message translates to:
  /// **'民谣精选'**
  String get minYaoJingXuan;

  /// No description provided for @shuoChangReGe.
  ///
  /// In zh, this message translates to:
  /// **'说唱热歌'**
  String get shuoChangReGe;

  /// No description provided for @guoFengXinSheng.
  ///
  /// In zh, this message translates to:
  /// **'国风新声'**
  String get guoFengXinSheng;

  /// No description provided for @yaoGunJingDian.
  ///
  /// In zh, this message translates to:
  /// **'摇滚经典'**
  String get yaoGunJingDian;

  /// No description provided for @dianZiYeXing.
  ///
  /// In zh, this message translates to:
  /// **'电子夜行'**
  String get dianZiYeXing;

  /// No description provided for @zhiYuXi.
  ///
  /// In zh, this message translates to:
  /// **'治愈系'**
  String get zhiYuXi;

  /// No description provided for @meiRiTuiJianJiaZaiShiBaiQingJianChaWangLuoHouCho.
  ///
  /// In zh, this message translates to:
  /// **'每日推荐加载失败，请检查网络后重试'**
  String get meiRiTuiJianJiaZaiShiBaiQingJianChaWangLuoHouCho;

  /// No description provided for @dengLuHouKeHuoQuGeXingHuaMeiRiTuiJian.
  ///
  /// In zh, this message translates to:
  /// **'登录后可获取个性化每日推荐'**
  String get dengLuHouKeHuoQuGeXingHuaMeiRiTuiJian;

  /// No description provided for @fengGeTuiJian.
  ///
  /// In zh, this message translates to:
  /// **'风格推荐'**
  String get fengGeTuiJian;

  /// No description provided for @fengGeTuiJianJiaZaiShiBaiQingShaoHouChongShi.
  ///
  /// In zh, this message translates to:
  /// **'风格推荐加载失败，请稍后重试'**
  String get fengGeTuiJianJiaZaiShiBaiQingShaoHouChongShi;

  /// No description provided for @dengLuHouKeHuoQuGengTieHeKouWeiDeFengGeTuiJian.
  ///
  /// In zh, this message translates to:
  /// **'登录后可获取更贴合口味的风格推荐'**
  String get dengLuHouKeHuoQuGengTieHeKouWeiDeFengGeTuiJian;

  /// No description provided for @dengLuHouKeHuoQuFengGeTuiJian.
  ///
  /// In zh, this message translates to:
  /// **'登录后可获取风格推荐'**
  String get dengLuHouKeHuoQuFengGeTuiJian;

  /// No description provided for @tuiJianGeDan.
  ///
  /// In zh, this message translates to:
  /// **'推荐歌单'**
  String get tuiJianGeDan;

  /// No description provided for @tuiJianGeDanJiaZaiShiBai.
  ///
  /// In zh, this message translates to:
  /// **'推荐歌单加载失败'**
  String get tuiJianGeDanJiaZaiShiBai;

  /// No description provided for @zanWuTuiJianGeDan.
  ///
  /// In zh, this message translates to:
  /// **'暂无推荐歌单'**
  String get zanWuTuiJianGeDan;

  /// No description provided for @bianJiJingXuan.
  ///
  /// In zh, this message translates to:
  /// **'编辑精选'**
  String get bianJiJingXuan;

  /// No description provided for @bianJiJingXuanJiaZaiShiBai.
  ///
  /// In zh, this message translates to:
  /// **'编辑精选加载失败'**
  String get bianJiJingXuanJiaZaiShiBai;

  /// No description provided for @zanWuBianJiJingXuan.
  ///
  /// In zh, this message translates to:
  /// **'暂无编辑精选'**
  String get zanWuBianJiJingXuan;

  /// No description provided for @tuiJianJieKou.
  ///
  /// In zh, this message translates to:
  /// **'推荐接口'**
  String get tuiJianJieKou;

  /// No description provided for @xuYaoDengLuHouChaKan.
  ///
  /// In zh, this message translates to:
  /// **'需要登录后查看'**
  String get xuYaoDengLuHouChaKan;

  /// No description provided for @meiRiTuiJianXuYaoDengLu.
  ///
  /// In zh, this message translates to:
  /// **'每日推荐需要登录'**
  String get meiRiTuiJianXuYaoDengLu;

  /// No description provided for @meiRiTuiJianXiangYingWuFaJieXi.
  ///
  /// In zh, this message translates to:
  /// **'每日推荐响应无法解析'**
  String get meiRiTuiJianXiangYingWuFaJieXi;

  /// No description provided for @meiRiTuiJianXuYaoDengLuHuoAnQuanJiaoYan.
  ///
  /// In zh, this message translates to:
  /// **'每日推荐需要登录或安全校验'**
  String get meiRiTuiJianXuYaoDengLuHuoAnQuanJiaoYan;

  /// No description provided for @meiRiTuiJianXuYaoDengLuHouChaKan.
  ///
  /// In zh, this message translates to:
  /// **'每日推荐需要登录后查看'**
  String get meiRiTuiJianXuYaoDengLuHouChaKan;

  /// No description provided for @meiRiTuiJianWangLuoCuoWu.
  ///
  /// In zh, this message translates to:
  /// **'每日推荐网络错误'**
  String get meiRiTuiJianWangLuoCuoWu;

  /// No description provided for @meiRiTuiJianYiChangQingShaoHouChongShi.
  ///
  /// In zh, this message translates to:
  /// **'每日推荐异常，请稍后重试'**
  String get meiRiTuiJianYiChangQingShaoHouChongShi;

  /// No description provided for @qingQiuShiBai.
  ///
  /// In zh, this message translates to:
  /// **'请求失败'**
  String get qingQiuShiBai;

  /// No description provided for @qianMingJiaoYanShiBai20006.
  ///
  /// In zh, this message translates to:
  /// **'签名校验失败（20006）'**
  String get qianMingJiaoYanShiBai20006;

  /// No description provided for @qingQiuCanShuQueShi20010.
  ///
  /// In zh, this message translates to:
  /// **'请求参数缺失（20010）'**
  String get qingQiuCanShuQueShi20010;

  /// No description provided for @yunDuanGeDanJianQuanShiBai20017QingTuiChuHouChon.
  ///
  /// In zh, this message translates to:
  /// **'云端歌单鉴权失败（20017），请退出后重新登录'**
  String get yunDuanGeDanJianQuanShiBai20017QingTuiChuHouChon;

  /// No description provided for @dengLuTaiWuXiao20018QingTuiChuHouChongXinDengLu.
  ///
  /// In zh, this message translates to:
  /// **'登录态无效（20018），请退出后重新登录'**
  String get dengLuTaiWuXiao20018QingTuiChuHouChongXinDengLu;

  /// No description provided for @chuFaAnQuanJiaoYanSsa20028QingChongXinDengLuHouZ.
  ///
  /// In zh, this message translates to:
  /// **'触发安全校验（SSA 20028），请重新登录后再试'**
  String get chuFaAnQuanJiaoYanSsa20028QingChongXinDengLuHouZ;

  /// No description provided for @jieXiYongHuGeDanXiangYingShiBai.
  ///
  /// In zh, this message translates to:
  /// **'解析用户歌单响应失败'**
  String get jieXiYongHuGeDanXiangYingShiBai;

  /// No description provided for @huoQuYongHuGeDanShiBai.
  ///
  /// In zh, this message translates to:
  /// **'获取用户歌单失败'**
  String get huoQuYongHuGeDanShiBai;

  /// No description provided for @jieXiGuanZhuLieBiaoXiangYingShiBai.
  ///
  /// In zh, this message translates to:
  /// **'解析关注列表响应失败'**
  String get jieXiGuanZhuLieBiaoXiangYingShiBai;

  /// No description provided for @huoQuGuanZhuLieBiaoShiBai.
  ///
  /// In zh, this message translates to:
  /// **'获取关注列表失败'**
  String get huoQuGuanZhuLieBiaoShiBai;

  /// No description provided for @jieXiYongHuGeDanGeQuXiangYingShiBai.
  ///
  /// In zh, this message translates to:
  /// **'解析用户歌单歌曲响应失败'**
  String get jieXiYongHuGeDanGeQuXiangYingShiBai;

  /// No description provided for @huoQuYongHuGeDanGeQuShiBai.
  ///
  /// In zh, this message translates to:
  /// **'获取用户歌单歌曲失败'**
  String get huoQuYongHuGeDanGeQuShiBai;

  /// No description provided for @tianJiaDaoWoXiHuanShiBai.
  ///
  /// In zh, this message translates to:
  /// **'添加到我喜欢失败'**
  String get tianJiaDaoWoXiHuanShiBai;

  /// No description provided for @congWoXiHuanYiChuShiBai.
  ///
  /// In zh, this message translates to:
  /// **'从我喜欢移除失败'**
  String get congWoXiHuanYiChuShiBai;

  /// No description provided for @ziJianShouCangJiaLieBiaoBuWanZhengQingChongShi.
  ///
  /// In zh, this message translates to:
  /// **'自建收藏夹列表不完整，请重试'**
  String get ziJianShouCangJiaLieBiaoBuWanZhengQingChongShi;

  /// No description provided for @shiPinBuCunZai.
  ///
  /// In zh, this message translates to:
  /// **'视频不存在'**
  String get shiPinBuCunZai;

  /// No description provided for @wuXiaoDeBZhanNeiRongId.
  ///
  /// In zh, this message translates to:
  /// **'无效的 B 站内容 ID'**
  String get wuXiaoDeBZhanNeiRongId;

  /// No description provided for @bZhanLieBiaoFenYeYiChangWeiFanHuiWanZhengNeiRong.
  ///
  /// In zh, this message translates to:
  /// **'B 站列表分页异常，未返回完整内容'**
  String get bZhanLieBiaoFenYeYiChangWeiFanHuiWanZhengNeiRong;

  /// No description provided for @bZhanNeiRong.
  ///
  /// In zh, this message translates to:
  /// **'B 站内容'**
  String get bZhanNeiRong;

  /// No description provided for @wuXiaoDeUpZhuId.
  ///
  /// In zh, this message translates to:
  /// **'无效的 UP 主 ID'**
  String get wuXiaoDeUpZhuId;

  /// No description provided for @saoMaChengGongDanWeiShouDaoDengLuPingJu.
  ///
  /// In zh, this message translates to:
  /// **'扫码成功但未收到登录凭据'**
  String get saoMaChengGongDanWeiShouDaoDengLuPingJu;

  /// No description provided for @dengLuTaiQueRenShiBaiQingChongShi.
  ///
  /// In zh, this message translates to:
  /// **'登录态确认失败，请重试'**
  String get dengLuTaiQueRenShiBaiQingChongShi;

  /// No description provided for @qingXianDengLuBiLiBiLi.
  ///
  /// In zh, this message translates to:
  /// **'请先登录哔哩哔哩'**
  String get qingXianDengLuBiLiBiLi;

  /// No description provided for @shouCangJiaFenYeYiChangWeiFanHuiWanZhengLieBiao.
  ///
  /// In zh, this message translates to:
  /// **'收藏夹分页异常，未返回完整列表'**
  String get shouCangJiaFenYeYiChangWeiFanHuiWanZhengLieBiao;

  /// No description provided for @bZhanGaiShiPinWuKeYongYinGui.
  ///
  /// In zh, this message translates to:
  /// **'B 站：该视频无可用音轨'**
  String get bZhanGaiShiPinWuKeYongYinGui;

  /// No description provided for @bZhanQuMuIdWeiKong.
  ///
  /// In zh, this message translates to:
  /// **'B 站：曲目 id 为空'**
  String get bZhanQuMuIdWeiKong;

  /// No description provided for @wuFaDingWeiGaiGeQuQueShaoGeQuIdGeMing.
  ///
  /// In zh, this message translates to:
  /// **'无法定位该歌曲（缺少歌曲 ID / 歌名）'**
  String get wuFaDingWeiGaiGeQuQueShaoGeQuIdGeMing;

  /// No description provided for @kuGouWeiDengLuWuFaDuQuYunDuanZiLiaoKu.
  ///
  /// In zh, this message translates to:
  /// **'酷狗未登录，无法读取云端资料库'**
  String get kuGouWeiDengLuWuFaDuQuYunDuanZiLiaoKu;

  /// No description provided for @kuGouWeiDengLuWuFaDuQuWoXiHuan.
  ///
  /// In zh, this message translates to:
  /// **'酷狗未登录，无法读取「我喜欢」'**
  String get kuGouWeiDengLuWuFaDuQuWoXiHuan;

  /// No description provided for @weiZhaoDaoYunDuanWoXiHuanGeDan.
  ///
  /// In zh, this message translates to:
  /// **'未找到云端「我喜欢」歌单'**
  String get weiZhaoDaoYunDuanWoXiHuanGeDan;

  /// No description provided for @yunDuanWoXiHuanGeDanQueShaoListid.
  ///
  /// In zh, this message translates to:
  /// **'云端「我喜欢」歌单缺少 listId'**
  String get yunDuanWoXiHuanGeDanQueShaoListid;

  /// No description provided for @kuGouWeiDengLuWuFaTongBuHongXin.
  ///
  /// In zh, this message translates to:
  /// **'酷狗未登录，无法同步红心'**
  String get kuGouWeiDengLuWuFaTongBuHongXin;

  /// No description provided for @zhuanJiJiaZaiShiBaiJieKouBuKeYongHuoGaiIdWuGongK.
  ///
  /// In zh, this message translates to:
  /// **'专辑加载失败：接口不可用或该 ID 无公开数据'**
  String get zhuanJiJiaZaiShiBaiJieKouBuKeYongHuoGaiIdWuGongK;

  /// No description provided for @fanHui.
  ///
  /// In zh, this message translates to:
  /// **'返回'**
  String get fanHui;

  /// No description provided for @boFangQuanBu.
  ///
  /// In zh, this message translates to:
  /// **'播放全部'**
  String get boFangQuanBu;

  /// No description provided for @chongXinJiaZai.
  ///
  /// In zh, this message translates to:
  /// **'重新加载'**
  String get chongXinJiaZai;

  /// No description provided for @geShouJiaZaiShiBaiJieKouBuKeYongHuoWuGongKaiShuJ.
  ///
  /// In zh, this message translates to:
  /// **'歌手加载失败：接口不可用或无公开数据'**
  String get geShouJiaZaiShiBaiJieKouBuKeYongHuoWuGongKaiShuJ;

  /// No description provided for @zanWuGongKaiGeQu.
  ///
  /// In zh, this message translates to:
  /// **'暂无公开歌曲'**
  String get zanWuGongKaiGeQu;

  /// No description provided for @geShouJieShao.
  ///
  /// In zh, this message translates to:
  /// **'歌手介绍'**
  String get geShouJieShao;

  /// No description provided for @guanBi.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get guanBi;

  /// No description provided for @zaiXianJiaZai.
  ///
  /// In zh, this message translates to:
  /// **'在线加载'**
  String get zaiXianJiaZai;

  /// No description provided for @heJiXiLie.
  ///
  /// In zh, this message translates to:
  /// **'合集 / 系列'**
  String get heJiXiLie;

  /// No description provided for @jiaZaiGengDuoChongShi.
  ///
  /// In zh, this message translates to:
  /// **'加载更多 / 重试'**
  String get jiaZaiGengDuoChongShi;

  /// No description provided for @geQuJiaZaiShiBaiJieKouBuKeYongHuoWuGongKaiShuJu.
  ///
  /// In zh, this message translates to:
  /// **'歌曲加载失败：接口不可用或无公开数据'**
  String get geQuJiaZaiShiBaiJieKouBuKeYongHuoWuGongKaiShuJu;

  /// No description provided for @weiZhaoDaoPiPeiDeGeQu.
  ///
  /// In zh, this message translates to:
  /// **'未找到匹配的歌曲'**
  String get weiZhaoDaoPiPeiDeGeQu;

  /// No description provided for @shangLaHuoShaoHouJiaZaiGengDuo.
  ///
  /// In zh, this message translates to:
  /// **'上拉或稍候加载更多'**
  String get shangLaHuoShaoHouJiaZaiGengDuo;

  /// No description provided for @boFangReMen.
  ///
  /// In zh, this message translates to:
  /// **'播放热门'**
  String get boFangReMen;

  /// No description provided for @chaKanXiangQing.
  ///
  /// In zh, this message translates to:
  /// **'查看详情'**
  String get chaKanXiangQing;

  /// No description provided for @souSuoGeQu.
  ///
  /// In zh, this message translates to:
  /// **'搜索歌曲…'**
  String get souSuoGeQu;

  /// No description provided for @dingWeiDangQianBoFang.
  ///
  /// In zh, this message translates to:
  /// **'定位当前播放'**
  String get dingWeiDangQianBoFang;

  /// No description provided for @dengLuPingJuHuiFuChaoShiYiJinRuYouKeMoShiBaoCunD.
  ///
  /// In zh, this message translates to:
  /// **'登录凭据恢复超时；已进入游客模式，保存的凭据未删除。'**
  String get dengLuPingJuHuiFuChaoShiYiJinRuYouKeMoShiBaoCunD;

  /// No description provided for @dengLuPingJuHuiFuShiBaiQingJianChaXiTongAnQuanCu.
  ///
  /// In zh, this message translates to:
  /// **'登录凭据恢复失败，请检查系统安全存储后重新登录。'**
  String get dengLuPingJuHuiFuShiBaiQingJianChaXiTongAnQuanCu;

  /// No description provided for @saoMaChengGongDanWeiFanHuiHuiHua.
  ///
  /// In zh, this message translates to:
  /// **'扫码成功但未返回会话'**
  String get saoMaChengGongDanWeiFanHuiHuiHua;

  /// No description provided for @qingShuRu11WeiShouJiHao.
  ///
  /// In zh, this message translates to:
  /// **'请输入 11 位手机号'**
  String get qingShuRu11WeiShouJiHao;

  /// No description provided for @qingShuRuZhiShao4WeiYanZhengMa.
  ///
  /// In zh, this message translates to:
  /// **'请输入至少 4 位验证码'**
  String get qingShuRuZhiShao4WeiYanZhengMa;

  /// No description provided for @qingShuRuZhangHaoHeMiMa.
  ///
  /// In zh, this message translates to:
  /// **'请输入账号和密码'**
  String get qingShuRuZhangHaoHeMiMa;

  /// No description provided for @yiDengLuDanAnQuanCunChuBuKeYongBenCiDengLuWuFaBa.
  ///
  /// In zh, this message translates to:
  /// **'已登录，但安全存储不可用；本次登录无法保存，请稍后重试。'**
  String get yiDengLuDanAnQuanCunChuBuKeYongBenCiDengLuWuFaBa;

  /// No description provided for @yiTuiChuDengLuAnQuanCunChuQingLiWeiWanChengQingJ.
  ///
  /// In zh, this message translates to:
  /// **'已退出登录；安全存储清理未完成，请检查系统权限。'**
  String get yiTuiChuDengLuAnQuanCunChuQingLiWeiWanChengQingJ;

  /// No description provided for @erWeiMaHuoQuShiBaiQingChongShi.
  ///
  /// In zh, this message translates to:
  /// **'二维码获取失败，请重试'**
  String get erWeiMaHuoQuShiBaiQingChongShi;

  /// No description provided for @yiDengLuDanAnQuanCunChuBuKeYongBenCiDengLuWuFaBa_2.
  ///
  /// In zh, this message translates to:
  /// **'已登录，但安全存储不可用；本次登录无法保存。'**
  String get yiDengLuDanAnQuanCunChuBuKeYongBenCiDengLuWuFaBa_2;

  /// No description provided for @dengLuZhuangTaiQueRenShiBaiQingChongShi.
  ///
  /// In zh, this message translates to:
  /// **'登录状态确认失败，请重试'**
  String get dengLuZhuangTaiQueRenShiBaiQingChongShi;

  /// No description provided for @biLiBiLiZhangHao.
  ///
  /// In zh, this message translates to:
  /// **'哔哩哔哩账号'**
  String get biLiBiLiZhangHao;

  /// No description provided for @qieHuanZhangHao.
  ///
  /// In zh, this message translates to:
  /// **'切换账号'**
  String get qieHuanZhangHao;

  /// No description provided for @tuiChuDengLu.
  ///
  /// In zh, this message translates to:
  /// **'退出登录'**
  String get tuiChuDengLu;

  /// No description provided for @daKaiBiLiBiLiAppSaoYiSaoSaoMaHouZaiShouJiShangQu.
  ///
  /// In zh, this message translates to:
  /// **'打开哔哩哔哩 App 扫一扫，扫码后在手机上确认登录。'**
  String get daKaiBiLiBiLiAppSaoYiSaoSaoMaHouZaiShouJiShangQu;

  /// No description provided for @yiSaoMaQingZaiShouJiShangQueRen.
  ///
  /// In zh, this message translates to:
  /// **'已扫码，请在手机上确认'**
  String get yiSaoMaQingZaiShouJiShangQueRen;

  /// No description provided for @erWeiMaYiGuoQiQingShuaXin.
  ///
  /// In zh, this message translates to:
  /// **'二维码已过期，请刷新'**
  String get erWeiMaYiGuoQiQingShuaXin;

  /// No description provided for @dengDaiSaoMa.
  ///
  /// In zh, this message translates to:
  /// **'等待扫码'**
  String get dengDaiSaoMa;

  /// No description provided for @shuaXinErWeiMa.
  ///
  /// In zh, this message translates to:
  /// **'刷新二维码'**
  String get shuaXinErWeiMa;

  /// No description provided for @dengLu.
  ///
  /// In zh, this message translates to:
  /// **'登录'**
  String get dengLu;

  /// No description provided for @saoMa.
  ///
  /// In zh, this message translates to:
  /// **'扫码'**
  String get saoMa;

  /// No description provided for @yanZhengMa.
  ///
  /// In zh, this message translates to:
  /// **'验证码'**
  String get yanZhengMa;

  /// No description provided for @zhangHao.
  ///
  /// In zh, this message translates to:
  /// **'账号'**
  String get zhangHao;

  /// No description provided for @shouJiYanZhengMaDengLu.
  ///
  /// In zh, this message translates to:
  /// **'手机验证码登录'**
  String get shouJiYanZhengMaDengLu;

  /// No description provided for @shiYongKuGouBangDingShouJiHaoJieShouDuanXinYanZh.
  ///
  /// In zh, this message translates to:
  /// **'使用酷狗绑定手机号接收短信验证码'**
  String get shiYongKuGouBangDingShouJiHaoJieShouDuanXinYanZh;

  /// No description provided for @shouJiHao.
  ///
  /// In zh, this message translates to:
  /// **'手机号'**
  String get shouJiHao;

  /// No description provided for @huoQuYanZhengMa.
  ///
  /// In zh, this message translates to:
  /// **'获取验证码'**
  String get huoQuYanZhengMa;

  /// No description provided for @zhangHaoMiMaDengLu.
  ///
  /// In zh, this message translates to:
  /// **'账号密码登录'**
  String get zhangHaoMiMaDengLu;

  /// No description provided for @kuGouZhangHaoShouJiHaoMiMa.
  ///
  /// In zh, this message translates to:
  /// **'酷狗账号 / 手机号 + 密码'**
  String get kuGouZhangHaoShouJiHaoMiMa;

  /// No description provided for @zhangHaoShouJiHao.
  ///
  /// In zh, this message translates to:
  /// **'账号 / 手机号'**
  String get zhangHaoShouJiHao;

  /// No description provided for @miMa.
  ///
  /// In zh, this message translates to:
  /// **'密码'**
  String get miMa;

  /// No description provided for @youKeJiXuXianTingGe.
  ///
  /// In zh, this message translates to:
  /// **'游客继续，先听歌'**
  String get youKeJiXuXianTingGe;

  /// No description provided for @dengLuChengGong.
  ///
  /// In zh, this message translates to:
  /// **'登录成功'**
  String get dengLuChengGong;

  /// No description provided for @qingYongKuGouAppSaoMaDengLu.
  ///
  /// In zh, this message translates to:
  /// **'请用酷狗 App 扫码登录'**
  String get qingYongKuGouAppSaoMaDengLu;

  /// No description provided for @mei3MiaoZiDongJianCe.
  ///
  /// In zh, this message translates to:
  /// **'每 3 秒自动检测'**
  String get mei3MiaoZiDongJianCe;

  /// No description provided for @erWeiMaYiGuoQi.
  ///
  /// In zh, this message translates to:
  /// **'二维码已过期'**
  String get erWeiMaYiGuoQi;

  /// No description provided for @shuaXin.
  ///
  /// In zh, this message translates to:
  /// **'刷新'**
  String get shuaXin;

  /// No description provided for @kuGouSaoMaDengLu.
  ///
  /// In zh, this message translates to:
  /// **'酷狗扫码登录'**
  String get kuGouSaoMaDengLu;

  /// No description provided for @daKaiShouJiKuGouSaoYiSaoDengLuHouKeTongBuXiHuanY.
  ///
  /// In zh, this message translates to:
  /// **'打开手机酷狗扫一扫；登录后可同步喜欢与播放地址权限'**
  String get daKaiShouJiKuGouSaoYiSaoDengLuHouKeTongBuXiHuanY;

  /// No description provided for @wangYiYunZhangHao.
  ///
  /// In zh, this message translates to:
  /// **'网易云账号'**
  String get wangYiYunZhangHao;

  /// No description provided for @wangYiYunSaoMaDengLu.
  ///
  /// In zh, this message translates to:
  /// **'网易云扫码登录'**
  String get wangYiYunSaoMaDengLu;

  /// No description provided for @daKaiShouJiWangYiYunYinYueAppSaoYiSaoSaoMiaoXiaF.
  ///
  /// In zh, this message translates to:
  /// **'打开手机「网易云音乐」App → 扫一扫，扫描下方二维码'**
  String get daKaiShouJiWangYiYunYinYueAppSaoYiSaoSaoMiaoXiaF;

  /// No description provided for @qingYongWangYiYunYinYueAppSaoMaDengLu.
  ///
  /// In zh, this message translates to:
  /// **'请用网易云音乐 App 扫码登录'**
  String get qingYongWangYiYunYinYueAppSaoMaDengLu;

  /// No description provided for @mei2MiaoZiDongJianCe.
  ///
  /// In zh, this message translates to:
  /// **'每 2 秒自动检测'**
  String get mei2MiaoZiDongJianCe;

  /// No description provided for @yiDengLu.
  ///
  /// In zh, this message translates to:
  /// **'已登录'**
  String get yiDengLu;

  /// No description provided for @dangQianYinYuanBuZhiChiYunPan.
  ///
  /// In zh, this message translates to:
  /// **'当前音源不支持云盘'**
  String get dangQianYinYuanBuZhiChiYunPan;

  /// No description provided for @yunPanJiaZaiShiBaiQingShaoHouChongShi.
  ///
  /// In zh, this message translates to:
  /// **'云盘加载失败，请稍后重试'**
  String get yunPanJiaZaiShiBaiQingShaoHouChongShi;

  /// No description provided for @congYunPanShanChu.
  ///
  /// In zh, this message translates to:
  /// **'从云盘删除'**
  String get congYunPanShanChu;

  /// No description provided for @quXiao.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get quXiao;

  /// No description provided for @shanChu.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get shanChu;

  /// No description provided for @yiCongYunPanShanChu.
  ///
  /// In zh, this message translates to:
  /// **'已从云盘删除'**
  String get yiCongYunPanShanChu;

  /// No description provided for @shangChuanDaoYunPan.
  ///
  /// In zh, this message translates to:
  /// **'上传到云盘'**
  String get shangChuanDaoYunPan;

  /// No description provided for @souSuoYunPanGeQu.
  ///
  /// In zh, this message translates to:
  /// **'搜索云盘歌曲'**
  String get souSuoYunPanGeQu;

  /// No description provided for @yunPanZanWuGeQu.
  ///
  /// In zh, this message translates to:
  /// **'云盘暂无歌曲'**
  String get yunPanZanWuGeQu;

  /// No description provided for @jiaZaiGengDuo.
  ///
  /// In zh, this message translates to:
  /// **'加载更多'**
  String get jiaZaiGengDuo;

  /// No description provided for @dengLuHouChaKanYunPan.
  ///
  /// In zh, this message translates to:
  /// **'登录后查看云盘'**
  String get dengLuHouChaKanYunPan;

  /// No description provided for @bengKuiRiZhi.
  ///
  /// In zh, this message translates to:
  /// **'崩溃日志'**
  String get bengKuiRiZhi;

  /// No description provided for @meiYouBengKuiJiLu.
  ///
  /// In zh, this message translates to:
  /// **'没有崩溃记录'**
  String get meiYouBengKuiJiLu;

  /// No description provided for @qingKong.
  ///
  /// In zh, this message translates to:
  /// **'清空'**
  String get qingKong;

  /// No description provided for @qingTian.
  ///
  /// In zh, this message translates to:
  /// **'晴天'**
  String get qingTian;

  /// No description provided for @kongJieGuo.
  ///
  /// In zh, this message translates to:
  /// **'空结果'**
  String get kongJieGuo;

  /// No description provided for @geCi.
  ///
  /// In zh, this message translates to:
  /// **'歌词'**
  String get geCi;

  /// No description provided for @zhouJieLun.
  ///
  /// In zh, this message translates to:
  /// **'周杰伦'**
  String get zhouJieLun;

  /// No description provided for @xiangYingYiChang.
  ///
  /// In zh, this message translates to:
  /// **'响应异常'**
  String get xiangYingYiChang;

  /// No description provided for @boFangYu.
  ///
  /// In zh, this message translates to:
  /// **'播放域'**
  String get boFangYu;

  /// No description provided for @neiRongGuoLv.
  ///
  /// In zh, this message translates to:
  /// **'内容过滤'**
  String get neiRongGuoLv;

  /// No description provided for @lianTongXing.
  ///
  /// In zh, this message translates to:
  /// **'连通性'**
  String get lianTongXing;

  /// No description provided for @boFang.
  ///
  /// In zh, this message translates to:
  /// **'播放'**
  String get boFang;

  /// No description provided for @zanWuRiZhi.
  ///
  /// In zh, this message translates to:
  /// **'暂无日志'**
  String get zanWuRiZhi;

  /// No description provided for @yiFuZhiGaiTiao.
  ///
  /// In zh, this message translates to:
  /// **'已复制该条'**
  String get yiFuZhiGaiTiao;

  /// No description provided for @yiKaiQiShiShiTanCe.
  ///
  /// In zh, this message translates to:
  /// **'已开启实时探测'**
  String get yiKaiQiShiShiTanCe;

  /// No description provided for @wangLuoQingQiuRiZhi.
  ///
  /// In zh, this message translates to:
  /// **'网络请求日志'**
  String get wangLuoQingQiuRiZhi;

  /// No description provided for @ceShiWangLuo.
  ///
  /// In zh, this message translates to:
  /// **'测试网络'**
  String get ceShiWangLuo;

  /// No description provided for @qingQiu.
  ///
  /// In zh, this message translates to:
  /// **'请求'**
  String get qingQiu;

  /// No description provided for @xiangYing.
  ///
  /// In zh, this message translates to:
  /// **'响应'**
  String get xiangYing;

  /// No description provided for @cuoWu.
  ///
  /// In zh, this message translates to:
  /// **'错误'**
  String get cuoWu;

  /// No description provided for @fuZhiQuanBu.
  ///
  /// In zh, this message translates to:
  /// **'复制全部'**
  String get fuZhiQuanBu;

  /// No description provided for @qingKongRiZhi.
  ///
  /// In zh, this message translates to:
  /// **'清空日志'**
  String get qingKongRiZhi;

  /// No description provided for @shiShiTanCe.
  ///
  /// In zh, this message translates to:
  /// **'实时探测'**
  String get shiShiTanCe;

  /// No description provided for @fuZhiCiTiao.
  ///
  /// In zh, this message translates to:
  /// **'复制此条'**
  String get fuZhiCiTiao;

  /// No description provided for @cuoWuXinXi.
  ///
  /// In zh, this message translates to:
  /// **'错误信息'**
  String get cuoWuXinXi;

  /// No description provided for @jingDianXuanFu.
  ///
  /// In zh, this message translates to:
  /// **'经典悬浮'**
  String get jingDianXuanFu;

  /// No description provided for @kuGouLv.
  ///
  /// In zh, this message translates to:
  /// **'酷狗绿'**
  String get kuGouLv;

  /// No description provided for @wangYiYunHong.
  ///
  /// In zh, this message translates to:
  /// **'网易云红'**
  String get wangYiYunHong;

  /// No description provided for @riLuoJu.
  ///
  /// In zh, this message translates to:
  /// **'日落橘'**
  String get riLuoJu;

  /// No description provided for @saiBoZi.
  ///
  /// In zh, this message translates to:
  /// **'赛博紫'**
  String get saiBoZi;

  /// No description provided for @shenSeKaPian.
  ///
  /// In zh, this message translates to:
  /// **'深色卡片'**
  String get shenSeKaPian;

  /// No description provided for @shuiMoHei.
  ///
  /// In zh, this message translates to:
  /// **'水墨黑'**
  String get shuiMoHei;

  /// No description provided for @jieSuo.
  ///
  /// In zh, this message translates to:
  /// **'解锁'**
  String get jieSuo;

  /// No description provided for @shangYiShou.
  ///
  /// In zh, this message translates to:
  /// **'上一首'**
  String get shangYiShou;

  /// No description provided for @xiaYiShou.
  ///
  /// In zh, this message translates to:
  /// **'下一首'**
  String get xiaYiShou;

  /// No description provided for @suoDing.
  ///
  /// In zh, this message translates to:
  /// **'锁定'**
  String get suoDing;

  /// No description provided for @geDanJiaZaiShiBaiQingJianChaWangLuoHouChongShi.
  ///
  /// In zh, this message translates to:
  /// **'歌单加载失败，请检查网络后重试'**
  String get geDanJiaZaiShiBaiQingJianChaWangLuoHouChongShi;

  /// No description provided for @xinDieJiaZaiShiBaiQingJianChaWangLuoHouChongShi.
  ///
  /// In zh, this message translates to:
  /// **'新碟加载失败，请检查网络后重试'**
  String get xinDieJiaZaiShiBaiQingJianChaWangLuoHouChongShi;

  /// No description provided for @xinGeJiaZaiShiBaiQingJianChaWangLuoHouChongShi.
  ///
  /// In zh, this message translates to:
  /// **'新歌加载失败，请检查网络后重试'**
  String get xinGeJiaZaiShiBaiQingJianChaWangLuoHouChongShi;

  /// No description provided for @geShouJiaZaiShiBaiQingJianChaWangLuoHouChongShi.
  ///
  /// In zh, this message translates to:
  /// **'歌手加载失败，请检查网络后重试'**
  String get geShouJiaZaiShiBaiQingJianChaWangLuoHouChongShi;

  /// No description provided for @tanSuoFaXian.
  ///
  /// In zh, this message translates to:
  /// **'探索发现'**
  String get tanSuoFaXian;

  /// No description provided for @zanWuGeDan.
  ///
  /// In zh, this message translates to:
  /// **'暂无歌单'**
  String get zanWuGeDan;

  /// No description provided for @dangQianWangLuoBeiWangGuanLanJieUrlGuoLvWuFaFang_3.
  ///
  /// In zh, this message translates to:
  /// **'当前网络被网关拦截（URL过滤），无法访问该音源。\n请换手机热点 / 关闭路由器「上网行为管理」后重试。'**
  String get dangQianWangLuoBeiWangGuanLanJieUrlGuoLvWuFaFang_3;

  /// No description provided for @jieKouJuJueFangWenAccessDenyShaoHouChongShiHuoJi.
  ///
  /// In zh, this message translates to:
  /// **'接口拒绝访问（Access Deny）。\n稍后重试，或检查是否触发风控。'**
  String get jieKouJuJueFangWenAccessDenyShaoHouChongShiHuoJi;

  /// No description provided for @shuJuJiaZaiShiBaiQingJianChaWangLuoHouChongShi.
  ///
  /// In zh, this message translates to:
  /// **'数据加载失败，请检查网络后重试'**
  String get shuJuJiaZaiShiBaiQingJianChaWangLuoHouChongShi;

  /// No description provided for @lingChenHao.
  ///
  /// In zh, this message translates to:
  /// **'凌晨好'**
  String get lingChenHao;

  /// No description provided for @zaoShangHao.
  ///
  /// In zh, this message translates to:
  /// **'早上好'**
  String get zaoShangHao;

  /// No description provided for @xiaWuHao.
  ///
  /// In zh, this message translates to:
  /// **'下午好'**
  String get xiaWuHao;

  /// No description provided for @wanShangHao.
  ///
  /// In zh, this message translates to:
  /// **'晚上好'**
  String get wanShangHao;

  /// No description provided for @faXianHaoYinLeWeiNiJingXuanJinRiXuanLv.
  ///
  /// In zh, this message translates to:
  /// **'发现好音乐 · 为你精选今日旋律'**
  String get faXianHaoYinLeWeiNiJingXuanJinRiXuanLv;

  /// No description provided for @gengDuo.
  ///
  /// In zh, this message translates to:
  /// **'更多'**
  String get gengDuo;

  /// No description provided for @jinRiReGe.
  ///
  /// In zh, this message translates to:
  /// **'今日热歌'**
  String get jinRiReGe;

  /// No description provided for @targetJianSuo.
  ///
  /// In zh, this message translates to:
  /// **'TARGET // 检索'**
  String get targetJianSuo;

  /// No description provided for @diShiWuYeYinLvBuWan.
  ///
  /// In zh, this message translates to:
  /// **'第拾伍夜·音律补完'**
  String get diShiWuYeYinLvBuWan;

  /// No description provided for @yiJiaRuWoXiHuan.
  ///
  /// In zh, this message translates to:
  /// **'已加入我喜欢'**
  String get yiJiaRuWoXiHuan;

  /// No description provided for @tan.
  ///
  /// In zh, this message translates to:
  /// **'探'**
  String get tan;

  /// No description provided for @yinLvTanSuo.
  ///
  /// In zh, this message translates to:
  /// **'音律探索'**
  String get yinLvTanSuo;

  /// No description provided for @geDanBangDanXinDieGeShouArchive.
  ///
  /// In zh, this message translates to:
  /// **'歌单 · 榜单 · 新碟 · 歌手 // ARCHIVE'**
  String get geDanBangDanXinDieGeShouArchive;

  /// No description provided for @tanSuo.
  ///
  /// In zh, this message translates to:
  /// **'探索'**
  String get tanSuo;

  /// No description provided for @geDanBangDanXinDieGeShou.
  ///
  /// In zh, this message translates to:
  /// **'歌单 · 榜单 · 新碟 · 歌手'**
  String get geDanBangDanXinDieGeShou;

  /// No description provided for @weiNiTuiJian.
  ///
  /// In zh, this message translates to:
  /// **'为你推荐'**
  String get weiNiTuiJian;

  /// No description provided for @meiRiFengGeGeDanJingXuanDailySync.
  ///
  /// In zh, this message translates to:
  /// **'每日 · 风格 · 歌单精选 // DAILY SYNC'**
  String get meiRiFengGeGeDanJingXuanDailySync;

  /// No description provided for @meiRiFengGeGeDanJingXuan.
  ///
  /// In zh, this message translates to:
  /// **'每日 · 风格 · 歌单精选'**
  String get meiRiFengGeGeDanJingXuan;

  /// No description provided for @meiYouKeYongDeSiRenFmYinYuanQingDaoSheZhiLiKaiQi.
  ///
  /// In zh, this message translates to:
  /// **'没有可用的私人 FM 音源，请到设置里开启'**
  String get meiYouKeYongDeSiRenFmYinYuanQingDaoSheZhiLiKaiQi;

  /// No description provided for @fmGeChiJiaZaiShiBaiQingJianChaWangLuo.
  ///
  /// In zh, this message translates to:
  /// **'FM 歌池加载失败，请检查网络'**
  String get fmGeChiJiaZaiShiBaiQingJianChaWangLuo;

  /// No description provided for @dangQianYinYuanBuZhiChiSiRenFm.
  ///
  /// In zh, this message translates to:
  /// **'当前音源不支持私人 FM'**
  String get dangQianYinYuanBuZhiChiSiRenFm;

  /// No description provided for @siRenFmJiaZaiShiBaiQingJianChaWangLuo.
  ///
  /// In zh, this message translates to:
  /// **'私人 FM 加载失败，请检查网络'**
  String get siRenFmJiaZaiShiBaiQingJianChaWangLuo;

  /// No description provided for @kaiShiDianTai.
  ///
  /// In zh, this message translates to:
  /// **'开始电台'**
  String get kaiShiDianTai;

  /// No description provided for @liJiShengXiao.
  ///
  /// In zh, this message translates to:
  /// **'立即生效'**
  String get liJiShengXiao;

  /// No description provided for @dangQianBoFang.
  ///
  /// In zh, this message translates to:
  /// **'当前播放'**
  String get dangQianBoFang;

  /// No description provided for @shangWeiKaiShiDianTai.
  ///
  /// In zh, this message translates to:
  /// **'尚未开始电台'**
  String get shangWeiKaiShiDianTai;

  /// No description provided for @jieXiaLai.
  ///
  /// In zh, this message translates to:
  /// **'接下来'**
  String get jieXiaLai;

  /// No description provided for @geChiJianDiLeHuanGeMoShiHuoGeChiShiShi.
  ///
  /// In zh, this message translates to:
  /// **'歌池见底了，换个模式或歌池试试'**
  String get geChiJianDiLeHuanGeMoShiHuoGeChiShiShi;

  /// No description provided for @buXiHuan.
  ///
  /// In zh, this message translates to:
  /// **'不喜欢'**
  String get buXiHuan;

  /// No description provided for @yiCongBoFangLiShiZhongYiChu.
  ///
  /// In zh, this message translates to:
  /// **'已从播放历史中移除'**
  String get yiCongBoFangLiShiZhongYiChu;

  /// No description provided for @cheXiao.
  ///
  /// In zh, this message translates to:
  /// **'撤销'**
  String get cheXiao;

  /// No description provided for @qingKongBoFangLiShi.
  ///
  /// In zh, this message translates to:
  /// **'清空播放历史'**
  String get qingKongBoFangLiShi;

  /// No description provided for @queDingYaoQingKongQuanBuBoFangLiShiMaCiCaoZuoWuF.
  ///
  /// In zh, this message translates to:
  /// **'确定要清空全部播放历史吗？此操作无法撤销。'**
  String get queDingYaoQingKongQuanBuBoFangLiShiMaCiCaoZuoWuF;

  /// No description provided for @boFangLiShiYiQingKong.
  ///
  /// In zh, this message translates to:
  /// **'播放历史已清空'**
  String get boFangLiShiYiQingKong;

  /// No description provided for @souSuoLiShiGeQuGeShou.
  ///
  /// In zh, this message translates to:
  /// **'搜索历史歌曲、歌手...'**
  String get souSuoLiShiGeQuGeShou;

  /// No description provided for @boFangLiShi.
  ///
  /// In zh, this message translates to:
  /// **'播放历史'**
  String get boFangLiShi;

  /// No description provided for @souSuoLiShi.
  ///
  /// In zh, this message translates to:
  /// **'搜索历史'**
  String get souSuoLiShi;

  /// No description provided for @qingKongLiShi.
  ///
  /// In zh, this message translates to:
  /// **'清空历史'**
  String get qingKongLiShi;

  /// No description provided for @boFangJiLu.
  ///
  /// In zh, this message translates to:
  /// **'播放记录'**
  String get boFangJiLu;

  /// No description provided for @tingGeTongJi.
  ///
  /// In zh, this message translates to:
  /// **'听歌统计'**
  String get tingGeTongJi;

  /// No description provided for @haiMeiYouBoFangJiLuQuSouSuoTingYiShouBa.
  ///
  /// In zh, this message translates to:
  /// **'还没有播放记录\n去搜索听一首吧'**
  String get haiMeiYouBoFangJiLuQuSouSuoTingYiShouBa;

  /// No description provided for @weiZhaoDaoPiPeiDeBoFangJiLu.
  ///
  /// In zh, this message translates to:
  /// **'未找到匹配的播放记录'**
  String get weiZhaoDaoPiPeiDeBoFangJiLu;

  /// No description provided for @congLiShiYiChu.
  ///
  /// In zh, this message translates to:
  /// **'从历史移除'**
  String get congLiShiYiChu;

  /// No description provided for @zanWuTingGeShuJuTingJiShouGeHouZaiLaiKanKanFenXi.
  ///
  /// In zh, this message translates to:
  /// **'暂无听歌数据\n听几首歌后再来看看分析吧'**
  String get zanWuTingGeShuJuTingJiShouGeHouZaiLaiKanKanFenXi;

  /// No description provided for @n6TianQian.
  ///
  /// In zh, this message translates to:
  /// **'6天前'**
  String get n6TianQian;

  /// No description provided for @n5TianQian.
  ///
  /// In zh, this message translates to:
  /// **'5天前'**
  String get n5TianQian;

  /// No description provided for @n4TianQian.
  ///
  /// In zh, this message translates to:
  /// **'4天前'**
  String get n4TianQian;

  /// No description provided for @n3TianQian.
  ///
  /// In zh, this message translates to:
  /// **'3天前'**
  String get n3TianQian;

  /// No description provided for @qianTian.
  ///
  /// In zh, this message translates to:
  /// **'前天'**
  String get qianTian;

  /// No description provided for @zuoTian.
  ///
  /// In zh, this message translates to:
  /// **'昨天'**
  String get zuoTian;

  /// No description provided for @jinTian.
  ///
  /// In zh, this message translates to:
  /// **'今天'**
  String get jinTian;

  /// No description provided for @liShiQuMu.
  ///
  /// In zh, this message translates to:
  /// **'历史曲目'**
  String get liShiQuMu;

  /// No description provided for @yuGuShiChang.
  ///
  /// In zh, this message translates to:
  /// **'预估时长'**
  String get yuGuShiChang;

  /// No description provided for @jin7TianTingGePinCi.
  ///
  /// In zh, this message translates to:
  /// **'近 7 天听歌频次'**
  String get jin7TianTingGePinCi;

  /// No description provided for @tingGeShiDuanPianHao.
  ///
  /// In zh, this message translates to:
  /// **'听歌时段偏好'**
  String get tingGeShiDuanPianHao;

  /// No description provided for @lingChen00000559.
  ///
  /// In zh, this message translates to:
  /// **'凌晨 (00:00 - 05:59)'**
  String get lingChen00000559;

  /// No description provided for @shangWu06001159.
  ///
  /// In zh, this message translates to:
  /// **'上午 (06:00 - 11:59)'**
  String get shangWu06001159;

  /// No description provided for @xiaWu12001759.
  ///
  /// In zh, this message translates to:
  /// **'下午 (12:00 - 17:59)'**
  String get xiaWu12001759;

  /// No description provided for @yeWan18002359.
  ///
  /// In zh, this message translates to:
  /// **'夜晚 (18:00 - 23:59)'**
  String get yeWan18002359;

  /// No description provided for @changTingGeShouTopBang.
  ///
  /// In zh, this message translates to:
  /// **'常听歌手 TOP 榜'**
  String get changTingGeShouTopBang;

  /// No description provided for @moRenPaiXu.
  ///
  /// In zh, this message translates to:
  /// **'默认排序'**
  String get moRenPaiXu;

  /// No description provided for @geQuMing.
  ///
  /// In zh, this message translates to:
  /// **'歌曲名'**
  String get geQuMing;

  /// No description provided for @geShouMing.
  ///
  /// In zh, this message translates to:
  /// **'歌手名'**
  String get geShouMing;

  /// No description provided for @souSuoGeMingGeShouZhuanJi.
  ///
  /// In zh, this message translates to:
  /// **'搜索歌名、歌手、专辑...'**
  String get souSuoGeMingGeShouZhuanJi;

  /// No description provided for @souSuoGuanZhuDeGeShou.
  ///
  /// In zh, this message translates to:
  /// **'搜索关注的歌手...'**
  String get souSuoGuanZhuDeGeShou;

  /// No description provided for @souSuoShouCangDeZhuanJiHuoGeShou.
  ///
  /// In zh, this message translates to:
  /// **'搜索收藏的专辑或歌手...'**
  String get souSuoShouCangDeZhuanJiHuoGeShou;

  /// No description provided for @shuaXinWoXiHuanGeQu.
  ///
  /// In zh, this message translates to:
  /// **'刷新我喜欢歌曲'**
  String get shuaXinWoXiHuanGeQu;

  /// No description provided for @paiXuFangShi.
  ///
  /// In zh, this message translates to:
  /// **'排序方式'**
  String get paiXuFangShi;

  /// No description provided for @shuaXinGuanZhuGeShou.
  ///
  /// In zh, this message translates to:
  /// **'刷新关注歌手'**
  String get shuaXinGuanZhuGeShou;

  /// No description provided for @shuaXinShouCangZhuanJi.
  ///
  /// In zh, this message translates to:
  /// **'刷新收藏专辑'**
  String get shuaXinShouCangZhuanJi;

  /// No description provided for @weiZhaoDaoPiPeiDeGeQuHuanGeGuanJianCiShiShi.
  ///
  /// In zh, this message translates to:
  /// **'未找到匹配的歌曲\n换个关键词试试'**
  String get weiZhaoDaoPiPeiDeGeQuHuanGeGuanJianCiShiShi;

  /// No description provided for @yiQuXiaoXiHuan.
  ///
  /// In zh, this message translates to:
  /// **'已取消喜欢'**
  String get yiQuXiaoXiHuan;

  /// No description provided for @quXiaoXiHuan.
  ///
  /// In zh, this message translates to:
  /// **'取消喜欢'**
  String get quXiaoXiHuan;

  /// No description provided for @wangYiYunWoXiHuanHaiMeiYouHongXinGeQuZaiWangYiYu.
  ///
  /// In zh, this message translates to:
  /// **'网易云「我喜欢」还没有红心歌曲\n在网易云点 ♥ 即可同步到此处'**
  String get wangYiYunWoXiHuanHaiMeiYouHongXinGeQuZaiWangYiYu;

  /// No description provided for @bZhanMeiYouYunDuanWoXiHuanHongXinZhiBaoCunZaiBen.
  ///
  /// In zh, this message translates to:
  /// **'B 站没有云端「我喜欢」\n红心只保存在本机'**
  String get bZhanMeiYouYunDuanWoXiHuanHongXinZhiBaoCunZaiBen;

  /// No description provided for @dengLuKuGouZhangHaoHouJiKeTongBuYunDuanWoXiHuan.
  ///
  /// In zh, this message translates to:
  /// **'登录酷狗账号后，即可同步云端「我喜欢」'**
  String get dengLuKuGouZhangHaoHouJiKeTongBuYunDuanWoXiHuan;

  /// No description provided for @haiMeiYouHongXinGeQuBoFangShiDianJiKeShouCangDao.
  ///
  /// In zh, this message translates to:
  /// **'还没有红心歌曲\n播放时点 ♥ 即可收藏到云端'**
  String get haiMeiYouHongXinGeQuBoFangShiDianJiKeShouCangDao;

  /// No description provided for @liJiDengLu.
  ///
  /// In zh, this message translates to:
  /// **'立即登录'**
  String get liJiDengLu;

  /// No description provided for @dengLuKuGouZhangHaoHouJiKeTongBuGuanZhuDeGeShou.
  ///
  /// In zh, this message translates to:
  /// **'登录酷狗账号后，即可同步关注的歌手'**
  String get dengLuKuGouZhangHaoHouJiKeTongBuGuanZhuDeGeShou;

  /// No description provided for @zanWuGuanZhuDeGeShouSouSuoGeShouBingDianJiGuanZh.
  ///
  /// In zh, this message translates to:
  /// **'暂无关注的歌手\n搜索歌手并点击关注即可在此查看'**
  String get zanWuGuanZhuDeGeShouSouSuoGeShouBingDianJiGuanZh;

  /// No description provided for @weiZhaoDaoPiPeiDeGeShou.
  ///
  /// In zh, this message translates to:
  /// **'未找到匹配的歌手'**
  String get weiZhaoDaoPiPeiDeGeShou;

  /// No description provided for @dengLuKuGouZhangHaoHouJiKeTongBuShouCangDeZhuanJ.
  ///
  /// In zh, this message translates to:
  /// **'登录酷狗账号后，即可同步收藏的专辑'**
  String get dengLuKuGouZhangHaoHouJiKeTongBuShouCangDeZhuanJ;

  /// No description provided for @zanWuShouCangDeZhuanJiZaiZhuanJiXiangQingZhongDi.
  ///
  /// In zh, this message translates to:
  /// **'暂无收藏的专辑\n在专辑详情中点击收藏即可在此查看'**
  String get zanWuShouCangDeZhuanJiZaiZhuanJiXiangQingZhongDi;

  /// No description provided for @weiZhaoDaoPiPeiDeZhuanJi.
  ///
  /// In zh, this message translates to:
  /// **'未找到匹配的专辑'**
  String get weiZhaoDaoPiPeiDeZhuanJi;

  /// No description provided for @xuDengLuHouChaKan.
  ///
  /// In zh, this message translates to:
  /// **'需登录后查看'**
  String get xuDengLuHouChaKan;

  /// No description provided for @danMuYiGuanBiSheZhiYuFaSong.
  ///
  /// In zh, this message translates to:
  /// **'弹幕已关闭 · 设置与发送'**
  String get danMuYiGuanBiSheZhiYuFaSong;

  /// No description provided for @dangQianYinYuanBuZhiChiDanMu.
  ///
  /// In zh, this message translates to:
  /// **'当前音源不支持弹幕'**
  String get dangQianYinYuanBuZhiChiDanMu;

  /// No description provided for @danMuYiFaSong.
  ///
  /// In zh, this message translates to:
  /// **'弹幕已发送'**
  String get danMuYiFaSong;

  /// No description provided for @yiGuanBi.
  ///
  /// In zh, this message translates to:
  /// **'已关闭'**
  String get yiGuanBi;

  /// No description provided for @touMingDu.
  ///
  /// In zh, this message translates to:
  /// **'透明度'**
  String get touMingDu;

  /// No description provided for @ziHao.
  ///
  /// In zh, this message translates to:
  /// **'字号'**
  String get ziHao;

  /// No description provided for @suDu.
  ///
  /// In zh, this message translates to:
  /// **'速度'**
  String get suDu;

  /// No description provided for @miDu.
  ///
  /// In zh, this message translates to:
  /// **'密度'**
  String get miDu;

  /// No description provided for @xiShu.
  ///
  /// In zh, this message translates to:
  /// **'稀疏'**
  String get xiShu;

  /// No description provided for @shiZhong.
  ///
  /// In zh, this message translates to:
  /// **'适中'**
  String get shiZhong;

  /// No description provided for @miJi.
  ///
  /// In zh, this message translates to:
  /// **'密集'**
  String get miJi;

  /// No description provided for @xianShiQuYu.
  ///
  /// In zh, this message translates to:
  /// **'显示区域'**
  String get xianShiQuYu;

  /// No description provided for @dingBu.
  ///
  /// In zh, this message translates to:
  /// **'顶部'**
  String get dingBu;

  /// No description provided for @shangBanPing.
  ///
  /// In zh, this message translates to:
  /// **'上半屏'**
  String get shangBanPing;

  /// No description provided for @quanPing.
  ///
  /// In zh, this message translates to:
  /// **'全屏'**
  String get quanPing;

  /// No description provided for @faSongDanMu.
  ///
  /// In zh, this message translates to:
  /// **'发送弹幕'**
  String get faSongDanMu;

  /// No description provided for @xieXiaCiKeDeGanShou.
  ///
  /// In zh, this message translates to:
  /// **'写下此刻的感受…'**
  String get xieXiaCiKeDeGanShou;

  /// No description provided for @faSongHouKaiQiDanMuJiKeZaiHuaMianShangKanDao.
  ///
  /// In zh, this message translates to:
  /// **'发送后开启弹幕即可在画面上看到'**
  String get faSongHouKaiQiDanMuJiKeZaiHuaMianShangKanDao;

  /// No description provided for @faSong.
  ///
  /// In zh, this message translates to:
  /// **'发送'**
  String get faSong;

  /// No description provided for @danMuJiaZaiZhong.
  ///
  /// In zh, this message translates to:
  /// **'弹幕加载中…'**
  String get danMuJiaZaiZhong;

  /// No description provided for @zanWuDanMu.
  ///
  /// In zh, this message translates to:
  /// **'暂无弹幕'**
  String get zanWuDanMu;

  /// No description provided for @dangQianYinYuanBuZhiChiMv.
  ///
  /// In zh, this message translates to:
  /// **'当前音源不支持 MV'**
  String get dangQianYinYuanBuZhiChiMv;

  /// No description provided for @meiYouKeYongDeShiPinPianYuan.
  ///
  /// In zh, this message translates to:
  /// **'没有可用的视频片源'**
  String get meiYouKeYongDeShiPinPianYuan;

  /// No description provided for @mvJiaZaiShiBai.
  ///
  /// In zh, this message translates to:
  /// **'MV 加载失败'**
  String get mvJiaZaiShiBai;

  /// No description provided for @zheShouGeZanWuMv.
  ///
  /// In zh, this message translates to:
  /// **'这首歌暂无 MV'**
  String get zheShouGeZanWuMv;

  /// No description provided for @boFangMv.
  ///
  /// In zh, this message translates to:
  /// **'播放 MV'**
  String get boFangMv;

  /// No description provided for @dangQianZhuoMianWuFaJinRuXiaoChuangJiXuQuanYeBoF.
  ///
  /// In zh, this message translates to:
  /// **'当前桌面无法进入小窗，继续全页播放'**
  String get dangQianZhuoMianWuFaJinRuXiaoChuangJiXuQuanYeBoF;

  /// No description provided for @huanYuanChuangKou.
  ///
  /// In zh, this message translates to:
  /// **'还原窗口'**
  String get huanYuanChuangKou;

  /// No description provided for @tingZhiBingGuanBi.
  ///
  /// In zh, this message translates to:
  /// **'停止并关闭'**
  String get tingZhiBingGuanBi;

  /// No description provided for @suoWeiZhiDingMiNiChuang.
  ///
  /// In zh, this message translates to:
  /// **'缩为置顶迷你窗'**
  String get suoWeiZhiDingMiNiChuang;

  /// No description provided for @suoXiaoWeiXiaoChuang.
  ///
  /// In zh, this message translates to:
  /// **'缩小为小窗'**
  String get suoXiaoWeiXiaoChuang;

  /// No description provided for @zanTing.
  ///
  /// In zh, this message translates to:
  /// **'暂停'**
  String get zanTing;

  /// No description provided for @xiangQing.
  ///
  /// In zh, this message translates to:
  /// **'详情'**
  String get xiangQing;

  /// No description provided for @qiTaBanBen.
  ///
  /// In zh, this message translates to:
  /// **'其他版本'**
  String get qiTaBanBen;

  /// No description provided for @guanFangTuiJian.
  ///
  /// In zh, this message translates to:
  /// **'官方推荐'**
  String get guanFangTuiJian;

  /// No description provided for @shouCangMv.
  ///
  /// In zh, this message translates to:
  /// **'收藏 MV'**
  String get shouCangMv;

  /// No description provided for @yiQuXiaoShouCang.
  ///
  /// In zh, this message translates to:
  /// **'已取消收藏'**
  String get yiQuXiaoShouCang;

  /// No description provided for @shouCang.
  ///
  /// In zh, this message translates to:
  /// **'收藏'**
  String get shouCang;

  /// No description provided for @xiaZai.
  ///
  /// In zh, this message translates to:
  /// **'下载'**
  String get xiaZai;

  /// No description provided for @faXing.
  ///
  /// In zh, this message translates to:
  /// **'发行'**
  String get faXing;

  /// No description provided for @huaZhi.
  ///
  /// In zh, this message translates to:
  /// **'画质'**
  String get huaZhi;

  /// No description provided for @jianJie.
  ///
  /// In zh, this message translates to:
  /// **'简介'**
  String get jianJie;

  /// No description provided for @beiSu.
  ///
  /// In zh, this message translates to:
  /// **'倍速'**
  String get beiSu;

  /// No description provided for @jingYin.
  ///
  /// In zh, this message translates to:
  /// **'静音'**
  String get jingYin;

  /// No description provided for @n10Miao.
  ///
  /// In zh, this message translates to:
  /// **'10 秒'**
  String get n10Miao;

  /// No description provided for @buXiHuanHuanXiaYiShou.
  ///
  /// In zh, this message translates to:
  /// **'不喜欢，换下一首'**
  String get buXiHuanHuanXiaYiShou;

  /// No description provided for @yiJingShiSiRenFmDeDiYiShou.
  ///
  /// In zh, this message translates to:
  /// **'已经是私人 FM 的第一首'**
  String get yiJingShiSiRenFmDeDiYiShou;

  /// No description provided for @guanBiSiRenFmMianBan.
  ///
  /// In zh, this message translates to:
  /// **'关闭私人 FM 面板'**
  String get guanBiSiRenFmMianBan;

  /// No description provided for @shouQi.
  ///
  /// In zh, this message translates to:
  /// **'收起'**
  String get shouQi;

  /// No description provided for @geChiZhengZaiXuJie.
  ///
  /// In zh, this message translates to:
  /// **'歌池正在续接…'**
  String get geChiZhengZaiXuJie;

  /// No description provided for @zanWuBoFangNeiRongQuSouSuoHuoGeDanLiDianYiShouGe.
  ///
  /// In zh, this message translates to:
  /// **'暂无播放内容\n去搜索或歌单里点一首歌'**
  String get zanWuBoFangNeiRongQuSouSuoHuoGeDanLiDianYiShouGe;

  /// No description provided for @shouQiBoFangYe.
  ///
  /// In zh, this message translates to:
  /// **'收起播放页'**
  String get shouQiBoFangYe;

  /// No description provided for @boFangDuiLie.
  ///
  /// In zh, this message translates to:
  /// **'播放队列'**
  String get boFangDuiLie;

  /// No description provided for @zhengZaiBoFang.
  ///
  /// In zh, this message translates to:
  /// **'正在播放'**
  String get zhengZaiBoFang;

  /// No description provided for @gongKai.
  ///
  /// In zh, this message translates to:
  /// **'公开'**
  String get gongKai;

  /// No description provided for @shiShiTongXinRiZhi.
  ///
  /// In zh, this message translates to:
  /// **'实时通信日志'**
  String get shiShiTongXinRiZhi;

  /// No description provided for @zanWuBoFangNeiRong.
  ///
  /// In zh, this message translates to:
  /// **'暂无播放内容'**
  String get zanWuBoFangNeiRong;

  /// No description provided for @shouQiGeCi.
  ///
  /// In zh, this message translates to:
  /// **'收起歌词'**
  String get shouQiGeCi;

  /// No description provided for @boFangShiBaiKeDianXiaYiShouChongShi.
  ///
  /// In zh, this message translates to:
  /// **'播放失败，可点下一首重试'**
  String get boFangShiBaiKeDianXiaYiShouChongShi;

  /// No description provided for @quDengLu.
  ///
  /// In zh, this message translates to:
  /// **'去登录'**
  String get quDengLu;

  /// No description provided for @queShaoGeQuGuanLianIdWuFaChaXunQuKuMv.
  ///
  /// In zh, this message translates to:
  /// **'缺少歌曲关联 ID，无法查询曲库 MV'**
  String get queShaoGeQuGuanLianIdWuFaChaXunQuKuMv;

  /// No description provided for @guanLianShiPinJunBeiPingTaiBiaoJiWeiDuanShiPinWe.
  ///
  /// In zh, this message translates to:
  /// **'关联视频均被平台标记为短视频，未找到可用 MV'**
  String get guanLianShiPinJunBeiPingTaiBiaoJiWeiDuanShiPinWe;

  /// No description provided for @weiZhaoDaoFuHeTiaoJianDeQuKuMv.
  ///
  /// In zh, this message translates to:
  /// **'未找到符合条件的曲库 MV'**
  String get weiZhaoDaoFuHeTiaoJianDeQuKuMv;

  /// No description provided for @quKuMvBoFangDiZhiHuoQuShiBai.
  ///
  /// In zh, this message translates to:
  /// **'曲库 MV 播放地址获取失败'**
  String get quKuMvBoFangDiZhiHuoQuShiBai;

  /// No description provided for @quKuMvChaXunShiBaiQingShaoHouChongShi.
  ///
  /// In zh, this message translates to:
  /// **'曲库 MV 查询失败，请稍后重试'**
  String get quKuMvChaXunShiBaiQingShaoHouChongShi;

  /// No description provided for @shunXuBoFang.
  ///
  /// In zh, this message translates to:
  /// **'顺序播放'**
  String get shunXuBoFang;

  /// No description provided for @lieBiaoXunHuan.
  ///
  /// In zh, this message translates to:
  /// **'列表循环'**
  String get lieBiaoXunHuan;

  /// No description provided for @suiJiBoFang.
  ///
  /// In zh, this message translates to:
  /// **'随机播放'**
  String get suiJiBoFang;

  /// No description provided for @danQuXunHuan.
  ///
  /// In zh, this message translates to:
  /// **'单曲循环'**
  String get danQuXunHuan;

  /// No description provided for @boFangShiBaiYuanBuKeBoVipFangDaoLianWangLuo.
  ///
  /// In zh, this message translates to:
  /// **'播放失败：源不可播（VIP/防盗链/网络）'**
  String get boFangShiBaiYuanBuKeBoVipFangDaoLianWangLuo;

  /// No description provided for @boFangChuCuo.
  ///
  /// In zh, this message translates to:
  /// **'播放出错'**
  String get boFangChuCuo;

  /// No description provided for @moRenShunXu.
  ///
  /// In zh, this message translates to:
  /// **'默认顺序'**
  String get moRenShunXu;

  /// No description provided for @qieHuanBangDan.
  ///
  /// In zh, this message translates to:
  /// **'切换榜单'**
  String get qieHuanBangDan;

  /// No description provided for @zanWuBangDan.
  ///
  /// In zh, this message translates to:
  /// **'暂无榜单'**
  String get zanWuBangDan;

  /// No description provided for @gaiWeiJiangXu.
  ///
  /// In zh, this message translates to:
  /// **'改为降序'**
  String get gaiWeiJiangXu;

  /// No description provided for @wanCheng.
  ///
  /// In zh, this message translates to:
  /// **'完成'**
  String get wanCheng;

  /// No description provided for @souSuoGeMingGeShouZhuanJi_2.
  ///
  /// In zh, this message translates to:
  /// **'搜索歌名、歌手、专辑…'**
  String get souSuoGeMingGeShouZhuanJi_2;

  /// No description provided for @zanWuGeQu.
  ///
  /// In zh, this message translates to:
  /// **'暂无歌曲'**
  String get zanWuGeQu;

  /// No description provided for @meiYouPiPeiDeGeQu.
  ///
  /// In zh, this message translates to:
  /// **'没有匹配的歌曲'**
  String get meiYouPiPeiDeGeQu;

  /// No description provided for @beiJing.
  ///
  /// In zh, this message translates to:
  /// **'北京'**
  String get beiJing;

  /// No description provided for @tianJin.
  ///
  /// In zh, this message translates to:
  /// **'天津'**
  String get tianJin;

  /// No description provided for @heBei.
  ///
  /// In zh, this message translates to:
  /// **'河北'**
  String get heBei;

  /// No description provided for @shanXi.
  ///
  /// In zh, this message translates to:
  /// **'山西'**
  String get shanXi;

  /// No description provided for @neiMengGu.
  ///
  /// In zh, this message translates to:
  /// **'内蒙古'**
  String get neiMengGu;

  /// No description provided for @liaoNing.
  ///
  /// In zh, this message translates to:
  /// **'辽宁'**
  String get liaoNing;

  /// No description provided for @jiLin.
  ///
  /// In zh, this message translates to:
  /// **'吉林'**
  String get jiLin;

  /// No description provided for @heiLongJiang.
  ///
  /// In zh, this message translates to:
  /// **'黑龙江'**
  String get heiLongJiang;

  /// No description provided for @shangHai.
  ///
  /// In zh, this message translates to:
  /// **'上海'**
  String get shangHai;

  /// No description provided for @jiangSu.
  ///
  /// In zh, this message translates to:
  /// **'江苏'**
  String get jiangSu;

  /// No description provided for @zheJiang.
  ///
  /// In zh, this message translates to:
  /// **'浙江'**
  String get zheJiang;

  /// No description provided for @anHui.
  ///
  /// In zh, this message translates to:
  /// **'安徽'**
  String get anHui;

  /// No description provided for @fuJian.
  ///
  /// In zh, this message translates to:
  /// **'福建'**
  String get fuJian;

  /// No description provided for @jiangXi.
  ///
  /// In zh, this message translates to:
  /// **'江西'**
  String get jiangXi;

  /// No description provided for @shanDong.
  ///
  /// In zh, this message translates to:
  /// **'山东'**
  String get shanDong;

  /// No description provided for @heNan.
  ///
  /// In zh, this message translates to:
  /// **'河南'**
  String get heNan;

  /// No description provided for @huBei.
  ///
  /// In zh, this message translates to:
  /// **'湖北'**
  String get huBei;

  /// No description provided for @huNan.
  ///
  /// In zh, this message translates to:
  /// **'湖南'**
  String get huNan;

  /// No description provided for @guangDong.
  ///
  /// In zh, this message translates to:
  /// **'广东'**
  String get guangDong;

  /// No description provided for @guangXi.
  ///
  /// In zh, this message translates to:
  /// **'广西'**
  String get guangXi;

  /// No description provided for @haiNan.
  ///
  /// In zh, this message translates to:
  /// **'海南'**
  String get haiNan;

  /// No description provided for @chongQing.
  ///
  /// In zh, this message translates to:
  /// **'重庆'**
  String get chongQing;

  /// No description provided for @siChuan.
  ///
  /// In zh, this message translates to:
  /// **'四川'**
  String get siChuan;

  /// No description provided for @guiZhou.
  ///
  /// In zh, this message translates to:
  /// **'贵州'**
  String get guiZhou;

  /// No description provided for @yunNan.
  ///
  /// In zh, this message translates to:
  /// **'云南'**
  String get yunNan;

  /// No description provided for @xiZang.
  ///
  /// In zh, this message translates to:
  /// **'西藏'**
  String get xiZang;

  /// No description provided for @shanXi_2.
  ///
  /// In zh, this message translates to:
  /// **'陕西'**
  String get shanXi_2;

  /// No description provided for @ganSu.
  ///
  /// In zh, this message translates to:
  /// **'甘肃'**
  String get ganSu;

  /// No description provided for @qingHai.
  ///
  /// In zh, this message translates to:
  /// **'青海'**
  String get qingHai;

  /// No description provided for @ningXia.
  ///
  /// In zh, this message translates to:
  /// **'宁夏'**
  String get ningXia;

  /// No description provided for @xinJiang.
  ///
  /// In zh, this message translates to:
  /// **'新疆'**
  String get xinJiang;

  /// No description provided for @taiWan.
  ///
  /// In zh, this message translates to:
  /// **'台湾'**
  String get taiWan;

  /// No description provided for @xiangGang.
  ///
  /// In zh, this message translates to:
  /// **'香港'**
  String get xiangGang;

  /// No description provided for @aoMen.
  ///
  /// In zh, this message translates to:
  /// **'澳门'**
  String get aoMen;

  /// No description provided for @weiZhi.
  ///
  /// In zh, this message translates to:
  /// **'未知'**
  String get weiZhi;

  /// No description provided for @heiJiaoVip.
  ///
  /// In zh, this message translates to:
  /// **'黑胶VIP'**
  String get heiJiaoVip;

  /// No description provided for @geRenZhongXin.
  ///
  /// In zh, this message translates to:
  /// **'个人中心'**
  String get geRenZhongXin;

  /// No description provided for @souSuoYuBoFangGongKaiNeiRongWuXuDengLu.
  ///
  /// In zh, this message translates to:
  /// **'搜索与播放公开内容无需登录'**
  String get souSuoYuBoFangGongKaiNeiRongWuXuDengLu;

  /// No description provided for @shou.
  ///
  /// In zh, this message translates to:
  /// **'首'**
  String get shou;

  /// No description provided for @jingYan.
  ///
  /// In zh, this message translates to:
  /// **'经验'**
  String get jingYan;

  /// No description provided for @changTing.
  ///
  /// In zh, this message translates to:
  /// **'畅听'**
  String get changTing;

  /// No description provided for @gaiNian.
  ///
  /// In zh, this message translates to:
  /// **'概念'**
  String get gaiNian;

  /// No description provided for @huiYuan.
  ///
  /// In zh, this message translates to:
  /// **'会员'**
  String get huiYuan;

  /// No description provided for @shengJiJinDu.
  ///
  /// In zh, this message translates to:
  /// **'升级进度'**
  String get shengJiJinDu;

  /// No description provided for @guanZhu.
  ///
  /// In zh, this message translates to:
  /// **'关注'**
  String get guanZhu;

  /// No description provided for @fenSi.
  ///
  /// In zh, this message translates to:
  /// **'粉丝'**
  String get fenSi;

  /// No description provided for @fangKe.
  ///
  /// In zh, this message translates to:
  /// **'访客'**
  String get fangKe;

  /// No description provided for @woDeDengJi.
  ///
  /// In zh, this message translates to:
  /// **'我的等级'**
  String get woDeDengJi;

  /// No description provided for @meiYiCiLingTingDouZaiJiLeiChengZhang.
  ///
  /// In zh, this message translates to:
  /// **'每一次聆听，都在积累成长。'**
  String get meiYiCiLingTingDouZaiJiLeiChengZhang;

  /// No description provided for @dangQianDengJi.
  ///
  /// In zh, this message translates to:
  /// **'当前等级'**
  String get dangQianDengJi;

  /// No description provided for @zanWeiHuoQuDaoXiaYiDengJiJinDu.
  ///
  /// In zh, this message translates to:
  /// **'暂未获取到下一等级进度'**
  String get zanWeiHuoQuDaoXiaYiDengJiJinDu;

  /// No description provided for @dangQianDengJiQuanYi.
  ///
  /// In zh, this message translates to:
  /// **'当前等级权益'**
  String get dangQianDengJiQuanYi;

  /// No description provided for @zhangHaoDangAn.
  ///
  /// In zh, this message translates to:
  /// **'账号档案'**
  String get zhangHaoDangAn;

  /// No description provided for @yongHuId.
  ///
  /// In zh, this message translates to:
  /// **'用户 ID'**
  String get yongHuId;

  /// No description provided for @xingBie.
  ///
  /// In zh, this message translates to:
  /// **'性别'**
  String get xingBie;

  /// No description provided for @leLing.
  ///
  /// In zh, this message translates to:
  /// **'乐龄'**
  String get leLing;

  /// No description provided for @leiJiTingGe.
  ///
  /// In zh, this message translates to:
  /// **'累计听歌'**
  String get leiJiTingGe;

  /// No description provided for @suoZaiDiQu.
  ///
  /// In zh, this message translates to:
  /// **'所在地区'**
  String get suoZaiDiQu;

  /// No description provided for @huiYuanZhuangTai.
  ///
  /// In zh, this message translates to:
  /// **'会员状态'**
  String get huiYuanZhuangTai;

  /// No description provided for @changTingHuiYuan.
  ///
  /// In zh, this message translates to:
  /// **'畅听会员'**
  String get changTingHuiYuan;

  /// No description provided for @gaiNianHuiYuan.
  ///
  /// In zh, this message translates to:
  /// **'概念会员'**
  String get gaiNianHuiYuan;

  /// No description provided for @zhengZaiHuoQuZhangHaoXinXi.
  ///
  /// In zh, this message translates to:
  /// **'正在获取账号信息…'**
  String get zhengZaiHuoQuZhangHaoXinXi;

  /// No description provided for @yunBei.
  ///
  /// In zh, this message translates to:
  /// **'云贝'**
  String get yunBei;

  /// No description provided for @ziJianGeDan.
  ///
  /// In zh, this message translates to:
  /// **'自建歌单'**
  String get ziJianGeDan;

  /// No description provided for @weiKaiTong.
  ///
  /// In zh, this message translates to:
  /// **'未开通'**
  String get weiKaiTong;

  /// No description provided for @sheZhi.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get sheZhi;

  /// No description provided for @heiJiaoHuiYuan.
  ///
  /// In zh, this message translates to:
  /// **'黑胶会员'**
  String get heiJiaoHuiYuan;

  /// No description provided for @yiDengLuChaKanGeRenZhongXin.
  ///
  /// In zh, this message translates to:
  /// **'已登录 · 查看个人中心'**
  String get yiDengLuChaKanGeRenZhongXin;

  /// No description provided for @weiDengLuGongKaiNeiRongKeYong.
  ///
  /// In zh, this message translates to:
  /// **'未登录 · 公开内容可用'**
  String get weiDengLuGongKaiNeiRongKeYong;

  /// No description provided for @zanBuZhiChi.
  ///
  /// In zh, this message translates to:
  /// **'暂不支持'**
  String get zanBuZhiChi;

  /// No description provided for @woDe.
  ///
  /// In zh, this message translates to:
  /// **'我的'**
  String get woDe;

  /// No description provided for @zuiJinBoFang.
  ///
  /// In zh, this message translates to:
  /// **'最近播放'**
  String get zuiJinBoFang;

  /// No description provided for @woDeGeDan.
  ///
  /// In zh, this message translates to:
  /// **'我的歌单'**
  String get woDeGeDan;

  /// No description provided for @shuaXinGeDan.
  ///
  /// In zh, this message translates to:
  /// **'刷新歌单'**
  String get shuaXinGeDan;

  /// No description provided for @gengDuoSheZhi.
  ///
  /// In zh, this message translates to:
  /// **'更多设置'**
  String get gengDuoSheZhi;

  /// No description provided for @dingShiTingZhi.
  ///
  /// In zh, this message translates to:
  /// **'定时停止'**
  String get dingShiTingZhi;

  /// No description provided for @yinZhiSheZhi.
  ///
  /// In zh, this message translates to:
  /// **'音质设置'**
  String get yinZhiSheZhi;

  /// No description provided for @zhuTiWaiGuan.
  ///
  /// In zh, this message translates to:
  /// **'主题外观'**
  String get zhuTiWaiGuan;

  /// No description provided for @guanYu.
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get guanYu;

  /// No description provided for @zanWuShouCangGeDan.
  ///
  /// In zh, this message translates to:
  /// **'暂无收藏歌单'**
  String get zanWuShouCangGeDan;

  /// No description provided for @shenSe.
  ///
  /// In zh, this message translates to:
  /// **'深色'**
  String get shenSe;

  /// No description provided for @gaiNianBanMoRenShenSe.
  ///
  /// In zh, this message translates to:
  /// **'概念版默认深色'**
  String get gaiNianBanMoRenShenSe;

  /// No description provided for @qianSe.
  ///
  /// In zh, this message translates to:
  /// **'浅色'**
  String get qianSe;

  /// No description provided for @qianSeWanZhengShiPei.
  ///
  /// In zh, this message translates to:
  /// **'浅色完整适配'**
  String get qianSeWanZhengShiPei;

  /// No description provided for @genSuiXiTong.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get genSuiXiTong;

  /// No description provided for @suiXiTongShenQianSeQieHuan.
  ///
  /// In zh, this message translates to:
  /// **'随系统深浅色切换'**
  String get suiXiTongShenQianSeQieHuan;

  /// No description provided for @baoMi.
  ///
  /// In zh, this message translates to:
  /// **'保密'**
  String get baoMi;

  /// No description provided for @yiGuoQi.
  ///
  /// In zh, this message translates to:
  /// **'已过期'**
  String get yiGuoQi;

  /// No description provided for @jiJiangDaoQi.
  ///
  /// In zh, this message translates to:
  /// **'即将到期'**
  String get jiJiangDaoQi;

  /// No description provided for @tuiChu.
  ///
  /// In zh, this message translates to:
  /// **'退出'**
  String get tuiChu;

  /// No description provided for @paiHangBangJiaZaiShiBaiQingJianChaWangLuoHouChon.
  ///
  /// In zh, this message translates to:
  /// **'排行榜加载失败，请检查网络后重试'**
  String get paiHangBangJiaZaiShiBaiQingJianChaWangLuoHouChon;

  /// No description provided for @weiNiLiangShenDingZhiDeMeiRiGeDan.
  ///
  /// In zh, this message translates to:
  /// **'为你量身定制的每日歌单'**
  String get weiNiLiangShenDingZhiDeMeiRiGeDan;

  /// No description provided for @dengLuHouChaKanJinRiTuiJian.
  ///
  /// In zh, this message translates to:
  /// **'登录后查看今日推荐'**
  String get dengLuHouChaKanJinRiTuiJian;

  /// No description provided for @jinRiGongKaiGeDan.
  ///
  /// In zh, this message translates to:
  /// **'今日公开歌单'**
  String get jinRiGongKaiGeDan;

  /// No description provided for @zhengZaiWeiNiDingZhiTuiJian.
  ///
  /// In zh, this message translates to:
  /// **'正在为你定制推荐...'**
  String get zhengZaiWeiNiDingZhiTuiJian;

  /// No description provided for @quDengLuHuoQuGeXingHuaMeiRiTuiJian.
  ///
  /// In zh, this message translates to:
  /// **'去登录，获取个性化每日推荐'**
  String get quDengLuHuoQuGeXingHuaMeiRiTuiJian;

  /// No description provided for @jinRiZanWuTuiJian.
  ///
  /// In zh, this message translates to:
  /// **'今日暂无推荐'**
  String get jinRiZanWuTuiJian;

  /// No description provided for @fengGeGeDanJiaZaiShiBaiQingJianChaWangLuoHouChon.
  ///
  /// In zh, this message translates to:
  /// **'风格歌单加载失败，请检查网络后重试'**
  String get fengGeGeDanJiaZaiShiBaiQingJianChaWangLuoHouChon;

  /// No description provided for @tuiJianGeDanJiaZaiShiBaiQingJianChaWangLuoHouCho.
  ///
  /// In zh, this message translates to:
  /// **'推荐歌单加载失败，请检查网络后重试'**
  String get tuiJianGeDanJiaZaiShiBaiQingJianChaWangLuoHouCho;

  /// No description provided for @bianJiJingXuanJiaZaiShiBaiQingJianChaWangLuoHouC.
  ///
  /// In zh, this message translates to:
  /// **'编辑精选加载失败，请检查网络后重试'**
  String get bianJiJingXuanJiaZaiShiBaiQingJianChaWangLuoHouC;

  /// No description provided for @moRenTuiJian.
  ///
  /// In zh, this message translates to:
  /// **'默认推荐'**
  String get moRenTuiJian;

  /// No description provided for @shangWuHao.
  ///
  /// In zh, this message translates to:
  /// **'上午好'**
  String get shangWuHao;

  /// No description provided for @zhongWuHao.
  ///
  /// In zh, this message translates to:
  /// **'中午好'**
  String get zhongWuHao;

  /// No description provided for @youCiKaiQiHaoXinQing.
  ///
  /// In zh, this message translates to:
  /// **'由此开启好心情 ~'**
  String get youCiKaiQiHaoXinQing;

  /// No description provided for @zanWuFengGeGeDan.
  ///
  /// In zh, this message translates to:
  /// **'暂无风格歌单'**
  String get zanWuFengGeGeDan;

  /// No description provided for @zanWuNeiRong.
  ///
  /// In zh, this message translates to:
  /// **'暂无内容'**
  String get zanWuNeiRong;

  /// No description provided for @weiNiLiangShenDingZhi.
  ///
  /// In zh, this message translates to:
  /// **'为你量身定制'**
  String get weiNiLiangShenDingZhi;

  /// No description provided for @shiShiReMenQuShi.
  ///
  /// In zh, this message translates to:
  /// **'实时热门趋势'**
  String get shiShiReMenQuShi;

  /// No description provided for @meiYouKeYongYinYuan.
  ///
  /// In zh, this message translates to:
  /// **'没有可用音源'**
  String get meiYouKeYongYinYuan;

  /// No description provided for @souSuoShiBaiQingChongShi.
  ///
  /// In zh, this message translates to:
  /// **'搜索失败，请重试'**
  String get souSuoShiBaiQingChongShi;

  /// No description provided for @qingKongSouSuoLiShi.
  ///
  /// In zh, this message translates to:
  /// **'清空搜索历史'**
  String get qingKongSouSuoLiShi;

  /// No description provided for @queDingYaoQingKongQuanBuSouSuoLiShiMaCiCaoZuoWuF.
  ///
  /// In zh, this message translates to:
  /// **'确定要清空全部搜索历史吗？此操作无法撤销。'**
  String get queDingYaoQingKongQuanBuSouSuoLiShiMaCiCaoZuoWuF;

  /// No description provided for @souSuoGeQuGeDanZhuanJiGeShou.
  ///
  /// In zh, this message translates to:
  /// **'搜索歌曲、歌单、专辑、歌手'**
  String get souSuoGeQuGeDanZhuanJiGeShou;

  /// No description provided for @jiaZaiShiBaiDianJiChongShi.
  ///
  /// In zh, this message translates to:
  /// **'加载失败，点击重试'**
  String get jiaZaiShiBaiDianJiChongShi;

  /// No description provided for @meiYouGengDuoLe.
  ///
  /// In zh, this message translates to:
  /// **'没有更多了'**
  String get meiYouGengDuoLe;

  /// No description provided for @linJunJie.
  ///
  /// In zh, this message translates to:
  /// **'林俊杰'**
  String get linJunJie;

  /// No description provided for @chenYiXun.
  ///
  /// In zh, this message translates to:
  /// **'陈奕迅'**
  String get chenYiXun;

  /// No description provided for @shuoChang.
  ///
  /// In zh, this message translates to:
  /// **'说唱'**
  String get shuoChang;

  /// No description provided for @yueYu.
  ///
  /// In zh, this message translates to:
  /// **'粤语'**
  String get yueYu;

  /// No description provided for @reMenSouSuo.
  ///
  /// In zh, this message translates to:
  /// **'热门搜索'**
  String get reMenSouSuo;

  /// No description provided for @meiCiXunWen.
  ///
  /// In zh, this message translates to:
  /// **'每次询问'**
  String get meiCiXunWen;

  /// No description provided for @zuiXiaoHuaDaoTuoPan.
  ///
  /// In zh, this message translates to:
  /// **'最小化到托盘'**
  String get zuiXiaoHuaDaoTuoPan;

  /// No description provided for @tuiChuYingYong.
  ///
  /// In zh, this message translates to:
  /// **'退出应用'**
  String get tuiChuYingYong;

  /// No description provided for @guanBiShiTanChuTiShiKeGouXuanJiZhuWoDeXuanZe.
  ///
  /// In zh, this message translates to:
  /// **'关闭时弹出提示，可勾选「记住我的选择」'**
  String get guanBiShiTanChuTiShiKeGouXuanJiZhuWoDeXuanZe;

  /// No description provided for @guanBiShiZuiXiaoHuaDaoXiTongTuoPanBuTuiChuYingYo.
  ///
  /// In zh, this message translates to:
  /// **'关闭时最小化到系统托盘，不退出应用'**
  String get guanBiShiZuiXiaoHuaDaoXiTongTuoPanBuTuiChuYingYo;

  /// No description provided for @guanBiShiZhiJieTuiChuYingYong.
  ///
  /// In zh, this message translates to:
  /// **'关闭时直接退出应用'**
  String get guanBiShiZhiJieTuiChuYingYong;

  /// No description provided for @yiQingLiTuPianHuanCunBoFangYuSouSuoLiShi.
  ///
  /// In zh, this message translates to:
  /// **'已清理图片缓存、播放与搜索历史'**
  String get yiQingLiTuPianHuanCunBoFangYuSouSuoLiShi;

  /// No description provided for @waiGuan.
  ///
  /// In zh, this message translates to:
  /// **'外观'**
  String get waiGuan;

  /// No description provided for @shiYanUi.
  ///
  /// In zh, this message translates to:
  /// **'实验UI'**
  String get shiYanUi;

  /// No description provided for @chuangKou.
  ///
  /// In zh, this message translates to:
  /// **'窗口'**
  String get chuangKou;

  /// No description provided for @guanBiZhuChuangKouShi.
  ///
  /// In zh, this message translates to:
  /// **'关闭主窗口时'**
  String get guanBiZhuChuangKouShi;

  /// No description provided for @renWuLanBoFangJinDu.
  ///
  /// In zh, this message translates to:
  /// **'任务栏播放进度'**
  String get renWuLanBoFangJinDu;

  /// No description provided for @zaiRenWuLanAnNiuShangXianShiBoFangJinDuBoFangLvZ.
  ///
  /// In zh, this message translates to:
  /// **'在任务栏按钮上显示播放进度（播放绿 / 暂停黄）'**
  String get zaiRenWuLanAnNiuShangXianShiBoFangJinDuBoFangLvZ;

  /// No description provided for @renWuLanFengMianYuLan.
  ///
  /// In zh, this message translates to:
  /// **'任务栏封面预览'**
  String get renWuLanFengMianYuLan;

  /// No description provided for @xuanTingHeChuangKouQieHuanXianShiFengMianXinXiKa.
  ///
  /// In zh, this message translates to:
  /// **'悬停和窗口切换显示封面信息卡；关闭恢复窗口预览'**
  String get xuanTingHeChuangKouQieHuanXianShiFengMianXinXiKa;

  /// No description provided for @duLiBoKongHengTiao.
  ///
  /// In zh, this message translates to:
  /// **'独立播控横条'**
  String get duLiBoKongHengTiao;

  /// No description provided for @renWuLanShangFangFuTiaoKeTuoDongTuoJinDuHeDiaoYi.
  ///
  /// In zh, this message translates to:
  /// **'任务栏上方浮条，可拖动、拖进度和调音量；全屏时隐藏'**
  String get renWuLanShangFangFuTiaoKeTuoDongTuoJinDuHeDiaoYi;

  /// No description provided for @zhuoMianGeCi.
  ///
  /// In zh, this message translates to:
  /// **'桌面歌词'**
  String get zhuoMianGeCi;

  /// No description provided for @xianShiZhuoMianGeCi.
  ///
  /// In zh, this message translates to:
  /// **'显示桌面歌词'**
  String get xianShiZhuoMianGeCi;

  /// No description provided for @xuanFuChuangXianShiDangQianGeCiKeTuoDongSuoDingD.
  ///
  /// In zh, this message translates to:
  /// **'悬浮窗显示当前歌词，可拖动、锁定点击穿透'**
  String get xuanFuChuangXianShiDangQianGeCiKeTuoDongSuoDingD;

  /// No description provided for @x11DuLiGeCiChuangKeTuoDongHeSuoDingChuanTouWuHeC.
  ///
  /// In zh, this message translates to:
  /// **'X11 独立歌词窗，可拖动和锁定穿透；无合成器时使用歌词卡片'**
  String get x11DuLiGeCiChuangKeTuoDongHeSuoDingChuanTouWuHeC;

  /// No description provided for @duLiXuanFuChuangXianShiDangQianGeCiKeZhiDingSuoD.
  ///
  /// In zh, this message translates to:
  /// **'独立悬浮窗显示当前歌词，可置顶、锁定穿透'**
  String get duLiXuanFuChuangXianShiDangQianGeCiKeZhiDingSuoD;

  /// No description provided for @xuYaoXianShiZaiQiTaYingYongShangCengQuanXianCaiN.
  ///
  /// In zh, this message translates to:
  /// **'需要「显示在其他应用上层」权限才能开悬浮歌词'**
  String get xuYaoXianShiZaiQiTaYingYongShangCengQuanXianCaiN;

  /// No description provided for @suoDingGeCiChuang.
  ///
  /// In zh, this message translates to:
  /// **'锁定歌词窗'**
  String get suoDingGeCiChuang;

  /// No description provided for @suoDingHouDianJiChuanTouDaoXiaCengYingYongBiMian.
  ///
  /// In zh, this message translates to:
  /// **'锁定后点击穿透到下层应用，避免挡住操作'**
  String get suoDingHouDianJiChuanTouDaoXiaCengYingYongBiMian;

  /// No description provided for @dianJiChuanTouDaoXiaCengYingYongBiMianDangZhuCao.
  ///
  /// In zh, this message translates to:
  /// **'点击穿透到下层应用，避免挡住操作'**
  String get dianJiChuanTouDaoXiaCengYingYongBiMianDangZhuCao;

  /// No description provided for @geCiYangShi.
  ///
  /// In zh, this message translates to:
  /// **'歌词样式'**
  String get geCiYangShi;

  /// No description provided for @ziDingYi.
  ///
  /// In zh, this message translates to:
  /// **'自定义'**
  String get ziDingYi;

  /// No description provided for @geCiPianYiQuanJu.
  ///
  /// In zh, this message translates to:
  /// **'歌词偏移（全局）'**
  String get geCiPianYiQuanJu;

  /// No description provided for @yuXiTongShiJianDuiQiBoFangYeGeCiXianShiLiKeAnDan.
  ///
  /// In zh, this message translates to:
  /// **'与系统时间对齐；播放页「歌词显示」里可按当前歌曲再微调'**
  String get yuXiTongShiJianDuiQiBoFangYeGeCiXianShiLiKeAnDan;

  /// No description provided for @tiQian05s.
  ///
  /// In zh, this message translates to:
  /// **'提前 0.5s'**
  String get tiQian05s;

  /// No description provided for @yanHou05s.
  ///
  /// In zh, this message translates to:
  /// **'延后 0.5s'**
  String get yanHou05s;

  /// No description provided for @chongZhiGeCiWeiZhi.
  ///
  /// In zh, this message translates to:
  /// **'重置歌词位置'**
  String get chongZhiGeCiWeiZhi;

  /// No description provided for @huiDaoPingMuDingBuJuZhongLiDingDuan12px.
  ///
  /// In zh, this message translates to:
  /// **'回到屏幕顶部居中（离顶端 12px）'**
  String get huiDaoPingMuDingBuJuZhongLiDingDuan12px;

  /// No description provided for @geCiWeiZhiYiChongZhiWeiDingBuJuZhong.
  ///
  /// In zh, this message translates to:
  /// **'歌词位置已重置为顶部居中'**
  String get geCiWeiZhiYiChongZhiWeiDingBuJuZhong;

  /// No description provided for @moRenYinZhi.
  ///
  /// In zh, this message translates to:
  /// **'默认音质'**
  String get moRenYinZhi;

  /// No description provided for @shiBaiShiChangShiMvYinPin.
  ///
  /// In zh, this message translates to:
  /// **'失败时尝试 MV 音频'**
  String get shiBaiShiChangShiMvYinPin;

  /// No description provided for @yinYuanBuKeYongShiJieYongGeQuGuanLianQuKuMvDeYin.
  ///
  /// In zh, this message translates to:
  /// **'音源不可用时借用歌曲关联曲库 MV 的音轨；音质未知，歌词与时长可能不同步'**
  String get yinYuanBuKeYongShiJieYongGeQuGuanLianQuKuMvDeYin;

  /// No description provided for @geCiYuFengMian.
  ///
  /// In zh, this message translates to:
  /// **'歌词与封面'**
  String get geCiYuFengMian;

  /// No description provided for @suoPingLanYaXianShiGeCi.
  ///
  /// In zh, this message translates to:
  /// **'锁屏/蓝牙显示歌词'**
  String get suoPingLanYaXianShiGeCi;

  /// No description provided for @xiTongMeiTiFuBiaoTiXianShiGeShouDangQianGeCi.
  ///
  /// In zh, this message translates to:
  /// **'系统媒体副标题显示「歌手 · 当前歌词」'**
  String get xiTongMeiTiFuBiaoTiXianShiGeShouDangQianGeCi;

  /// No description provided for @jinWiFiJiaZaiFengMian.
  ///
  /// In zh, this message translates to:
  /// **'仅 Wi-Fi 加载封面'**
  String get jinWiFiJiaZaiFengMian;

  /// No description provided for @zhangHaoGuanLi.
  ///
  /// In zh, this message translates to:
  /// **'账号管理'**
  String get zhangHaoGuanLi;

  /// No description provided for @moRenYinYuan.
  ///
  /// In zh, this message translates to:
  /// **'默认音源'**
  String get moRenYinYuan;

  /// No description provided for @youKeMoShiShuJuJinCunBenJi.
  ///
  /// In zh, this message translates to:
  /// **'游客模式，数据仅存本机'**
  String get youKeMoShiShuJuJinCunBenJi;

  /// No description provided for @saoMaDengLuHouKeTongBuGeDanYuBoFangQuanXian.
  ///
  /// In zh, this message translates to:
  /// **'扫码登录后可同步歌单与播放权限'**
  String get saoMaDengLuHouKeTongBuGeDanYuBoFangQuanXian;

  /// No description provided for @youKeKeBoFangDengLuHouDuQuShouCangJia.
  ///
  /// In zh, this message translates to:
  /// **'游客可播放，登录后读取收藏夹'**
  String get youKeKeBoFangDengLuHouDuQuShouCangJia;

  /// No description provided for @tiaoShi.
  ///
  /// In zh, this message translates to:
  /// **'调试'**
  String get tiaoShi;

  /// No description provided for @qingQiuXiangYingCuoWuCeShiWangLuoShiShiTanCeFuZh.
  ///
  /// In zh, this message translates to:
  /// **'请求/响应/错误 · 测试网络 · 实时探测 · 复制'**
  String get qingQiuXiangYingCuoWuCeShiWangLuoShiShiTanCeFuZh;

  /// No description provided for @huanCun.
  ///
  /// In zh, this message translates to:
  /// **'缓存'**
  String get huanCun;

  /// No description provided for @qingLiTuPianHuanCunYuBoFangSouSuoLiShi.
  ///
  /// In zh, this message translates to:
  /// **'清理图片缓存与播放、搜索历史'**
  String get qingLiTuPianHuanCunYuBoFangSouSuoLiShi;

  /// No description provided for @buYingXiangDengLuYuWoXiHuanDuiLieBenDiFuBenHuiYi.
  ///
  /// In zh, this message translates to:
  /// **'不影响登录与我喜欢；队列本地副本会一并清空'**
  String get buYingXiangDengLuYuWoXiHuanDuiLieBenDiFuBenHuiYi;

  /// No description provided for @zuiHouYiGeYinYuanZhiShaoBaoLiuYiGe.
  ///
  /// In zh, this message translates to:
  /// **'最后一个音源，至少保留一个'**
  String get zuiHouYiGeYinYuanZhiShaoBaoLiuYiGe;

  /// No description provided for @guanBiHouYinCangYinYueYunPanRuKouYuGaiYuanYunPan.
  ///
  /// In zh, this message translates to:
  /// **'关闭后隐藏「音乐云盘」入口与该源云盘'**
  String get guanBiHouYinCangYinYueYunPanRuKouYuGaiYuanYunPan;

  /// No description provided for @zhuTiSe.
  ///
  /// In zh, this message translates to:
  /// **'主题色'**
  String get zhuTiSe;

  /// No description provided for @wu.
  ///
  /// In zh, this message translates to:
  /// **'无'**
  String get wu;

  /// No description provided for @dangQianYinYuanBuZhiChiPingLun.
  ///
  /// In zh, this message translates to:
  /// **'当前音源不支持评论'**
  String get dangQianYinYuanBuZhiChiPingLun;

  /// No description provided for @pingLunYiFaBu.
  ///
  /// In zh, this message translates to:
  /// **'评论已发布'**
  String get pingLunYiFaBu;

  /// No description provided for @huiFuYiFaBu.
  ///
  /// In zh, this message translates to:
  /// **'回复已发布'**
  String get huiFuYiFaBu;

  /// No description provided for @dianZanShiBaiQingShaoHouZaiShi.
  ///
  /// In zh, this message translates to:
  /// **'点赞失败，请稍后再试'**
  String get dianZanShiBaiQingShaoHouZaiShi;

  /// No description provided for @yiJiaRuBoFang.
  ///
  /// In zh, this message translates to:
  /// **'已加入播放'**
  String get yiJiaRuBoFang;

  /// No description provided for @jingCaiPingLun.
  ///
  /// In zh, this message translates to:
  /// **'精彩评论'**
  String get jingCaiPingLun;

  /// No description provided for @meiYouGengDuoPingLunLe.
  ///
  /// In zh, this message translates to:
  /// **'没有更多评论了'**
  String get meiYouGengDuoPingLunLe;

  /// No description provided for @laiYuan.
  ///
  /// In zh, this message translates to:
  /// **'来源'**
  String get laiYuan;

  /// No description provided for @dengLuHouCanYuPingLun.
  ///
  /// In zh, this message translates to:
  /// **'登录后参与评论'**
  String get dengLuHouCanYuPingLun;

  /// No description provided for @kuGouDengLuHuiFu.
  ///
  /// In zh, this message translates to:
  /// **'酷狗登录恢复'**
  String get kuGouDengLuHuiFu;

  /// No description provided for @wangYiYunDengLuHuiFu.
  ///
  /// In zh, this message translates to:
  /// **'网易云登录恢复'**
  String get wangYiYunDengLuHuiFu;

  /// No description provided for @bZhanDengLuHuiFu.
  ///
  /// In zh, this message translates to:
  /// **'B 站登录恢复'**
  String get bZhanDengLuHuiFu;

  /// No description provided for @fanYinBoFang.
  ///
  /// In zh, this message translates to:
  /// **'泛音 播放'**
  String get fanYinBoFang;

  /// No description provided for @zuiXiaoHua.
  ///
  /// In zh, this message translates to:
  /// **'最小化'**
  String get zuiXiaoHua;

  /// No description provided for @zuiDaHua.
  ///
  /// In zh, this message translates to:
  /// **'最大化'**
  String get zuiDaHua;

  /// No description provided for @guanBiFanYin.
  ///
  /// In zh, this message translates to:
  /// **'关闭 泛音'**
  String get guanBiFanYin;

  /// No description provided for @tuiChuYingYongHaiShiZuiXiaoHuaDaoXiTongTuoPanJiX.
  ///
  /// In zh, this message translates to:
  /// **'退出应用，还是最小化到系统托盘继续播放？'**
  String get tuiChuYingYongHaiShiZuiXiaoHuaDaoXiTongTuoPanJiX;

  /// No description provided for @dangQianZhuoMianMeiYouKeYongDeXiTongTuoPanTuiChu.
  ///
  /// In zh, this message translates to:
  /// **'当前桌面没有可用的系统托盘。退出应用，还是保持窗口打开？'**
  String get dangQianZhuoMianMeiYouKeYongDeXiTongTuoPanTuiChu;

  /// No description provided for @jiZhuWoDeXuanZe.
  ///
  /// In zh, this message translates to:
  /// **'记住我的选择'**
  String get jiZhuWoDeXuanZe;

  /// No description provided for @xiaCiGuanBiBuZaiXunWenKeZaiSheZhiZhongXiuGai.
  ///
  /// In zh, this message translates to:
  /// **'下次关闭不再询问，可在设置中修改'**
  String get xiaCiGuanBiBuZaiXunWenKeZaiSheZhiZhongXiuGai;

  /// No description provided for @xuanZeGeQuKaiShiBoFang.
  ///
  /// In zh, this message translates to:
  /// **'选择歌曲开始播放'**
  String get xuanZeGeQuKaiShiBoFang;

  /// No description provided for @xianShiChuangKou.
  ///
  /// In zh, this message translates to:
  /// **'显示窗口'**
  String get xianShiChuangKou;

  /// No description provided for @boFangMoShi.
  ///
  /// In zh, this message translates to:
  /// **'播放模式'**
  String get boFangMoShi;

  /// No description provided for @zengDaYinLiang.
  ///
  /// In zh, this message translates to:
  /// **'增大音量'**
  String get zengDaYinLiang;

  /// No description provided for @jianXiaoYinLiang.
  ///
  /// In zh, this message translates to:
  /// **'减小音量'**
  String get jianXiaoYinLiang;

  /// No description provided for @jiaZaiShiBai.
  ///
  /// In zh, this message translates to:
  /// **'加载失败'**
  String get jiaZaiShiBai;

  /// No description provided for @shuoShuoGuanYuZheShouGeDeGuShi.
  ///
  /// In zh, this message translates to:
  /// **'说说关于这首歌的故事'**
  String get shuoShuoGuanYuZheShouGeDeGuShi;

  /// No description provided for @jiaZaiZhong.
  ///
  /// In zh, this message translates to:
  /// **'加载中…'**
  String get jiaZaiZhong;

  /// No description provided for @zanWuHuiFu.
  ///
  /// In zh, this message translates to:
  /// **'暂无回复'**
  String get zanWuHuiFu;

  /// No description provided for @laiYuan_2.
  ///
  /// In zh, this message translates to:
  /// **'来源：'**
  String get laiYuan_2;

  /// No description provided for @quSheZhiKaiQi.
  ///
  /// In zh, this message translates to:
  /// **'去设置开启'**
  String get quSheZhiKaiQi;

  /// No description provided for @xiaLaGuanBiNieHeSuoFang.
  ///
  /// In zh, this message translates to:
  /// **'下拉关闭 · 捏合缩放'**
  String get xiaLaGuanBiNieHeSuoFang;

  /// No description provided for @zhuoMianGeCiYangShi.
  ///
  /// In zh, this message translates to:
  /// **'桌面歌词样式'**
  String get zhuoMianGeCiYangShi;

  /// No description provided for @ziHaoQuanJuTongYiZaiBoFangYeGeCiXianShiLiTiaoYin.
  ///
  /// In zh, this message translates to:
  /// **'字号全局统一：在播放页「歌词显示」里调，应用内歌词与悬浮窗同步生效'**
  String get ziHaoQuanJuTongYiZaiBoFangYeGeCiXianShiLiTiaoYin;

  /// No description provided for @yiChangYanSe.
  ///
  /// In zh, this message translates to:
  /// **'已唱颜色'**
  String get yiChangYanSe;

  /// No description provided for @weiChangYanSe.
  ///
  /// In zh, this message translates to:
  /// **'未唱颜色'**
  String get weiChangYanSe;

  /// No description provided for @miaoBianYanSe.
  ///
  /// In zh, this message translates to:
  /// **'描边颜色'**
  String get miaoBianYanSe;

  /// No description provided for @miaoBianKuanDu.
  ///
  /// In zh, this message translates to:
  /// **'描边宽度'**
  String get miaoBianKuanDu;

  /// No description provided for @beiJingYanSe.
  ///
  /// In zh, this message translates to:
  /// **'背景颜色'**
  String get beiJingYanSe;

  /// No description provided for @beiJingShenDu.
  ///
  /// In zh, this message translates to:
  /// **'背景深度'**
  String get beiJingShenDu;

  /// No description provided for @beiJingYuanJiao.
  ///
  /// In zh, this message translates to:
  /// **'背景圆角'**
  String get beiJingYuanJiao;

  /// No description provided for @ziZhong.
  ///
  /// In zh, this message translates to:
  /// **'字重'**
  String get ziZhong;

  /// No description provided for @changGui.
  ///
  /// In zh, this message translates to:
  /// **'常规'**
  String get changGui;

  /// No description provided for @zhongDeng.
  ///
  /// In zh, this message translates to:
  /// **'中等'**
  String get zhongDeng;

  /// No description provided for @banCu.
  ///
  /// In zh, this message translates to:
  /// **'半粗'**
  String get banCu;

  /// No description provided for @cuTi.
  ///
  /// In zh, this message translates to:
  /// **'粗体'**
  String get cuTi;

  /// No description provided for @teCu.
  ///
  /// In zh, this message translates to:
  /// **'特粗'**
  String get teCu;

  /// No description provided for @heiTi.
  ///
  /// In zh, this message translates to:
  /// **'黑体'**
  String get heiTi;

  /// No description provided for @huiFuMoRen.
  ///
  /// In zh, this message translates to:
  /// **'恢复默认'**
  String get huiFuMoRen;

  /// No description provided for @yeKongZhongZuiLiangDeXing.
  ///
  /// In zh, this message translates to:
  /// **'夜空中最亮的星'**
  String get yeKongZhongZuiLiangDeXing;

  /// No description provided for @xuanZeYanSe.
  ///
  /// In zh, this message translates to:
  /// **'选择颜色'**
  String get xuanZeYanSe;

  /// No description provided for @seXiang.
  ///
  /// In zh, this message translates to:
  /// **'色相'**
  String get seXiang;

  /// No description provided for @baoHeDu.
  ///
  /// In zh, this message translates to:
  /// **'饱和度'**
  String get baoHeDu;

  /// No description provided for @mingDu.
  ///
  /// In zh, this message translates to:
  /// **'明度'**
  String get mingDu;

  /// No description provided for @buTouMingDu.
  ///
  /// In zh, this message translates to:
  /// **'不透明度'**
  String get buTouMingDu;

  /// No description provided for @queDing.
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get queDing;

  /// No description provided for @zanWuBoFangYinYue.
  ///
  /// In zh, this message translates to:
  /// **'暂无播放音乐'**
  String get zanWuBoFangYinYue;

  /// No description provided for @buXiHuanBingTiaoGuo.
  ///
  /// In zh, this message translates to:
  /// **'不喜欢并跳过'**
  String get buXiHuanBingTiaoGuo;

  /// No description provided for @kaiQiZhuoMianGeCi.
  ///
  /// In zh, this message translates to:
  /// **'开启桌面歌词'**
  String get kaiQiZhuoMianGeCi;

  /// No description provided for @geCiXianShi.
  ///
  /// In zh, this message translates to:
  /// **'歌词显示'**
  String get geCiXianShi;

  /// No description provided for @dangQianGeYouYiWenYinYiShiCaiHuiXianShiFuXing.
  ///
  /// In zh, this message translates to:
  /// **'当前歌有译文/音译时才会显示副行'**
  String get dangQianGeYouYiWenYinYiShiCaiHuiXianShiFuXing;

  /// No description provided for @xianShiFanYi.
  ///
  /// In zh, this message translates to:
  /// **'显示翻译'**
  String get xianShiFanYi;

  /// No description provided for @geCiXiaFangXianShiZhongWenYiWen.
  ///
  /// In zh, this message translates to:
  /// **'歌词下方显示中文译文'**
  String get geCiXiaFangXianShiZhongWenYiWen;

  /// No description provided for @xianShiLuoMaYin.
  ///
  /// In zh, this message translates to:
  /// **'显示罗马音'**
  String get xianShiLuoMaYin;

  /// No description provided for @riWenDengYinYiXianShiZaiFuXing.
  ///
  /// In zh, this message translates to:
  /// **'日文等音译显示在副行'**
  String get riWenDengYinYiXianShiZaiFuXing;

  /// No description provided for @xuanFuGeCi.
  ///
  /// In zh, this message translates to:
  /// **'悬浮歌词'**
  String get xuanFuGeCi;

  /// No description provided for @xuanFuChuangXianShiZhuoMianGeCiKeTuoDongSuoDing.
  ///
  /// In zh, this message translates to:
  /// **'悬浮窗显示桌面歌词，可拖动锁定'**
  String get xuanFuChuangXianShiZhuoMianGeCiKeTuoDongSuoDing;

  /// No description provided for @geCiZiHao.
  ///
  /// In zh, this message translates to:
  /// **'歌词字号'**
  String get geCiZiHao;

  /// No description provided for @geCiHangJianJu.
  ///
  /// In zh, this message translates to:
  /// **'歌词行间距'**
  String get geCiHangJianJu;

  /// No description provided for @geCiPianYi.
  ///
  /// In zh, this message translates to:
  /// **'歌词偏移'**
  String get geCiPianYi;

  /// No description provided for @geCiPianYiDangQianGeQu.
  ///
  /// In zh, this message translates to:
  /// **'歌词偏移（当前歌曲）'**
  String get geCiPianYiDangQianGeQu;

  /// No description provided for @zhiWeiTiaoZheYiShouZhengShuGeCiTiQianFuShuGeCiYa.
  ///
  /// In zh, this message translates to:
  /// **'只微调这一首；正数 = 歌词提前，负数 = 歌词延后'**
  String get zhiWeiTiaoZheYiShouZhengShuGeCiTiQianFuShuGeCiYa;

  /// No description provided for @chongZhiBenQuWeiTiao.
  ///
  /// In zh, this message translates to:
  /// **'重置本曲微调'**
  String get chongZhiBenQuWeiTiao;

  /// No description provided for @geCiJiaZaiZhong.
  ///
  /// In zh, this message translates to:
  /// **'歌词加载中…'**
  String get geCiJiaZaiZhong;

  /// No description provided for @zanWuGeCi.
  ///
  /// In zh, this message translates to:
  /// **'暂无歌词'**
  String get zanWuGeCi;

  /// No description provided for @huiDaoZhengZaiBoFangDeNaYiXing.
  ///
  /// In zh, this message translates to:
  /// **'回到正在播放的那一行'**
  String get huiDaoZhengZaiBoFangDeNaYiXing;

  /// No description provided for @huiDaoDangQianXing.
  ///
  /// In zh, this message translates to:
  /// **'回到当前行'**
  String get huiDaoDangQianXing;

  /// No description provided for @ling.
  ///
  /// In zh, this message translates to:
  /// **'零'**
  String get ling;

  /// No description provided for @yi.
  ///
  /// In zh, this message translates to:
  /// **'壱'**
  String get yi;

  /// No description provided for @er.
  ///
  /// In zh, this message translates to:
  /// **'弐'**
  String get er;

  /// No description provided for @can.
  ///
  /// In zh, this message translates to:
  /// **'参'**
  String get can;

  /// No description provided for @si.
  ///
  /// In zh, this message translates to:
  /// **'肆'**
  String get si;

  /// No description provided for @wu_2.
  ///
  /// In zh, this message translates to:
  /// **'伍'**
  String get wu_2;

  /// No description provided for @lu.
  ///
  /// In zh, this message translates to:
  /// **'陆'**
  String get lu;

  /// No description provided for @qi.
  ///
  /// In zh, this message translates to:
  /// **'柒'**
  String get qi;

  /// No description provided for @ba.
  ///
  /// In zh, this message translates to:
  /// **'捌'**
  String get ba;

  /// No description provided for @jiu.
  ///
  /// In zh, this message translates to:
  /// **'玖'**
  String get jiu;

  /// No description provided for @neiBuDianYuanShengYu.
  ///
  /// In zh, this message translates to:
  /// **'内部电源剩余'**
  String get neiBuDianYuanShengYu;

  /// No description provided for @diYiShou.
  ///
  /// In zh, this message translates to:
  /// **'第一首'**
  String get diYiShou;

  /// No description provided for @yinZhiXuanZe.
  ///
  /// In zh, this message translates to:
  /// **'音质选择'**
  String get yinZhiXuanZe;

  /// No description provided for @zhengZaiQieHuanYinZhi.
  ///
  /// In zh, this message translates to:
  /// **'正在切换音质…'**
  String get zhengZaiQieHuanYinZhi;

  /// No description provided for @huiSeDangWeiDangQianGeQuBuKeYong.
  ///
  /// In zh, this message translates to:
  /// **'灰色档位当前歌曲不可用'**
  String get huiSeDangWeiDangQianGeQuBuKeYong;

  /// No description provided for @weiZhiDangWeiJiangZiDongXiangXiaJianRong.
  ///
  /// In zh, this message translates to:
  /// **'未知档位将自动向下兼容'**
  String get weiZhiDangWeiJiangZiDongXiangXiaJianRong;

  /// No description provided for @dangQianBoFangMvYinPinGeCiKeNengBuTongBu.
  ///
  /// In zh, this message translates to:
  /// **'当前播放 MV 音频 · 歌词可能不同步'**
  String get dangQianBoFangMvYinPinGeCiKeNengBuTongBu;

  /// No description provided for @buKeYong.
  ///
  /// In zh, this message translates to:
  /// **'不可用'**
  String get buKeYong;

  /// No description provided for @duiLieWeiKong.
  ///
  /// In zh, this message translates to:
  /// **'队列为空'**
  String get duiLieWeiKong;

  /// No description provided for @n15FenZhong.
  ///
  /// In zh, this message translates to:
  /// **'15 分钟'**
  String get n15FenZhong;

  /// No description provided for @n30FenZhong.
  ///
  /// In zh, this message translates to:
  /// **'30 分钟'**
  String get n30FenZhong;

  /// No description provided for @n60FenZhong.
  ///
  /// In zh, this message translates to:
  /// **'60 分钟'**
  String get n60FenZhong;

  /// No description provided for @ziDingYi45FenZhong.
  ///
  /// In zh, this message translates to:
  /// **'自定义 45 分钟'**
  String get ziDingYi45FenZhong;

  /// No description provided for @banBen.
  ///
  /// In zh, this message translates to:
  /// **'版本'**
  String get banBen;

  /// No description provided for @xingTai.
  ///
  /// In zh, this message translates to:
  /// **'形态'**
  String get xingTai;

  /// No description provided for @dingWei.
  ///
  /// In zh, this message translates to:
  /// **'定位'**
  String get dingWei;

  /// No description provided for @duoYinYuanDiSanFangKeHuDuan.
  ///
  /// In zh, this message translates to:
  /// **'多音源第三方客户端'**
  String get duoYinYuanDiSanFangKeHuDuan;

  /// No description provided for @qingZunShouDangDiFaLvYuMuBiaoPingTaiFuWuTiaoKuan.
  ///
  /// In zh, this message translates to:
  /// **'请遵守当地法律与目标平台服务条款；对外发布请勿使用「酷狗」注册商标作为应用名。'**
  String get qingZunShouDangDiFaLvYuMuBiaoPingTaiFuWuTiaoKuan;

  /// No description provided for @tiYanTanSuoXingSheJiFengGeYuPaiBanXiTong.
  ///
  /// In zh, this message translates to:
  /// **'体验探索性设计风格与排版系统'**
  String get tiYanTanSuoXingSheJiFengGeYuPaiBanXiTong;

  /// No description provided for @dangQianShiYong.
  ///
  /// In zh, this message translates to:
  /// **'当前使用'**
  String get dangQianShiYong;

  /// No description provided for @boFangBeiSu.
  ///
  /// In zh, this message translates to:
  /// **'播放倍速'**
  String get boFangBeiSu;

  /// No description provided for @beiSuBuBaoLiuYinDiaoJinDuGeCiYuShengYuShiJianSui.
  ///
  /// In zh, this message translates to:
  /// **'倍速不保留音调；进度、歌词与剩余时间随倍速一致变化'**
  String get beiSuBuBaoLiuYinDiaoJinDuGeCiYuShengYuShiJianSui;

  /// No description provided for @yuYan.
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get yuYan;

  /// No description provided for @jieMianYuYan.
  ///
  /// In zh, this message translates to:
  /// **'界面语言'**
  String get jieMianYuYan;

  /// No description provided for @zaiXianYinLe.
  ///
  /// In zh, this message translates to:
  /// **'在线音乐'**
  String get zaiXianYinLe;

  /// No description provided for @woDeYinLe.
  ///
  /// In zh, this message translates to:
  /// **'我的音乐'**
  String get woDeYinLe;

  /// No description provided for @tongYong.
  ///
  /// In zh, this message translates to:
  /// **'通用'**
  String get tongYong;

  /// No description provided for @xiTongSheZhi.
  ///
  /// In zh, this message translates to:
  /// **'系统设置'**
  String get xiTongSheZhi;

  /// No description provided for @gaiNianBan.
  ///
  /// In zh, this message translates to:
  /// **'概念版'**
  String get gaiNianBan;

  /// No description provided for @zhanKaiCeLan.
  ///
  /// In zh, this message translates to:
  /// **'展开侧栏'**
  String get zhanKaiCeLan;

  /// No description provided for @zheDieCeLan.
  ///
  /// In zh, this message translates to:
  /// **'折叠侧栏'**
  String get zheDieCeLan;

  /// No description provided for @qianMingBeiJuJianChaWRidMixinkeyShiFouGuoQi.
  ///
  /// In zh, this message translates to:
  /// **'{p1}（签名被拒：检查 w_rid / mixinKey 是否过期）'**
  String qianMingBeiJuJianChaWRidMixinkeyShiFouGuoQi(Object p1);

  /// No description provided for @chuFaFengKongTuiBiChongShiHuoGengHuanWangLuo.
  ///
  /// In zh, this message translates to:
  /// **'{p1}（触发风控：退避重试或更换网络环境）'**
  String chuFaFengKongTuiBiChongShiHuoGengHuanWangLuo(Object p1);

  /// No description provided for @bZhanFengKongJiaoYanShiBaiQingShaoHouChongSh.
  ///
  /// In zh, this message translates to:
  /// **'{p1}（B 站风控校验失败，请稍后重试或登录）'**
  String bZhanFengKongJiaoYanShiBaiQingShaoHouChongSh(Object p1);

  /// No description provided for @xiangYingBuShiJsonDuiXiang.
  ///
  /// In zh, this message translates to:
  /// **'{p1}：响应不是 JSON 对象'**
  String xiangYingBuShiJsonDuiXiang(Object p1);

  /// No description provided for @xiangYingQueShaoCodeZiDuan.
  ///
  /// In zh, this message translates to:
  /// **'{p1}：响应缺少 code 字段'**
  String xiangYingQueShaoCodeZiDuan(Object p1);

  /// No description provided for @dataBuShiJsonDuiXiang.
  ///
  /// In zh, this message translates to:
  /// **'{p1}：data 不是 JSON 对象'**
  String dataBuShiJsonDuiXiang(Object p1);

  /// No description provided for @dataBuShiJsonShuZu.
  ///
  /// In zh, this message translates to:
  /// **'{p1}：data 不是 JSON 数组'**
  String dataBuShiJsonShuZu(Object p1);

  /// No description provided for @wan.
  ///
  /// In zh, this message translates to:
  /// **'{p1}万'**
  String wan(Object p1);

  /// No description provided for @yunPanXinXiShangChuanShiBai.
  ///
  /// In zh, this message translates to:
  /// **'云盘信息上传失败（{p1}）：{p2}'**
  String yunPanXinXiShangChuanShiBai(Object p1, Object p2);

  /// No description provided for @saoMaHuiHuaChuangJianShiBaiCode.
  ///
  /// In zh, this message translates to:
  /// **'扫码会话创建失败 code={p1} {p2}'**
  String saoMaHuiHuaChuangJianShiBaiCode(Object p1, Object p2);

  /// No description provided for @boFangDiZhiCode.
  ///
  /// In zh, this message translates to:
  /// **'播放地址 code={p1}'**
  String boFangDiZhiCode(Object p1);

  /// No description provided for @mvQuLiuCode.
  ///
  /// In zh, this message translates to:
  /// **'MV 取流 code={p1}'**
  String mvQuLiuCode(Object p1);

  /// No description provided for @mvQuLiuDataCode.
  ///
  /// In zh, this message translates to:
  /// **'MV 取流 data.code={p1}'**
  String mvQuLiuDataCode(Object p1);

  /// No description provided for @geCiCode.
  ///
  /// In zh, this message translates to:
  /// **'歌词 code={p1}'**
  String geCiCode(Object p1);

  /// No description provided for @yunPanQuLiuCode.
  ///
  /// In zh, this message translates to:
  /// **'云盘取流 code={p1}'**
  String yunPanQuLiuCode(Object p1);

  /// No description provided for @yunPanGeCiCode.
  ///
  /// In zh, this message translates to:
  /// **'云盘歌词 code={p1}'**
  String yunPanGeCiCode(Object p1);

  /// No description provided for @shiBaiCode.
  ///
  /// In zh, this message translates to:
  /// **'{p1} 失败 code={p2}'**
  String shiBaiCode(Object p1, Object p2);

  /// No description provided for @fuWuQiZanShiBuKeYongHttpQingShaoHouChongShi.
  ///
  /// In zh, this message translates to:
  /// **'服务器暂时不可用（HTTP {p1}），请稍后重试'**
  String fuWuQiZanShiBuKeYongHttpQingShaoHouChongShi(Object p1);

  /// No description provided for @dangQianWangLuoBeiWangGuanLanJieUrlGuoLvWuFa.
  ///
  /// In zh, this message translates to:
  /// **'当前网络被网关拦截（URL过滤），无法访问音源。\n请换手机热点 / 关闭路由器「上网行为管理」后重试'**
  String get dangQianWangLuoBeiWangGuanLanJieUrlGuoLvWuFa;

  /// No description provided for @yiJieDuanYuanChangDuZiFu.
  ///
  /// In zh, this message translates to:
  /// **'{p1}\n…(已截断，原长度 {p2} 字符)'**
  String yiJieDuanYuanChangDuZiFu(Object p1, Object p2);

  /// No description provided for @appInfoDuQuBanBenShiBai.
  ///
  /// In zh, this message translates to:
  /// **'[app_info] 读取版本失败: {p1}'**
  String appInfoDuQuBanBenShiBai(Object p1);

  /// No description provided for @tiaoZuiJin.
  ///
  /// In zh, this message translates to:
  /// **'{p1} 条 · 最近 {p2}'**
  String tiaoZuiJin(Object p1, Object p2);

  /// No description provided for @fanYinQiDongShiBaiQingJianChaXiTongQuanXianH.
  ///
  /// In zh, this message translates to:
  /// **'泛音 启动失败（{p1}）。请检查系统权限和运行依赖。'**
  String fanYinQiDongShiBaiQingJianChaXiTongQuanXianH(Object p1);

  /// No description provided for @chuShiHuaShiBaiHuoChaoShiYingYongYiXiangJiYu.
  ///
  /// In zh, this message translates to:
  /// **'{p1} 初始化失败或超时，应用已降级运行。'**
  String chuShiHuaShiBaiHuoChaoShiYingYongYiXiangJiYu(Object p1);

  /// No description provided for @yueRi.
  ///
  /// In zh, this message translates to:
  /// **'{p1}月{p2}日'**
  String yueRi(Object p1, Object p2);

  /// No description provided for @yue.
  ///
  /// In zh, this message translates to:
  /// **'{p1}月'**
  String yue(Object p1);

  /// No description provided for @yiShanChuShouShouQueShaoWenJianBiaoZhiBeiTia.
  ///
  /// In zh, this message translates to:
  /// **'已删除 {p1} 首，{p2} 首缺少文件标识被跳过'**
  String yiShanChuShouShouQueShaoWenJianBiaoZhiBeiTia(Object p1, Object p2);

  /// No description provided for @danMuZuiDuoZiQingJingJianHouZaiFa.
  ///
  /// In zh, this message translates to:
  /// **'弹幕最多 {p1} 字，请精简后再发'**
  String danMuZuiDuoZiQingJingJianHouZaiFa(Object p1);

  /// No description provided for @pingLunZuiDuoZiQingJingJianHouZaiFa.
  ///
  /// In zh, this message translates to:
  /// **'评论最多 {p1} 字，请精简后再发'**
  String pingLunZuiDuoZiQingJingJianHouZaiFa(Object p1);

  /// No description provided for @pingLunJiaZaiShiBaiStatusErr.
  ///
  /// In zh, this message translates to:
  /// **'评论加载失败（status={p1} err={p2}）'**
  String pingLunJiaZaiShiBaiStatusErr(Object p1, Object p2);

  /// No description provided for @xiangYingWuFaJieXi.
  ///
  /// In zh, this message translates to:
  /// **'{p1}响应无法解析'**
  String xiangYingWuFaJieXi(Object p1);

  /// No description provided for @yiChangQingShaoHouChongShi.
  ///
  /// In zh, this message translates to:
  /// **'{p1}异常，请稍后重试'**
  String yiChangQingShaoHouChongShi(Object p1);

  /// No description provided for @xuYaoDengLuHuoAnQuanJiaoYan.
  ///
  /// In zh, this message translates to:
  /// **'{p1}需要登录或安全校验'**
  String xuYaoDengLuHuoAnQuanJiaoYan(Object p1);

  /// No description provided for @fanHuiShiBaiStatusErr.
  ///
  /// In zh, this message translates to:
  /// **'{p1}返回失败（status={p2} err={p3}）'**
  String fanHuiShiBaiStatusErr(Object p1, Object p2, Object p3);

  /// No description provided for @meiRiTuiJianJiaZaiShiBaiStatusErr.
  ///
  /// In zh, this message translates to:
  /// **'每日推荐加载失败（status={p1} err={p2}）'**
  String meiRiTuiJianJiaZaiShiBaiStatusErr(Object p1, Object p2);

  /// No description provided for @bZhanWuFenP.
  ///
  /// In zh, this message translates to:
  /// **'B 站：{p1} 无分 P'**
  String bZhanWuFenP(Object p1);

  /// No description provided for @caoZuoShiBaiCode.
  ///
  /// In zh, this message translates to:
  /// **'操作失败（code={p1}）'**
  String caoZuoShiBaiCode(Object p1);

  /// No description provided for @zhuanJiJiaZaiShiBaiYinYuanBuKeYong.
  ///
  /// In zh, this message translates to:
  /// **'专辑加载失败：{p1}音源不可用'**
  String zhuanJiJiaZaiShiBaiYinYuanBuKeYong(Object p1);

  /// No description provided for @zhuanJiJiaZaiShiBai.
  ///
  /// In zh, this message translates to:
  /// **'专辑加载失败：{p1}'**
  String zhuanJiJiaZaiShiBai(Object p1);

  /// No description provided for @zhuanJiDangAn.
  ///
  /// In zh, this message translates to:
  /// **'专辑档案 · {p1}'**
  String zhuanJiDangAn(Object p1);

  /// No description provided for @geShiPin.
  ///
  /// In zh, this message translates to:
  /// **'{p1} 个视频 · {p2}'**
  String geShiPin(Object p1, Object p2);

  /// No description provided for @dengLuPingJuJinCunBenJiTuiChuDengLuJiQingChu.
  ///
  /// In zh, this message translates to:
  /// **'登录凭据仅存本机，退出登录即清除。游客仍可搜索与播放；登录后可读取收藏夹。B 站不提供云端红心歌曲，红心仅保存在本地。'**
  String get dengLuPingJuJinCunBenJiTuiChuDengLuJiQingChu;

  /// No description provided for @shuoMingDengLuJinZouWangYiYunZhenShiWangGuan.
  ///
  /// In zh, this message translates to:
  /// **'说明：登录仅走网易云真实网关，失败不会生成假账号。\n登录态（MUSIC_U）只存本机，退出即清除。'**
  String get shuoMingDengLuJinZouWangYiYunZhenShiWangGuan;

  /// No description provided for @shangChuanWanChengShouQiZhongShouMiaoChuan.
  ///
  /// In zh, this message translates to:
  /// **'上传完成：{p1} 首（其中 {p2} 首秒传）'**
  String shangChuanWanChengShouQiZhongShouMiaoChuan(Object p1, Object p2);

  /// No description provided for @shangChuanWanChengShou.
  ///
  /// In zh, this message translates to:
  /// **'上传完成：{p1} 首'**
  String shangChuanWanChengShou(Object p1);

  /// No description provided for @shangChuanWanChengChengGongShouShiBaiShou.
  ///
  /// In zh, this message translates to:
  /// **'上传完成：成功 {p1} 首，失败 {p2} 首'**
  String shangChuanWanChengChengGongShouShiBaiShou(Object p1, Object p2);

  /// No description provided for @queRenShanChuCiCaoZuoWuFaCheXiao.
  ///
  /// In zh, this message translates to:
  /// **'确认删除『{p1}』？此操作无法撤销。'**
  String queRenShanChuCiCaoZuoWuFaCheXiao(Object p1);

  /// No description provided for @shanChuShiBai.
  ///
  /// In zh, this message translates to:
  /// **'删除失败：{p1}'**
  String shanChuShiBai(Object p1);

  /// No description provided for @yiYong.
  ///
  /// In zh, this message translates to:
  /// **'已用 {p1} / {p2}'**
  String yiYong(Object p1, Object p2);

  /// No description provided for @shangChuanZhong.
  ///
  /// In zh, this message translates to:
  /// **'上传中 {p1} / {p2} · {p3}'**
  String shangChuanZhong(Object p1, Object p2, Object p3);

  /// No description provided for @zhaoDaoShouGongShou.
  ///
  /// In zh, this message translates to:
  /// **'找到 {p1} 首 / 共 {p2} 首'**
  String zhaoDaoShouGongShou(Object p1, Object p2);

  /// No description provided for @gongShou.
  ///
  /// In zh, this message translates to:
  /// **'共 {p1} 首{p2}'**
  String gongShou(Object p1, Object p2);

  /// No description provided for @yunPanShiZhangHaoDeSiYouWenJianKu.
  ///
  /// In zh, this message translates to:
  /// **'云盘是{p1}账号的私有文件库'**
  String yunPanShiZhangHaoDeSiYouWenJianKu(Object p1);

  /// No description provided for @dengLuZhangHao.
  ///
  /// In zh, this message translates to:
  /// **'登录{p1}账号'**
  String dengLuZhangHao(Object p1);

  /// No description provided for @wuFaDaKaiWenJianXuanZeQiLinuxQingAnZhuangZen.
  ///
  /// In zh, this message translates to:
  /// **'无法打开文件选择器。Linux 请安装 zenity、kdialog 或 qarma，并确认当前桌面会话可访问文件对话框。'**
  String get wuFaDaKaiWenJianXuanZeQiLinuxQingAnZhuangZen;

  /// No description provided for @buShiZhiChiDeYinPinWenJian.
  ///
  /// In zh, this message translates to:
  /// **'{p1}: 不是支持的音频文件'**
  String buShiZhiChiDeYinPinWenJian(Object p1);

  /// No description provided for @duQuShiBai.
  ///
  /// In zh, this message translates to:
  /// **'{p1}: 读取失败'**
  String duQuShiBai(Object p1);

  /// No description provided for @chaoGuo100mbXianZhi.
  ///
  /// In zh, this message translates to:
  /// **'{p1}: 超过 100MB 限制'**
  String chaoGuo100mbXianZhi(Object p1);

  /// No description provided for @shiShiTanCeRoundIntervalS.
  ///
  /// In zh, this message translates to:
  /// **'== 实时探测 round={p1} interval={p2}s =='**
  String shiShiTanCeRoundIntervalS(Object p1, Object p2);

  /// No description provided for @fanYinWangLuoRiZhi.
  ///
  /// In zh, this message translates to:
  /// **'== 泛音 网络日志 ==\n\n{p1}'**
  String fanYinWangLuoRiZhi(Object p1);

  /// No description provided for @yiFuZhiQuanBuRiZhiTiao.
  ///
  /// In zh, this message translates to:
  /// **'已复制全部日志 ({p1} 条)'**
  String yiFuZhiQuanBuRiZhiTiao(Object p1);

  /// No description provided for @haoShiMs.
  ///
  /// In zh, this message translates to:
  /// **'耗时: {p1}ms'**
  String haoShiMs(Object p1);

  /// No description provided for @zanBuZhiChiKeQieHuanQiTaYinYuanChaKan.
  ///
  /// In zh, this message translates to:
  /// **'{p1}暂不支持「{p2}」，可切换其他音源查看'**
  String zanBuZhiChiKeQieHuanQiTaYinYuanChaKan(Object p1, Object p2);

  /// No description provided for @shou_2.
  ///
  /// In zh, this message translates to:
  /// **'{p1} 首'**
  String shou_2(Object p1);

  /// No description provided for @meiRiFaXian.
  ///
  /// In zh, this message translates to:
  /// **'每日发现 · {p1}'**
  String meiRiFaXian(Object p1);

  /// No description provided for @yiQieDaoXiaYiShouShengXiao.
  ///
  /// In zh, this message translates to:
  /// **'已切到 {p1} · {p2}，下一首生效'**
  String yiQieDaoXiaYiShouShengXiao(Object p1, Object p2);

  /// No description provided for @dianJiKaiShiDianTaiJiKeShouLiu.
  ///
  /// In zh, this message translates to:
  /// **'{p1} · {p2} · {p3}，点击「开始电台」即可收流'**
  String dianJiKaiShiDianTaiJiKeShouLiu(Object p1, Object p2, Object p3);

  /// No description provided for @dianJiKaiShiDianTaiJiKeShouTing.
  ///
  /// In zh, this message translates to:
  /// **'{p1}，点击「开始电台」即可收听'**
  String dianJiKaiShiDianTaiJiKeShouTing(Object p1);

  /// No description provided for @shouDaiBo.
  ///
  /// In zh, this message translates to:
  /// **'{p1} 首待播'**
  String shouDaiBo(Object p1);

  /// No description provided for @xiangSiDu.
  ///
  /// In zh, this message translates to:
  /// **'相似度{p1}'**
  String xiangSiDu(Object p1);

  /// No description provided for @laiYuanSiRenFm.
  ///
  /// In zh, this message translates to:
  /// **'来源：{p1}私人 FM · {p2}{p3}'**
  String laiYuanSiRenFm(Object p1, Object p2, Object p3);

  /// No description provided for @laiYuanSiRenFm_2.
  ///
  /// In zh, this message translates to:
  /// **'来源：{p1}私人 FM'**
  String laiYuanSiRenFm_2(Object p1);

  /// No description provided for @laiYuanGuanJianCiJianSuo.
  ///
  /// In zh, this message translates to:
  /// **'来源：关键词检索 · {p1}'**
  String laiYuanGuanJianCiJianSuo(Object p1);

  /// No description provided for @laiYuanGuanJianCiJianSuoFeiGeXingHua.
  ///
  /// In zh, this message translates to:
  /// **'来源：关键词检索（{p1}，非个性化）'**
  String laiYuanGuanJianCiJianSuoFeiGeXingHua(Object p1);

  /// No description provided for @gongShou_2.
  ///
  /// In zh, this message translates to:
  /// **'共 {p1} 首'**
  String gongShou_2(Object p1);

  /// No description provided for @fenZhong.
  ///
  /// In zh, this message translates to:
  /// **'{p1} 分钟'**
  String fenZhong(Object p1);

  /// No description provided for @xiaoShi.
  ///
  /// In zh, this message translates to:
  /// **'{p1} 小时'**
  String xiaoShi(Object p1);

  /// No description provided for @ci.
  ///
  /// In zh, this message translates to:
  /// **'{p1} 次'**
  String ci(Object p1);

  /// No description provided for @shou_3.
  ///
  /// In zh, this message translates to:
  /// **'{p1} 首 ({p2}%)'**
  String shou_3(Object p1, Object p2);

  /// No description provided for @geQu_2.
  ///
  /// In zh, this message translates to:
  /// **'歌曲 ({p1})'**
  String geQu_2(Object p1);

  /// No description provided for @zhuanJi_2.
  ///
  /// In zh, this message translates to:
  /// **'专辑 ({p1})'**
  String zhuanJi_2(Object p1);

  /// No description provided for @dengLuHouJiKeTongBuYunDuanWoXiHuan.
  ///
  /// In zh, this message translates to:
  /// **'登录{p1}后，即可同步云端「我喜欢」'**
  String dengLuHouJiKeTongBuYunDuanWoXiHuan(Object p1);

  /// No description provided for @shou_4.
  ///
  /// In zh, this message translates to:
  /// **'{p1} 首 · {p2}'**
  String shou_4(Object p1, Object p2);

  /// No description provided for @zhaoDaoWeiGongWei.
  ///
  /// In zh, this message translates to:
  /// **'找到 {p1} 位 / 共 {p2} 位'**
  String zhaoDaoWeiGongWei(Object p1, Object p2);

  /// No description provided for @gongWeiGuanZhuGeShou.
  ///
  /// In zh, this message translates to:
  /// **'共 {p1} 位关注歌手'**
  String gongWeiGuanZhuGeShou(Object p1);

  /// No description provided for @shouDanQu.
  ///
  /// In zh, this message translates to:
  /// **'{p1} · {p2} 首单曲'**
  String shouDanQu(Object p1, Object p2);

  /// No description provided for @zhaoDaoZhangGongZhang.
  ///
  /// In zh, this message translates to:
  /// **'找到 {p1} 张 / 共 {p2} 张'**
  String zhaoDaoZhangGongZhang(Object p1, Object p2);

  /// No description provided for @gongZhangShouCangZhuanJi.
  ///
  /// In zh, this message translates to:
  /// **'共 {p1} 张收藏专辑'**
  String gongZhangShouCangZhuanJi(Object p1);

  /// No description provided for @ruanJieChongKaiShiBai.
  ///
  /// In zh, this message translates to:
  /// **'软解重开失败：{p1}'**
  String ruanJieChongKaiShiBai(Object p1);

  /// No description provided for @boFangQiCuoWu.
  ///
  /// In zh, this message translates to:
  /// **'播放器错误：{p1}'**
  String boFangQiCuoWu(Object p1);

  /// No description provided for @ge.
  ///
  /// In zh, this message translates to:
  /// **'{p1} 个'**
  String ge(Object p1);

  /// No description provided for @fenMiao.
  ///
  /// In zh, this message translates to:
  /// **'{p1} 分 {p2} 秒'**
  String fenMiao(Object p1, Object p2);

  /// No description provided for @miao.
  ///
  /// In zh, this message translates to:
  /// **'{p1} 秒'**
  String miao(Object p1);

  /// No description provided for @siRenFmDianTai.
  ///
  /// In zh, this message translates to:
  /// **'私人 FM 电台：{p1}'**
  String siRenFmDianTai(Object p1);

  /// No description provided for @yinPinYuanWuFaJiaZai.
  ///
  /// In zh, this message translates to:
  /// **'音频源无法加载: {p1}'**
  String yinPinYuanWuFaJiaZai(Object p1);

  /// No description provided for @yinPinYuanWuFaQiBo.
  ///
  /// In zh, this message translates to:
  /// **'音频源无法起播: {p1}'**
  String yinPinYuanWuFaQiBo(Object p1);

  /// No description provided for @yinPinYuanJiaZaiShiBai.
  ///
  /// In zh, this message translates to:
  /// **'音频源加载失败: {p1}'**
  String yinPinYuanJiaZaiShiBai(Object p1);

  /// No description provided for @boFangQiDongShiBai.
  ///
  /// In zh, this message translates to:
  /// **'播放启动失败: {p1}'**
  String boFangQiDongShiBai(Object p1);

  /// No description provided for @boFangShiBai.
  ///
  /// In zh, this message translates to:
  /// **'播放失败：{p1}'**
  String boFangShiBai(Object p1);

  /// No description provided for @boFangTingZhiYiChongShiCiRengWeiHuiFu.
  ///
  /// In zh, this message translates to:
  /// **'播放停滞：已重试 {p1} 次仍未恢复'**
  String boFangTingZhiYiChongShiCiRengWeiHuiFu(Object p1);

  /// No description provided for @stallTingZhiYuMsDiCiZiYu.
  ///
  /// In zh, this message translates to:
  /// **'[stall] {p1} 停滞于 {p2}ms，第 {p3} 次自愈'**
  String stallTingZhiYuMsDiCiZiYu(Object p1, Object p2, Object p3);

  /// No description provided for @boFangXuYaoDengLu.
  ///
  /// In zh, this message translates to:
  /// **'{p1}播放需要登录'**
  String boFangXuYaoDengLu(Object p1);

  /// No description provided for @jiaZaiShiBaiYinYuanBuKeYong.
  ///
  /// In zh, this message translates to:
  /// **'{p1}加载失败：{p2}音源不可用'**
  String jiaZaiShiBaiYinYuanBuKeYong(Object p1, Object p2);

  /// No description provided for @jiaZaiShiBaiJieKouBuKeYongHuoGaiIdWuGongKaiS.
  ///
  /// In zh, this message translates to:
  /// **'{p1}加载失败：接口不可用或该 ID 无公开数据'**
  String jiaZaiShiBaiJieKouBuKeYongHuoGaiIdWuGongKaiS(Object p1);

  /// No description provided for @jiaZaiShiBai_2.
  ///
  /// In zh, this message translates to:
  /// **'加载失败：{p1}'**
  String jiaZaiShiBai_2(Object p1);

  /// No description provided for @shou_5.
  ///
  /// In zh, this message translates to:
  /// **'{p1} / {p2} 首'**
  String shou_5(Object p1, Object p2);

  /// No description provided for @buFenZhangHaoXinXiHuoQuShiBai.
  ///
  /// In zh, this message translates to:
  /// **'部分账号信息获取失败：{p1}'**
  String buFenZhangHaoXinXiHuoQuShiBai(Object p1);

  /// No description provided for @qingXianDengLuZhangHao.
  ///
  /// In zh, this message translates to:
  /// **'请先登录{p1}账号'**
  String qingXianDengLuZhangHao(Object p1);

  /// No description provided for @zanBuZhiChiZhangHaoDengLu.
  ///
  /// In zh, this message translates to:
  /// **'{p1}暂不支持账号登录'**
  String zanBuZhiChiZhangHaoDengLu(Object p1);

  /// No description provided for @juLvHaiCha.
  ///
  /// In zh, this message translates to:
  /// **'距 Lv.{p1} 还差 {p2} {p3}'**
  String juLvHaiCha(Object p1, Object p2, Object p3);

  /// No description provided for @kaiShiDaoQi.
  ///
  /// In zh, this message translates to:
  /// **'开始 {p1} · 到期 {p2}'**
  String kaiShiDaoQi(Object p1, Object p2);

  /// No description provided for @dengLuZhangHaoHouJiKeTongBuZiJianYuShouCangG.
  ///
  /// In zh, this message translates to:
  /// **'登录{p1}账号后，即可同步自建与收藏歌单'**
  String dengLuZhangHaoHouJiKeTongBuZiJianYuShouCangG(Object p1);

  /// No description provided for @zanWuYunDuanGeDan.
  ///
  /// In zh, this message translates to:
  /// **'{p1}暂无云端歌单'**
  String zanWuYunDuanGeDan(Object p1);

  /// No description provided for @ziJian.
  ///
  /// In zh, this message translates to:
  /// **'自建 ({p1})'**
  String ziJian(Object p1);

  /// No description provided for @shou_6.
  ///
  /// In zh, this message translates to:
  /// **'{p1} 首{p2}'**
  String shou_6(Object p1, Object p2);

  /// No description provided for @tian.
  ///
  /// In zh, this message translates to:
  /// **'{p1} 天'**
  String tian(Object p1);

  /// No description provided for @nian.
  ///
  /// In zh, this message translates to:
  /// **'{p1} 年'**
  String nian(Object p1);

  /// No description provided for @geYue.
  ///
  /// In zh, this message translates to:
  /// **'{p1} 个月'**
  String geYue(Object p1);

  /// No description provided for @nianHouDaoQi.
  ///
  /// In zh, this message translates to:
  /// **'{p1}年后到期'**
  String nianHouDaoQi(Object p1);

  /// No description provided for @geYueHouDaoQi.
  ///
  /// In zh, this message translates to:
  /// **'{p1}个月后到期'**
  String geYueHouDaoQi(Object p1);

  /// No description provided for @tianHouDaoQi.
  ///
  /// In zh, this message translates to:
  /// **'{p1}天后到期'**
  String tianHouDaoQi(Object p1);

  /// No description provided for @xiaoShiHouDaoQi.
  ///
  /// In zh, this message translates to:
  /// **'{p1}小时后到期'**
  String xiaoShiHouDaoQi(Object p1);

  /// No description provided for @fenZhongHouDaoQi.
  ///
  /// In zh, this message translates to:
  /// **'{p1}分钟后到期'**
  String fenZhongHouDaoQi(Object p1);

  /// No description provided for @tuiChuZhangHao.
  ///
  /// In zh, this message translates to:
  /// **'退出{p1}账号？'**
  String tuiChuZhangHao(Object p1);

  /// No description provided for @tuiChuHouYunDuanDiGeDanWoXiHuanYuFuFeiBoFang.
  ///
  /// In zh, this message translates to:
  /// **'退出后{p1}云端的歌单、「我喜欢」与付费播放权限将不可用，本机数据不受影响。'**
  String tuiChuHouYunDuanDiGeDanWoXiHuanYuFuFeiBoFang(Object p1);

  /// No description provided for @geDanDangAn.
  ///
  /// In zh, this message translates to:
  /// **'歌单档案 · {p1}'**
  String geDanDangAn(Object p1);

  /// No description provided for @shouGeXingHuaTuiJian.
  ///
  /// In zh, this message translates to:
  /// **'{p1} 首 · 个性化推荐'**
  String shouGeXingHuaTuiJian(Object p1);

  /// No description provided for @meiYouZhaoDaoXiangGuan.
  ///
  /// In zh, this message translates to:
  /// **'没有找到相关{p1}'**
  String meiYouZhaoDaoXiangGuan(Object p1);

  /// No description provided for @duLiXuanFuChuangXianShiDangQianGeCiShiYanGon.
  ///
  /// In zh, this message translates to:
  /// **'独立悬浮窗显示当前歌词。实验功能：开启后主窗口会失去响应，且不会开机自启，谨慎开启（排查见 桌面歌词接入方案.md §12）'**
  String get duLiXuanFuChuangXianShiDangQianGeCiShiYanGon;

  /// No description provided for @sQuanJuAnGeQuDeWeiTiaoHuiZaiDieJia.
  ///
  /// In zh, this message translates to:
  /// **'{p1}{p2}s（全局，按歌曲的微调会再叠加）'**
  String sQuanJuAnGeQuDeWeiTiaoHuiZaiDieJia(Object p1, Object p2);

  /// No description provided for @xinGeMoRenAnCiJieXiBoFangZhongKeQieHuan.
  ///
  /// In zh, this message translates to:
  /// **'{p1} · 新歌默认按此解析，播放中可切换'**
  String xinGeMoRenAnCiJieXiBoFangZhongKeQieHuan(Object p1);

  /// No description provided for @souSuoYuWoXiHuanDeChuShiYinYuan.
  ///
  /// In zh, this message translates to:
  /// **'{p1} · 搜索与「我喜欢」的初始音源'**
  String souSuoYuWoXiHuanDeChuShiYinYuan(Object p1);

  /// No description provided for @xueXiYanJiuXiangDiSanFangKeHuDuanBuTiGongYin.
  ///
  /// In zh, this message translates to:
  /// **'{p1} · 学习/研究向第三方客户端\n不提供音频中转或账号托管'**
  String xueXiYanJiuXiangDiSanFangKeHuDuanBuTiGongYin(Object p1);

  /// No description provided for @qiYongYinYuan.
  ///
  /// In zh, this message translates to:
  /// **'启用{p1}音源'**
  String qiYongYinYuan(Object p1);

  /// No description provided for @dengLuHouKeQiYong.
  ///
  /// In zh, this message translates to:
  /// **'登录{p1}后可启用'**
  String dengLuHouKeQiYong(Object p1);

  /// No description provided for @guanBiHouGaiYuanBuZaiChuXianZaiRuKou.
  ///
  /// In zh, this message translates to:
  /// **'关闭后该源不再出现在「{p1}」入口'**
  String guanBiHouGaiYuanBuZaiChuXianZaiRuKou(Object p1);

  /// No description provided for @yinYuanYiGuanBiCiXiangZanShiBuShengXiao.
  ///
  /// In zh, this message translates to:
  /// **'{p1}音源已关闭，此项暂时不生效'**
  String yinYuanYiGuanBiCiXiangZanShiBuShengXiao(Object p1);

  /// No description provided for @kuangJiaYuanShengWeiBuHuoCuoWu.
  ///
  /// In zh, this message translates to:
  /// **'框架 / 原生 / 未捕获错误 · {p1}'**
  String kuangJiaYuanShengWeiBuHuoCuoWu(Object p1);

  /// No description provided for @faSongShiBai.
  ///
  /// In zh, this message translates to:
  /// **'发送失败：{p1}'**
  String faSongShiBai(Object p1);

  /// No description provided for @tiao.
  ///
  /// In zh, this message translates to:
  /// **'{p1}条'**
  String tiao(Object p1);

  /// No description provided for @danQuDangAn.
  ///
  /// In zh, this message translates to:
  /// **'单曲档案 · {p1}'**
  String danQuDangAn(Object p1);

  /// No description provided for @tiao_2.
  ///
  /// In zh, this message translates to:
  /// **'{p1} 条'**
  String tiao_2(Object p1);

  /// No description provided for @fanYin_2.
  ///
  /// In zh, this message translates to:
  /// **'泛音 · {p1} · {p2}'**
  String fanYin_2(Object p1, Object p2);

  /// No description provided for @yinLiang.
  ///
  /// In zh, this message translates to:
  /// **'音量 {p1}%'**
  String yinLiang(Object p1);

  /// No description provided for @tiaoHuiFu.
  ///
  /// In zh, this message translates to:
  /// **'{p1}条回复'**
  String tiaoHuiFu(Object p1);

  /// No description provided for @yinYuanYiTingYong.
  ///
  /// In zh, this message translates to:
  /// **'{p1}音源已停用'**
  String yinYuanYiTingYong(Object p1);

  /// No description provided for @deYiGuanBi.
  ///
  /// In zh, this message translates to:
  /// **'{p1}的「{p2}」已关闭'**
  String deYiGuanBi(Object p1, Object p2);

  /// No description provided for @benYeNeiRongYiLaiYiTingYongQiJianBuZaiQingQi.
  ///
  /// In zh, this message translates to:
  /// **'本页内容依赖{p1}。已停用期间不再请求该音源；已在播放队列中的歌曲不受影响。'**
  String benYeNeiRongYiLaiYiTingYongQiJianBuZaiQingQi(Object p1);

  /// No description provided for @yinYuanRengQiYongZhiShiZheYiXiangGongNengBei.
  ///
  /// In zh, this message translates to:
  /// **'{p1}音源仍启用，只是这一项功能被单独关掉了；开启后本页即可用。已在播放队列中的歌曲不受影响。'**
  String yinYuanRengQiYongZhiShiZheYiXiangGongNengBei(Object p1);

  /// No description provided for @benQuWeiTiaoQuanJuHeJiShengXiao.
  ///
  /// In zh, this message translates to:
  /// **'本曲微调 {p1}　全局 {p2}　合计生效 {p3}'**
  String benQuWeiTiaoQuanJuHeJiShengXiao(Object p1, Object p2, Object p3);

  /// No description provided for @shi.
  ///
  /// In zh, this message translates to:
  /// **'{p1}拾{p2}'**
  String shi(Object p1, Object p2);

  /// No description provided for @boFangDuiLieShou.
  ///
  /// In zh, this message translates to:
  /// **'播放队列 · {p1} 首'**
  String boFangDuiLieShou(Object p1);

  /// No description provided for @geRenXueXiYanJiuXiangXiangMuShuJuJingGongKai.
  ///
  /// In zh, this message translates to:
  /// **'个人学习 / 研究向项目。数据经公开接口直接获取，不提供音频中转或云端账号托管。音乐版权归原平台及版权方所有。'**
  String get geRenXueXiYanJiuXiangXiangMuShuJuJingGongKai;

  /// No description provided for @boFangLiang.
  ///
  /// In zh, this message translates to:
  /// **'播放 {p1}'**
  String boFangLiang(Object p1);

  /// No description provided for @fenSi_2.
  ///
  /// In zh, this message translates to:
  /// **'{p1} 粉丝'**
  String fenSi_2(Object p1);

  /// No description provided for @geShou_2.
  ///
  /// In zh, this message translates to:
  /// **'歌手 ({p1})'**
  String geShou_2(Object p1);

  /// No description provided for @huiFu_2.
  ///
  /// In zh, this message translates to:
  /// **'回复 @{p1}'**
  String huiFu_2(Object p1);

  /// No description provided for @laiYuan_3.
  ///
  /// In zh, this message translates to:
  /// **'来源：{p1}'**
  String laiYuan_3(Object p1);

  /// No description provided for @paiXuFangShi_2.
  ///
  /// In zh, this message translates to:
  /// **'按 {p1} 排序（{p2}）'**
  String paiXuFangShi_2(Object p1, Object p2);

  /// No description provided for @qiTaBanBen_2.
  ///
  /// In zh, this message translates to:
  /// **'其他版本 {p1}'**
  String qiTaBanBen_2(Object p1);

  /// No description provided for @shouCang_2.
  ///
  /// In zh, this message translates to:
  /// **'收藏 ({p1})'**
  String shouCang_2(Object p1);

  /// No description provided for @siRenFm_2.
  ///
  /// In zh, this message translates to:
  /// **'{p1}私人 FM'**
  String siRenFm_2(Object p1);

  /// No description provided for @wangLuoCuoWu_2.
  ///
  /// In zh, this message translates to:
  /// **'{p1}网络错误'**
  String wangLuoCuoWu_2(Object p1);

  /// No description provided for @yi_2.
  ///
  /// In zh, this message translates to:
  /// **'{p1}亿'**
  String yi_2(Object p1);

  /// No description provided for @yongHu_2.
  ///
  /// In zh, this message translates to:
  /// **'{p1}用户'**
  String yongHu_2(Object p1);

  /// No description provided for @fanYinLabel.
  ///
  /// In zh, this message translates to:
  /// **'泛音 · {p1}'**
  String fanYinLabel(Object p1);

  /// No description provided for @dianTaiJieShu.
  ///
  /// In zh, this message translates to:
  /// **'点击「开始电台」即可收听'**
  String get dianTaiJieShu;

  /// No description provided for @juLiShengJi.
  ///
  /// In zh, this message translates to:
  /// **'距离 Lv.{p1} 还需 {p2} {p3}'**
  String juLiShengJi(Object p1, Object p2, Object p3);

  /// No description provided for @xiangYingWeiKong.
  ///
  /// In zh, this message translates to:
  /// **'{p1}响应为空'**
  String xiangYingWeiKong(Object p1);

  /// No description provided for @geQu_3.
  ///
  /// In zh, this message translates to:
  /// **'{p1} 歌曲'**
  String geQu_3(Object p1);

  /// No description provided for @zhuanJi_3.
  ///
  /// In zh, this message translates to:
  /// **'{p1} 专辑'**
  String zhuanJi_3(Object p1);

  /// No description provided for @quXiaoShouCang.
  ///
  /// In zh, this message translates to:
  /// **'取消收藏'**
  String get quXiaoShouCang;

  /// No description provided for @biaoShengBang.
  ///
  /// In zh, this message translates to:
  /// **'飙升榜'**
  String get biaoShengBang;

  /// No description provided for @xinGeBang.
  ///
  /// In zh, this message translates to:
  /// **'新歌榜'**
  String get xinGeBang;

  /// No description provided for @yuanChuangBang.
  ///
  /// In zh, this message translates to:
  /// **'原创榜'**
  String get yuanChuangBang;

  /// No description provided for @reGeBang.
  ///
  /// In zh, this message translates to:
  /// **'热歌榜'**
  String get reGeBang;

  /// No description provided for @wangYiYunShuoChangBang.
  ///
  /// In zh, this message translates to:
  /// **'网易云中文说唱榜'**
  String get wangYiYunShuoChangBang;

  /// No description provided for @wangYiYunGuoFengBang.
  ///
  /// In zh, this message translates to:
  /// **'网易云国风榜'**
  String get wangYiYunGuoFengBang;

  /// No description provided for @wangYiYunMinYaoBang.
  ///
  /// In zh, this message translates to:
  /// **'网易云民谣榜'**
  String get wangYiYunMinYaoBang;

  /// No description provided for @wangYiYunYaoGunBang.
  ///
  /// In zh, this message translates to:
  /// **'网易云摇滚榜'**
  String get wangYiYunYaoGunBang;

  /// No description provided for @wangYiYunDianYinBang.
  ///
  /// In zh, this message translates to:
  /// **'网易云电音榜'**
  String get wangYiYunDianYinBang;

  /// No description provided for @wangYiYunGuDianBang.
  ///
  /// In zh, this message translates to:
  /// **'网易云古典榜'**
  String get wangYiYunGuDianBang;

  /// No description provided for @wangYiYunAcgBang.
  ///
  /// In zh, this message translates to:
  /// **'网易云ACG榜'**
  String get wangYiYunAcgBang;

  /// No description provided for @wangYiYunOuMeiReGeBang.
  ///
  /// In zh, this message translates to:
  /// **'网易云欧美热歌榜'**
  String get wangYiYunOuMeiReGeBang;

  /// No description provided for @wangYiYunOuMeiXinGeBang.
  ///
  /// In zh, this message translates to:
  /// **'网易云欧美新歌榜'**
  String get wangYiYunOuMeiXinGeBang;

  /// No description provided for @ouMeiRnBBang.
  ///
  /// In zh, this message translates to:
  /// **'欧美R&B榜'**
  String get ouMeiRnBBang;

  /// No description provided for @wangYiYunRiYuBang.
  ///
  /// In zh, this message translates to:
  /// **'网易云日语榜'**
  String get wangYiYunRiYuBang;

  /// No description provided for @wangYiYunHanYuBang.
  ///
  /// In zh, this message translates to:
  /// **'网易云韩语榜'**
  String get wangYiYunHanYuBang;

  /// No description provided for @meiGuoBillboardBang.
  ///
  /// In zh, this message translates to:
  /// **'美国Billboard榜'**
  String get meiGuoBillboardBang;

  /// No description provided for @ukZhouBang.
  ///
  /// In zh, this message translates to:
  /// **'UK排行榜周榜'**
  String get ukZhouBang;

  /// No description provided for @riBenOriconBang.
  ///
  /// In zh, this message translates to:
  /// **'日本Oricon榜'**
  String get riBenOriconBang;

  /// No description provided for @beatportQuanQiuBang.
  ///
  /// In zh, this message translates to:
  /// **'Beatport全球电子舞曲榜'**
  String get beatportQuanQiuBang;

  /// No description provided for @qiTa.
  ///
  /// In zh, this message translates to:
  /// **'其他'**
  String get qiTa;

  /// No description provided for @wangYiGuanFangBang.
  ///
  /// In zh, this message translates to:
  /// **'网易官方榜'**
  String get wangYiGuanFangBang;

  /// No description provided for @bangDanIdWuXiao.
  ///
  /// In zh, this message translates to:
  /// **'榜单 id 无效'**
  String get bangDanIdWuXiao;

  /// No description provided for @geDanIdWuXiao.
  ///
  /// In zh, this message translates to:
  /// **'歌单 id 无效'**
  String get geDanIdWuXiao;

  /// No description provided for @yunPanShanChu.
  ///
  /// In zh, this message translates to:
  /// **'云盘删除'**
  String get yunPanShanChu;

  /// No description provided for @geDanJiaQu.
  ///
  /// In zh, this message translates to:
  /// **'歌单加曲'**
  String get geDanJiaQu;

  /// No description provided for @geDanShanQu.
  ///
  /// In zh, this message translates to:
  /// **'歌单删曲'**
  String get geDanShanQu;

  /// No description provided for @fmXiHuan.
  ///
  /// In zh, this message translates to:
  /// **'FM 喜欢'**
  String get fmXiHuan;

  /// No description provided for @quXiaoHongXin.
  ///
  /// In zh, this message translates to:
  /// **'取消红心'**
  String get quXiaoHongXin;

  /// No description provided for @wangYiYunWeiDengLuWuFaDuQuGeDan.
  ///
  /// In zh, this message translates to:
  /// **'网易云未登录，无法读取歌单'**
  String get wangYiYunWeiDengLuWuFaDuQuGeDan;

  /// No description provided for @wangYiYunWeiDengLuWuFaDuQuWoXiHuan.
  ///
  /// In zh, this message translates to:
  /// **'网易云未登录，无法读取「我喜欢」'**
  String get wangYiYunWeiDengLuWuFaDuQuWoXiHuan;

  /// No description provided for @geQuIdWuXiao.
  ///
  /// In zh, this message translates to:
  /// **'曲目 id 无效'**
  String get geQuIdWuXiao;

  /// No description provided for @saoMaHuiHuaGuoQiQingChongXinHuoQu.
  ///
  /// In zh, this message translates to:
  /// **'扫码会话已失效，请重新获取二维码'**
  String get saoMaHuiHuaGuoQiQingChongXinHuoQu;

  /// No description provided for @xinSaoMaHuiHuaWeiQuDePingJu.
  ///
  /// In zh, this message translates to:
  /// **'新扫码会话未取得有效凭据，请重新扫码'**
  String get xinSaoMaHuiHuaWeiQuDePingJu;

  /// No description provided for @wangYiYunWeiDengLuWuFaDuQuZhangHaoDangAn.
  ///
  /// In zh, this message translates to:
  /// **'网易云未登录，无法读取账号档案'**
  String get wangYiYunWeiDengLuWuFaDuQuZhangHaoDangAn;

  /// No description provided for @wangYiYunWeiDengLuWuFaDuQuHuiYuanXinXi.
  ///
  /// In zh, this message translates to:
  /// **'网易云未登录，无法读取会员信息'**
  String get wangYiYunWeiDengLuWuFaDuQuHuiYuanXinXi;

  /// No description provided for @pingLunJiaZaiShiBai.
  ///
  /// In zh, this message translates to:
  /// **'评论加载失败'**
  String get pingLunJiaZaiShiBai;

  /// No description provided for @louCengJiaZaiShiBai.
  ///
  /// In zh, this message translates to:
  /// **'楼层加载失败'**
  String get louCengJiaZaiShiBai;

  /// No description provided for @pingLunChiWeiZhiWuFaJiaZaiLouCeng.
  ///
  /// In zh, this message translates to:
  /// **'评论池未知，无法加载楼层'**
  String get pingLunChiWeiZhiWuFaJiaZaiLouCeng;

  /// No description provided for @dengLuZhuangTaiYiShiXiaoQingChongXinDengLu.
  ///
  /// In zh, this message translates to:
  /// **'登录状态已失效，请重新登录'**
  String get dengLuZhuangTaiYiShiXiaoQingChongXinDengLu;

  /// No description provided for @caoZuoTaiPinFanQingShaoHouZaiShi.
  ///
  /// In zh, this message translates to:
  /// **'操作太频繁，请稍后再试'**
  String get caoZuoTaiPinFanQingShaoHouZaiShi;

  /// No description provided for @meiYouQuanXianZhiXingGaiCaoZuo.
  ///
  /// In zh, this message translates to:
  /// **'没有权限执行该操作'**
  String get meiYouQuanXianZhiXingGaiCaoZuo;

  /// No description provided for @geQuIdWeiZhiWuFaFaBiaoPingLun.
  ///
  /// In zh, this message translates to:
  /// **'歌曲 ID 未知，无法发表评论'**
  String get geQuIdWeiZhiWuFaFaBiaoPingLun;

  /// No description provided for @geQuIdWeiZhiWuFaHuiFu.
  ///
  /// In zh, this message translates to:
  /// **'歌曲 ID 未知，无法回复'**
  String get geQuIdWeiZhiWuFaHuiFu;

  /// No description provided for @wuXiaoDeMvLaiYuanBiaoShi.
  ///
  /// In zh, this message translates to:
  /// **'无效的 MV 来源标识'**
  String get wuXiaoDeMvLaiYuanBiaoShi;

  /// No description provided for @zanWuPingLun.
  ///
  /// In zh, this message translates to:
  /// **'暂无评论'**
  String get zanWuPingLun;

  /// No description provided for @shuoDianShenMe.
  ///
  /// In zh, this message translates to:
  /// **'说点什么…'**
  String get shuoDianShenMe;

  /// No description provided for @youKe.
  ///
  /// In zh, this message translates to:
  /// **'游客'**
  String get youKe;

  /// No description provided for @xuDengLu.
  ///
  /// In zh, this message translates to:
  /// **'需登录'**
  String get xuDengLu;

  /// No description provided for @yunDuanSiYouWenJianKu.
  ///
  /// In zh, this message translates to:
  /// **'云端私有文件库'**
  String get yunDuanSiYouWenJianKu;

  /// No description provided for @zanWuZiJianGeDan.
  ///
  /// In zh, this message translates to:
  /// **'暂无自建歌单'**
  String get zanWuZiJianGeDan;

  /// No description provided for @mvShouCangXinXiBuKeYong.
  ///
  /// In zh, this message translates to:
  /// **'暂无可用的 MV 收藏信息'**
  String get mvShouCangXinXiBuKeYong;

  /// No description provided for @yiShouCang.
  ///
  /// In zh, this message translates to:
  /// **'已收藏'**
  String get yiShouCang;

  /// No description provided for @shiPinJiaZaiShiBai.
  ///
  /// In zh, this message translates to:
  /// **'视频加载失败'**
  String get shiPinJiaZaiShiBai;

  /// No description provided for @zhengChang.
  ///
  /// In zh, this message translates to:
  /// **'正常'**
  String get zhengChang;

  /// No description provided for @quXiaoJingYin.
  ///
  /// In zh, this message translates to:
  /// **'取消静音'**
  String get quXiaoJingYin;

  /// No description provided for @tuiChuQuanPing.
  ///
  /// In zh, this message translates to:
  /// **'退出全屏'**
  String get tuiChuQuanPing;

  /// No description provided for @kuaiJin.
  ///
  /// In zh, this message translates to:
  /// **'快进'**
  String get kuaiJin;

  /// No description provided for @kuaiTui.
  ///
  /// In zh, this message translates to:
  /// **'快退'**
  String get kuaiTui;

  /// No description provided for @xianShiXuanFuGeCi.
  ///
  /// In zh, this message translates to:
  /// **'显示悬浮歌词'**
  String get xianShiXuanFuGeCi;

  /// No description provided for @huiDaoPingMuDingBuJuZhongSimple.
  ///
  /// In zh, this message translates to:
  /// **'回到屏幕顶部居中'**
  String get huiDaoPingMuDingBuJuZhongSimple;

  /// No description provided for @guanBiHouSouSuoYuGongNengYeBuZaiShiYongGaiYuan.
  ///
  /// In zh, this message translates to:
  /// **'关闭后搜索与功能页不再使用该源'**
  String get guanBiHouSouSuoYuGongNengYeBuZaiShiYongGaiYuan;

  /// No description provided for @yiDengLuWithName.
  ///
  /// In zh, this message translates to:
  /// **'已登录：{p1}'**
  String yiDengLuWithName(Object p1);

  /// No description provided for @pingLunChiWeiZhiWuFaAnZuiRePaiXu.
  ///
  /// In zh, this message translates to:
  /// **'评论池未知，无法按最热排序'**
  String get pingLunChiWeiZhiWuFaAnZuiRePaiXu;

  /// No description provided for @pingLunChiWeiZhiWuFaJiaZaiDanMu.
  ///
  /// In zh, this message translates to:
  /// **'评论池未知，无法加载弹幕'**
  String get pingLunChiWeiZhiWuFaJiaZaiDanMu;

  /// No description provided for @wuFaJieXiGaiMvDeDanMuChi.
  ///
  /// In zh, this message translates to:
  /// **'无法解析该 MV 的弹幕池'**
  String get wuFaJieXiGaiMvDeDanMuChi;

  /// No description provided for @pingLunCanShuBuWanZheng.
  ///
  /// In zh, this message translates to:
  /// **'评论参数不完整（{p1}）'**
  String pingLunCanShuBuWanZheng(Object p1);

  /// No description provided for @whatFaSongShiBai.
  ///
  /// In zh, this message translates to:
  /// **'{p1}发送失败（status={p2} err={p3}）'**
  String whatFaSongShiBai(Object p1, Object p2, Object p3);

  /// No description provided for @jinRiZanWuFengGeTuiJian.
  ///
  /// In zh, this message translates to:
  /// **'今日暂无风格推荐'**
  String get jinRiZanWuFengGeTuiJian;

  /// No description provided for @meiRiTuiJianXiangYingWeiKong.
  ///
  /// In zh, this message translates to:
  /// **'每日推荐响应为空'**
  String get meiRiTuiJianXiangYingWeiKong;

  /// No description provided for @jinRiZanWuGeXingHuaTuiJian.
  ///
  /// In zh, this message translates to:
  /// **'今日暂无个性化推荐'**
  String get jinRiZanWuGeXingHuaTuiJian;

  /// No description provided for @siRenFmXiangYingWuFaJieXi.
  ///
  /// In zh, this message translates to:
  /// **'私人FM响应无法解析'**
  String get siRenFmXiangYingWuFaJieXi;

  /// No description provided for @siRenFmZanWuTuiJian.
  ///
  /// In zh, this message translates to:
  /// **'私人FM暂无推荐'**
  String get siRenFmZanWuTuiJian;

  /// No description provided for @siRenFmJiaZaiShiBaiShort.
  ///
  /// In zh, this message translates to:
  /// **'私人FM加载失败'**
  String get siRenFmJiaZaiShiBaiShort;

  /// No description provided for @wangLuoYiChangShort.
  ///
  /// In zh, this message translates to:
  /// **'网络异常'**
  String get wangLuoYiChangShort;

  /// No description provided for @erWeiMaJiaZaiShiBai.
  ///
  /// In zh, this message translates to:
  /// **'二维码加载失败'**
  String get erWeiMaJiaZaiShiBai;

  /// No description provided for @zhengZaiJiaZaiGengDuoGeQu.
  ///
  /// In zh, this message translates to:
  /// **'正在加载更多歌曲…'**
  String get zhengZaiJiaZaiGengDuoGeQu;

  /// No description provided for @guanBiSouSuo.
  ///
  /// In zh, this message translates to:
  /// **'关闭搜索'**
  String get guanBiSouSuo;

  /// No description provided for @zhengZaiXuJieGeChi.
  ///
  /// In zh, this message translates to:
  /// **'正在续接歌池…'**
  String get zhengZaiXuJieGeChi;

  /// No description provided for @geChiZhengZaiXuJianDian.
  ///
  /// In zh, this message translates to:
  /// **'歌池正在续接…'**
  String get geChiZhengZaiXuJianDian;

  /// No description provided for @shangChuanShiBaiQingShaoHouChongShi.
  ///
  /// In zh, this message translates to:
  /// **'上传失败，请稍后重试'**
  String get shangChuanShiBaiQingShaoHouChongShi;

  /// No description provided for @qingShaoHouChongShi.
  ///
  /// In zh, this message translates to:
  /// **'请稍后重试'**
  String get qingShaoHouChongShi;

  /// No description provided for @zhengZaiBuQuan.
  ///
  /// In zh, this message translates to:
  /// **'（正在补全…）'**
  String get zhengZaiBuQuan;

  /// No description provided for @jieKouJuJueFangWenAccessDeny.
  ///
  /// In zh, this message translates to:
  /// **'接口拒绝访问（Access Deny）'**
  String get jieKouJuJueFangWenAccessDeny;

  /// No description provided for @meiYouBoFangQuanXianFee.
  ///
  /// In zh, this message translates to:
  /// **'没有播放权限 fee={p1}'**
  String meiYouBoFangQuanXianFee(Object p1);

  /// No description provided for @quMuBuCunZai.
  ///
  /// In zh, this message translates to:
  /// **'曲目不存在'**
  String get quMuBuCunZai;

  /// No description provided for @wuBoFangDiZhiCode.
  ///
  /// In zh, this message translates to:
  /// **'无播放地址 code={p1}'**
  String wuBoFangDiZhiCode(Object p1);

  /// No description provided for @sheBeiZhuCeShiBai.
  ///
  /// In zh, this message translates to:
  /// **'设备注册失败'**
  String get sheBeiZhuCeShiBai;

  /// No description provided for @fanHuiShiBaiPlain.
  ///
  /// In zh, this message translates to:
  /// **'{p1}返回失败'**
  String fanHuiShiBaiPlain(Object p1);

  /// No description provided for @bZhanFanHuiCode.
  ///
  /// In zh, this message translates to:
  /// **'B 站返回 code={p1}'**
  String bZhanFanHuiCode(Object p1);

  /// No description provided for @weiZhiShort.
  ///
  /// In zh, this message translates to:
  /// **'未知'**
  String get weiZhiShort;

  /// No description provided for @yiShuRenJiShou.
  ///
  /// In zh, this message translates to:
  /// **'{p1} · {p2}首'**
  String yiShuRenJiShou(Object p1, Object p2);

  /// No description provided for @geShouShuCompact.
  ///
  /// In zh, this message translates to:
  /// **'{p1}首'**
  String geShouShuCompact(Object p1);

  /// No description provided for @gaiWeiShengXu.
  ///
  /// In zh, this message translates to:
  /// **'改为升序'**
  String get gaiWeiShengXu;

  /// No description provided for @jiangXu.
  ///
  /// In zh, this message translates to:
  /// **'降序'**
  String get jiangXu;

  /// No description provided for @shengXu.
  ///
  /// In zh, this message translates to:
  /// **'升序'**
  String get shengXu;

  /// No description provided for @wangLuoBuKeDaHuoBeiWangGuanLanJie.
  ///
  /// In zh, this message translates to:
  /// **'网络不可达或被网关拦截，请检查网络后重试'**
  String get wangLuoBuKeDaHuoBeiWangGuanLanJie;

  /// No description provided for @danMuYiKaiQiSheZhiYuFaSong.
  ///
  /// In zh, this message translates to:
  /// **'弹幕已开启 · 设置与发送'**
  String get danMuYiKaiQiSheZhiYuFaSong;

  /// No description provided for @xianShiZhong.
  ///
  /// In zh, this message translates to:
  /// **'显示中'**
  String get xianShiZhong;

  /// No description provided for @buZu1FenZhong.
  ///
  /// In zh, this message translates to:
  /// **'不足 1 分钟'**
  String get buZu1FenZhong;

  /// No description provided for @buZu1Tian.
  ///
  /// In zh, this message translates to:
  /// **'不足 1 天'**
  String get buZu1Tian;

  /// No description provided for @zhangHaoXinXiHuoQuShiBaiQingShaoHou.
  ///
  /// In zh, this message translates to:
  /// **'账号信息获取失败，请稍后重试'**
  String get zhangHaoXinXiHuoQuShiBaiQingShaoHou;

  /// No description provided for @fengGeGeDan.
  ///
  /// In zh, this message translates to:
  /// **'风格歌单'**
  String get fengGeGeDan;

  /// No description provided for @zanWuFengGeTuiJian.
  ///
  /// In zh, this message translates to:
  /// **'暂无风格推荐'**
  String get zanWuFengGeTuiJian;

  /// No description provided for @wangYiYunYongHu.
  ///
  /// In zh, this message translates to:
  /// **'网易云用户'**
  String get wangYiYunYongHu;

  /// No description provided for @faBiaoPingLun.
  ///
  /// In zh, this message translates to:
  /// **'发表评论'**
  String get faBiaoPingLun;

  /// No description provided for @guanBiKaiGuan.
  ///
  /// In zh, this message translates to:
  /// **'关'**
  String get guanBiKaiGuan;

  /// No description provided for @touMing.
  ///
  /// In zh, this message translates to:
  /// **'透明'**
  String get touMing;

  /// No description provided for @huiFuYinLiang.
  ///
  /// In zh, this message translates to:
  /// **'恢复音量'**
  String get huiFuYinLiang;

  /// No description provided for @guanBiZhuoMianGeCi.
  ///
  /// In zh, this message translates to:
  /// **'关闭桌面歌词'**
  String get guanBiZhuoMianGeCi;

  /// No description provided for @quXiaoXiHuanShort.
  ///
  /// In zh, this message translates to:
  /// **'取消喜欢'**
  String get quXiaoXiHuanShort;

  /// No description provided for @beiSuWithLabel.
  ///
  /// In zh, this message translates to:
  /// **'倍速 · {p1}'**
  String beiSuWithLabel(Object p1);

  /// No description provided for @wuFaDaKaiShiPinDiZhi.
  ///
  /// In zh, this message translates to:
  /// **'无法打开视频地址'**
  String get wuFaDaKaiShiPinDiZhi;

  /// No description provided for @danMuJiaZaiShiBaiQingGuanBiHouChongKai.
  ///
  /// In zh, this message translates to:
  /// **'弹幕加载失败，请关闭后重开'**
  String get danMuJiaZaiShiBaiQingGuanBiHouChongKai;

  /// No description provided for @huanYuan.
  ///
  /// In zh, this message translates to:
  /// **'还原'**
  String get huanYuan;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'ko', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
