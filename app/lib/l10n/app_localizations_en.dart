// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get fanYin => '泛音';

  @override
  String get i3SpiWeiFanHuiBuvidXiLieZiDuan => 'I3 spi: buvid fields missing';

  @override
  String get i1NavXiangYingBuShiJsonDuiXiang =>
      'I1 nav: response is not a JSON object';

  @override
  String get i1NavQueShaoWbiImg => 'I1 nav: wbi_img missing';

  @override
  String get i1NavWbiImgQueShaoImgUrlSubUrl =>
      'I1 nav: wbi_img is missing img_url/sub_url';

  @override
  String get bZhanXuYaoDengLu => 'Bilibili: login required';

  @override
  String get bZhanXuYaoDengLuYanZhengMa => 'Bilibili: login required (captcha)';

  @override
  String get g1XiangYingQueShaoData => 'G1: response has no data';

  @override
  String get g1XiangYingQueShaoQrcodeKeyUrl =>
      'G1: response is missing qrcode_key/url';

  @override
  String get anQuanCeLveZuZhiXiangBuAnQuanHuoFeiKuGouMuBiaoFa =>
      'Security policy blocked sending account info to an insecure or non-KuGou target';

  @override
  String get yunPanFanHuiLiaoBuAnQuanDeShangChuanMuBiaoYiTing =>
      'Cloud drive returned an insecure upload target; upload stopped';

  @override
  String get wangLuoWangGuanLanJieUrlGuoLvWuFaFangWenKuGouJie =>
      'Blocked by network gateway (URL filtering); KuGou API unreachable';

  @override
  String get wangLuoQingQiuShiBai => 'Network request failed';

  @override
  String get weiZhiGeQu => 'Unknown track';

  @override
  String get weiZhiGeShou => 'Unknown artist';

  @override
  String get geDan => 'Playlist';

  @override
  String get bangDan => 'Charts';

  @override
  String get kuGouGuanFang => 'KuGou Official';

  @override
  String get zhuanJi => 'Album';

  @override
  String get yunPanDaoRuShiBai => 'Cloud drive import failed';

  @override
  String get saoMaHuiHuaYiShiXiao => 'QR session expired';

  @override
  String get quanBu => 'All';

  @override
  String get souSuo => 'Search';

  @override
  String get geDanSouSuo => 'Playlist search';

  @override
  String get zhuanJiSouSuo => 'Album search';

  @override
  String get geShouSouSuo => 'Artist search';

  @override
  String get geDanXiangQing => 'Playlist details';

  @override
  String get zhuanJiXiangQing => 'Album details';

  @override
  String get geShouXiangQing => 'Artist details';

  @override
  String get geShouGeQu => 'Artist tracks';

  @override
  String get meiRiTuiJian => 'Daily recommendations';

  @override
  String get siRenFm => 'Personal FM';

  @override
  String get xinGeSuDi => 'New releases';

  @override
  String get fenLeiGeDan => 'Playlist categories';

  @override
  String get xinDieShangJia => 'New albums';

  @override
  String get geShouLieBiao => 'Artists';

  @override
  String get geDanBiaoQian => 'Playlist tags';

  @override
  String get tuiJian => 'Recommended';

  @override
  String get woXiHuan => 'Liked';

  @override
  String get geQuXiangQing => 'Track details';

  @override
  String get yongHuGeDan => 'User playlists';

  @override
  String get wangYiYunHuiHuaShiXiaoCode301 =>
      'NetEase session expired (code=301)';

  @override
  String get boFangDiZhiWeiKong => 'Playback URL is empty';

  @override
  String get mvXiangQing => 'MV details';

  @override
  String get mvXiangQingWeiKong => 'MV details are empty';

  @override
  String get mvBoFangDiZhiWeiKong => 'MV playback URL is empty';

  @override
  String get yongHuXiangQingCodeYiChang => 'Unexpected user details code';

  @override
  String get vipXinXiCodeYiChang => 'Unexpected VIP info code';

  @override
  String get yongHuDengJiCodeYiChang => 'Unexpected user level code';

  @override
  String get yunPan => 'Cloud Drive';

  @override
  String get yunPanWenJianMeiYouQuLiuDiZhi => 'Cloud file has no stream URL';

  @override
  String get yunPanXiangQing => 'Cloud file details';

  @override
  String get wangYiYunXiangYingBuShiJson => 'NetEase response is not JSON';

  @override
  String get zuiRe => 'Hottest';

  @override
  String get zuiXin => 'Newest';

  @override
  String get pingLun => 'Comments';

  @override
  String get reSou => 'Trending searches';

  @override
  String get louCengPingLun => 'Thread comments';

  @override
  String get yinYueRen => 'Artist';

  @override
  String get zuoZheHuiFu => 'Author reply';

  @override
  String get wangLuoYiChangQingShaoHouChongShi =>
      'Network error. Please try again.';

  @override
  String get yuFuWuQiJianLiAnQuanLianJieShiBaiQingJianChaWang =>
      'Could not establish a secure connection. Check your network or proxy settings and try again.';

  @override
  String get wangLuoLianJieShiBaiQingJianChaWangLuoHouChongSh =>
      'Connection failed. Check your network and try again.';

  @override
  String get wangLuoQingQiuChaoShiQingJianChaWangLuoHouChongS =>
      'Request timed out. Check your network and try again.';

  @override
  String get renZhengJieKouNeiRongYiShengLve => '[Credential response omitted]';

  @override
  String get wuFaAnQuanJieXiDeUrlYiShengLve => '[Unparsable URL omitted]';

  @override
  String get qianTaoNeiRongYiShengLve => '[Nested content omitted]';

  @override
  String get wuFaAnQuanJieXiDeBiaoDanYiShengLve => '[Unparsable form omitted]';

  @override
  String get pingJuTouYiShengLve => '[Credential headers omitted]';

  @override
  String get qiDongFuWuXiangYingChaoShiRengZaiDengDaiDangQian =>
      'Startup service timed out. Still waiting for the current task to finish to avoid duplicate initialization.';

  @override
  String get zhengZaiQiDongFanYin => 'Starting 泛音…';

  @override
  String get xiangXiJiLuJianYingYongMuLuCrashLog =>
      'See crash.log in the app directory for details.';

  @override
  String get chongShi => 'Retry';

  @override
  String get guanBiTiShi => 'Close';

  @override
  String get biaoZhun => 'Standard';

  @override
  String get gaoPin => 'High';

  @override
  String get wuSun => 'Lossless';

  @override
  String get reMen => 'Popular';

  @override
  String get hongXin => 'Hearted';

  @override
  String get xiaoZhong => 'Niche';

  @override
  String get suLan => 'Quick picks';

  @override
  String get hongXinDianTai => 'Hearted radio';

  @override
  String get xiaoZhongDianTai => 'Niche radio';

  @override
  String get suLanDianTai => 'Quick radio';

  @override
  String get caiNiXiHuan => 'For you';

  @override
  String get xiaoZhongJingXuan => 'Niche picks';

  @override
  String get duanQuSuLan => 'Short-track picks';

  @override
  String get genJuKouWeiTuiJianXiangSiGeQu =>
      'Similar tracks based on your taste';

  @override
  String get genJuFengGeTuiJianXiangSiGeQu => 'Similar tracks by style';

  @override
  String get huaYuLiuXing => 'Mandarin pop';

  @override
  String get jingDian => 'Classics';

  @override
  String get minYao => 'Folk';

  @override
  String get dianZi => 'Electronic';

  @override
  String get qingYinYue => 'Easy listening';

  @override
  String get duLi => 'Indie';

  @override
  String get lengMen => 'Underrated';

  @override
  String get jueShi => 'Jazz';

  @override
  String get laiZiReMenHuaYuLiuXing => 'From “Popular / Mandarin pop”';

  @override
  String get laiZiMinYaoDianZi => 'From “Folk / Electronic”';

  @override
  String get laiZiDuLiJueShi => 'From “Indie / Jazz”';

  @override
  String get diXia => 'Underground';

  @override
  String get baoZang => 'Hidden gems';

  @override
  String get geQu => 'Tracks';

  @override
  String get geShou => 'Artists';

  @override
  String get woXiHuanDeYinYue => 'My liked music';

  @override
  String get xiHuan => 'Like';

  @override
  String get moRenShouCang => 'Default favorites';

  @override
  String get paiHangBang => 'Charts';

  @override
  String get faXian => 'Discover';

  @override
  String get yinYueYunPan => 'Cloud Drive';

  @override
  String get kuGou => 'KuGou';

  @override
  String get wangYiYun => 'NetEase';

  @override
  String get biLiBiLi => 'Bilibili';

  @override
  String get xuYaoDengLu => 'Login required';

  @override
  String get meiYouBoFangQuanXian => 'No playback permission';

  @override
  String get weiZhaoDao => 'Not found';

  @override
  String get qingQiuGuoYuPinFan => 'Too many requests';

  @override
  String get shangYouXiangYingYiChang => 'Unexpected upstream response';

  @override
  String get moRen => 'Default';

  @override
  String get biaoZhunShenQianZiShiYingYangShi =>
      'Standard adaptive light/dark style';

  @override
  String get ruiShiGuoJiPaiBan => 'Swiss International Typography';

  @override
  String get zhiBaiMoHeiWuChenXianPaiBanXuanZhongHouQuanZhanQ =>
      'Paper-white, ink-black sans-serif layout; switches the whole app to light mode';

  @override
  String get evaHong => 'EVA Red';

  @override
  String get evaZhanShuChaoSuanHongHeiZhongDuanMingRiXiangAnS =>
      'EVA tactical supercomputer terminal in red and black — Asuka dark alert style';

  @override
  String get evaLan => 'EVA Blue';

  @override
  String get evaLingHaoJiCiBaiBingLanLingBoLiLiangSeDangAnJie =>
      'Unit-00 porcelain white and ice blue — Rei light archive interface';

  @override
  String get souSuoGeQuGeShouZhuanJi => 'Search tracks, artists and albums';

  @override
  String get qingLv => 'Teal';

  @override
  String get shanHu => 'Coral';

  @override
  String get dianLan => 'Indigo';

  @override
  String get ziLuoLan => 'Violet';

  @override
  String get geMing => 'Title';

  @override
  String get shiChang => 'Duration';

  @override
  String get weiDengLu => 'Not signed in';

  @override
  String get qingXianDengLuHouChaKanYunPan =>
      'Sign in to view your cloud drive';

  @override
  String get huoQuYunPanLieBiaoShiBai => 'Failed to load the cloud drive';

  @override
  String get queShaoYunPanWenJianHash => 'Cloud file hash is missing';

  @override
  String get queShaoYunPanWenJianBiaoZhiWuFaBoFang =>
      'Cloud file identifier missing; cannot play';

  @override
  String get wangLuoWangGuanLanJieUrlGuoLvWuFaFangWenKuGou =>
      'Blocked by network gateway (URL filtering); KuGou unreachable';

  @override
  String get yunPanBoFangDiZhiXiangYingWuFaJieXi =>
      'Could not parse the cloud playback response';

  @override
  String get huoQuYunPanBoFangDiZhiShiBai =>
      'Failed to get the cloud playback URL';

  @override
  String get yunPanWenJianZanWuBoFangDiZhi =>
      'Cloud file has no playback URL yet';

  @override
  String get qingXianDengLuHouCaoZuoYunPan =>
      'Sign in to manage your cloud drive';

  @override
  String get queShaoYunPanWenJianBiaoZhiKvIdWuFaShanChu =>
      'Cloud file id (kv_id) missing; cannot delete';

  @override
  String get queShaoYunPanWenJianBiaoZhiWuFaShanChu =>
      'Cloud file identifier missing; cannot delete';

  @override
  String get shanChuYunPanGeQuShiBai => 'Failed to delete the cloud track';

  @override
  String get qingXianDengLuHouShangChuanYunPan =>
      'Sign in to upload to your cloud drive';

  @override
  String get wenJianWeiKong => 'File is empty';

  @override
  String get wenJianWeiKongWuFaShangChuan => 'File is empty; cannot upload';

  @override
  String get chuShiHuaShangChuanShiBai => 'Failed to start the upload';

  @override
  String get huoQuShangChuanShouQuanShiBai =>
      'Failed to get upload authorization';

  @override
  String get chuShiHuaFenPianShangChuanShiBai =>
      'Failed to start the chunked upload';

  @override
  String get fenPianShangChuanShiBai => 'Chunk upload failed';

  @override
  String get wanChengShangChuanShiBai => 'Failed to finish the upload';

  @override
  String get wangLuoQingQiuShiBaiQingShaoHouChongShi =>
      'Request failed. Please try again later.';

  @override
  String get yunPanFuWuXiangYingWeiKong =>
      'Cloud service returned an empty response';

  @override
  String get yunPanFuWuXiangYingWuFaJieXi =>
      'Could not parse the cloud service response';

  @override
  String get queShaoGeQuId => 'Track ID is missing';

  @override
  String get queShaoZiYuanId => 'Resource ID is missing';

  @override
  String get louCengCanShuQueShiQingShuaXinPingLunHouChongShi =>
      'Thread parameter missing. Refresh comments and try again.';

  @override
  String get pingLunChiWeiZhiQingShuaXinPingLunHouZaiShi =>
      'Unknown comment pool. Refresh comments and try again.';

  @override
  String get louCengXinXiBuWanZhengQingShuaXinPingLunHouZaiSh =>
      'Incomplete thread info. Refresh comments and try again.';

  @override
  String get huiFuNeiRongBuNengWeiKong => 'Reply cannot be empty';

  @override
  String get huiFu => 'Reply';

  @override
  String get fenLeiCanShuQueShi => 'Category parameter missing';

  @override
  String get reCiCanShuQueShi => 'Keyword parameter missing';

  @override
  String get queShaoMvHashWuFaJiaZaiDanMu =>
      'MV hash missing; cannot load danmaku';

  @override
  String get queShaoMvHashWuFaFaSongDanMu =>
      'MV hash missing; cannot send danmaku';

  @override
  String get danMu => 'Danmaku';

  @override
  String get danMuNeiRongBuNengWeiKong => 'Danmaku cannot be empty';

  @override
  String get wangLuoCuoWuWuFaFaSong => 'Network error; message not sent';

  @override
  String get wangLuoWangGuanLanJieWuFaFaSong =>
      'Blocked by network gateway; message not sent';

  @override
  String get pingLunXiangYingWuFaJieXi =>
      'Could not parse the comments response';

  @override
  String get xuYaoAnQuanJiaoYanQingXianZaiKuGouGuanFangKeHuDu =>
      'Verification required: complete it once in the official KuGou app, then try again';

  @override
  String get pingLunCanShuJiaoYanShiBai20006 =>
      'Comment parameter check failed (20006)';

  @override
  String get pingLunNeiRongChangDuBuHeGui10003 =>
      'Comment length not allowed (10003)';

  @override
  String get dengLuHouCaiNengFaBiaoPingLun => 'Sign in to post a comment';

  @override
  String get pingLunNeiRongBuNengWeiKong => 'Comment cannot be empty';

  @override
  String get pingLunJieKouBeiJuJueAccessDeny =>
      'Comment API refused (Access Deny)';

  @override
  String get pingLunXiangYingWeiKong => 'Comments response is empty';

  @override
  String get wangLuoCuoWuWuFaJiaZaiPingLun =>
      'Network error; comments could not load';

  @override
  String get dengLuTaiChuFaAnQuanJiaoYanSsa20028QingChongXinD =>
      'Session triggered a security check (SSA 20028). Sign in again and retry.';

  @override
  String get pingLunXuYaoAnQuanJiaoYanSsa20028 =>
      'Comments need verification (SSA 20028)';

  @override
  String get pingLunCanShuWuXiao => 'Invalid comment parameter';

  @override
  String get pingLunQianMingJiaoYanShiBai => 'Comment signature check failed';

  @override
  String get yongHu => 'User';

  @override
  String get xueSheng => 'Student';

  @override
  String get yanYuan => 'Singer';

  @override
  String get renZheng => 'Verified';

  @override
  String get mingXing => 'Celebrity';

  @override
  String get daRen => 'Influencer';

  @override
  String get yanChangZhe => 'Performer';

  @override
  String get chaoJiVip => 'Super VIP';

  @override
  String get gaiNianVip => 'Concept VIP';

  @override
  String get zhouKa => 'Weekly pass';

  @override
  String get changTingVip => 'Listening VIP';

  @override
  String get jiKa => 'Quarterly pass';

  @override
  String get haoHuaVip => 'Deluxe VIP';

  @override
  String get nianFeiYinYueBao => 'Annual music package';

  @override
  String get yinYueBao => 'Music package';

  @override
  String get sheBeiZhuCeXiangYingWeiKong =>
      'Device registration response is empty';

  @override
  String get sheBeiZhuCeXiangYingWuFaJieXi =>
      'Could not parse the device registration response';

  @override
  String get sheBeiZhuCeWeiFanHuiDfid =>
      'Device registration did not return dfid';

  @override
  String get sheBeiZhuCeWangLuoCuoWu => 'Device registration network error';

  @override
  String get sheBeiZhuCeYiChangQingShaoHouChongShi =>
      'Device registration failed. Please try again later.';

  @override
  String get huaYu => 'Mandarin';

  @override
  String get ouMei => 'Western';

  @override
  String get riBen => 'Japanese';

  @override
  String get hanGuo => 'Korean';

  @override
  String get nan => 'Male';

  @override
  String get nv => 'Female';

  @override
  String get zuHe => 'Group';

  @override
  String get liuXing => 'Pop';

  @override
  String get xiHa => 'Hip-hop';

  @override
  String get yaoGun => 'Rock';

  @override
  String get guDian => 'Classical';

  @override
  String get geDanFenLei => 'Playlist categories';

  @override
  String get zanWuGeDanFenLei => 'No playlist categories yet';

  @override
  String get zanWuXinGe => 'No new tracks yet';

  @override
  String get zanWuXinDie => 'No new albums yet';

  @override
  String get zanWuGeShou => 'No artists yet';

  @override
  String get dangQianWangLuoBeiWangGuanLanJieUrlGuoLvWuFaFang =>
      'Your network is blocking KuGou (gateway URL filtering)';

  @override
  String get tanSuoJieKou => 'Explore API';

  @override
  String get dangQianWangLuoBeiWangGuanLanJieUrlGuoLvWuFaFang_2 =>
      'Your network is blocking KuGou (gateway URL filtering).\nSwitch to a mobile hotspot and try again.';

  @override
  String get siRenFmXuYaoDengLuHouChaKan => 'Sign in to view Personal FM';

  @override
  String get dengLuHouKeHuoQuSiRenFm => 'Sign in to get Personal FM';

  @override
  String get siRenFmZanWuKeBoFangGeQu =>
      'Personal FM has nothing playable right now';

  @override
  String get siRenFmWangLuoCuoWu => 'Personal FM network error';

  @override
  String get siRenFmYiChangQingShaoHouChongShi =>
      'Personal FM failed. Please try again later.';

  @override
  String get huoQuErWeiMaShiBai => 'Failed to get the QR code';

  @override
  String get erWeiMaXiangYingYiChang => 'Unexpected QR code response';

  @override
  String get erWeiMaKeyWeiKong => 'QR key is empty';

  @override
  String get faSongYanZhengMaShiBai => 'Failed to send the verification code';

  @override
  String get dengLuShiBai => 'Sign-in failed';

  @override
  String get dengLuXiangYingYiChang => 'Unexpected sign-in response';

  @override
  String get dengLuChengGongDanWeiFanHuiToken =>
      'Signed in, but no token returned';

  @override
  String get huoQuYongHuZiLiaoShiBai => 'Failed to load the user profile';

  @override
  String get queShaoShiPinHash => 'Video hash is missing';

  @override
  String get shiPinDiZhiWeiKong => 'Video URL is empty';

  @override
  String get wuXiaoDeMvId => 'Invalid MV ID';

  @override
  String get qingXianDengLu => 'Please sign in first';

  @override
  String get wangLuoCuoWu => 'Network error';

  @override
  String get mvShouCangCaoZuoShiBai => 'MV favorite action failed';

  @override
  String get mvJieKouXiangYingWuFaJieXi =>
      'Could not parse the MV API response';

  @override
  String get xuYaoDengLuAnQuanYanZheng => 'Login or verification required';

  @override
  String get qianMingShiBai20006 => 'Signature failed (20006)';

  @override
  String get quMuQueShaoHash => 'Track is missing its hash';

  @override
  String get boFangDiZhiXiangYingWuFaJieXi =>
      'Could not parse the playback URL response';

  @override
  String get chuFaAnQuanYanZhengSsa20028QingChongXinDengLuHou =>
      'Security check triggered (SSA 20028). Sign in again and retry.';

  @override
  String get boFangXuYaoDengLuAnQuanYanZhengYouKeTongDaoYiGua =>
      'Playback requires sign-in or verification (guest access is closed)';

  @override
  String get wuFaHuoQuBoFangDiZhi => 'Could not get the playback URL';

  @override
  String get minYaoJingXuan => 'Folk picks';

  @override
  String get shuoChangReGe => 'Rap hits';

  @override
  String get guoFengXinSheng => 'Guofeng new voices';

  @override
  String get yaoGunJingDian => 'Rock classics';

  @override
  String get dianZiYeXing => 'Electronic after dark';

  @override
  String get zhiYuXi => 'Soothing';

  @override
  String get meiRiTuiJianJiaZaiShiBaiQingJianChaWangLuoHouCho =>
      'Daily recommendations failed to load. Check your network and retry.';

  @override
  String get dengLuHouKeHuoQuGeXingHuaMeiRiTuiJian =>
      'Sign in for personalized daily recommendations';

  @override
  String get fengGeTuiJian => 'Style-based picks';

  @override
  String get fengGeTuiJianJiaZaiShiBaiQingShaoHouChongShi =>
      'Style picks failed to load. Please try again later.';

  @override
  String get dengLuHouKeHuoQuGengTieHeKouWeiDeFengGeTuiJian =>
      'Sign in for style picks that match your taste better';

  @override
  String get dengLuHouKeHuoQuFengGeTuiJian => 'Sign in for style-based picks';

  @override
  String get tuiJianGeDan => 'Recommended playlists';

  @override
  String get tuiJianGeDanJiaZaiShiBai => 'Failed to load recommended playlists';

  @override
  String get zanWuTuiJianGeDan => 'No recommended playlists yet';

  @override
  String get bianJiJingXuan => 'Editor’s picks';

  @override
  String get bianJiJingXuanJiaZaiShiBai => 'Failed to load editor’s picks';

  @override
  String get zanWuBianJiJingXuan => 'No editor’s picks yet';

  @override
  String get tuiJianJieKou => 'Recommendations API';

  @override
  String get xuYaoDengLuHouChaKan => 'Sign in to view';

  @override
  String get meiRiTuiJianXuYaoDengLu => 'Daily recommendations require sign-in';

  @override
  String get meiRiTuiJianXiangYingWuFaJieXi =>
      'Could not parse the daily recommendations response';

  @override
  String get meiRiTuiJianXuYaoDengLuHuoAnQuanJiaoYan =>
      'Daily recommendations require sign-in or verification';

  @override
  String get meiRiTuiJianXuYaoDengLuHouChaKan =>
      'Sign in to view daily recommendations';

  @override
  String get meiRiTuiJianWangLuoCuoWu => 'Daily recommendations network error';

  @override
  String get meiRiTuiJianYiChangQingShaoHouChongShi =>
      'Daily recommendations failed. Please try again later.';

  @override
  String get qingQiuShiBai => 'Request failed';

  @override
  String get qianMingJiaoYanShiBai20006 => 'Signature check failed (20006)';

  @override
  String get qingQiuCanShuQueShi20010 => 'Request parameter missing (20010)';

  @override
  String get yunDuanGeDanJianQuanShiBai20017QingTuiChuHouChon =>
      'Cloud playlist authorization failed (20017). Sign out and sign in again.';

  @override
  String get dengLuTaiWuXiao20018QingTuiChuHouChongXinDengLu =>
      'Session is invalid (20018). Sign out and sign in again.';

  @override
  String get chuFaAnQuanJiaoYanSsa20028QingChongXinDengLuHouZ =>
      'Security check triggered (SSA 20028). Sign in again and retry.';

  @override
  String get jieXiYongHuGeDanXiangYingShiBai =>
      'Could not parse the user playlists response';

  @override
  String get huoQuYongHuGeDanShiBai => 'Failed to load user playlists';

  @override
  String get jieXiGuanZhuLieBiaoXiangYingShiBai =>
      'Could not parse the following list response';

  @override
  String get huoQuGuanZhuLieBiaoShiBai => 'Failed to load the following list';

  @override
  String get jieXiYongHuGeDanGeQuXiangYingShiBai =>
      'Could not parse the playlist tracks response';

  @override
  String get huoQuYongHuGeDanGeQuShiBai => 'Failed to load playlist tracks';

  @override
  String get tianJiaDaoWoXiHuanShiBai => 'Failed to add to Liked';

  @override
  String get congWoXiHuanYiChuShiBai => 'Failed to remove from Liked';

  @override
  String get ziJianShouCangJiaLieBiaoBuWanZhengQingChongShi =>
      'Your saved-folder list is incomplete. Please retry.';

  @override
  String get shiPinBuCunZai => 'Video does not exist';

  @override
  String get wuXiaoDeBZhanNeiRongId => 'Invalid Bilibili content ID';

  @override
  String get bZhanLieBiaoFenYeYiChangWeiFanHuiWanZhengNeiRong =>
      'Bilibili paging went wrong; the list is incomplete';

  @override
  String get bZhanNeiRong => 'Bilibili content';

  @override
  String get wuXiaoDeUpZhuId => 'Invalid uploader ID';

  @override
  String get saoMaChengGongDanWeiShouDaoDengLuPingJu =>
      'Scan succeeded, but no login credentials were received';

  @override
  String get dengLuTaiQueRenShiBaiQingChongShi =>
      'Could not confirm the session. Please retry.';

  @override
  String get qingXianDengLuBiLiBiLi => 'Sign in to Bilibili first';

  @override
  String get shouCangJiaFenYeYiChangWeiFanHuiWanZhengLieBiao =>
      'Folder paging went wrong; the list is incomplete';

  @override
  String get bZhanGaiShiPinWuKeYongYinGui =>
      'Bilibili: this video has no usable audio';

  @override
  String get bZhanQuMuIdWeiKong => 'Bilibili: track id is empty';

  @override
  String get wuFaDingWeiGaiGeQuQueShaoGeQuIdGeMing =>
      'Cannot locate this track (missing track ID or title)';

  @override
  String get kuGouWeiDengLuWuFaDuQuYunDuanZiLiaoKu =>
      'KuGou is not signed in; cannot read the cloud library';

  @override
  String get kuGouWeiDengLuWuFaDuQuWoXiHuan =>
      'KuGou is not signed in; cannot read Liked';

  @override
  String get weiZhaoDaoYunDuanWoXiHuanGeDan => 'Cloud Liked playlist not found';

  @override
  String get yunDuanWoXiHuanGeDanQueShaoListid =>
      'Cloud Liked playlist has no listId';

  @override
  String get kuGouWeiDengLuWuFaTongBuHongXin =>
      'KuGou is not signed in; cannot sync hearts';

  @override
  String get zhuanJiJiaZaiShiBaiJieKouBuKeYongHuoGaiIdWuGongK =>
      'Album failed to load: API unavailable or no public data for this ID';

  @override
  String get fanHui => 'Back';

  @override
  String get boFangQuanBu => 'Play all';

  @override
  String get chongXinJiaZai => 'Reload';

  @override
  String get geShouJiaZaiShiBaiJieKouBuKeYongHuoWuGongKaiShuJ =>
      'Artist failed to load: API unavailable or no public data';

  @override
  String get zanWuGongKaiGeQu => 'No public tracks';

  @override
  String get geShouJieShao => 'About the artist';

  @override
  String get guanBi => 'Close';

  @override
  String get zaiXianJiaZai => 'Load online';

  @override
  String get heJiXiLie => 'Collections / series';

  @override
  String get jiaZaiGengDuoChongShi => 'Load more / Retry';

  @override
  String get geQuJiaZaiShiBaiJieKouBuKeYongHuoWuGongKaiShuJu =>
      'Track failed to load: API unavailable or no public data';

  @override
  String get weiZhaoDaoPiPeiDeGeQu => 'No matching tracks found';

  @override
  String get shangLaHuoShaoHouJiaZaiGengDuo => 'Pull up or wait to load more';

  @override
  String get boFangReMen => 'Play popular';

  @override
  String get chaKanXiangQing => 'View details';

  @override
  String get souSuoGeQu => 'Search tracks…';

  @override
  String get dingWeiDangQianBoFang => 'Jump to now playing';

  @override
  String get dengLuPingJuHuiFuChaoShiYiJinRuYouKeMoShiBaoCunD =>
      'Restoring your session timed out; you are now in guest mode. Saved credentials were not deleted.';

  @override
  String get dengLuPingJuHuiFuShiBaiQingJianChaXiTongAnQuanCu =>
      'Could not restore your session. Check the system secure storage, then sign in again.';

  @override
  String get saoMaChengGongDanWeiFanHuiHuiHua =>
      'Scan succeeded, but no session was returned';

  @override
  String get qingShuRu11WeiShouJiHao => 'Enter an 11-digit phone number';

  @override
  String get qingShuRuZhiShao4WeiYanZhengMa =>
      'Enter at least 4 digits of the code';

  @override
  String get qingShuRuZhangHaoHeMiMa => 'Enter your account and password';

  @override
  String get yiDengLuDanAnQuanCunChuBuKeYongBenCiDengLuWuFaBa =>
      'Signed in, but secure storage is unavailable; this session cannot be saved. Please try again later.';

  @override
  String get yiTuiChuDengLuAnQuanCunChuQingLiWeiWanChengQingJ =>
      'Signed out, but secure storage cleanup did not finish. Check system permissions.';

  @override
  String get erWeiMaHuoQuShiBaiQingChongShi =>
      'Failed to get the QR code. Please retry.';

  @override
  String get yiDengLuDanAnQuanCunChuBuKeYongBenCiDengLuWuFaBa_2 =>
      'Signed in, but secure storage is unavailable; this session cannot be saved.';

  @override
  String get dengLuZhuangTaiQueRenShiBaiQingChongShi =>
      'Could not confirm the session. Please retry.';

  @override
  String get biLiBiLiZhangHao => 'Bilibili account';

  @override
  String get qieHuanZhangHao => 'Switch account';

  @override
  String get tuiChuDengLu => 'Sign out';

  @override
  String get daKaiBiLiBiLiAppSaoYiSaoSaoMaHouZaiShouJiShangQu =>
      'Open the Bilibili app, tap Scan, then confirm on your phone.';

  @override
  String get yiSaoMaQingZaiShouJiShangQueRen =>
      'Scanned. Confirm on your phone.';

  @override
  String get erWeiMaYiGuoQiQingShuaXin => 'QR code expired. Refresh it.';

  @override
  String get dengDaiSaoMa => 'Waiting for scan';

  @override
  String get shuaXinErWeiMa => 'Refresh QR code';

  @override
  String get dengLu => 'Sign in';

  @override
  String get saoMa => 'Scan';

  @override
  String get yanZhengMa => 'Code';

  @override
  String get zhangHao => 'Account';

  @override
  String get shouJiYanZhengMaDengLu => 'Sign in with SMS code';

  @override
  String get shiYongKuGouBangDingShouJiHaoJieShouDuanXinYanZh =>
      'Use the phone number linked to KuGou to receive the SMS code';

  @override
  String get shouJiHao => 'Phone number';

  @override
  String get huoQuYanZhengMa => 'Get code';

  @override
  String get zhangHaoMiMaDengLu => 'Sign in with account and password';

  @override
  String get kuGouZhangHaoShouJiHaoMiMa => 'KuGou account / phone + password';

  @override
  String get zhangHaoShouJiHao => 'Account / phone';

  @override
  String get miMa => 'Password';

  @override
  String get youKeJiXuXianTingGe => 'Continue as guest';

  @override
  String get dengLuChengGong => 'Signed in';

  @override
  String get qingYongKuGouAppSaoMaDengLu =>
      'Scan with the KuGou app to sign in';

  @override
  String get mei3MiaoZiDongJianCe => 'Checked automatically every 3 seconds';

  @override
  String get erWeiMaYiGuoQi => 'QR code expired';

  @override
  String get shuaXin => 'Refresh';

  @override
  String get kuGouSaoMaDengLu => 'Sign in to KuGou by QR';

  @override
  String get daKaiShouJiKuGouSaoYiSaoDengLuHouKeTongBuXiHuanY =>
      'Open the KuGou app and scan. After signing in you can sync likes and playback permissions.';

  @override
  String get wangYiYunZhangHao => 'NetEase account';

  @override
  String get wangYiYunSaoMaDengLu => 'Sign in to NetEase by QR';

  @override
  String get daKaiShouJiWangYiYunYinYueAppSaoYiSaoSaoMiaoXiaF =>
      'Open the NetEase Cloud Music app → Scan → scan the code below';

  @override
  String get qingYongWangYiYunYinYueAppSaoMaDengLu =>
      'Scan with the NetEase Cloud Music app to sign in';

  @override
  String get mei2MiaoZiDongJianCe => 'Checked automatically every 2 seconds';

  @override
  String get yiDengLu => 'Signed in';

  @override
  String get dangQianYinYuanBuZhiChiYunPan =>
      'The current source does not support the cloud drive';

  @override
  String get yunPanJiaZaiShiBaiQingShaoHouChongShi =>
      'Failed to load the cloud drive. Please try again later.';

  @override
  String get congYunPanShanChu => 'Delete from cloud';

  @override
  String get quXiao => 'Cancel';

  @override
  String get shanChu => 'Delete';

  @override
  String get yiCongYunPanShanChu => 'Deleted from cloud';

  @override
  String get shangChuanDaoYunPan => 'Upload to cloud';

  @override
  String get souSuoYunPanGeQu => 'Search cloud tracks';

  @override
  String get yunPanZanWuGeQu => 'No cloud tracks yet';

  @override
  String get jiaZaiGengDuo => 'Load more';

  @override
  String get dengLuHouChaKanYunPan => 'Sign in to view the cloud drive';

  @override
  String get bengKuiRiZhi => 'Crash log';

  @override
  String get meiYouBengKuiJiLu => 'No crash records';

  @override
  String get qingKong => 'Clear';

  @override
  String get qingTian => 'Sunny';

  @override
  String get kongJieGuo => 'Empty result';

  @override
  String get geCi => 'Lyrics';

  @override
  String get zhouJieLun => 'Jay Chou';

  @override
  String get xiangYingYiChang => 'Unexpected response';

  @override
  String get boFangYu => 'Playback';

  @override
  String get neiRongGuoLv => 'Content filter';

  @override
  String get lianTongXing => 'Connectivity';

  @override
  String get boFang => 'Play';

  @override
  String get zanWuRiZhi => 'No logs';

  @override
  String get yiFuZhiGaiTiao => 'Entry copied';

  @override
  String get yiKaiQiShiShiTanCe => 'Live probe enabled';

  @override
  String get wangLuoQingQiuRiZhi => 'Network request log';

  @override
  String get ceShiWangLuo => 'Test network';

  @override
  String get qingQiu => 'Request';

  @override
  String get xiangYing => 'Response';

  @override
  String get cuoWu => 'Error';

  @override
  String get fuZhiQuanBu => 'Copy all';

  @override
  String get qingKongRiZhi => 'Clear log';

  @override
  String get shiShiTanCe => 'Live probe';

  @override
  String get fuZhiCiTiao => 'Copy entry';

  @override
  String get cuoWuXinXi => 'Error details';

  @override
  String get jingDianXuanFu => 'Classic overlay';

  @override
  String get kuGouLv => 'KuGou green';

  @override
  String get wangYiYunHong => 'NetEase red';

  @override
  String get riLuoJu => 'Sunset orange';

  @override
  String get saiBoZi => 'Cyber purple';

  @override
  String get shenSeKaPian => 'Dark card';

  @override
  String get shuiMoHei => 'Ink black';

  @override
  String get jieSuo => 'Unlock';

  @override
  String get shangYiShou => 'Previous';

  @override
  String get xiaYiShou => 'Next';

  @override
  String get suoDing => 'Lock';

  @override
  String get geDanJiaZaiShiBaiQingJianChaWangLuoHouChongShi =>
      'Failed to load playlists. Check your network and retry.';

  @override
  String get xinDieJiaZaiShiBaiQingJianChaWangLuoHouChongShi =>
      'Failed to load new albums. Check your network and retry.';

  @override
  String get xinGeJiaZaiShiBaiQingJianChaWangLuoHouChongShi =>
      'Failed to load new tracks. Check your network and retry.';

  @override
  String get geShouJiaZaiShiBaiQingJianChaWangLuoHouChongShi =>
      'Failed to load artists. Check your network and retry.';

  @override
  String get tanSuoFaXian => 'Explore';

  @override
  String get zanWuGeDan => 'No playlists yet';

  @override
  String get dangQianWangLuoBeiWangGuanLanJieUrlGuoLvWuFaFang_3 =>
      'Your network is blocking this source (gateway URL filtering).\nSwitch to a mobile hotspot or turn off the router’s web filter and retry.';

  @override
  String get jieKouJuJueFangWenAccessDenyShaoHouChongShiHuoJi =>
      'The API refused access (Access Deny).\nRetry later, or check whether rate limiting was triggered.';

  @override
  String get shuJuJiaZaiShiBaiQingJianChaWangLuoHouChongShi =>
      'Failed to load data. Check your network and retry.';

  @override
  String get lingChenHao => 'Good night';

  @override
  String get zaoShangHao => 'Good morning';

  @override
  String get xiaWuHao => 'Good afternoon';

  @override
  String get wanShangHao => 'Good evening';

  @override
  String get faXianHaoYinLeWeiNiJingXuanJinRiXuanLv =>
      'Discover music · today’s picks for you';

  @override
  String get gengDuo => 'More';

  @override
  String get jinRiReGe => 'Today’s hits';

  @override
  String get targetJianSuo => 'TARGET // SEARCH';

  @override
  String get diShiWuYeYinLvBuWan => 'Night Fifteen · Tuning Complete';

  @override
  String get yiJiaRuWoXiHuan => 'Added to Liked';

  @override
  String get tan => 'EXPLORE';

  @override
  String get yinLvTanSuo => 'Sound exploration';

  @override
  String get geDanBangDanXinDieGeShouArchive =>
      'PLAYLISTS · CHARTS · NEW ALBUMS · ARTISTS // ARCHIVE';

  @override
  String get tanSuo => 'Explore';

  @override
  String get geDanBangDanXinDieGeShou =>
      'Playlists · Charts · New albums · Artists';

  @override
  String get weiNiTuiJian => 'For you';

  @override
  String get meiRiFengGeGeDanJingXuanDailySync =>
      'DAILY · STYLE · PLAYLIST PICKS // DAILY SYNC';

  @override
  String get meiRiFengGeGeDanJingXuan => 'Daily · Style · Playlist picks';

  @override
  String get meiYouKeYongDeSiRenFmYinYuanQingDaoSheZhiLiKaiQi =>
      'No source supports Personal FM. Turn one on in Settings.';

  @override
  String get fmGeChiJiaZaiShiBaiQingJianChaWangLuo =>
      'Failed to load the FM pool. Check your network.';

  @override
  String get dangQianYinYuanBuZhiChiSiRenFm =>
      'The current source does not support Personal FM';

  @override
  String get siRenFmJiaZaiShiBaiQingJianChaWangLuo =>
      'Failed to load Personal FM. Check your network.';

  @override
  String get kaiShiDianTai => 'Start radio';

  @override
  String get liJiShengXiao => 'Applies immediately';

  @override
  String get dangQianBoFang => 'Now playing';

  @override
  String get shangWeiKaiShiDianTai => 'Radio not started yet';

  @override
  String get jieXiaLai => 'Up next';

  @override
  String get geChiJianDiLeHuanGeMoShiHuoGeChiShiShi =>
      'The pool ran dry. Try another mode or pool.';

  @override
  String get buXiHuan => 'Not interested';

  @override
  String get yiCongBoFangLiShiZhongYiChu => 'Removed from history';

  @override
  String get cheXiao => 'Undo';

  @override
  String get qingKongBoFangLiShi => 'Clear play history';

  @override
  String get queDingYaoQingKongQuanBuBoFangLiShiMaCiCaoZuoWuF =>
      'Clear all play history? This cannot be undone.';

  @override
  String get boFangLiShiYiQingKong => 'Play history cleared';

  @override
  String get souSuoLiShiGeQuGeShou => 'Search history, tracks, artists…';

  @override
  String get boFangLiShi => 'Play history';

  @override
  String get souSuoLiShi => 'Search history';

  @override
  String get qingKongLiShi => 'Clear history';

  @override
  String get boFangJiLu => 'Play log';

  @override
  String get tingGeTongJi => 'Listening stats';

  @override
  String get haiMeiYouBoFangJiLuQuSouSuoTingYiShouBa =>
      'No play history yet.\nSearch for a track and give it a listen.';

  @override
  String get weiZhaoDaoPiPeiDeBoFangJiLu => 'No matching play history';

  @override
  String get congLiShiYiChu => 'Remove from history';

  @override
  String get zanWuTingGeShuJuTingJiShouGeHouZaiLaiKanKanFenXi =>
      'No listening data yet.\nPlay a few tracks, then come back for insights.';

  @override
  String get n6TianQian => '6 days ago';

  @override
  String get n5TianQian => '5 days ago';

  @override
  String get n4TianQian => '4 days ago';

  @override
  String get n3TianQian => '3 days ago';

  @override
  String get qianTian => '2 days ago';

  @override
  String get zuoTian => 'Yesterday';

  @override
  String get jinTian => 'Today';

  @override
  String get liShiQuMu => 'Tracks played';

  @override
  String get yuGuShiChang => 'Estimated duration';

  @override
  String get jin7TianTingGePinCi => 'Listening frequency, last 7 days';

  @override
  String get tingGeShiDuanPianHao => 'Preferred listening hours';

  @override
  String get lingChen00000559 => 'Late night (00:00–05:59)';

  @override
  String get shangWu06001159 => 'Morning (06:00–11:59)';

  @override
  String get xiaWu12001759 => 'Afternoon (12:00–17:59)';

  @override
  String get yeWan18002359 => 'Evening (18:00–23:59)';

  @override
  String get changTingGeShouTopBang => 'Most-played artists';

  @override
  String get moRenPaiXu => 'Default order';

  @override
  String get geQuMing => 'Track title';

  @override
  String get geShouMing => 'Artist name';

  @override
  String get souSuoGeMingGeShouZhuanJi => 'Search titles, artists, albums…';

  @override
  String get souSuoGuanZhuDeGeShou => 'Search followed artists…';

  @override
  String get souSuoShouCangDeZhuanJiHuoGeShou =>
      'Search saved albums or artists…';

  @override
  String get shuaXinWoXiHuanGeQu => 'Refresh liked tracks';

  @override
  String get paiXuFangShi => 'Sort by';

  @override
  String get shuaXinGuanZhuGeShou => 'Refresh followed artists';

  @override
  String get shuaXinShouCangZhuanJi => 'Refresh saved albums';

  @override
  String get weiZhaoDaoPiPeiDeGeQuHuanGeGuanJianCiShiShi =>
      'No matching tracks.\nTry another keyword.';

  @override
  String get yiQuXiaoXiHuan => 'Removed from Liked';

  @override
  String get quXiaoXiHuan => 'Unlike';

  @override
  String get wangYiYunWoXiHuanHaiMeiYouHongXinGeQuZaiWangYiYu =>
      'NetEase Liked has no hearted tracks yet.\nTap ♥ in NetEase to sync them here.';

  @override
  String get bZhanMeiYouYunDuanWoXiHuanHongXinZhiBaoCunZaiBen =>
      'Bilibili has no cloud Liked list.\nHearts are stored on this device only.';

  @override
  String get dengLuKuGouZhangHaoHouJiKeTongBuYunDuanWoXiHuan =>
      'Sign in to KuGou to sync your cloud Liked list';

  @override
  String get haiMeiYouHongXinGeQuBoFangShiDianJiKeShouCangDao =>
      'No hearted tracks yet.\nTap ♥ while playing to save one to the cloud.';

  @override
  String get liJiDengLu => 'Sign in';

  @override
  String get dengLuKuGouZhangHaoHouJiKeTongBuGuanZhuDeGeShou =>
      'Sign in to KuGou to sync followed artists';

  @override
  String get zanWuGuanZhuDeGeShouSouSuoGeShouBingDianJiGuanZh =>
      'No followed artists yet.\nSearch for an artist and follow to see them here.';

  @override
  String get weiZhaoDaoPiPeiDeGeShou => 'No matching artists';

  @override
  String get dengLuKuGouZhangHaoHouJiKeTongBuShouCangDeZhuanJ =>
      'Sign in to KuGou to sync saved albums';

  @override
  String get zanWuShouCangDeZhuanJiZaiZhuanJiXiangQingZhongDi =>
      'No saved albums yet.\nSave one from an album page to see it here.';

  @override
  String get weiZhaoDaoPiPeiDeZhuanJi => 'No matching albums';

  @override
  String get xuDengLuHouChaKan => 'Sign in to view';

  @override
  String get danMuYiGuanBiSheZhiYuFaSong =>
      'Danmaku is off · settings and posting';

  @override
  String get dangQianYinYuanBuZhiChiDanMu =>
      'The current source does not support danmaku';

  @override
  String get danMuYiFaSong => 'Danmaku sent';

  @override
  String get yiGuanBi => 'Off';

  @override
  String get touMingDu => 'Opacity';

  @override
  String get ziHao => 'Size';

  @override
  String get suDu => 'Speed';

  @override
  String get miDu => 'Density';

  @override
  String get xiShu => 'Sparse';

  @override
  String get shiZhong => 'Medium';

  @override
  String get miJi => 'Dense';

  @override
  String get xianShiQuYu => 'Area';

  @override
  String get dingBu => 'Top';

  @override
  String get shangBanPing => 'Upper half';

  @override
  String get quanPing => 'Full screen';

  @override
  String get faSongDanMu => 'Send danmaku';

  @override
  String get xieXiaCiKeDeGanShou => 'Write what you feel right now…';

  @override
  String get faSongHouKaiQiDanMuJiKeZaiHuaMianShangKanDao =>
      'Turn on danmaku to see it on the video';

  @override
  String get faSong => 'Send';

  @override
  String get danMuJiaZaiZhong => 'Loading danmaku…';

  @override
  String get zanWuDanMu => 'No danmaku yet';

  @override
  String get dangQianYinYuanBuZhiChiMv =>
      'The current source does not support MV';

  @override
  String get meiYouKeYongDeShiPinPianYuan => 'No playable video source';

  @override
  String get mvJiaZaiShiBai => 'Failed to load the MV';

  @override
  String get zheShouGeZanWuMv => 'No MV for this track';

  @override
  String get boFangMv => 'Play MV';

  @override
  String get dangQianZhuoMianWuFaJinRuXiaoChuangJiXuQuanYeBoF =>
      'Cannot open the mini window on this desktop; continuing full-page playback';

  @override
  String get huanYuanChuangKou => 'Restore window';

  @override
  String get tingZhiBingGuanBi => 'Stop and close';

  @override
  String get suoWeiZhiDingMiNiChuang => 'Shrink to pinned mini window';

  @override
  String get suoXiaoWeiXiaoChuang => 'Shrink to mini window';

  @override
  String get zanTing => 'Pause';

  @override
  String get xiangQing => 'Details';

  @override
  String get qiTaBanBen => 'Other versions';

  @override
  String get guanFangTuiJian => 'Official pick';

  @override
  String get shouCangMv => 'Save MV';

  @override
  String get yiQuXiaoShouCang => 'Removed from saved';

  @override
  String get shouCang => 'Save';

  @override
  String get xiaZai => 'Download';

  @override
  String get faXing => 'Released';

  @override
  String get huaZhi => 'Quality';

  @override
  String get jianJie => 'About';

  @override
  String get beiSu => 'Speed';

  @override
  String get jingYin => 'Mute';

  @override
  String get n10Miao => '10 seconds';

  @override
  String get buXiHuanHuanXiaYiShou => 'Not for me, next';

  @override
  String get yiJingShiSiRenFmDeDiYiShou =>
      'This is already the first Personal FM track';

  @override
  String get shouQi => 'Collapse';

  @override
  String get geChiZhengZaiXuJie => 'Refilling the pool…';

  @override
  String get zanWuBoFangNeiRongQuSouSuoHuoGeDanLiDianYiShouGe =>
      'Nothing playing.\nPick a track from search or a playlist.';

  @override
  String get shouQiBoFangYe => 'Collapse player';

  @override
  String get boFangDuiLie => 'Queue';

  @override
  String get zhengZaiBoFang => 'Now playing';

  @override
  String get gongKai => 'Public';

  @override
  String get shiShiTongXinRiZhi => 'Realtime transport log';

  @override
  String get zanWuBoFangNeiRong => 'Nothing playing';

  @override
  String get shouQiGeCi => 'Collapse lyrics';

  @override
  String get boFangShiBaiKeDianXiaYiShouChongShi =>
      'Playback failed. Skip to the next track to retry.';

  @override
  String get quDengLu => 'Sign in';

  @override
  String get queShaoGeQuGuanLianIdWuFaChaXunQuKuMv =>
      'No linked track ID, so the catalog MV cannot be looked up';

  @override
  String get guanLianShiPinJunBeiPingTaiBiaoJiWeiDuanShiPinWe =>
      'All linked videos are flagged as short clips; no usable MV found';

  @override
  String get weiZhaoDaoFuHeTiaoJianDeQuKuMv => 'No suitable catalog MV found';

  @override
  String get quKuMvBoFangDiZhiHuoQuShiBai =>
      'Could not get the catalog MV playback URL';

  @override
  String get quKuMvChaXunShiBaiQingShaoHouChongShi =>
      'Catalog MV lookup failed. Please try again later.';

  @override
  String get shunXuBoFang => 'Play in order';

  @override
  String get lieBiaoXunHuan => 'Repeat all';

  @override
  String get suiJiBoFang => 'Shuffle';

  @override
  String get danQuXunHuan => 'Repeat one';

  @override
  String get boFangShiBaiYuanBuKeBoVipFangDaoLianWangLuo =>
      'Playback failed: source unavailable (VIP, hotlink protection or network)';

  @override
  String get boFangChuCuo => 'Playback error';

  @override
  String get moRenShunXu => 'Default order';

  @override
  String get qieHuanBangDan => 'Switch charts';

  @override
  String get zanWuBangDan => 'No charts yet';

  @override
  String get gaiWeiJiangXu => 'Sort descending';

  @override
  String get wanCheng => 'Done';

  @override
  String get souSuoGeMingGeShouZhuanJi_2 => 'Search titles, artists, albums…';

  @override
  String get zanWuGeQu => 'No tracks yet';

  @override
  String get meiYouPiPeiDeGeQu => 'No matching tracks';

  @override
  String get beiJing => 'Beijing';

  @override
  String get tianJin => 'Tianjin';

  @override
  String get heBei => 'Hebei';

  @override
  String get shanXi => 'Shanxi';

  @override
  String get neiMengGu => 'Inner Mongolia';

  @override
  String get liaoNing => 'Liaoning';

  @override
  String get jiLin => 'Jilin';

  @override
  String get heiLongJiang => 'Heilongjiang';

  @override
  String get shangHai => 'Shanghai';

  @override
  String get jiangSu => 'Jiangsu';

  @override
  String get zheJiang => 'Zhejiang';

  @override
  String get anHui => 'Anhui';

  @override
  String get fuJian => 'Fujian';

  @override
  String get jiangXi => 'Jiangxi';

  @override
  String get shanDong => 'Shandong';

  @override
  String get heNan => 'Henan';

  @override
  String get huBei => 'Hubei';

  @override
  String get huNan => 'Hunan';

  @override
  String get guangDong => 'Guangdong';

  @override
  String get guangXi => 'Guangxi';

  @override
  String get haiNan => 'Hainan';

  @override
  String get chongQing => 'Chongqing';

  @override
  String get siChuan => 'Sichuan';

  @override
  String get guiZhou => 'Guizhou';

  @override
  String get yunNan => 'Yunnan';

  @override
  String get xiZang => 'Tibet';

  @override
  String get shanXi_2 => 'Shaanxi';

  @override
  String get ganSu => 'Gansu';

  @override
  String get qingHai => 'Qinghai';

  @override
  String get ningXia => 'Ningxia';

  @override
  String get xinJiang => 'Xinjiang';

  @override
  String get taiWan => 'Taiwan';

  @override
  String get xiangGang => 'Hong Kong';

  @override
  String get aoMen => 'Macao';

  @override
  String get weiZhi => 'Unknown';

  @override
  String get heiJiaoVip => 'Vinyl VIP';

  @override
  String get geRenZhongXin => 'Profile';

  @override
  String get souSuoYuBoFangGongKaiNeiRongWuXuDengLu =>
      'No sign-in needed to search and play public content';

  @override
  String get shou => 'tracks';

  @override
  String get jingYan => 'XP';

  @override
  String get changTing => 'Listening';

  @override
  String get gaiNian => 'Concept';

  @override
  String get huiYuan => 'Membership';

  @override
  String get shengJiJinDu => 'Level progress';

  @override
  String get guanZhu => 'Following';

  @override
  String get fenSi => 'Followers';

  @override
  String get fangKe => 'Visitors';

  @override
  String get woDeDengJi => 'My level';

  @override
  String get meiYiCiLingTingDouZaiJiLeiChengZhang =>
      'Every listen counts toward your growth.';

  @override
  String get dangQianDengJi => 'Current level';

  @override
  String get zanWeiHuoQuDaoXiaYiDengJiJinDu =>
      'Progress to the next level is not available yet';

  @override
  String get dangQianDengJiQuanYi => 'Current level perks';

  @override
  String get zhangHaoDangAn => 'Account profile';

  @override
  String get yongHuId => 'User ID';

  @override
  String get xingBie => 'Gender';

  @override
  String get leLing => 'Account age';

  @override
  String get leiJiTingGe => 'Total listening';

  @override
  String get suoZaiDiQu => 'Region';

  @override
  String get huiYuanZhuangTai => 'Membership status';

  @override
  String get changTingHuiYuan => 'Listening membership';

  @override
  String get gaiNianHuiYuan => 'Concept membership';

  @override
  String get zhengZaiHuoQuZhangHaoXinXi => 'Loading account info…';

  @override
  String get yunBei => 'Cloud shells';

  @override
  String get ziJianGeDan => 'My playlists';

  @override
  String get weiKaiTong => 'Not active';

  @override
  String get sheZhi => 'Settings';

  @override
  String get heiJiaoHuiYuan => 'Vinyl membership';

  @override
  String get yiDengLuChaKanGeRenZhongXin => 'Signed in · open your profile';

  @override
  String get weiDengLuGongKaiNeiRongKeYong =>
      'Signed out · public content available';

  @override
  String get zanBuZhiChi => 'Not supported yet';

  @override
  String get woDe => 'Mine';

  @override
  String get zuiJinBoFang => 'Recently played';

  @override
  String get woDeGeDan => 'My playlists';

  @override
  String get shuaXinGeDan => 'Refresh playlists';

  @override
  String get gengDuoSheZhi => 'More settings';

  @override
  String get dingShiTingZhi => 'Sleep timer';

  @override
  String get yinZhiSheZhi => 'Audio quality';

  @override
  String get zhuTiWaiGuan => 'Appearance';

  @override
  String get guanYu => 'About';

  @override
  String get zanWuShouCangGeDan => 'No saved playlists';

  @override
  String get shenSe => 'Dark';

  @override
  String get gaiNianBanMoRenShenSe => 'Concept edition ships in dark';

  @override
  String get qianSe => 'Light';

  @override
  String get qianSeWanZhengShiPei => 'Fully tuned for light mode';

  @override
  String get genSuiXiTong => 'Follow system';

  @override
  String get suiXiTongShenQianSeQieHuan =>
      'Switch with the system light/dark setting';

  @override
  String get baoMi => 'Private';

  @override
  String get yiGuoQi => 'Expired';

  @override
  String get jiJiangDaoQi => 'Expiring soon';

  @override
  String get tuiChu => 'Sign out';

  @override
  String get paiHangBangJiaZaiShiBaiQingJianChaWangLuoHouChon =>
      'Failed to load charts. Check your network and retry.';

  @override
  String get weiNiLiangShenDingZhiDeMeiRiGeDan =>
      'A daily playlist made for you';

  @override
  String get dengLuHouChaKanJinRiTuiJian => 'Sign in to see today’s picks';

  @override
  String get jinRiGongKaiGeDan => 'Today’s public playlists';

  @override
  String get zhengZaiWeiNiDingZhiTuiJian =>
      'Tailoring recommendations for you…';

  @override
  String get quDengLuHuoQuGeXingHuaMeiRiTuiJian =>
      'Sign in for personalized daily recommendations';

  @override
  String get jinRiZanWuTuiJian => 'No recommendations today';

  @override
  String get fengGeGeDanJiaZaiShiBaiQingJianChaWangLuoHouChon =>
      'Failed to load style playlists. Check your network and retry.';

  @override
  String get tuiJianGeDanJiaZaiShiBaiQingJianChaWangLuoHouCho =>
      'Failed to load recommended playlists. Check your network and retry.';

  @override
  String get bianJiJingXuanJiaZaiShiBaiQingJianChaWangLuoHouC =>
      'Failed to load editor’s picks. Check your network and retry.';

  @override
  String get moRenTuiJian => 'Default recommendations';

  @override
  String get shangWuHao => 'Good morning';

  @override
  String get zhongWuHao => 'Good afternoon';

  @override
  String get youCiKaiQiHaoXinQing => 'Starting your day on a good note ~';

  @override
  String get zanWuFengGeGeDan => 'No style playlists yet';

  @override
  String get zanWuNeiRong => 'Nothing here yet';

  @override
  String get weiNiLiangShenDingZhi => 'Made for you';

  @override
  String get shiShiReMenQuShi => 'Trending right now';

  @override
  String get meiYouKeYongYinYuan => 'No source available';

  @override
  String get souSuoShiBaiQingChongShi => 'Search failed. Please retry.';

  @override
  String get qingKongSouSuoLiShi => 'Clear search history';

  @override
  String get queDingYaoQingKongQuanBuSouSuoLiShiMaCiCaoZuoWuF =>
      'Clear all search history? This cannot be undone.';

  @override
  String get souSuoGeQuGeDanZhuanJiGeShou =>
      'Search tracks, playlists, albums and artists';

  @override
  String get jiaZaiShiBaiDianJiChongShi => 'Failed to load. Tap to retry.';

  @override
  String get meiYouGengDuoLe => 'No more results';

  @override
  String get linJunJie => 'JJ Lin';

  @override
  String get chenYiXun => 'Eason Chan';

  @override
  String get shuoChang => 'Rap';

  @override
  String get yueYu => 'Cantonese';

  @override
  String get reMenSouSuo => 'Trending';

  @override
  String get meiCiXunWen => 'Ask every time';

  @override
  String get zuiXiaoHuaDaoTuoPan => 'Minimize to tray';

  @override
  String get tuiChuYingYong => 'Quit app';

  @override
  String get guanBiShiTanChuTiShiKeGouXuanJiZhuWoDeXuanZe =>
      'Show a prompt on close; tick “Remember my choice” to skip it';

  @override
  String get guanBiShiZuiXiaoHuaDaoXiTongTuoPanBuTuiChuYingYo =>
      'Minimize to the system tray on close instead of quitting';

  @override
  String get guanBiShiZhiJieTuiChuYingYong => 'Quit the app on close';

  @override
  String get yiQingLiTuPianHuanCunBoFangYuSouSuoLiShi =>
      'Cleared image cache, play history and search history';

  @override
  String get waiGuan => 'Appearance';

  @override
  String get shiYanUi => 'Experimental UI';

  @override
  String get chuangKou => 'Window';

  @override
  String get guanBiZhuChuangKouShi => 'When the main window closes';

  @override
  String get renWuLanBoFangJinDu => 'Taskbar playback progress';

  @override
  String get zaiRenWuLanAnNiuShangXianShiBoFangJinDuBoFangLvZ =>
      'Show progress on the taskbar button (green playing / yellow paused)';

  @override
  String get renWuLanFengMianYuLan => 'Taskbar cover preview';

  @override
  String get xuanTingHeChuangKouQieHuanXianShiFengMianXinXiKa =>
      'Show a cover card on hover and window switching; turn off to restore the preview';

  @override
  String get duLiBoKongHengTiao => 'Independent playback bar';

  @override
  String get renWuLanShangFangFuTiaoKeTuoDongTuoJinDuHeDiaoYi =>
      'A floating bar above the taskbar: drag, seek and adjust volume; hidden in full screen';

  @override
  String get zhuoMianGeCi => 'Desktop lyrics';

  @override
  String get xianShiZhuoMianGeCi => 'Show desktop lyrics';

  @override
  String get xuanFuChuangXianShiDangQianGeCiKeTuoDongSuoDingD =>
      'A floating window shows the current lyrics; draggable, lockable, click-through';

  @override
  String get x11DuLiGeCiChuangKeTuoDongHeSuoDingChuanTouWuHeC =>
      'Standalone X11 lyrics window; draggable and click-through when locked; falls back to a lyrics card without a compositor';

  @override
  String get duLiXuanFuChuangXianShiDangQianGeCiKeZhiDingSuoD =>
      'A standalone floating window shows the current lyrics; always on top, click-through when locked';

  @override
  String get xuYaoXianShiZaiQiTaYingYongShangCengQuanXianCaiN =>
      '“Display over other apps” permission is required for floating lyrics';

  @override
  String get suoDingGeCiChuang => 'Lock the lyrics window';

  @override
  String get suoDingHouDianJiChuanTouDaoXiaCengYingYongBiMian =>
      'When locked, clicks pass through to the app below so it never blocks you';

  @override
  String get dianJiChuanTouDaoXiaCengYingYongBiMianDangZhuCao =>
      'Clicks pass through to the app below so it never blocks you';

  @override
  String get geCiYangShi => 'Lyrics style';

  @override
  String get ziDingYi => 'Custom';

  @override
  String get geCiPianYiQuanJu => 'Lyrics offset (global)';

  @override
  String get yuXiTongShiJianDuiQiBoFangYeGeCiXianShiLiKeAnDan =>
      'Aligned with system time; fine-tune per track from “Lyrics display” on the player page';

  @override
  String get tiQian05s => '0.5s earlier';

  @override
  String get yanHou05s => '0.5s later';

  @override
  String get chongZhiGeCiWeiZhi => 'Reset lyrics position';

  @override
  String get huiDaoPingMuDingBuJuZhongLiDingDuan12px =>
      'Back to top center (12px from the top)';

  @override
  String get geCiWeiZhiYiChongZhiWeiDingBuJuZhong =>
      'Lyrics position reset to top center';

  @override
  String get moRenYinZhi => 'Default quality';

  @override
  String get shiBaiShiChangShiMvYinPin => 'Fall back to MV audio on failure';

  @override
  String get yinYuanBuKeYongShiJieYongGeQuGuanLianQuKuMvDeYin =>
      'Borrow the audio from the track’s catalog MV when the source fails; quality is unknown and lyrics/duration may drift';

  @override
  String get geCiYuFengMian => 'Lyrics & artwork';

  @override
  String get suoPingLanYaXianShiGeCi =>
      'Show lyrics on lock screen / Bluetooth';

  @override
  String get xiTongMeiTiFuBiaoTiXianShiGeShouDangQianGeCi =>
      'The system media subtitle shows “artist · current lyric”';

  @override
  String get jinWiFiJiaZaiFengMian => 'Load artwork on Wi-Fi only';

  @override
  String get zhangHaoGuanLi => 'Accounts';

  @override
  String get moRenYinYuan => 'Default source';

  @override
  String get youKeMoShiShuJuJinCunBenJi =>
      'Guest mode; data stays on this device';

  @override
  String get saoMaDengLuHouKeTongBuGeDanYuBoFangQuanXian =>
      'Sign in by QR to sync playlists and playback permissions';

  @override
  String get youKeKeBoFangDengLuHouDuQuShouCangJia =>
      'Guests can play; sign in to read your saved folders';

  @override
  String get tiaoShi => 'Debug';

  @override
  String get qingQiuXiangYingCuoWuCeShiWangLuoShiShiTanCeFuZh =>
      'Request / response / error · test network · live probe · copy';

  @override
  String get huanCun => 'Cache';

  @override
  String get qingLiTuPianHuanCunYuBoFangSouSuoLiShi =>
      'Clear image cache, play history and search history';

  @override
  String get buYingXiangDengLuYuWoXiHuanDuiLieBenDiFuBenHuiYi =>
      'Sign-in and Liked are untouched; the local queue copy is cleared too';

  @override
  String get zuiHouYiGeYinYuanZhiShaoBaoLiuYiGe =>
      'This is the last source; at least one must stay enabled';

  @override
  String get guanBiHouYinCangYinYueYunPanRuKouYuGaiYuanYunPan =>
      'Hides the Cloud Drive entry and this source’s cloud drive';

  @override
  String get zhuTiSe => 'Accent color';

  @override
  String get wu => 'None';

  @override
  String get dangQianYinYuanBuZhiChiPingLun =>
      'The current source does not support comments';

  @override
  String get pingLunYiFaBu => 'Comment posted';

  @override
  String get huiFuYiFaBu => 'Reply posted';

  @override
  String get dianZanShiBaiQingShaoHouZaiShi =>
      'Like failed. Please try again later.';

  @override
  String get yiJiaRuBoFang => 'Added to the queue';

  @override
  String get jingCaiPingLun => 'Top comments';

  @override
  String get meiYouGengDuoPingLunLe => 'No more comments';

  @override
  String get laiYuan => 'Source';

  @override
  String get dengLuHouCanYuPingLun => 'Sign in to join the discussion';

  @override
  String get kuGouDengLuHuiFu => 'KuGou sign-in restore';

  @override
  String get wangYiYunDengLuHuiFu => 'NetEase sign-in restore';

  @override
  String get bZhanDengLuHuiFu => 'Bilibili sign-in restore';

  @override
  String get fanYinBoFang => '泛音 playback';

  @override
  String get zuiXiaoHua => 'Minimize';

  @override
  String get zuiDaHua => 'Maximize';

  @override
  String get guanBiFanYin => 'Close 泛音';

  @override
  String get tuiChuYingYongHaiShiZuiXiaoHuaDaoXiTongTuoPanJiX =>
      'Quit the app, or minimize to the system tray and keep playing?';

  @override
  String get dangQianZhuoMianMeiYouKeYongDeXiTongTuoPanTuiChu =>
      'No system tray is available on this desktop. Quit the app, or keep the window open?';

  @override
  String get jiZhuWoDeXuanZe => 'Remember my choice';

  @override
  String get xiaCiGuanBiBuZaiXunWenKeZaiSheZhiZhongXiuGai =>
      'Won’t ask again on close; change it in Settings';

  @override
  String get xuanZeGeQuKaiShiBoFang => 'Pick a track to start playing';

  @override
  String get xianShiChuangKou => 'Show window';

  @override
  String get boFangMoShi => 'Play mode';

  @override
  String get zengDaYinLiang => 'Volume up';

  @override
  String get jianXiaoYinLiang => 'Volume down';

  @override
  String get jiaZaiShiBai => 'Failed to load';

  @override
  String get shuoShuoGuanYuZheShouGeDeGuShi =>
      'Tell the story behind this track';

  @override
  String get jiaZaiZhong => 'Loading…';

  @override
  String get zanWuHuiFu => 'No replies yet';

  @override
  String get laiYuan_2 => 'Source: ';

  @override
  String get quSheZhiKaiQi => 'Enable in Settings';

  @override
  String get xiaLaGuanBiNieHeSuoFang => 'Swipe down to close · pinch to zoom';

  @override
  String get zhuoMianGeCiYangShi => 'Desktop lyrics style';

  @override
  String get ziHaoQuanJuTongYiZaiBoFangYeGeCiXianShiLiTiaoYin =>
      'Font size is global: adjust it from “Lyrics display” on the player page; in-app lyrics and the overlay stay in sync';

  @override
  String get yiChangYanSe => 'Sung color';

  @override
  String get weiChangYanSe => 'Unsung color';

  @override
  String get miaoBianYanSe => 'Stroke color';

  @override
  String get miaoBianKuanDu => 'Stroke width';

  @override
  String get beiJingYanSe => 'Background color';

  @override
  String get beiJingShenDu => 'Background depth';

  @override
  String get beiJingYuanJiao => 'Background radius';

  @override
  String get ziZhong => 'Weight';

  @override
  String get changGui => 'Regular';

  @override
  String get zhongDeng => 'Medium';

  @override
  String get banCu => 'Semibold';

  @override
  String get cuTi => 'Bold';

  @override
  String get teCu => 'Extra bold';

  @override
  String get heiTi => 'Black';

  @override
  String get huiFuMoRen => 'Restore defaults';

  @override
  String get yeKongZhongZuiLiangDeXing => 'Brightest Star in the Night Sky';

  @override
  String get xuanZeYanSe => 'Pick a color';

  @override
  String get seXiang => 'Hue';

  @override
  String get baoHeDu => 'Saturation';

  @override
  String get mingDu => 'Brightness';

  @override
  String get buTouMingDu => 'Opacity';

  @override
  String get queDing => 'OK';

  @override
  String get zanWuBoFangYinYue => 'Nothing playing';

  @override
  String get buXiHuanBingTiaoGuo => 'Not for me, skip';

  @override
  String get kaiQiZhuoMianGeCi => 'Turn on desktop lyrics';

  @override
  String get geCiXianShi => 'Lyrics display';

  @override
  String get dangQianGeYouYiWenYinYiShiCaiHuiXianShiFuXing =>
      'The secondary line appears only when a translation or romanization exists';

  @override
  String get xianShiFanYi => 'Show translation';

  @override
  String get geCiXiaFangXianShiZhongWenYiWen =>
      'Show the Chinese translation below the lyrics';

  @override
  String get xianShiLuoMaYin => 'Show romanization';

  @override
  String get riWenDengYinYiXianShiZaiFuXing =>
      'Romanization (e.g. Japanese) appears on the secondary line';

  @override
  String get xuanFuGeCi => 'Floating lyrics';

  @override
  String get xuanFuChuangXianShiZhuoMianGeCiKeTuoDongSuoDing =>
      'Show desktop lyrics in a floating window; draggable and lockable';

  @override
  String get geCiZiHao => 'Lyrics font size';

  @override
  String get geCiHangJianJu => 'Lyrics line spacing';

  @override
  String get geCiPianYi => 'Lyrics offset';

  @override
  String get geCiPianYiDangQianGeQu => 'Lyrics offset (this track)';

  @override
  String get zhiWeiTiaoZheYiShouZhengShuGeCiTiQianFuShuGeCiYa =>
      'Fine-tunes this track only; positive = lyrics earlier, negative = later';

  @override
  String get chongZhiBenQuWeiTiao => 'Reset this track’s offset';

  @override
  String get geCiJiaZaiZhong => 'Loading lyrics…';

  @override
  String get zanWuGeCi => 'No lyrics';

  @override
  String get huiDaoZhengZaiBoFangDeNaYiXing => 'Back to the current line';

  @override
  String get huiDaoDangQianXing => 'Back to current line';

  @override
  String get ling => '零';

  @override
  String get yi => '壱';

  @override
  String get er => '弐';

  @override
  String get can => '参';

  @override
  String get si => '肆';

  @override
  String get wu_2 => '伍';

  @override
  String get lu => '陆';

  @override
  String get qi => '柒';

  @override
  String get ba => '捌';

  @override
  String get jiu => '玖';

  @override
  String get neiBuDianYuanShengYu => 'Battery remaining';

  @override
  String get diYiShou => 'First track';

  @override
  String get yinZhiXuanZe => 'Audio quality';

  @override
  String get zhengZaiQieHuanYinZhi => 'Switching quality…';

  @override
  String get huiSeDangWeiDangQianGeQuBuKeYong =>
      'Greyed-out tiers are unavailable for this track';

  @override
  String get weiZhiDangWeiJiangZiDongXiangXiaJianRong =>
      'Unknown tiers fall back to the next lower one automatically';

  @override
  String get dangQianBoFangMvYinPinGeCiKeNengBuTongBu =>
      'Playing MV audio · lyrics may be out of sync';

  @override
  String get buKeYong => 'Unavailable';

  @override
  String get duiLieWeiKong => 'Queue is empty';

  @override
  String get n15FenZhong => '15 minutes';

  @override
  String get n30FenZhong => '30 minutes';

  @override
  String get n60FenZhong => '60 minutes';

  @override
  String get ziDingYi45FenZhong => 'Custom, 45 minutes';

  @override
  String get banBen => 'Version';

  @override
  String get xingTai => 'Form';

  @override
  String get dingWei => 'Positioning';

  @override
  String get duoYinYuanDiSanFangKeHuDuan => 'Multi-source third-party client';

  @override
  String get qingZunShouDangDiFaLvYuMuBiaoPingTaiFuWuTiaoKuan =>
      'Follow local laws and the target platform’s terms of service; do not publish under the “KuGou” trademark as the app name.';

  @override
  String get tiYanTanSuoXingSheJiFengGeYuPaiBanXiTong =>
      'An experimental take on design language and typography';

  @override
  String get dangQianShiYong => 'In use';

  @override
  String get boFangBeiSu => 'Playback speed';

  @override
  String get beiSuBuBaoLiuYinDiaoJinDuGeCiYuShengYuShiJianSui =>
      'Pitch is not preserved; progress, lyrics and remaining time all follow the new speed';

  @override
  String get yuYan => 'Language';

  @override
  String get jieMianYuYan => 'Interface language';

  @override
  String get zaiXianYinLe => 'Online music';

  @override
  String get woDeYinLe => 'My music';

  @override
  String get tongYong => 'General';

  @override
  String get xiTongSheZhi => 'Settings';

  @override
  String get gaiNianBan => 'Concept edition';

  @override
  String get zhanKaiCeLan => 'Expand sidebar';

  @override
  String get zheDieCeLan => 'Collapse sidebar';

  @override
  String qianMingBeiJuJianChaWRidMixinkeyShiFouGuoQi(Object p1) {
    return '$p1 (signature rejected: check whether w_rid / mixinKey expired)';
  }

  @override
  String chuFaFengKongTuiBiChongShiHuoGengHuanWangLuo(Object p1) {
    return '$p1 (rate limit triggered: back off and retry, or change network)';
  }

  @override
  String bZhanFengKongJiaoYanShiBaiQingShaoHouChongSh(Object p1) {
    return '$p1 (Bilibili risk check failed; retry later or sign in)';
  }

  @override
  String xiangYingBuShiJsonDuiXiang(Object p1) {
    return '$p1: response is not a JSON object';
  }

  @override
  String xiangYingQueShaoCodeZiDuan(Object p1) {
    return '$p1: response is missing the code field';
  }

  @override
  String dataBuShiJsonDuiXiang(Object p1) {
    return '$p1: data is not a JSON object';
  }

  @override
  String dataBuShiJsonShuZu(Object p1) {
    return '$p1: data is not a JSON array';
  }

  @override
  String wan(Object p1) {
    return '$p1 × 10K';
  }

  @override
  String yunPanXinXiShangChuanShiBai(Object p1, Object p2) {
    return 'Cloud info upload failed ($p1): $p2';
  }

  @override
  String saoMaHuiHuaChuangJianShiBaiCode(Object p1, Object p2) {
    return 'Failed to create the QR session (code=$p1) $p2';
  }

  @override
  String boFangDiZhiCode(Object p1) {
    return 'Playback URL code=$p1';
  }

  @override
  String mvQuLiuCode(Object p1) {
    return 'MV stream code=$p1';
  }

  @override
  String mvQuLiuDataCode(Object p1) {
    return 'MV stream data.code=$p1';
  }

  @override
  String geCiCode(Object p1) {
    return 'Lyrics code=$p1';
  }

  @override
  String yunPanQuLiuCode(Object p1) {
    return 'Cloud stream code=$p1';
  }

  @override
  String yunPanGeCiCode(Object p1) {
    return 'Cloud lyrics code=$p1';
  }

  @override
  String shiBaiCode(Object p1, Object p2) {
    return '$p1 failed (code=$p2)';
  }

  @override
  String fuWuQiZanShiBuKeYongHttpQingShaoHouChongShi(Object p1) {
    return 'Server temporarily unavailable (HTTP $p1). Please try again later.';
  }

  @override
  String get dangQianWangLuoBeiWangGuanLanJieUrlGuoLvWuFa =>
      'Your network is blocking the source (gateway URL filtering).\nSwitch to a mobile hotspot or turn off the router’s web filter and retry.';

  @override
  String yiJieDuanYuanChangDuZiFu(Object p1, Object p2) {
    return '$p1\n…(truncated, original length $p2 characters)';
  }

  @override
  String appInfoDuQuBanBenShiBai(Object p1) {
    return '[app_info] failed to read the version: $p1';
  }

  @override
  String tiaoZuiJin(Object p1, Object p2) {
    return '$p1 entries · latest $p2';
  }

  @override
  String fanYinQiDongShiBaiQingJianChaXiTongQuanXianH(Object p1) {
    return '泛音 failed to start ($p1). Check system permissions and runtime dependencies.';
  }

  @override
  String chuShiHuaShiBaiHuoChaoShiYingYongYiXiangJiYu(Object p1) {
    return '$p1 failed to initialize or timed out; the app is running in degraded mode.';
  }

  @override
  String yueRi(Object p1, Object p2) {
    return '$p1/$p2';
  }

  @override
  String yue(Object p1) {
    return '$p1';
  }

  @override
  String yiShanChuShouShouQueShaoWenJianBiaoZhiBeiTia(Object p1, Object p2) {
    return 'Deleted $p1 tracks; skipped $p2 without a file identifier';
  }

  @override
  String danMuZuiDuoZiQingJingJianHouZaiFa(Object p1) {
    return 'Danmaku is limited to $p1 characters. Please shorten it.';
  }

  @override
  String pingLunZuiDuoZiQingJingJianHouZaiFa(Object p1) {
    return 'Comments are limited to $p1 characters. Please shorten it.';
  }

  @override
  String pingLunJiaZaiShiBaiStatusErr(Object p1, Object p2) {
    return 'Failed to load comments (status=$p1 err=$p2)';
  }

  @override
  String xiangYingWuFaJieXi(Object p1) {
    return 'Could not parse the $p1 response';
  }

  @override
  String yiChangQingShaoHouChongShi(Object p1) {
    return '$p1 failed. Please try again later.';
  }

  @override
  String xuYaoDengLuHuoAnQuanJiaoYan(Object p1) {
    return '$p1 requires sign-in or verification';
  }

  @override
  String fanHuiShiBaiStatusErr(Object p1, Object p2, Object p3) {
    return '$p1 returned a failure (status=$p2 err=$p3)';
  }

  @override
  String meiRiTuiJianJiaZaiShiBaiStatusErr(Object p1, Object p2) {
    return 'Daily recommendations failed to load (status=$p1 err=$p2)';
  }

  @override
  String bZhanWuFenP(Object p1) {
    return 'Bilibili: $p1 has no parts';
  }

  @override
  String caoZuoShiBaiCode(Object p1) {
    return 'Operation failed (code=$p1)';
  }

  @override
  String zhuanJiJiaZaiShiBaiYinYuanBuKeYong(Object p1) {
    return 'Album failed to load: $p1 source unavailable';
  }

  @override
  String zhuanJiJiaZaiShiBai(Object p1) {
    return 'Album failed to load: $p1';
  }

  @override
  String zhuanJiDangAn(Object p1) {
    return 'ALBUM ARCHIVE · $p1';
  }

  @override
  String geShiPin(Object p1, Object p2) {
    return '$p1 videos · $p2';
  }

  @override
  String get dengLuPingJuJinCunBenJiTuiChuDengLuJiQingChu =>
      'Credentials stay on this device and are erased on sign-out. Guests can still search and play; signing in unlocks saved folders. Bilibili has no cloud hearts — hearts stay local.';

  @override
  String get shuoMingDengLuJinZouWangYiYunZhenShiWangGuan =>
      'Note: sign-in goes through the real NetEase gateway; a failed attempt never creates a fake account.\nThe session (MUSIC_U) is stored only on this device and cleared on sign-out.';

  @override
  String shangChuanWanChengShouQiZhongShouMiaoChuan(Object p1, Object p2) {
    return 'Upload complete: $p1 tracks ($p2 instant)';
  }

  @override
  String shangChuanWanChengShou(Object p1) {
    return 'Upload complete: $p1 tracks';
  }

  @override
  String shangChuanWanChengChengGongShouShiBaiShou(Object p1, Object p2) {
    return 'Upload complete: $p1 succeeded, $p2 failed';
  }

  @override
  String queRenShanChuCiCaoZuoWuFaCheXiao(Object p1) {
    return 'Delete “$p1”? This cannot be undone.';
  }

  @override
  String shanChuShiBai(Object p1) {
    return 'Delete failed: $p1';
  }

  @override
  String yiYong(Object p1, Object p2) {
    return '$p1 of $p2 used';
  }

  @override
  String shangChuanZhong(Object p1, Object p2, Object p3) {
    return 'Uploading $p1 / $p2 · $p3';
  }

  @override
  String zhaoDaoShouGongShou(Object p1, Object p2) {
    return '$p1 of $p2 tracks';
  }

  @override
  String gongShou(Object p1, Object p2) {
    return '$p1 tracks$p2';
  }

  @override
  String yunPanShiZhangHaoDeSiYouWenJianKu(Object p1) {
    return 'The cloud drive is the private file library of the $p1 account';
  }

  @override
  String dengLuZhangHao(Object p1) {
    return 'Sign in to $p1';
  }

  @override
  String get wuFaDaKaiWenJianXuanZeQiLinuxQingAnZhuangZen =>
      'Could not open the file picker. On Linux install zenity, kdialog or qarma, and make sure the desktop session can access file dialogs.';

  @override
  String buShiZhiChiDeYinPinWenJian(Object p1) {
    return '$p1: unsupported audio file';
  }

  @override
  String duQuShiBai(Object p1) {
    return '$p1: read failed';
  }

  @override
  String chaoGuo100mbXianZhi(Object p1) {
    return '$p1: exceeds the 100MB limit';
  }

  @override
  String shiShiTanCeRoundIntervalS(Object p1, Object p2) {
    return '== live probe round=$p1 interval=${p2}s ==';
  }

  @override
  String fanYinWangLuoRiZhi(Object p1) {
    return '== 泛音 network log ==\n\n$p1';
  }

  @override
  String yiFuZhiQuanBuRiZhiTiao(Object p1) {
    return 'Copied all log entries ($p1)';
  }

  @override
  String haoShiMs(Object p1) {
    return 'Took: ${p1}ms';
  }

  @override
  String zanBuZhiChiKeQieHuanQiTaYinYuanChaKan(Object p1, Object p2) {
    return '$p1 does not support “$p2”. Switch to another source to view it.';
  }

  @override
  String shou_2(Object p1) {
    return '$p1 tracks';
  }

  @override
  String meiRiFaXian(Object p1) {
    return 'Daily discovery · $p1';
  }

  @override
  String yiQieDaoXiaYiShouShengXiao(Object p1, Object p2) {
    return 'Switched to $p1 · $p2; takes effect on the next track';
  }

  @override
  String dianJiKaiShiDianTaiJiKeShouLiu(Object p1, Object p2, Object p3) {
    return '$p1 · $p2 · $p3. Tap “Start radio” to start streaming.';
  }

  @override
  String dianJiKaiShiDianTaiJiKeShouTing(Object p1) {
    return '$p1. Tap “Start radio” to listen.';
  }

  @override
  String shouDaiBo(Object p1) {
    return '$p1 queued';
  }

  @override
  String xiangSiDu(Object p1) {
    return 'Similarity $p1';
  }

  @override
  String laiYuanSiRenFm(Object p1, Object p2, Object p3) {
    return 'Source: $p1 Personal FM · $p2$p3';
  }

  @override
  String laiYuanSiRenFm_2(Object p1) {
    return 'Source: $p1 Personal FM';
  }

  @override
  String laiYuanGuanJianCiJianSuo(Object p1) {
    return 'Source: keyword search · $p1';
  }

  @override
  String laiYuanGuanJianCiJianSuoFeiGeXingHua(Object p1) {
    return 'Source: keyword search ($p1, not personalized)';
  }

  @override
  String gongShou_2(Object p1) {
    return '$p1 tracks';
  }

  @override
  String fenZhong(Object p1) {
    return '$p1 min';
  }

  @override
  String xiaoShi(Object p1) {
    return '$p1 hr';
  }

  @override
  String ci(Object p1) {
    return '$p1 times';
  }

  @override
  String shou_3(Object p1, Object p2) {
    return '$p1 tracks ($p2%)';
  }

  @override
  String geQu_2(Object p1) {
    return '$p1 tracks';
  }

  @override
  String zhuanJi_2(Object p1) {
    return '$p1 albums';
  }

  @override
  String dengLuHouJiKeTongBuYunDuanWoXiHuan(Object p1) {
    return 'Sign in to $p1 to sync your cloud Liked list';
  }

  @override
  String shou_4(Object p1, Object p2) {
    return '$p1 tracks · $p2';
  }

  @override
  String zhaoDaoWeiGongWei(Object p1, Object p2) {
    return '$p1 of $p2 artists';
  }

  @override
  String gongWeiGuanZhuGeShou(Object p1) {
    return '$p1 followed artists';
  }

  @override
  String shouDanQu(Object p1, Object p2) {
    return '$p1 · $p2 tracks';
  }

  @override
  String zhaoDaoZhangGongZhang(Object p1, Object p2) {
    return '$p1 of $p2 albums';
  }

  @override
  String gongZhangShouCangZhuanJi(Object p1) {
    return '$p1 saved albums';
  }

  @override
  String ruanJieChongKaiShiBai(Object p1) {
    return 'Software decode restart failed: $p1';
  }

  @override
  String boFangQiCuoWu(Object p1) {
    return 'Player error: $p1';
  }

  @override
  String ge(Object p1) {
    return '$p1 items';
  }

  @override
  String fenMiao(Object p1, Object p2) {
    return '$p1 min $p2 s';
  }

  @override
  String miao(Object p1) {
    return '$p1 s';
  }

  @override
  String yinPinYuanWuFaJiaZai(Object p1) {
    return 'Audio source could not load: $p1';
  }

  @override
  String yinPinYuanWuFaQiBo(Object p1) {
    return 'Audio source could not start: $p1';
  }

  @override
  String yinPinYuanJiaZaiShiBai(Object p1) {
    return 'Audio source failed to load: $p1';
  }

  @override
  String boFangQiDongShiBai(Object p1) {
    return 'Playback failed to start: $p1';
  }

  @override
  String boFangShiBai(Object p1) {
    return 'Playback failed: $p1';
  }

  @override
  String boFangTingZhiYiChongShiCiRengWeiHuiFu(Object p1) {
    return 'Playback stalled: $p1 retries without recovery';
  }

  @override
  String stallTingZhiYuMsDiCiZiYu(Object p1, Object p2, Object p3) {
    return '[stall] $p1 stuck at ${p2}ms, self-heal attempt $p3';
  }

  @override
  String boFangXuYaoDengLu(Object p1) {
    return '$p1 playback requires sign-in';
  }

  @override
  String jiaZaiShiBaiYinYuanBuKeYong(Object p1, Object p2) {
    return 'Failed to load $p1: $p2 source unavailable';
  }

  @override
  String jiaZaiShiBaiJieKouBuKeYongHuoGaiIdWuGongKaiS(Object p1) {
    return 'Failed to load $p1: API unavailable or no public data for this ID';
  }

  @override
  String jiaZaiShiBai_2(Object p1) {
    return 'Failed to load $p1';
  }

  @override
  String shou_5(Object p1, Object p2) {
    return '$p1 / $p2 tracks';
  }

  @override
  String buFenZhangHaoXinXiHuoQuShiBai(Object p1) {
    return 'Some account info could not be loaded: $p1';
  }

  @override
  String qingXianDengLuZhangHao(Object p1) {
    return 'Sign in to $p1 first';
  }

  @override
  String zanBuZhiChiZhangHaoDengLu(Object p1) {
    return '$p1 does not support account sign-in yet';
  }

  @override
  String juLvHaiCha(Object p1, Object p2, Object p3) {
    return '$p2 $p3 to Lv.$p1';
  }

  @override
  String kaiShiDaoQi(Object p1, Object p2) {
    return 'Started $p1 · expires $p2';
  }

  @override
  String dengLuZhangHaoHouJiKeTongBuZiJianYuShouCangG(Object p1) {
    return 'Sign in to $p1 to sync your own and saved playlists';
  }

  @override
  String zanWuYunDuanGeDan(Object p1) {
    return '$p1 has no cloud playlists';
  }

  @override
  String ziJian(Object p1) {
    return 'Created ($p1)';
  }

  @override
  String shou_6(Object p1, Object p2) {
    return '$p1 tracks$p2';
  }

  @override
  String tian(Object p1) {
    return '$p1 d';
  }

  @override
  String nian(Object p1) {
    return '$p1 yr';
  }

  @override
  String geYue(Object p1) {
    return '$p1 mo';
  }

  @override
  String nianHouDaoQi(Object p1) {
    return 'Expires in $p1 yr';
  }

  @override
  String geYueHouDaoQi(Object p1) {
    return 'Expires in $p1 mo';
  }

  @override
  String tianHouDaoQi(Object p1) {
    return 'Expires in $p1 d';
  }

  @override
  String xiaoShiHouDaoQi(Object p1) {
    return 'Expires in $p1 hr';
  }

  @override
  String fenZhongHouDaoQi(Object p1) {
    return 'Expires in $p1 min';
  }

  @override
  String tuiChuZhangHao(Object p1) {
    return 'Sign out of $p1?';
  }

  @override
  String tuiChuHouYunDuanDiGeDanWoXiHuanYuFuFeiBoFang(Object p1) {
    return 'After signing out, $p1 cloud playlists, Liked and paid playback permissions become unavailable. Local data is unaffected.';
  }

  @override
  String geDanDangAn(Object p1) {
    return 'PLAYLIST ARCHIVE · $p1';
  }

  @override
  String shouGeXingHuaTuiJian(Object p1) {
    return '$p1 tracks · personalized recommendations';
  }

  @override
  String meiYouZhaoDaoXiangGuan(Object p1) {
    return 'No matching $p1 found';
  }

  @override
  String get duLiXuanFuChuangXianShiDangQianGeCiShiYanGon =>
      'A standalone floating window shows the current lyrics. Experimental: the main window may become unresponsive while enabled, and it will not start at boot. Enable with care (troubleshooting: desktop lyrics integration doc, §12).';

  @override
  String sQuanJuAnGeQuDeWeiTiaoHuiZaiDieJia(Object p1, Object p2) {
    return '$p1${p2}s (global; per-track fine-tuning stacks on top)';
  }

  @override
  String xinGeMoRenAnCiJieXiBoFangZhongKeQieHuan(Object p1) {
    return '$p1 · new tracks resolve at this quality by default; switchable while playing';
  }

  @override
  String souSuoYuWoXiHuanDeChuShiYinYuan(Object p1) {
    return '$p1 · initial source for search and Liked';
  }

  @override
  String xueXiYanJiuXiangDiSanFangKeHuDuanBuTiGongYin(Object p1) {
    return '$p1 · third-party client for study and research\nNo audio relay or account hosting is provided';
  }

  @override
  String qiYongYinYuan(Object p1) {
    return 'Enable the $p1 source';
  }

  @override
  String dengLuHouKeQiYong(Object p1) {
    return 'Sign in to $p1 to enable';
  }

  @override
  String guanBiHouGaiYuanBuZaiChuXianZaiRuKou(Object p1) {
    return 'Once off, this source no longer appears in “$p1”';
  }

  @override
  String yinYuanYiGuanBiCiXiangZanShiBuShengXiao(Object p1) {
    return 'The $p1 source is off; this option is inactive for now';
  }

  @override
  String kuangJiaYuanShengWeiBuHuoCuoWu(Object p1) {
    return 'Framework / native / uncaught errors · $p1';
  }

  @override
  String faSongShiBai(Object p1) {
    return 'Failed to send: $p1';
  }

  @override
  String tiao(Object p1) {
    return '$p1 entries';
  }

  @override
  String danQuDangAn(Object p1) {
    return 'TRACK ARCHIVE · $p1';
  }

  @override
  String tiao_2(Object p1) {
    return '$p1 entries';
  }

  @override
  String fanYin_2(Object p1, Object p2) {
    return '泛音 · $p1 · $p2';
  }

  @override
  String yinLiang(Object p1) {
    return 'Volume $p1%';
  }

  @override
  String tiaoHuiFu(Object p1) {
    return '$p1 replies';
  }

  @override
  String yinYuanYiTingYong(Object p1) {
    return 'The $p1 source is disabled';
  }

  @override
  String deYiGuanBi(Object p1, Object p2) {
    return '“$p2” in $p1 is off';
  }

  @override
  String benYeNeiRongYiLaiYiTingYongQiJianBuZaiQingQi(Object p1) {
    return 'This page depends on $p1. No requests go to that source while it is off; tracks already queued are unaffected.';
  }

  @override
  String yinYuanRengQiYongZhiShiZheYiXiangGongNengBei(Object p1) {
    return 'The $p1 source is still enabled; only this feature is turned off. Turn it on to use this page. Tracks already queued are unaffected.';
  }

  @override
  String benQuWeiTiaoQuanJuHeJiShengXiao(Object p1, Object p2, Object p3) {
    return 'Track offset $p1  global $p2  effective $p3';
  }

  @override
  String shi(Object p1, Object p2) {
    return '$p1$p2';
  }

  @override
  String boFangDuiLieShou(Object p1) {
    return 'QUEUE · $p1 tracks';
  }

  @override
  String get geRenXueXiYanJiuXiangXiangMuShuJuJingGongKai =>
      'A personal study and research project. Data comes directly from public APIs; no audio relay or cloud account hosting is provided. Music copyrights belong to the original platforms and rights holders.';

  @override
  String boFangLiang(Object p1) {
    return 'Played $p1';
  }

  @override
  String fenSi_2(Object p1) {
    return '$p1 followers';
  }

  @override
  String geShou_2(Object p1) {
    return 'Artists ($p1)';
  }

  @override
  String huiFu_2(Object p1) {
    return 'Reply to @$p1';
  }

  @override
  String laiYuan_3(Object p1) {
    return 'Source: $p1';
  }

  @override
  String paiXuFangShi_2(Object p1, Object p2) {
    return 'Sort by $p1 ($p2)';
  }

  @override
  String qiTaBanBen_2(Object p1) {
    return 'Other versions ($p1)';
  }

  @override
  String shouCang_2(Object p1) {
    return 'Saved ($p1)';
  }

  @override
  String siRenFm_2(Object p1) {
    return '$p1 Personal FM';
  }

  @override
  String wangLuoCuoWu_2(Object p1) {
    return '$p1 network error';
  }

  @override
  String yi_2(Object p1) {
    return '$p1 hundred million';
  }

  @override
  String yongHu_2(Object p1) {
    return '$p1 user';
  }

  @override
  String fanYinLabel(Object p1) {
    return '泛音 · $p1';
  }

  @override
  String get dianTaiJieShu => 'Tap “Start radio” to listen';

  @override
  String juLiShengJi(Object p1, Object p2, Object p3) {
    return '$p2 $p3 to Lv.$p1';
  }

  @override
  String xiangYingWeiKong(Object p1) {
    return '$p1 returned an empty response';
  }

  @override
  String geQu_3(Object p1) {
    return '$p1 tracks';
  }

  @override
  String zhuanJi_3(Object p1) {
    return '$p1 albums';
  }

  @override
  String get quXiaoShouCang => 'Remove from favorites';

  @override
  String get biaoShengBang => 'Soaring';

  @override
  String get xinGeBang => 'New songs';

  @override
  String get yuanChuangBang => 'Originals';

  @override
  String get reGeBang => 'Hot songs';

  @override
  String get wangYiYunShuoChangBang => 'NetEase Chinese rap';

  @override
  String get wangYiYunGuoFengBang => 'NetEase Guofeng';

  @override
  String get wangYiYunMinYaoBang => 'NetEase Folk';

  @override
  String get wangYiYunYaoGunBang => 'NetEase Rock';

  @override
  String get wangYiYunDianYinBang => 'NetEase Electronic';

  @override
  String get wangYiYunGuDianBang => 'NetEase Classical';

  @override
  String get wangYiYunAcgBang => 'NetEase ACG';

  @override
  String get wangYiYunOuMeiReGeBang => 'NetEase Western hits';

  @override
  String get wangYiYunOuMeiXinGeBang => 'NetEase Western new';

  @override
  String get ouMeiRnBBang => 'Western R&B';

  @override
  String get wangYiYunRiYuBang => 'NetEase Japanese';

  @override
  String get wangYiYunHanYuBang => 'NetEase Korean';

  @override
  String get meiGuoBillboardBang => 'US Billboard';

  @override
  String get ukZhouBang => 'UK weekly';

  @override
  String get riBenOriconBang => 'Japan Oricon';

  @override
  String get beatportQuanQiuBang => 'Beatport global dance';

  @override
  String get qiTa => 'Other';

  @override
  String get wangYiGuanFangBang => 'NetEase official charts';

  @override
  String get bangDanIdWuXiao => 'Invalid chart id';

  @override
  String get geDanIdWuXiao => 'Invalid playlist id';

  @override
  String get yunPanShanChu => 'Cloud delete';

  @override
  String get geDanJiaQu => 'Add to playlist';

  @override
  String get geDanShanQu => 'Remove from playlist';

  @override
  String get fmXiHuan => 'FM like';

  @override
  String get quXiaoHongXin => 'Unheart';

  @override
  String get wangYiYunWeiDengLuWuFaDuQuGeDan =>
      'NetEase is not signed in; cannot read playlists';

  @override
  String get wangYiYunWeiDengLuWuFaDuQuWoXiHuan =>
      'NetEase is not signed in; cannot read Liked';

  @override
  String get geQuIdWuXiao => 'Invalid track id';

  @override
  String get saoMaHuiHuaGuoQiQingChongXinHuoQu =>
      'The QR session expired. Request a new code.';

  @override
  String get xinSaoMaHuiHuaWeiQuDePingJu =>
      'The new QR session got no valid credentials. Scan again.';

  @override
  String get wangYiYunWeiDengLuWuFaDuQuZhangHaoDangAn =>
      'NetEase is not signed in; cannot read the account profile';

  @override
  String get wangYiYunWeiDengLuWuFaDuQuHuiYuanXinXi =>
      'NetEase is not signed in; cannot read membership info';

  @override
  String get pingLunJiaZaiShiBai => 'Failed to load comments';

  @override
  String get louCengJiaZaiShiBai => 'Failed to load the thread';

  @override
  String get pingLunChiWeiZhiWuFaJiaZaiLouCeng =>
      'Unknown comment pool; cannot load the thread';

  @override
  String get dengLuZhuangTaiYiShiXiaoQingChongXinDengLu =>
      'The session is no longer valid. Sign in again.';

  @override
  String get caoZuoTaiPinFanQingShaoHouZaiShi =>
      'Too many operations. Please try again later.';

  @override
  String get meiYouQuanXianZhiXingGaiCaoZuo => 'No permission for this action';

  @override
  String get geQuIdWeiZhiWuFaFaBiaoPingLun =>
      'Unknown track ID; cannot post a comment';

  @override
  String get geQuIdWeiZhiWuFaHuiFu => 'Unknown track ID; cannot reply';

  @override
  String get wuXiaoDeMvLaiYuanBiaoShi => 'Invalid MV source identifier';

  @override
  String get zanWuPingLun => 'No comments yet';

  @override
  String get shuoDianShenMe => 'Say something…';

  @override
  String get youKe => 'Guest';

  @override
  String get xuDengLu => 'Sign-in required';

  @override
  String get yunDuanSiYouWenJianKu => 'Private cloud file library';

  @override
  String get zanWuZiJianGeDan => 'No playlists of your own yet';

  @override
  String get mvShouCangXinXiBuKeYong => 'No MV to save right now';

  @override
  String get yiShouCang => 'Saved';

  @override
  String get shiPinJiaZaiShiBai => 'Video failed to load';

  @override
  String get zhengChang => 'Normal';

  @override
  String get quXiaoJingYin => 'Unmute';

  @override
  String get tuiChuQuanPing => 'Exit full screen';

  @override
  String get kuaiJin => 'Forward';

  @override
  String get kuaiTui => 'Rewind';

  @override
  String get xianShiXuanFuGeCi => 'Show floating lyrics';

  @override
  String get huiDaoPingMuDingBuJuZhongSimple => 'Back to top center';

  @override
  String get guanBiHouSouSuoYuGongNengYeBuZaiShiYongGaiYuan =>
      'Once off, search and feature pages stop using this source';

  @override
  String yiDengLuWithName(Object p1) {
    return 'Signed in: $p1';
  }

  @override
  String get pingLunChiWeiZhiWuFaAnZuiRePaiXu =>
      'Unknown comment pool; cannot sort by hottest';

  @override
  String get pingLunChiWeiZhiWuFaJiaZaiDanMu =>
      'Unknown comment pool; cannot load danmaku';

  @override
  String get wuFaJieXiGaiMvDeDanMuChi =>
      'Could not resolve this MV’s danmaku pool';

  @override
  String pingLunCanShuBuWanZheng(Object p1) {
    return 'Incomplete comment parameters ($p1)';
  }

  @override
  String whatFaSongShiBai(Object p1, Object p2, Object p3) {
    return '$p1 failed to send (status=$p2 err=$p3)';
  }

  @override
  String get jinRiZanWuFengGeTuiJian => 'No style picks today';

  @override
  String get meiRiTuiJianXiangYingWeiKong =>
      'Daily recommendations response is empty';

  @override
  String get jinRiZanWuGeXingHuaTuiJian => 'No personalized picks today';

  @override
  String get siRenFmXiangYingWuFaJieXi =>
      'Could not parse the Personal FM response';

  @override
  String get siRenFmZanWuTuiJian =>
      'Personal FM has no recommendations right now';

  @override
  String get siRenFmJiaZaiShiBaiShort => 'Failed to load Personal FM';

  @override
  String get wangLuoYiChangShort => 'Network error';

  @override
  String get erWeiMaJiaZaiShiBai => 'Failed to load the QR code';

  @override
  String get zhengZaiJiaZaiGengDuoGeQu => 'Loading more tracks…';

  @override
  String get guanBiSouSuo => 'Close search';

  @override
  String get zhengZaiXuJieGeChi => 'Refilling the pool…';

  @override
  String get geChiZhengZaiXuJianDian => 'Refilling the pool…';

  @override
  String get shangChuanShiBaiQingShaoHouChongShi =>
      'Upload failed. Please try again later.';

  @override
  String get qingShaoHouChongShi => 'Please try again later';

  @override
  String get zhengZaiBuQuan => '(completing…)';

  @override
  String get jieKouJuJueFangWenAccessDeny => 'API refused access (Access Deny)';

  @override
  String meiYouBoFangQuanXianFee(Object p1) {
    return 'No playback permission (fee=$p1)';
  }

  @override
  String get quMuBuCunZai => 'Track does not exist';

  @override
  String wuBoFangDiZhiCode(Object p1) {
    return 'No playback URL (code=$p1)';
  }

  @override
  String get sheBeiZhuCeShiBai => 'Device registration failed';

  @override
  String fanHuiShiBaiPlain(Object p1) {
    return '$p1 returned a failure';
  }

  @override
  String bZhanFanHuiCode(Object p1) {
    return 'Bilibili returned code=$p1';
  }

  @override
  String get weiZhiShort => 'Unknown';

  @override
  String yiShuRenJiShou(Object p1, Object p2) {
    return '$p1 · $p2 tracks';
  }

  @override
  String geShouShuCompact(Object p1) {
    return '$p1 tracks';
  }

  @override
  String get gaiWeiShengXu => 'Sort ascending';

  @override
  String get jiangXu => 'Descending';

  @override
  String get shengXu => 'Ascending';

  @override
  String get wangLuoBuKeDaHuoBeiWangGuanLanJie =>
      'Network unreachable or blocked by a gateway. Check your network and retry.';

  @override
  String get danMuYiKaiQiSheZhiYuFaSong =>
      'Danmaku is on · settings and posting';

  @override
  String get xianShiZhong => 'On screen';

  @override
  String get buZu1FenZhong => 'Under 1 min';

  @override
  String get buZu1Tian => 'Under 1 day';

  @override
  String get zhangHaoXinXiHuoQuShiBaiQingShaoHou =>
      'Failed to load account info. Please try again later.';

  @override
  String get fengGeGeDan => 'Style playlists';

  @override
  String get zanWuFengGeTuiJian => 'No style picks yet';

  @override
  String get wangYiYunYongHu => 'NetEase user';

  @override
  String get faBiaoPingLun => 'Post a comment';

  @override
  String get guanBiKaiGuan => 'Off';

  @override
  String get touMing => 'Transparent';

  @override
  String get huiFuYinLiang => 'Restore volume';

  @override
  String get guanBiZhuoMianGeCi => 'Turn off desktop lyrics';

  @override
  String get quXiaoXiHuanShort => 'Unlike';

  @override
  String beiSuWithLabel(Object p1) {
    return 'Speed · $p1';
  }

  @override
  String get wuFaDaKaiShiPinDiZhi => 'Cannot open the video URL';

  @override
  String get danMuJiaZaiShiBaiQingGuanBiHouChongKai =>
      'Danmaku failed to load. Close and reopen it.';

  @override
  String get huanYuan => 'Restore';
}
