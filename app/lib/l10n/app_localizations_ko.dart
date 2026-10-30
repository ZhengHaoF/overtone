// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get fanYin => '泛音';

  @override
  String get i3SpiWeiFanHuiBuvidXiLieZiDuan => 'I3 spi: buvid 계열 필드가 없습니다';

  @override
  String get i1NavXiangYingBuShiJsonDuiXiang => 'I1 nav: 응답이 JSON 객체가 아닙니다';

  @override
  String get i1NavQueShaoWbiImg => 'I1 nav: wbi_img 누락';

  @override
  String get i1NavWbiImgQueShaoImgUrlSubUrl =>
      'I1 nav: wbi_img 에 img_url/sub_url 누락';

  @override
  String get bZhanXuYaoDengLu => 'Bilibili: 로그인이 필요합니다';

  @override
  String get bZhanXuYaoDengLuYanZhengMa => 'Bilibili: 로그인이 필요합니다(인증 코드)';

  @override
  String get g1XiangYingQueShaoData => 'G1: 응답에 data 가 없습니다';

  @override
  String get g1XiangYingQueShaoQrcodeKeyUrl => 'G1: qrcode_key/url 누락';

  @override
  String get anQuanCeLveZuZhiXiangBuAnQuanHuoFeiKuGouMuBiaoFa =>
      '보안 정책으로 인해 안전하지 않거나 KuGou 가 아닌 대상으로 계정 정보 전송을 차단했습니다';

  @override
  String get yunPanFanHuiLiaoBuAnQuanDeShangChuanMuBiaoYiTing =>
      '클라우드가 안전하지 않은 업로드 대상을 반환해 업로드를 중단했습니다';

  @override
  String get wangLuoWangGuanLanJieUrlGuoLvWuFaFangWenKuGouJie =>
      '네트워크 게이트웨이에서 차단되었습니다(URL 필터링). KuGou API 에 연결할 수 없습니다';

  @override
  String get wangLuoQingQiuShiBai => '네트워크 요청 실패';

  @override
  String get weiZhiGeQu => '알 수 없는 곡';

  @override
  String get weiZhiGeShou => '알 수 없는 아티스트';

  @override
  String get geDan => '재생목록';

  @override
  String get bangDan => '차트';

  @override
  String get kuGouGuanFang => 'KuGou 공식';

  @override
  String get zhuanJi => '앨범';

  @override
  String get yunPanDaoRuShiBai => '클라우드 가져오기 실패';

  @override
  String get saoMaHuiHuaYiShiXiao => 'QR 세션이 만료되었습니다';

  @override
  String get quanBu => '전체';

  @override
  String get souSuo => '검색';

  @override
  String get geDanSouSuo => '재생목록 검색';

  @override
  String get zhuanJiSouSuo => '앨범 검색';

  @override
  String get geShouSouSuo => '아티스트 검색';

  @override
  String get geDanXiangQing => '재생목록 상세';

  @override
  String get zhuanJiXiangQing => '앨범 상세';

  @override
  String get geShouXiangQing => '아티스트 상세';

  @override
  String get geShouGeQu => '아티스트 곡';

  @override
  String get meiRiTuiJian => '데일리 추천';

  @override
  String get siRenFm => '개인 FM';

  @override
  String get xinGeSuDi => '신곡';

  @override
  String get fenLeiGeDan => '재생목록 분류';

  @override
  String get xinDieShangJia => '신보';

  @override
  String get geShouLieBiao => '아티스트 목록';

  @override
  String get geDanBiaoQian => '재생목록 태그';

  @override
  String get tuiJian => '추천';

  @override
  String get woXiHuan => '좋아요';

  @override
  String get geQuXiangQing => '곡 상세';

  @override
  String get yongHuGeDan => '사용자 재생목록';

  @override
  String get wangYiYunHuiHuaShiXiaoCode301 => 'NetEase 세션 만료(code=301)';

  @override
  String get boFangDiZhiWeiKong => '재생 URL 이 비어 있습니다';

  @override
  String get mvXiangQing => 'MV 상세';

  @override
  String get mvXiangQingWeiKong => 'MV 상세가 비어 있습니다';

  @override
  String get mvBoFangDiZhiWeiKong => 'MV 재생 URL 이 비어 있습니다';

  @override
  String get yongHuXiangQingCodeYiChang => '사용자 상세 code 이상';

  @override
  String get vipXinXiCodeYiChang => 'VIP 정보 code 이상';

  @override
  String get yongHuDengJiCodeYiChang => '사용자 레벨 code 이상';

  @override
  String get yunPan => '클라우드';

  @override
  String get yunPanWenJianMeiYouQuLiuDiZhi => '클라우드 파일에 스트림 주소가 없습니다';

  @override
  String get yunPanXiangQing => '클라우드 파일 상세';

  @override
  String get wangYiYunXiangYingBuShiJson => 'NetEase 응답이 JSON 이 아닙니다';

  @override
  String get zuiRe => '인기순';

  @override
  String get zuiXin => '최신순';

  @override
  String get pingLun => '댓글';

  @override
  String get reSou => '실시간 검색어';

  @override
  String get louCengPingLun => '스레드 댓글';

  @override
  String get yinYueRen => '아티스트';

  @override
  String get zuoZheHuiFu => '작성자 답글';

  @override
  String get wangLuoYiChangQingShaoHouChongShi => '네트워크 오류입니다. 잠시 후 다시 시도하세요';

  @override
  String get yuFuWuQiJianLiAnQuanLianJieShiBaiQingJianChaWang =>
      '서버와 보안 연결에 실패했습니다. 네트워크 또는 프록시 설정을 확인한 후 다시 시도하세요';

  @override
  String get wangLuoLianJieShiBaiQingJianChaWangLuoHouChongSh =>
      '연결에 실패했습니다. 네트워크를 확인한 후 다시 시도하세요';

  @override
  String get wangLuoQingQiuChaoShiQingJianChaWangLuoHouChongS =>
      '요청 시간이 초과되었습니다. 네트워크를 확인한 후 다시 시도하세요';

  @override
  String get renZhengJieKouNeiRongYiShengLve => '[인증 응답 내용 생략]';

  @override
  String get wuFaAnQuanJieXiDeUrlYiShengLve => '[안전하게 해석할 수 없는 URL 생략]';

  @override
  String get qianTaoNeiRongYiShengLve => '[중첩된 내용 생략]';

  @override
  String get wuFaAnQuanJieXiDeBiaoDanYiShengLve => '[안전하게 해석할 수 없는 폼 생략]';

  @override
  String get pingJuTouYiShengLve => '[인증 헤더 생략]';

  @override
  String get qiDongFuWuXiangYingChaoShiRengZaiDengDaiDangQian =>
      '시작 서비스 응답이 시간 초과되었습니다. 중복 초기화를 피하기 위해 현재 작업이 끝나기를 기다립니다';

  @override
  String get zhengZaiQiDongFanYin => '泛音 시작 중…';

  @override
  String get xiangXiJiLuJianYingYongMuLuCrashLog =>
      '자세한 기록은 앱 폴더의 crash.log 를 참고하세요';

  @override
  String get chongShi => '다시 시도';

  @override
  String get guanBiTiShi => '닫기';

  @override
  String get biaoZhun => '표준';

  @override
  String get gaoPin => '고음질';

  @override
  String get wuSun => '무손실';

  @override
  String get reMen => '인기';

  @override
  String get hongXin => '하트';

  @override
  String get xiaoZhong => '마이너';

  @override
  String get suLan => '퀵';

  @override
  String get hongXinDianTai => '하트 라디오';

  @override
  String get xiaoZhongDianTai => '마이너 라디오';

  @override
  String get suLanDianTai => '퀵 라디오';

  @override
  String get caiNiXiHuan => '맞춤 추천';

  @override
  String get xiaoZhongJingXuan => '마이너 셀렉션';

  @override
  String get duanQuSuLan => '숏 트랙';

  @override
  String get genJuKouWeiTuiJianXiangSiGeQu => '취향 기반 유사곡';

  @override
  String get genJuFengGeTuiJianXiangSiGeQu => '스타일 기반 유사곡';

  @override
  String get huaYuLiuXing => '중국어 팝';

  @override
  String get jingDian => '클래식';

  @override
  String get minYao => '포크';

  @override
  String get dianZi => '일렉트로닉';

  @override
  String get qingYinYue => '이지 리스닝';

  @override
  String get duLi => '인디';

  @override
  String get lengMen => '숨은 명곡';

  @override
  String get jueShi => '재즈';

  @override
  String get laiZiReMenHuaYuLiuXing => '「인기 / 중국어 팝」에서';

  @override
  String get laiZiMinYaoDianZi => '「포크 / 일렉트로닉」에서';

  @override
  String get laiZiDuLiJueShi => '「인디 / 재즈」에서';

  @override
  String get diXia => '언더그라운드';

  @override
  String get baoZang => '보석 같은 곡';

  @override
  String get geQu => '곡';

  @override
  String get geShou => '아티스트';

  @override
  String get woXiHuanDeYinYue => '내가 좋아하는 음악';

  @override
  String get xiHuan => '좋아요';

  @override
  String get moRenShouCang => '기본 즐겨찾기';

  @override
  String get paiHangBang => '차트';

  @override
  String get faXian => '발견';

  @override
  String get yinYueYunPan => '음악 클라우드';

  @override
  String get kuGou => 'KuGou';

  @override
  String get wangYiYun => 'NetEase';

  @override
  String get biLiBiLi => 'Bilibili';

  @override
  String get xuYaoDengLu => '로그인이 필요합니다';

  @override
  String get meiYouBoFangQuanXian => '재생 권한이 없습니다';

  @override
  String get weiZhaoDao => '찾을 수 없습니다';

  @override
  String get qingQiuGuoYuPinFan => '요청이 너무 많습니다';

  @override
  String get shangYouXiangYingYiChang => '업스트림 응답 이상';

  @override
  String get moRen => '기본';

  @override
  String get biaoZhunShenQianZiShiYingYangShi => '표준 라이트/다크 자동 대응 스타일';

  @override
  String get ruiShiGuoJiPaiBan => '스위스 인터내셔널 타이포그래피';

  @override
  String get zhiBaiMoHeiWuChenXianPaiBanXuanZhongHouQuanZhanQ =>
      '종이 흰색과 먹색 산세리프 레이아웃. 선택하면 앱 전체가 라이트 모드로 전환됩니다';

  @override
  String get evaHong => 'EVA 레드';

  @override
  String get evaZhanShuChaoSuanHongHeiZhongDuanMingRiXiangAnS =>
      'EVA 전술 슈퍼컴퓨터풍의 적/흑 터미널. 아스카 다크 경계 스타일';

  @override
  String get evaLan => 'EVA 블루';

  @override
  String get evaLingHaoJiCiBaiBingLanLingBoLiLiangSeDangAnJie =>
      '영호기 도자기 화이트와 아이스 블루. 레이 라이트 아카이브 화면';

  @override
  String get souSuoGeQuGeShouZhuanJi => '곡, 아티스트, 앨범 검색';

  @override
  String get qingLv => '틸';

  @override
  String get shanHu => '코랄';

  @override
  String get dianLan => '인디고';

  @override
  String get ziLuoLan => '바이올렛';

  @override
  String get geMing => '곡명';

  @override
  String get shiChang => '재생 시간';

  @override
  String get weiDengLu => '로그인 안 됨';

  @override
  String get qingXianDengLuHouChaKanYunPan => '로그인 후 클라우드를 확인하세요';

  @override
  String get huoQuYunPanLieBiaoShiBai => '클라우드 목록을 불러오지 못했습니다';

  @override
  String get queShaoYunPanWenJianHash => '클라우드 파일 hash 누락';

  @override
  String get queShaoYunPanWenJianBiaoZhiWuFaBoFang =>
      '클라우드 파일 식별자가 없어 재생할 수 없습니다';

  @override
  String get wangLuoWangGuanLanJieUrlGuoLvWuFaFangWenKuGou =>
      '네트워크 게이트웨이에서 차단되었습니다(URL 필터링). KuGou 에 접속할 수 없습니다';

  @override
  String get yunPanBoFangDiZhiXiangYingWuFaJieXi => '클라우드 재생 응답을 해석할 수 없습니다';

  @override
  String get huoQuYunPanBoFangDiZhiShiBai => '클라우드 재생 URL 을 가져오지 못했습니다';

  @override
  String get yunPanWenJianZanWuBoFangDiZhi => '클라우드 파일에 재생 URL 이 없습니다';

  @override
  String get qingXianDengLuHouCaoZuoYunPan => '로그인 후 클라우드를 조작하세요';

  @override
  String get queShaoYunPanWenJianBiaoZhiKvIdWuFaShanChu =>
      '클라우드 파일 식별자(kv_id)가 없어 삭제할 수 없습니다';

  @override
  String get queShaoYunPanWenJianBiaoZhiWuFaShanChu =>
      '클라우드 파일 식별자가 없어 삭제할 수 없습니다';

  @override
  String get shanChuYunPanGeQuShiBai => '클라우드 곡 삭제 실패';

  @override
  String get qingXianDengLuHouShangChuanYunPan => '로그인 후 클라우드에 업로드하세요';

  @override
  String get wenJianWeiKong => '파일이 비어 있습니다';

  @override
  String get wenJianWeiKongWuFaShangChuan => '파일이 비어 있어 업로드할 수 없습니다';

  @override
  String get chuShiHuaShangChuanShiBai => '업로드 초기화 실패';

  @override
  String get huoQuShangChuanShouQuanShiBai => '업로드 권한을 가져오지 못했습니다';

  @override
  String get chuShiHuaFenPianShangChuanShiBai => '분할 업로드 초기화 실패';

  @override
  String get fenPianShangChuanShiBai => '분할 업로드 실패';

  @override
  String get wanChengShangChuanShiBai => '업로드 마무리 실패';

  @override
  String get wangLuoQingQiuShiBaiQingShaoHouChongShi =>
      '요청에 실패했습니다. 잠시 후 다시 시도하세요';

  @override
  String get yunPanFuWuXiangYingWeiKong => '클라우드 서비스 응답이 비어 있습니다';

  @override
  String get yunPanFuWuXiangYingWuFaJieXi => '클라우드 서비스 응답을 해석할 수 없습니다';

  @override
  String get queShaoGeQuId => '곡 ID 누락';

  @override
  String get queShaoZiYuanId => '리소스 ID 누락';

  @override
  String get louCengCanShuQueShiQingShuaXinPingLunHouChongShi =>
      '스레드 파라미터 누락. 댓글을 새로고침한 후 다시 시도하세요';

  @override
  String get pingLunChiWeiZhiQingShuaXinPingLunHouZaiShi =>
      '댓글 풀을 알 수 없습니다. 댓글을 새로고침한 후 다시 시도하세요';

  @override
  String get louCengXinXiBuWanZhengQingShuaXinPingLunHouZaiSh =>
      '스레드 정보가 불완전합니다. 댓글을 새로고침한 후 다시 시도하세요';

  @override
  String get huiFuNeiRongBuNengWeiKong => '답글 내용은 비울 수 없습니다';

  @override
  String get huiFu => '답글';

  @override
  String get fenLeiCanShuQueShi => '분류 파라미터 누락';

  @override
  String get reCiCanShuQueShi => '키워드 파라미터 누락';

  @override
  String get queShaoMvHashWuFaJiaZaiDanMu => 'MV hash 가 없어 탄막을 불러올 수 없습니다';

  @override
  String get queShaoMvHashWuFaFaSongDanMu => 'MV hash 가 없어 탄막을 보낼 수 없습니다';

  @override
  String get danMu => '탄막';

  @override
  String get danMuNeiRongBuNengWeiKong => '탄막 내용은 비울 수 없습니다';

  @override
  String get wangLuoCuoWuWuFaFaSong => '네트워크 오류로 보낼 수 없습니다';

  @override
  String get wangLuoWangGuanLanJieWuFaFaSong => '네트워크 게이트웨이에서 차단되어 보낼 수 없습니다';

  @override
  String get pingLunXiangYingWuFaJieXi => '댓글 응답을 해석할 수 없습니다';

  @override
  String get xuYaoAnQuanJiaoYanQingXianZaiKuGouGuanFangKeHuDu =>
      '보안 확인이 필요합니다. KuGou 공식 앱에서 한 번 인증한 후 다시 시도하세요';

  @override
  String get pingLunCanShuJiaoYanShiBai20006 => '댓글 파라미터 검증 실패(20006)';

  @override
  String get pingLunNeiRongChangDuBuHeGui10003 => '댓글 길이가 규정에 맞지 않습니다(10003)';

  @override
  String get dengLuHouCaiNengFaBiaoPingLun => '로그인 후 댓글을 작성할 수 있습니다';

  @override
  String get pingLunNeiRongBuNengWeiKong => '댓글 내용은 비울 수 없습니다';

  @override
  String get pingLunJieKouBeiJuJueAccessDeny => '댓글 API 가 거부되었습니다(Access Deny)';

  @override
  String get pingLunXiangYingWeiKong => '댓글 응답이 비어 있습니다';

  @override
  String get wangLuoCuoWuWuFaJiaZaiPingLun => '네트워크 오류로 댓글을 불러올 수 없습니다';

  @override
  String get dengLuTaiChuFaAnQuanJiaoYanSsa20028QingChongXinD =>
      '로그인 상태에서 보안 확인(SSA 20028)이 발생했습니다. 다시 로그인한 후 시도하세요';

  @override
  String get pingLunXuYaoAnQuanJiaoYanSsa20028 =>
      '댓글에는 보안 확인(SSA 20028)이 필요합니다';

  @override
  String get pingLunCanShuWuXiao => '댓글 파라미터가 올바르지 않습니다';

  @override
  String get pingLunQianMingJiaoYanShiBai => '댓글 서명 검증에 실패했습니다';

  @override
  String get yongHu => '사용자';

  @override
  String get xueSheng => '학생';

  @override
  String get yanYuan => '가수';

  @override
  String get renZheng => '인증됨';

  @override
  String get mingXing => '셀럽';

  @override
  String get daRen => '인플루언서';

  @override
  String get yanChangZhe => '공연자';

  @override
  String get chaoJiVip => '슈퍼 VIP';

  @override
  String get gaiNianVip => '컨셉트 VIP';

  @override
  String get zhouKa => '주간권';

  @override
  String get changTingVip => '무제한 VIP';

  @override
  String get jiKa => '분기권';

  @override
  String get haoHuaVip => '디럭스 VIP';

  @override
  String get nianFeiYinYueBao => '연간 뮤직 패키지';

  @override
  String get yinYueBao => '뮤직 패키지';

  @override
  String get sheBeiZhuCeXiangYingWeiKong => '기기 등록 응답이 비어 있습니다';

  @override
  String get sheBeiZhuCeXiangYingWuFaJieXi => '기기 등록 응답을 해석할 수 없습니다';

  @override
  String get sheBeiZhuCeWeiFanHuiDfid => '기기 등록이 dfid 를 반환하지 않았습니다';

  @override
  String get sheBeiZhuCeWangLuoCuoWu => '기기 등록 네트워크 오류';

  @override
  String get sheBeiZhuCeYiChangQingShaoHouChongShi =>
      '기기 등록에 실패했습니다. 잠시 후 다시 시도하세요';

  @override
  String get huaYu => '중국어';

  @override
  String get ouMei => '서구권';

  @override
  String get riBen => '일본';

  @override
  String get hanGuo => '한국';

  @override
  String get nan => '남성';

  @override
  String get nv => '여성';

  @override
  String get zuHe => '그룹';

  @override
  String get liuXing => '팝';

  @override
  String get xiHa => '힙합';

  @override
  String get yaoGun => '록';

  @override
  String get guDian => '클래식';

  @override
  String get geDanFenLei => '재생목록 분류';

  @override
  String get zanWuGeDanFenLei => '아직 재생목록 분류가 없습니다';

  @override
  String get zanWuXinGe => '아직 신곡이 없습니다';

  @override
  String get zanWuXinDie => '아직 신보가 없습니다';

  @override
  String get zanWuGeShou => '아직 아티스트가 없습니다';

  @override
  String get dangQianWangLuoBeiWangGuanLanJieUrlGuoLvWuFaFang =>
      '네트워크가 KuGou 를 차단하고 있습니다(게이트웨이 URL 필터링)';

  @override
  String get tanSuoJieKou => '탐색 API';

  @override
  String get dangQianWangLuoBeiWangGuanLanJieUrlGuoLvWuFaFang_2 =>
      '네트워크가 KuGou 를 차단하고 있습니다(게이트웨이 URL 필터링).\n모바일 핫스팟으로 전환한 후 다시 시도하세요.';

  @override
  String get siRenFmXuYaoDengLuHouChaKan => '개인 FM 은 로그인 후 볼 수 있습니다';

  @override
  String get dengLuHouKeHuoQuSiRenFm => '로그인하면 개인 FM 을 이용할 수 있습니다';

  @override
  String get siRenFmZanWuKeBoFangGeQu => '개인 FM 에 재생할 곡이 없습니다';

  @override
  String get siRenFmWangLuoCuoWu => '개인 FM 네트워크 오류';

  @override
  String get siRenFmYiChangQingShaoHouChongShi => '개인 FM 오류입니다. 잠시 후 다시 시도하세요';

  @override
  String get huoQuErWeiMaShiBai => 'QR 코드를 가져오지 못했습니다';

  @override
  String get erWeiMaXiangYingYiChang => 'QR 코드 응답 이상';

  @override
  String get erWeiMaKeyWeiKong => 'QR key 가 비어 있습니다';

  @override
  String get faSongYanZhengMaShiBai => '인증 코드 전송 실패';

  @override
  String get dengLuShiBai => '로그인 실패';

  @override
  String get dengLuXiangYingYiChang => '로그인 응답 이상';

  @override
  String get dengLuChengGongDanWeiFanHuiToken => '로그인했지만 token 이 반환되지 않았습니다';

  @override
  String get huoQuYongHuZiLiaoShiBai => '사용자 정보를 가져오지 못했습니다';

  @override
  String get queShaoShiPinHash => '동영상 hash 누락';

  @override
  String get shiPinDiZhiWeiKong => '동영상 주소가 비어 있습니다';

  @override
  String get wuXiaoDeMvId => '유효하지 않은 MV ID';

  @override
  String get qingXianDengLu => '먼저 로그인하세요';

  @override
  String get wangLuoCuoWu => '네트워크 오류';

  @override
  String get mvShouCangCaoZuoShiBai => 'MV 즐겨찾기 작업 실패';

  @override
  String get mvJieKouXiangYingWuFaJieXi => 'MV API 응답을 해석할 수 없습니다';

  @override
  String get xuYaoDengLuAnQuanYanZheng => '로그인 또는 보안 확인이 필요합니다';

  @override
  String get qianMingShiBai20006 => '서명 실패(20006)';

  @override
  String get quMuQueShaoHash => '곡에 hash 가 없습니다';

  @override
  String get boFangDiZhiXiangYingWuFaJieXi => '재생 URL 응답을 해석할 수 없습니다';

  @override
  String get chuFaAnQuanYanZhengSsa20028QingChongXinDengLuHou =>
      '보안 확인(SSA 20028)이 발생했습니다. 다시 로그인한 후 시도하세요';

  @override
  String get boFangXuYaoDengLuAnQuanYanZhengYouKeTongDaoYiGua =>
      '재생에는 로그인 또는 보안 확인이 필요합니다(게스트 이용 종료)';

  @override
  String get wuFaHuoQuBoFangDiZhi => '재생 URL 을 가져올 수 없습니다';

  @override
  String get minYaoJingXuan => '포크 셀렉션';

  @override
  String get shuoChangReGe => '랩 인기곡';

  @override
  String get guoFengXinSheng => '궈펑 신성';

  @override
  String get yaoGunJingDian => '록 명곡';

  @override
  String get dianZiYeXing => '밤의 일렉트로닉';

  @override
  String get zhiYuXi => '힐링';

  @override
  String get meiRiTuiJianJiaZaiShiBaiQingJianChaWangLuoHouCho =>
      '데일리 추천을 불러오지 못했습니다. 네트워크를 확인한 후 다시 시도하세요';

  @override
  String get dengLuHouKeHuoQuGeXingHuaMeiRiTuiJian =>
      '로그인하면 맞춤형 데일리 추천을 받을 수 있습니다';

  @override
  String get fengGeTuiJian => '스타일 추천';

  @override
  String get fengGeTuiJianJiaZaiShiBaiQingShaoHouChongShi =>
      '스타일 추천을 불러오지 못했습니다. 잠시 후 다시 시도하세요';

  @override
  String get dengLuHouKeHuoQuGengTieHeKouWeiDeFengGeTuiJian =>
      '로그인하면 취향에 더 맞는 스타일 추천을 받을 수 있습니다';

  @override
  String get dengLuHouKeHuoQuFengGeTuiJian => '로그인하면 스타일 추천을 받을 수 있습니다';

  @override
  String get tuiJianGeDan => '추천 재생목록';

  @override
  String get tuiJianGeDanJiaZaiShiBai => '추천 재생목록을 불러오지 못했습니다';

  @override
  String get zanWuTuiJianGeDan => '추천 재생목록이 없습니다';

  @override
  String get bianJiJingXuan => '에디터 추천';

  @override
  String get bianJiJingXuanJiaZaiShiBai => '에디터 추천을 불러오지 못했습니다';

  @override
  String get zanWuBianJiJingXuan => '에디터 추천이 없습니다';

  @override
  String get tuiJianJieKou => '추천 API';

  @override
  String get xuYaoDengLuHouChaKan => '로그인 후 확인할 수 있습니다';

  @override
  String get meiRiTuiJianXuYaoDengLu => '데일리 추천에는 로그인이 필요합니다';

  @override
  String get meiRiTuiJianXiangYingWuFaJieXi => '데일리 추천 응답을 해석할 수 없습니다';

  @override
  String get meiRiTuiJianXuYaoDengLuHuoAnQuanJiaoYan =>
      '데일리 추천에는 로그인 또는 보안 확인이 필요합니다';

  @override
  String get meiRiTuiJianXuYaoDengLuHouChaKan => '데일리 추천은 로그인 후 확인할 수 있습니다';

  @override
  String get meiRiTuiJianWangLuoCuoWu => '데일리 추천 네트워크 오류';

  @override
  String get meiRiTuiJianYiChangQingShaoHouChongShi =>
      '데일리 추천 오류입니다. 잠시 후 다시 시도하세요';

  @override
  String get qingQiuShiBai => '요청 실패';

  @override
  String get qianMingJiaoYanShiBai20006 => '서명 검증 실패(20006)';

  @override
  String get qingQiuCanShuQueShi20010 => '요청 파라미터 누락(20010)';

  @override
  String get yunDuanGeDanJianQuanShiBai20017QingTuiChuHouChon =>
      '클라우드 재생목록 인증 실패(20017). 로그아웃 후 다시 로그인하세요';

  @override
  String get dengLuTaiWuXiao20018QingTuiChuHouChongXinDengLu =>
      '로그인 상태가 유효하지 않습니다(20018). 로그아웃 후 다시 로그인하세요';

  @override
  String get chuFaAnQuanJiaoYanSsa20028QingChongXinDengLuHouZ =>
      '보안 확인(SSA 20028)이 발생했습니다. 다시 로그인한 후 시도하세요';

  @override
  String get jieXiYongHuGeDanXiangYingShiBai => '사용자 재생목록 응답을 해석할 수 없습니다';

  @override
  String get huoQuYongHuGeDanShiBai => '사용자 재생목록을 가져오지 못했습니다';

  @override
  String get jieXiGuanZhuLieBiaoXiangYingShiBai => '팔로잉 목록 응답을 해석할 수 없습니다';

  @override
  String get huoQuGuanZhuLieBiaoShiBai => '팔로잉 목록을 가져오지 못했습니다';

  @override
  String get jieXiYongHuGeDanGeQuXiangYingShiBai => '재생목록 곡 응답을 해석할 수 없습니다';

  @override
  String get huoQuYongHuGeDanGeQuShiBai => '재생목록 곡을 가져오지 못했습니다';

  @override
  String get tianJiaDaoWoXiHuanShiBai => '좋아요에 추가하지 못했습니다';

  @override
  String get congWoXiHuanYiChuShiBai => '좋아요에서 제거하지 못했습니다';

  @override
  String get ziJianShouCangJiaLieBiaoBuWanZhengQingChongShi =>
      '저장 폴더 목록이 불완전합니다. 다시 시도하세요';

  @override
  String get shiPinBuCunZai => '동영상이 존재하지 않습니다';

  @override
  String get wuXiaoDeBZhanNeiRongId => '유효하지 않은 Bilibili 콘텐츠 ID';

  @override
  String get bZhanLieBiaoFenYeYiChangWeiFanHuiWanZhengNeiRong =>
      'Bilibili 페이지 처리 오류로 목록이 불완전합니다';

  @override
  String get bZhanNeiRong => 'Bilibili 콘텐츠';

  @override
  String get wuXiaoDeUpZhuId => '유효하지 않은 업로더 ID';

  @override
  String get saoMaChengGongDanWeiShouDaoDengLuPingJu =>
      '스캔에 성공했지만 로그인 정보를 받지 못했습니다';

  @override
  String get dengLuTaiQueRenShiBaiQingChongShi =>
      '로그인 상태를 확인하지 못했습니다. 다시 시도하세요';

  @override
  String get qingXianDengLuBiLiBiLi => '먼저 Bilibili 에 로그인하세요';

  @override
  String get shouCangJiaFenYeYiChangWeiFanHuiWanZhengLieBiao =>
      '폴더 페이지 처리 오류로 목록이 불완전합니다';

  @override
  String get bZhanGaiShiPinWuKeYongYinGui =>
      'Bilibili: 이 동영상에는 사용할 수 있는 오디오가 없습니다';

  @override
  String get bZhanQuMuIdWeiKong => 'Bilibili: 곡 ID 가 비어 있습니다';

  @override
  String get wuFaDingWeiGaiGeQuQueShaoGeQuIdGeMing =>
      '이 곡을 찾을 수 없습니다(곡 ID 또는 곡명 누락)';

  @override
  String get kuGouWeiDengLuWuFaDuQuYunDuanZiLiaoKu =>
      'KuGou 에 로그인하지 않아 클라우드 라이브러리를 읽을 수 없습니다';

  @override
  String get kuGouWeiDengLuWuFaDuQuWoXiHuan =>
      'KuGou 에 로그인하지 않아 좋아요를 읽을 수 없습니다';

  @override
  String get weiZhaoDaoYunDuanWoXiHuanGeDan => '클라우드 좋아요 재생목록을 찾지 못했습니다';

  @override
  String get yunDuanWoXiHuanGeDanQueShaoListid =>
      '클라우드 좋아요 재생목록에 listId 가 없습니다';

  @override
  String get kuGouWeiDengLuWuFaTongBuHongXin =>
      'KuGou 에 로그인하지 않아 하트를 동기화할 수 없습니다';

  @override
  String get zhuanJiJiaZaiShiBaiJieKouBuKeYongHuoGaiIdWuGongK =>
      '앨범을 불러오지 못했습니다. API 를 사용할 수 없거나 이 ID 의 공개 데이터가 없습니다';

  @override
  String get fanHui => '뒤로';

  @override
  String get boFangQuanBu => '모두 재생';

  @override
  String get chongXinJiaZai => '새로고침';

  @override
  String get geShouJiaZaiShiBaiJieKouBuKeYongHuoWuGongKaiShuJ =>
      '아티스트를 불러오지 못했습니다. API 를 사용할 수 없거나 공개 데이터가 없습니다';

  @override
  String get zanWuGongKaiGeQu => '공개 곡이 없습니다';

  @override
  String get geShouJieShao => '아티스트 소개';

  @override
  String get guanBi => '닫기';

  @override
  String get zaiXianJiaZai => '온라인으로 불러오기';

  @override
  String get heJiXiLie => '컬렉션 / 시리즈';

  @override
  String get jiaZaiGengDuoChongShi => '더 불러오기 / 다시 시도';

  @override
  String get geQuJiaZaiShiBaiJieKouBuKeYongHuoWuGongKaiShuJu =>
      '곡을 불러오지 못했습니다. API 를 사용할 수 없거나 공개 데이터가 없습니다';

  @override
  String get weiZhaoDaoPiPeiDeGeQu => '일치하는 곡을 찾지 못했습니다';

  @override
  String get shangLaHuoShaoHouJiaZaiGengDuo => '위로 당기거나 잠시 기다리면 더 불러옵니다';

  @override
  String get boFangReMen => '인기곡 재생';

  @override
  String get chaKanXiangQing => '상세 보기';

  @override
  String get souSuoGeQu => '곡 검색…';

  @override
  String get dingWeiDangQianBoFang => '재생 중인 곡으로';

  @override
  String get dengLuPingJuHuiFuChaoShiYiJinRuYouKeMoShiBaoCunD =>
      '로그인 정보 복원 시간이 초과되어 게스트 모드로 시작합니다. 저장된 정보는 삭제되지 않았습니다';

  @override
  String get dengLuPingJuHuiFuShiBaiQingJianChaXiTongAnQuanCu =>
      '로그인 정보를 복원하지 못했습니다. 시스템 보안 저장소를 확인한 후 다시 로그인하세요';

  @override
  String get saoMaChengGongDanWeiFanHuiHuiHua => '스캔에 성공했지만 세션이 반환되지 않았습니다';

  @override
  String get qingShuRu11WeiShouJiHao => '11자리 휴대폰 번호를 입력하세요';

  @override
  String get qingShuRuZhiShao4WeiYanZhengMa => '인증 코드를 4자리 이상 입력하세요';

  @override
  String get qingShuRuZhangHaoHeMiMa => '계정과 비밀번호를 입력하세요';

  @override
  String get yiDengLuDanAnQuanCunChuBuKeYongBenCiDengLuWuFaBa =>
      '로그인했지만 보안 저장소를 사용할 수 없어 이번 로그인을 저장할 수 없습니다. 잠시 후 다시 시도하세요';

  @override
  String get yiTuiChuDengLuAnQuanCunChuQingLiWeiWanChengQingJ =>
      '로그아웃했지만 보안 저장소 정리가 끝나지 않았습니다. 시스템 권한을 확인하세요';

  @override
  String get erWeiMaHuoQuShiBaiQingChongShi => 'QR 코드를 가져오지 못했습니다. 다시 시도하세요';

  @override
  String get yiDengLuDanAnQuanCunChuBuKeYongBenCiDengLuWuFaBa_2 =>
      '로그인했지만 보안 저장소를 사용할 수 없어 이번 로그인을 저장할 수 없습니다';

  @override
  String get dengLuZhuangTaiQueRenShiBaiQingChongShi =>
      '로그인 상태를 확인하지 못했습니다. 다시 시도하세요';

  @override
  String get biLiBiLiZhangHao => 'Bilibili 계정';

  @override
  String get qieHuanZhangHao => '계정 전환';

  @override
  String get tuiChuDengLu => '로그아웃';

  @override
  String get daKaiBiLiBiLiAppSaoYiSaoSaoMaHouZaiShouJiShangQu =>
      'Bilibili 앱에서 스캔한 뒤 휴대폰에서 로그인을 확인하세요';

  @override
  String get yiSaoMaQingZaiShouJiShangQueRen => '스캔됨. 휴대폰에서 확인하세요';

  @override
  String get erWeiMaYiGuoQiQingShuaXin => 'QR 코드가 만료되었습니다. 새로 고치세요';

  @override
  String get dengDaiSaoMa => '스캔 대기 중';

  @override
  String get shuaXinErWeiMa => 'QR 코드 새로 고침';

  @override
  String get dengLu => '로그인';

  @override
  String get saoMa => '스캔';

  @override
  String get yanZhengMa => '인증 코드';

  @override
  String get zhangHao => '계정';

  @override
  String get shouJiYanZhengMaDengLu => 'SMS 코드로 로그인';

  @override
  String get shiYongKuGouBangDingShouJiHaoJieShouDuanXinYanZh =>
      'KuGou 에 연결된 휴대폰 번호로 SMS 코드를 받습니다';

  @override
  String get shouJiHao => '휴대폰 번호';

  @override
  String get huoQuYanZhengMa => '코드 받기';

  @override
  String get zhangHaoMiMaDengLu => '계정과 비밀번호로 로그인';

  @override
  String get kuGouZhangHaoShouJiHaoMiMa => 'KuGou 계정 / 휴대폰 번호 + 비밀번호';

  @override
  String get zhangHaoShouJiHao => '계정 / 휴대폰 번호';

  @override
  String get miMa => '비밀번호';

  @override
  String get youKeJiXuXianTingGe => '게스트로 계속';

  @override
  String get dengLuChengGong => '로그인되었습니다';

  @override
  String get qingYongKuGouAppSaoMaDengLu => 'KuGou 앱으로 스캔해 로그인하세요';

  @override
  String get mei3MiaoZiDongJianCe => '3초마다 자동 확인';

  @override
  String get erWeiMaYiGuoQi => 'QR 코드가 만료되었습니다';

  @override
  String get shuaXin => '새로 고침';

  @override
  String get kuGouSaoMaDengLu => 'KuGou QR 로그인';

  @override
  String get daKaiShouJiKuGouSaoYiSaoDengLuHouKeTongBuXiHuanY =>
      '휴대폰 KuGou 에서 스캔하세요. 로그인 후 좋아요와 재생 권한을 동기화할 수 있습니다';

  @override
  String get wangYiYunZhangHao => 'NetEase 계정';

  @override
  String get wangYiYunSaoMaDengLu => 'NetEase QR 로그인';

  @override
  String get daKaiShouJiWangYiYunYinYueAppSaoYiSaoSaoMiaoXiaF =>
      '휴대폰 「NetEase Cloud Music」 앱 → 스캔 → 아래 QR 코드를 인식합니다';

  @override
  String get qingYongWangYiYunYinYueAppSaoMaDengLu =>
      'NetEase Cloud Music 앱으로 스캔해 로그인하세요';

  @override
  String get mei2MiaoZiDongJianCe => '2초마다 자동 확인';

  @override
  String get yiDengLu => '로그인됨';

  @override
  String get dangQianYinYuanBuZhiChiYunPan => '현재 음원은 클라우드를 지원하지 않습니다';

  @override
  String get yunPanJiaZaiShiBaiQingShaoHouChongShi =>
      '클라우드를 불러오지 못했습니다. 잠시 후 다시 시도하세요';

  @override
  String get congYunPanShanChu => '클라우드에서 삭제';

  @override
  String get quXiao => '취소';

  @override
  String get shanChu => '삭제';

  @override
  String get yiCongYunPanShanChu => '클라우드에서 삭제했습니다';

  @override
  String get shangChuanDaoYunPan => '클라우드에 업로드';

  @override
  String get souSuoYunPanGeQu => '클라우드 곡 검색';

  @override
  String get yunPanZanWuGeQu => '클라우드에 곡이 없습니다';

  @override
  String get jiaZaiGengDuo => '더 불러오기';

  @override
  String get dengLuHouChaKanYunPan => '로그인 후 클라우드 확인';

  @override
  String get bengKuiRiZhi => '크래시 로그';

  @override
  String get meiYouBengKuiJiLu => '크래시 기록이 없습니다';

  @override
  String get qingKong => '비우기';

  @override
  String get qingTian => '맑음';

  @override
  String get kongJieGuo => '결과 없음';

  @override
  String get geCi => '가사';

  @override
  String get zhouJieLun => '저우제룬';

  @override
  String get xiangYingYiChang => '응답 이상';

  @override
  String get boFangYu => '재생';

  @override
  String get neiRongGuoLv => '콘텐츠 필터';

  @override
  String get lianTongXing => '연결성';

  @override
  String get boFang => '재생';

  @override
  String get zanWuRiZhi => '로그 없음';

  @override
  String get yiFuZhiGaiTiao => '항목을 복사했습니다';

  @override
  String get yiKaiQiShiShiTanCe => '실시간 측정을 켰습니다';

  @override
  String get wangLuoQingQiuRiZhi => '네트워크 요청 로그';

  @override
  String get ceShiWangLuo => '네트워크 테스트';

  @override
  String get qingQiu => '요청';

  @override
  String get xiangYing => '응답';

  @override
  String get cuoWu => '오류';

  @override
  String get fuZhiQuanBu => '모두 복사';

  @override
  String get qingKongRiZhi => '로그 비우기';

  @override
  String get shiShiTanCe => '실시간 측정';

  @override
  String get fuZhiCiTiao => '이 항목 복사';

  @override
  String get cuoWuXinXi => '오류 정보';

  @override
  String get jingDianXuanFu => '클래식 오버레이';

  @override
  String get kuGouLv => 'KuGou 그린';

  @override
  String get wangYiYunHong => 'NetEase 레드';

  @override
  String get riLuoJu => '선셋 오렌지';

  @override
  String get saiBoZi => '사이버 퍼플';

  @override
  String get shenSeKaPian => '다크 카드';

  @override
  String get shuiMoHei => '수묵 블랙';

  @override
  String get jieSuo => '잠금 해제';

  @override
  String get shangYiShou => '이전 곡';

  @override
  String get xiaYiShou => '다음 곡';

  @override
  String get suoDing => '잠금';

  @override
  String get geDanJiaZaiShiBaiQingJianChaWangLuoHouChongShi =>
      '재생목록을 불러오지 못했습니다. 네트워크를 확인한 후 다시 시도하세요';

  @override
  String get xinDieJiaZaiShiBaiQingJianChaWangLuoHouChongShi =>
      '신보를 불러오지 못했습니다. 네트워크를 확인한 후 다시 시도하세요';

  @override
  String get xinGeJiaZaiShiBaiQingJianChaWangLuoHouChongShi =>
      '신곡을 불러오지 못했습니다. 네트워크를 확인한 후 다시 시도하세요';

  @override
  String get geShouJiaZaiShiBaiQingJianChaWangLuoHouChongShi =>
      '아티스트를 불러오지 못했습니다. 네트워크를 확인한 후 다시 시도하세요';

  @override
  String get tanSuoFaXian => '탐색';

  @override
  String get zanWuGeDan => '재생목록이 없습니다';

  @override
  String get dangQianWangLuoBeiWangGuanLanJieUrlGuoLvWuFaFang_3 =>
      '네트워크가 이 음원을 차단하고 있습니다(게이트웨이 URL 필터링).\n모바일 핫스팟으로 전환하거나 공유기의 웹 필터를 끈 후 다시 시도하세요.';

  @override
  String get jieKouJuJueFangWenAccessDenyShaoHouChongShiHuoJi =>
      'API 가 접근을 거부했습니다(Access Deny).\n잠시 후 다시 시도하거나 요청 제한이 걸렸는지 확인하세요.';

  @override
  String get shuJuJiaZaiShiBaiQingJianChaWangLuoHouChongShi =>
      '데이터를 불러오지 못했습니다. 네트워크를 확인한 후 다시 시도하세요';

  @override
  String get lingChenHao => '좋은 밤이에요';

  @override
  String get zaoShangHao => '좋은 아침이에요';

  @override
  String get xiaWuHao => '좋은 오후예요';

  @override
  String get wanShangHao => '좋은 저녁이에요';

  @override
  String get faXianHaoYinLeWeiNiJingXuanJinRiXuanLv => '음악 발견 · 오늘을 위한 셀렉션';

  @override
  String get gengDuo => '더 보기';

  @override
  String get jinRiReGe => '오늘의 인기곡';

  @override
  String get targetJianSuo => 'TARGET // 검색';

  @override
  String get diShiWuYeYinLvBuWan => '제15야 · 음률 보완';

  @override
  String get yiJiaRuWoXiHuan => '좋아요에 추가했습니다';

  @override
  String get tan => '탐';

  @override
  String get yinLvTanSuo => '음률 탐색';

  @override
  String get geDanBangDanXinDieGeShouArchive =>
      '재생목록 · 차트 · 신보 · 아티스트 // ARCHIVE';

  @override
  String get tanSuo => '탐색';

  @override
  String get geDanBangDanXinDieGeShou => '재생목록 · 차트 · 신보 · 아티스트';

  @override
  String get weiNiTuiJian => '맞춤 추천';

  @override
  String get meiRiFengGeGeDanJingXuanDailySync =>
      '데일리 · 스타일 · 재생목록 셀렉션 // DAILY SYNC';

  @override
  String get meiRiFengGeGeDanJingXuan => '데일리 · 스타일 · 재생목록 셀렉션';

  @override
  String get meiYouKeYongDeSiRenFmYinYuanQingDaoSheZhiLiKaiQi =>
      '개인 FM 을 지원하는 음원이 없습니다. 설정에서 켜 주세요';

  @override
  String get fmGeChiJiaZaiShiBaiQingJianChaWangLuo =>
      'FM 곡 풀을 불러오지 못했습니다. 네트워크를 확인하세요';

  @override
  String get dangQianYinYuanBuZhiChiSiRenFm => '현재 음원은 개인 FM 을 지원하지 않습니다';

  @override
  String get siRenFmJiaZaiShiBaiQingJianChaWangLuo =>
      '개인 FM 을 불러오지 못했습니다. 네트워크를 확인하세요';

  @override
  String get kaiShiDianTai => '라디오 시작';

  @override
  String get liJiShengXiao => '즉시 적용';

  @override
  String get dangQianBoFang => '재생 중';

  @override
  String get shangWeiKaiShiDianTai => '아직 라디오를 시작하지 않았습니다';

  @override
  String get jieXiaLai => '다음 곡';

  @override
  String get geChiJianDiLeHuanGeMoShiHuoGeChiShiShi =>
      '곡 풀이 바닥났습니다. 다른 모드나 풀을 시도하세요';

  @override
  String get buXiHuan => '관심 없음';

  @override
  String get yiCongBoFangLiShiZhongYiChu => '재생 기록에서 삭제했습니다';

  @override
  String get cheXiao => '실행 취소';

  @override
  String get qingKongBoFangLiShi => '재생 기록 비우기';

  @override
  String get queDingYaoQingKongQuanBuBoFangLiShiMaCiCaoZuoWuF =>
      '모든 재생 기록을 비울까요? 이 작업은 되돌릴 수 없습니다.';

  @override
  String get boFangLiShiYiQingKong => '재생 기록을 비웠습니다';

  @override
  String get souSuoLiShiGeQuGeShou => '기록, 곡, 아티스트 검색…';

  @override
  String get boFangLiShi => '재생 기록';

  @override
  String get souSuoLiShi => '검색 기록';

  @override
  String get qingKongLiShi => '기록 비우기';

  @override
  String get boFangJiLu => '재생 로그';

  @override
  String get tingGeTongJi => '청취 통계';

  @override
  String get haiMeiYouBoFangJiLuQuSouSuoTingYiShouBa =>
      '아직 재생 기록이 없습니다.\n곡을 검색해서 들어 보세요.';

  @override
  String get weiZhaoDaoPiPeiDeBoFangJiLu => '일치하는 재생 기록이 없습니다';

  @override
  String get congLiShiYiChu => '기록에서 삭제';

  @override
  String get zanWuTingGeShuJuTingJiShouGeHouZaiLaiKanKanFenXi =>
      '아직 청취 데이터가 없습니다.\n몇 곡 듣고 나서 분석을 확인하세요.';

  @override
  String get n6TianQian => '6일 전';

  @override
  String get n5TianQian => '5일 전';

  @override
  String get n4TianQian => '4일 전';

  @override
  String get n3TianQian => '3일 전';

  @override
  String get qianTian => '그저께';

  @override
  String get zuoTian => '어제';

  @override
  String get jinTian => '오늘';

  @override
  String get liShiQuMu => '재생한 곡';

  @override
  String get yuGuShiChang => '예상 재생 시간';

  @override
  String get jin7TianTingGePinCi => '최근 7일 청취 빈도';

  @override
  String get tingGeShiDuanPianHao => '선호 청취 시간대';

  @override
  String get lingChen00000559 => '심야 (00:00–05:59)';

  @override
  String get shangWu06001159 => '오전 (06:00–11:59)';

  @override
  String get xiaWu12001759 => '오후 (12:00–17:59)';

  @override
  String get yeWan18002359 => '저녁 (18:00–23:59)';

  @override
  String get changTingGeShouTopBang => '자주 듣는 아티스트';

  @override
  String get moRenPaiXu => '기본 정렬';

  @override
  String get geQuMing => '곡명';

  @override
  String get geShouMing => '아티스트명';

  @override
  String get souSuoGeMingGeShouZhuanJi => '곡명, 아티스트, 앨범 검색…';

  @override
  String get souSuoGuanZhuDeGeShou => '팔로우한 아티스트 검색…';

  @override
  String get souSuoShouCangDeZhuanJiHuoGeShou => '저장한 앨범이나 아티스트 검색…';

  @override
  String get shuaXinWoXiHuanGeQu => '좋아요 곡 새로고침';

  @override
  String get paiXuFangShi => '정렬 방식';

  @override
  String get shuaXinGuanZhuGeShou => '팔로우 아티스트 새로고침';

  @override
  String get shuaXinShouCangZhuanJi => '저장 앨범 새로고침';

  @override
  String get weiZhaoDaoPiPeiDeGeQuHuanGeGuanJianCiShiShi =>
      '일치하는 곡이 없습니다.\n다른 키워드를 시도하세요.';

  @override
  String get yiQuXiaoXiHuan => '좋아요에서 제거했습니다';

  @override
  String get quXiaoXiHuan => '좋아요 취소';

  @override
  String get wangYiYunWoXiHuanHaiMeiYouHongXinGeQuZaiWangYiYu =>
      'NetEase 좋아요에 아직 하트한 곡이 없습니다.\nNetEase 에서 ♥ 를 누르면 여기로 동기화됩니다.';

  @override
  String get bZhanMeiYouYunDuanWoXiHuanHongXinZhiBaoCunZaiBen =>
      'Bilibili 에는 클라우드 좋아요 목록이 없습니다.\n하트는 이 기기에만 저장됩니다.';

  @override
  String get dengLuKuGouZhangHaoHouJiKeTongBuYunDuanWoXiHuan =>
      'KuGou 에 로그인하면 클라우드 좋아요를 동기화할 수 있습니다';

  @override
  String get haiMeiYouHongXinGeQuBoFangShiDianJiKeShouCangDao =>
      '하트한 곡이 없습니다.\n재생 중 ♥ 를 누르면 클라우드에 저장됩니다.';

  @override
  String get liJiDengLu => '지금 로그인';

  @override
  String get dengLuKuGouZhangHaoHouJiKeTongBuGuanZhuDeGeShou =>
      'KuGou 에 로그인하면 팔로우한 아티스트를 동기화할 수 있습니다';

  @override
  String get zanWuGuanZhuDeGeShouSouSuoGeShouBingDianJiGuanZh =>
      '팔로우한 아티스트가 없습니다.\n아티스트를 검색해 팔로우하면 여기에 표시됩니다.';

  @override
  String get weiZhaoDaoPiPeiDeGeShou => '일치하는 아티스트가 없습니다';

  @override
  String get dengLuKuGouZhangHaoHouJiKeTongBuShouCangDeZhuanJ =>
      'KuGou 에 로그인하면 저장한 앨범을 동기화할 수 있습니다';

  @override
  String get zanWuShouCangDeZhuanJiZaiZhuanJiXiangQingZhongDi =>
      '저장한 앨범이 없습니다.\n앨범 화면에서 저장하면 여기에 표시됩니다.';

  @override
  String get weiZhaoDaoPiPeiDeZhuanJi => '일치하는 앨범이 없습니다';

  @override
  String get xuDengLuHouChaKan => '로그인 후 확인';

  @override
  String get danMuYiGuanBiSheZhiYuFaSong => '탄막 꺼짐 · 설정 및 보내기';

  @override
  String get dangQianYinYuanBuZhiChiDanMu => '현재 음원은 탄막을 지원하지 않습니다';

  @override
  String get danMuYiFaSong => '탄막을 보냈습니다';

  @override
  String get yiGuanBi => '꺼짐';

  @override
  String get touMingDu => '투명도';

  @override
  String get ziHao => '글자 크기';

  @override
  String get suDu => '속도';

  @override
  String get miDu => '밀도';

  @override
  String get xiShu => '성김';

  @override
  String get shiZhong => '보통';

  @override
  String get miJi => '빽빽함';

  @override
  String get xianShiQuYu => '표시 영역';

  @override
  String get dingBu => '상단';

  @override
  String get shangBanPing => '화면 상단 절반';

  @override
  String get quanPing => '전체 화면';

  @override
  String get faSongDanMu => '탄막 보내기';

  @override
  String get xieXiaCiKeDeGanShou => '지금의 느낌을 적어 보세요…';

  @override
  String get faSongHouKaiQiDanMuJiKeZaiHuaMianShangKanDao => '탄막을 켜면 영상에 표시됩니다';

  @override
  String get faSong => '보내기';

  @override
  String get danMuJiaZaiZhong => '탄막 불러오는 중…';

  @override
  String get zanWuDanMu => '탄막이 없습니다';

  @override
  String get dangQianYinYuanBuZhiChiMv => '현재 음원은 MV 를 지원하지 않습니다';

  @override
  String get meiYouKeYongDeShiPinPianYuan => '재생할 수 있는 영상 소스가 없습니다';

  @override
  String get mvJiaZaiShiBai => 'MV 를 불러오지 못했습니다';

  @override
  String get zheShouGeZanWuMv => '이 곡에는 MV 가 없습니다';

  @override
  String get boFangMv => 'MV 재생';

  @override
  String get dangQianZhuoMianWuFaJinRuXiaoChuangJiXuQuanYeBoF =>
      '이 데스크톱에서는 미니 창을 열 수 없습니다. 전체 화면 재생을 계속합니다';

  @override
  String get huanYuanChuangKou => '창 복원';

  @override
  String get tingZhiBingGuanBi => '중지하고 닫기';

  @override
  String get suoWeiZhiDingMiNiChuang => '고정 미니 창으로 축소';

  @override
  String get suoXiaoWeiXiaoChuang => '작은 창으로 축소';

  @override
  String get zanTing => '일시정지';

  @override
  String get xiangQing => '상세';

  @override
  String get qiTaBanBen => '다른 버전';

  @override
  String get guanFangTuiJian => '공식 추천';

  @override
  String get shouCangMv => 'MV 저장';

  @override
  String get yiQuXiaoShouCang => '저장을 해제했습니다';

  @override
  String get shouCang => '저장';

  @override
  String get xiaZai => '다운로드';

  @override
  String get faXing => '발매';

  @override
  String get huaZhi => '화질';

  @override
  String get jianJie => '소개';

  @override
  String get beiSu => '배속';

  @override
  String get jingYin => '음소거';

  @override
  String get n10Miao => '10초';

  @override
  String get buXiHuanHuanXiaYiShou => '관심 없음, 다음 곡';

  @override
  String get yiJingShiSiRenFmDeDiYiShou => '이미 개인 FM 의 첫 곡입니다';

  @override
  String get guanBiSiRenFmMianBan => '개인 FM 패널 닫기';

  @override
  String get shouQi => '접기';

  @override
  String get geChiZhengZaiXuJie => '곡 풀을 채우는 중…';

  @override
  String get zanWuBoFangNeiRongQuSouSuoHuoGeDanLiDianYiShouGe =>
      '재생 중인 곡이 없습니다.\n검색이나 재생목록에서 곡을 선택하세요.';

  @override
  String get shouQiBoFangYe => '플레이어 접기';

  @override
  String get boFangDuiLie => '재생 대기열';

  @override
  String get zhengZaiBoFang => '재생 중';

  @override
  String get gongKai => '공개';

  @override
  String get shiShiTongXinRiZhi => '실시간 통신 로그';

  @override
  String get zanWuBoFangNeiRong => '재생 중인 곡이 없습니다';

  @override
  String get shouQiGeCi => '가사 접기';

  @override
  String get boFangShiBaiKeDianXiaYiShouChongShi =>
      '재생에 실패했습니다. 다음 곡을 누르면 다시 시도합니다';

  @override
  String get quDengLu => '로그인하기';

  @override
  String get queShaoGeQuGuanLianIdWuFaChaXunQuKuMv =>
      '곡 연결 ID 가 없어 카탈로그 MV 를 조회할 수 없습니다';

  @override
  String get guanLianShiPinJunBeiPingTaiBiaoJiWeiDuanShiPinWe =>
      '연결된 영상이 모두 숏클립으로 표시되어 사용할 MV 가 없습니다';

  @override
  String get weiZhaoDaoFuHeTiaoJianDeQuKuMv => '조건에 맞는 카탈로그 MV 를 찾지 못했습니다';

  @override
  String get quKuMvBoFangDiZhiHuoQuShiBai => '카탈로그 MV 재생 URL 을 가져오지 못했습니다';

  @override
  String get quKuMvChaXunShiBaiQingShaoHouChongShi =>
      '카탈로그 MV 조회에 실패했습니다. 잠시 후 다시 시도하세요';

  @override
  String get shunXuBoFang => '순차 재생';

  @override
  String get lieBiaoXunHuan => '목록 반복';

  @override
  String get suiJiBoFang => '셔플';

  @override
  String get danQuXunHuan => '한 곡 반복';

  @override
  String get boFangShiBaiYuanBuKeBoVipFangDaoLianWangLuo =>
      '재생 실패: 음원을 재생할 수 없습니다(VIP / 핫링크 보호 / 네트워크)';

  @override
  String get boFangChuCuo => '재생 오류';

  @override
  String get moRenShunXu => '기본 순서';

  @override
  String get qieHuanBangDan => '차트 전환';

  @override
  String get zanWuBangDan => '차트가 없습니다';

  @override
  String get gaiWeiJiangXu => '내림차순으로 변경';

  @override
  String get wanCheng => '완료';

  @override
  String get souSuoGeMingGeShouZhuanJi_2 => '곡명, 아티스트, 앨범 검색…';

  @override
  String get zanWuGeQu => '곡이 없습니다';

  @override
  String get meiYouPiPeiDeGeQu => '일치하는 곡이 없습니다';

  @override
  String get beiJing => '베이징';

  @override
  String get tianJin => '톈진';

  @override
  String get heBei => '허베이';

  @override
  String get shanXi => '산시';

  @override
  String get neiMengGu => '내몽골';

  @override
  String get liaoNing => '랴오닝';

  @override
  String get jiLin => '지린';

  @override
  String get heiLongJiang => '헤이룽장';

  @override
  String get shangHai => '상하이';

  @override
  String get jiangSu => '장쑤';

  @override
  String get zheJiang => '저장';

  @override
  String get anHui => '안후이';

  @override
  String get fuJian => '푸젠';

  @override
  String get jiangXi => '장시';

  @override
  String get shanDong => '산둥';

  @override
  String get heNan => '허난';

  @override
  String get huBei => '후베이';

  @override
  String get huNan => '후난';

  @override
  String get guangDong => '광둥';

  @override
  String get guangXi => '광시';

  @override
  String get haiNan => '하이난';

  @override
  String get chongQing => '충칭';

  @override
  String get siChuan => '쓰촨';

  @override
  String get guiZhou => '구이저우';

  @override
  String get yunNan => '윈난';

  @override
  String get xiZang => '티베트';

  @override
  String get shanXi_2 => '산시(섬서)';

  @override
  String get ganSu => '간쑤';

  @override
  String get qingHai => '칭하이';

  @override
  String get ningXia => '닝샤';

  @override
  String get xinJiang => '신장';

  @override
  String get taiWan => '타이완';

  @override
  String get xiangGang => '홍콩';

  @override
  String get aoMen => '마카오';

  @override
  String get weiZhi => '알 수 없음';

  @override
  String get heiJiaoVip => '바이닐 VIP';

  @override
  String get geRenZhongXin => '내 프로필';

  @override
  String get souSuoYuBoFangGongKaiNeiRongWuXuDengLu =>
      '공개 콘텐츠 검색과 재생에는 로그인이 필요하지 않습니다';

  @override
  String get shou => '곡';

  @override
  String get jingYan => '경험치';

  @override
  String get changTing => '무제한 듣기';

  @override
  String get gaiNian => '컨셉트';

  @override
  String get huiYuan => '멤버십';

  @override
  String get shengJiJinDu => '레벨 진행도';

  @override
  String get guanZhu => '팔로잉';

  @override
  String get fenSi => '팔로워';

  @override
  String get fangKe => '방문자';

  @override
  String get woDeDengJi => '내 레벨';

  @override
  String get meiYiCiLingTingDouZaiJiLeiChengZhang => '들을 때마다 성장이 쌓입니다.';

  @override
  String get dangQianDengJi => '현재 레벨';

  @override
  String get zanWeiHuoQuDaoXiaYiDengJiJinDu => '다음 레벨 진행도를 아직 가져올 수 없습니다';

  @override
  String get dangQianDengJiQuanYi => '현재 레벨 혜택';

  @override
  String get zhangHaoDangAn => '계정 정보';

  @override
  String get yongHuId => '사용자 ID';

  @override
  String get xingBie => '성별';

  @override
  String get leLing => '가입 기간';

  @override
  String get leiJiTingGe => '누적 청취';

  @override
  String get suoZaiDiQu => '지역';

  @override
  String get huiYuanZhuangTai => '멤버십 상태';

  @override
  String get changTingHuiYuan => '무제한 듣기 멤버십';

  @override
  String get gaiNianHuiYuan => '컨셉트 멤버십';

  @override
  String get zhengZaiHuoQuZhangHaoXinXi => '계정 정보를 가져오는 중…';

  @override
  String get yunBei => '클라우드 조개';

  @override
  String get ziJianGeDan => '내 재생목록';

  @override
  String get weiKaiTong => '미가입';

  @override
  String get sheZhi => '설정';

  @override
  String get heiJiaoHuiYuan => '바이닐 멤버십';

  @override
  String get yiDengLuChaKanGeRenZhongXin => '로그인됨 · 내 프로필 열기';

  @override
  String get weiDengLuGongKaiNeiRongKeYong => '로그아웃 · 공개 콘텐츠 이용 가능';

  @override
  String get zanBuZhiChi => '아직 지원하지 않음';

  @override
  String get woDe => '내 정보';

  @override
  String get zuiJinBoFang => '최근 재생';

  @override
  String get woDeGeDan => '내 재생목록';

  @override
  String get shuaXinGeDan => '재생목록 새로고침';

  @override
  String get gengDuoSheZhi => '추가 설정';

  @override
  String get dingShiTingZhi => '취침 타이머';

  @override
  String get yinZhiSheZhi => '음질 설정';

  @override
  String get zhuTiWaiGuan => '테마와 화면';

  @override
  String get guanYu => '정보';

  @override
  String get zanWuShouCangGeDan => '저장한 재생목록이 없습니다';

  @override
  String get shenSe => '다크';

  @override
  String get gaiNianBanMoRenShenSe => '컨셉트 에디션은 기본이 다크입니다';

  @override
  String get qianSe => '라이트';

  @override
  String get qianSeWanZhengShiPei => '라이트 모드에 완전 최적화';

  @override
  String get genSuiXiTong => '시스템 설정 따르기';

  @override
  String get suiXiTongShenQianSeQieHuan => '시스템 라이트/다크 설정에 따라 전환';

  @override
  String get baoMi => '비공개';

  @override
  String get yiGuoQi => '만료됨';

  @override
  String get jiJiangDaoQi => '곧 만료';

  @override
  String get tuiChu => '로그아웃';

  @override
  String get paiHangBangJiaZaiShiBaiQingJianChaWangLuoHouChon =>
      '차트를 불러오지 못했습니다. 네트워크를 확인한 후 다시 시도하세요';

  @override
  String get weiNiLiangShenDingZhiDeMeiRiGeDan => '당신을 위한 데일리 재생목록';

  @override
  String get dengLuHouChaKanJinRiTuiJian => '로그인하면 오늘의 추천을 볼 수 있습니다';

  @override
  String get jinRiGongKaiGeDan => '오늘의 공개 재생목록';

  @override
  String get zhengZaiWeiNiDingZhiTuiJian => '추천을 준비하는 중…';

  @override
  String get quDengLuHuoQuGeXingHuaMeiRiTuiJian => '로그인하고 맞춤형 데일리 추천을 받으세요';

  @override
  String get jinRiZanWuTuiJian => '오늘은 추천이 없습니다';

  @override
  String get fengGeGeDanJiaZaiShiBaiQingJianChaWangLuoHouChon =>
      '스타일 재생목록을 불러오지 못했습니다. 네트워크를 확인한 후 다시 시도하세요';

  @override
  String get tuiJianGeDanJiaZaiShiBaiQingJianChaWangLuoHouCho =>
      '추천 재생목록을 불러오지 못했습니다. 네트워크를 확인한 후 다시 시도하세요';

  @override
  String get bianJiJingXuanJiaZaiShiBaiQingJianChaWangLuoHouC =>
      '에디터 추천을 불러오지 못했습니다. 네트워크를 확인한 후 다시 시도하세요';

  @override
  String get moRenTuiJian => '기본 추천';

  @override
  String get shangWuHao => '좋은 아침이에요';

  @override
  String get zhongWuHao => '좋은 오후예요';

  @override
  String get youCiKaiQiHaoXinQing => '기분 좋은 하루의 시작 ~';

  @override
  String get zanWuFengGeGeDan => '스타일 재생목록이 없습니다';

  @override
  String get zanWuNeiRong => '아직 내용이 없습니다';

  @override
  String get weiNiLiangShenDingZhi => '당신을 위한 추천';

  @override
  String get shiShiReMenQuShi => '실시간 인기 트렌드';

  @override
  String get meiYouKeYongYinYuan => '사용할 수 있는 음원이 없습니다';

  @override
  String get souSuoShiBaiQingChongShi => '검색에 실패했습니다. 다시 시도하세요';

  @override
  String get qingKongSouSuoLiShi => '검색 기록 비우기';

  @override
  String get queDingYaoQingKongQuanBuSouSuoLiShiMaCiCaoZuoWuF =>
      '모든 검색 기록을 비울까요? 이 작업은 되돌릴 수 없습니다.';

  @override
  String get souSuoGeQuGeDanZhuanJiGeShou => '곡, 재생목록, 앨범, 아티스트 검색';

  @override
  String get jiaZaiShiBaiDianJiChongShi => '불러오지 못했습니다. 눌러서 다시 시도';

  @override
  String get meiYouGengDuoLe => '더 이상 없습니다';

  @override
  String get linJunJie => 'JJ 린';

  @override
  String get chenYiXun => '진이쉰';

  @override
  String get shuoChang => '랩';

  @override
  String get yueYu => '광둥어';

  @override
  String get reMenSouSuo => '인기 검색';

  @override
  String get meiCiXunWen => '매번 묻기';

  @override
  String get zuiXiaoHuaDaoTuoPan => '트레이로 최소화';

  @override
  String get tuiChuYingYong => '앱 종료';

  @override
  String get guanBiShiTanChuTiShiKeGouXuanJiZhuWoDeXuanZe =>
      '닫을 때 확인 창을 표시합니다. “선택 기억”을 체크하면 다시 묻지 않습니다';

  @override
  String get guanBiShiZuiXiaoHuaDaoXiTongTuoPanBuTuiChuYingYo =>
      '닫을 때 종료하지 않고 시스템 트레이로 최소화';

  @override
  String get guanBiShiZhiJieTuiChuYingYong => '닫을 때 앱 종료';

  @override
  String get yiQingLiTuPianHuanCunBoFangYuSouSuoLiShi =>
      '이미지 캐시, 재생 기록, 검색 기록을 지웠습니다';

  @override
  String get waiGuan => '화면';

  @override
  String get shiYanUi => '실험적 UI';

  @override
  String get chuangKou => '창';

  @override
  String get guanBiZhuChuangKouShi => '기본 창을 닫을 때';

  @override
  String get renWuLanBoFangJinDu => '작업 표시줄 재생 진행률';

  @override
  String get zaiRenWuLanAnNiuShangXianShiBoFangJinDuBoFangLvZ =>
      '작업 표시줄 버튼에 재생 진행률 표시(재생 초록 / 일시정지 노랑)';

  @override
  String get renWuLanFengMianYuLan => '작업 표시줄 커버 미리보기';

  @override
  String get xuanTingHeChuangKouQieHuanXianShiFengMianXinXiKa =>
      '호버와 창 전환 시 커버 카드를 표시합니다. 끄면 기본 미리보기로 돌아갑니다';

  @override
  String get duLiBoKongHengTiao => '독립 재생 바';

  @override
  String get renWuLanShangFangFuTiaoKeTuoDongTuoJinDuHeDiaoYi =>
      '작업 표시줄 위에 떠 있는 바. 드래그, 탐색, 볼륨 조절 가능하며 전체 화면에서는 숨겨집니다';

  @override
  String get zhuoMianGeCi => '바탕 화면 가사';

  @override
  String get xianShiZhuoMianGeCi => '바탕 화면 가사 표시';

  @override
  String get xuanFuChuangXianShiDangQianGeCiKeTuoDongSuoDingD =>
      '플로팅 창에 현재 가사를 표시합니다. 드래그, 잠금, 클릭 통과 지원';

  @override
  String get x11DuLiGeCiChuangKeTuoDongHeSuoDingChuanTouWuHeC =>
      'X11 전용 독립 가사 창. 드래그와 잠금 시 클릭 통과를 지원하며, 컴포지터가 없으면 가사 카드를 사용합니다';

  @override
  String get duLiXuanFuChuangXianShiDangQianGeCiKeZhiDingSuoD =>
      '독립 플로팅 창에 현재 가사를 표시합니다. 항상 위, 잠금 시 클릭 통과';

  @override
  String get xuYaoXianShiZaiQiTaYingYongShangCengQuanXianCaiN =>
      '플로팅 가사를 쓰려면 “다른 앱 위에 표시” 권한이 필요합니다';

  @override
  String get suoDingGeCiChuang => '가사 창 잠금';

  @override
  String get suoDingHouDianJiChuanTouDaoXiaCengYingYongBiMian =>
      '잠그면 클릭이 아래 앱으로 통과해 조작을 방해하지 않습니다';

  @override
  String get dianJiChuanTouDaoXiaCengYingYongBiMianDangZhuCao =>
      '클릭이 아래 앱으로 통과해 조작을 방해하지 않습니다';

  @override
  String get geCiYangShi => '가사 스타일';

  @override
  String get ziDingYi => '사용자 지정';

  @override
  String get geCiPianYiQuanJu => '가사 오프셋(전체)';

  @override
  String get yuXiTongShiJianDuiQiBoFangYeGeCiXianShiLiKeAnDan =>
      '시스템 시간에 맞춥니다. 곡별 미세 조정은 플레이어 화면의 “가사 표시”에서 할 수 있습니다';

  @override
  String get tiQian05s => '0.5초 앞당기기';

  @override
  String get yanHou05s => '0.5초 늦추기';

  @override
  String get chongZhiGeCiWeiZhi => '가사 위치 초기화';

  @override
  String get huiDaoPingMuDingBuJuZhongLiDingDuan12px =>
      '화면 상단 중앙으로 복귀(위에서 12px)';

  @override
  String get geCiWeiZhiYiChongZhiWeiDingBuJuZhong => '가사 위치를 상단 중앙으로 초기화했습니다';

  @override
  String get moRenYinZhi => '기본 음질';

  @override
  String get shiBaiShiChangShiMvYinPin => '실패 시 MV 오디오 시도';

  @override
  String get yinYuanBuKeYongShiJieYongGeQuGuanLianQuKuMvDeYin =>
      '음원을 쓸 수 없을 때 곡에 연결된 카탈로그 MV 오디오를 빌려 씁니다. 음질을 알 수 없고 가사와 재생 시간이 어긋날 수 있습니다';

  @override
  String get geCiYuFengMian => '가사와 커버';

  @override
  String get suoPingLanYaXianShiGeCi => '잠금 화면 / 블루투스에 가사 표시';

  @override
  String get xiTongMeiTiFuBiaoTiXianShiGeShouDangQianGeCi =>
      '시스템 미디어 부제목에 “아티스트 · 현재 가사” 표시';

  @override
  String get jinWiFiJiaZaiFengMian => 'Wi-Fi 에서만 커버 불러오기';

  @override
  String get zhangHaoGuanLi => '계정 관리';

  @override
  String get moRenYinYuan => '기본 음원';

  @override
  String get youKeMoShiShuJuJinCunBenJi => '게스트 모드. 데이터는 이 기기에만 저장됩니다';

  @override
  String get saoMaDengLuHouKeTongBuGeDanYuBoFangQuanXian =>
      'QR 로그인 후 재생목록과 재생 권한을 동기화할 수 있습니다';

  @override
  String get youKeKeBoFangDengLuHouDuQuShouCangJia =>
      '게스트도 재생할 수 있습니다. 로그인하면 저장 폴더를 읽을 수 있습니다';

  @override
  String get tiaoShi => '디버그';

  @override
  String get qingQiuXiangYingCuoWuCeShiWangLuoShiShiTanCeFuZh =>
      '요청 / 응답 / 오류 · 네트워크 테스트 · 실시간 측정 · 복사';

  @override
  String get huanCun => '캐시';

  @override
  String get qingLiTuPianHuanCunYuBoFangSouSuoLiShi => '이미지 캐시와 재생·검색 기록 지우기';

  @override
  String get buYingXiangDengLuYuWoXiHuanDuiLieBenDiFuBenHuiYi =>
      '로그인과 좋아요에는 영향이 없습니다. 대기열의 로컬 사본도 함께 비워집니다';

  @override
  String get zuiHouYiGeYinYuanZhiShaoBaoLiuYiGe => '마지막 음원입니다. 최소 한 개는 켜 두세요';

  @override
  String get guanBiHouYinCangYinYueYunPanRuKouYuGaiYuanYunPan =>
      '끄면 「음악 클라우드」 입구와 이 음원의 클라우드가 숨겨집니다';

  @override
  String get zhuTiSe => '강조 색상';

  @override
  String get wu => '없음';

  @override
  String get dangQianYinYuanBuZhiChiPingLun => '현재 음원은 댓글을 지원하지 않습니다';

  @override
  String get pingLunYiFaBu => '댓글을 게시했습니다';

  @override
  String get huiFuYiFaBu => '답글을 게시했습니다';

  @override
  String get dianZanShiBaiQingShaoHouZaiShi => '좋아요에 실패했습니다. 잠시 후 다시 시도하세요';

  @override
  String get yiJiaRuBoFang => '대기열에 추가했습니다';

  @override
  String get jingCaiPingLun => '주목할 댓글';

  @override
  String get meiYouGengDuoPingLunLe => '더 이상 댓글이 없습니다';

  @override
  String get laiYuan => '출처';

  @override
  String get dengLuHouCanYuPingLun => '로그인하고 댓글에 참여하세요';

  @override
  String get kuGouDengLuHuiFu => 'KuGou 로그인 복원';

  @override
  String get wangYiYunDengLuHuiFu => 'NetEase 로그인 복원';

  @override
  String get bZhanDengLuHuiFu => 'Bilibili 로그인 복원';

  @override
  String get fanYinBoFang => '泛音 재생';

  @override
  String get zuiXiaoHua => '최소화';

  @override
  String get zuiDaHua => '최대화';

  @override
  String get guanBiFanYin => '泛音 닫기';

  @override
  String get tuiChuYingYongHaiShiZuiXiaoHuaDaoXiTongTuoPanJiX =>
      '앱을 종료할까요, 아니면 시스템 트레이로 최소화하고 계속 재생할까요?';

  @override
  String get dangQianZhuoMianMeiYouKeYongDeXiTongTuoPanTuiChu =>
      '이 데스크톱에서는 시스템 트레이를 쓸 수 없습니다. 앱을 종료할까요, 아니면 창을 열어 둘까요?';

  @override
  String get jiZhuWoDeXuanZe => '선택 기억';

  @override
  String get xiaCiGuanBiBuZaiXunWenKeZaiSheZhiZhongXiuGai =>
      '다음부터 묻지 않습니다. 설정에서 변경할 수 있습니다';

  @override
  String get xuanZeGeQuKaiShiBoFang => '곡을 선택해 재생 시작';

  @override
  String get xianShiChuangKou => '창 표시';

  @override
  String get boFangMoShi => '재생 모드';

  @override
  String get zengDaYinLiang => '볼륨 높이기';

  @override
  String get jianXiaoYinLiang => '볼륨 낮추기';

  @override
  String get jiaZaiShiBai => '불러오지 못했습니다';

  @override
  String get shuoShuoGuanYuZheShouGeDeGuShi => '이 곡의 이야기를 적어 보세요';

  @override
  String get jiaZaiZhong => '불러오는 중…';

  @override
  String get zanWuHuiFu => '답글이 없습니다';

  @override
  String get laiYuan_2 => '출처: ';

  @override
  String get quSheZhiKaiQi => '설정에서 켜기';

  @override
  String get xiaLaGuanBiNieHeSuoFang => '아래로 밀어 닫기 · 핀치로 확대';

  @override
  String get zhuoMianGeCiYangShi => '바탕 화면 가사 스타일';

  @override
  String get ziHaoQuanJuTongYiZaiBoFangYeGeCiXianShiLiTiaoYin =>
      '글자 크기는 전체 공통입니다. 플레이어 화면의 「가사 표시」에서 조절하면 앱 내 가사와 플로팅 창에 함께 적용됩니다';

  @override
  String get yiChangYanSe => '불린 색';

  @override
  String get weiChangYanSe => '안 불린 색';

  @override
  String get miaoBianYanSe => '외곽선 색';

  @override
  String get miaoBianKuanDu => '외곽선 두께';

  @override
  String get beiJingYanSe => '배경 색';

  @override
  String get beiJingShenDu => '배경 농도';

  @override
  String get beiJingYuanJiao => '배경 모서리';

  @override
  String get ziZhong => '글꼴 두께';

  @override
  String get changGui => '보통';

  @override
  String get zhongDeng => '중간';

  @override
  String get banCu => '세미 볼드';

  @override
  String get cuTi => '볼드';

  @override
  String get teCu => '엑스트라 볼드';

  @override
  String get heiTi => '블랙';

  @override
  String get huiFuMoRen => '기본값 복원';

  @override
  String get yeKongZhongZuiLiangDeXing => '밤하늘에서 가장 밝은 별';

  @override
  String get xuanZeYanSe => '색 선택';

  @override
  String get seXiang => '색조';

  @override
  String get baoHeDu => '채도';

  @override
  String get mingDu => '명도';

  @override
  String get buTouMingDu => '불투명도';

  @override
  String get queDing => '확인';

  @override
  String get zanWuBoFangYinYue => '재생 중인 음악이 없습니다';

  @override
  String get buXiHuanBingTiaoGuo => '관심 없음, 건너뛰기';

  @override
  String get kaiQiZhuoMianGeCi => '바탕 화면 가사 켜기';

  @override
  String get geCiXianShi => '가사 표시';

  @override
  String get dangQianGeYouYiWenYinYiShiCaiHuiXianShiFuXing =>
      '번역이나 발음 표기가 있을 때만 보조 줄이 나타납니다';

  @override
  String get xianShiFanYi => '번역 표시';

  @override
  String get geCiXiaFangXianShiZhongWenYiWen => '가사 아래에 중국어 번역 표시';

  @override
  String get xianShiLuoMaYin => '발음 표기 표시';

  @override
  String get riWenDengYinYiXianShiZaiFuXing => '일본어 등의 발음 표기를 보조 줄에 표시합니다';

  @override
  String get xuanFuGeCi => '플로팅 가사';

  @override
  String get xuanFuChuangXianShiZhuoMianGeCiKeTuoDongSuoDing =>
      '플로팅 창에 바탕 화면 가사를 표시합니다. 드래그와 잠금 지원';

  @override
  String get geCiZiHao => '가사 글자 크기';

  @override
  String get geCiHangJianJu => '가사 줄 간격';

  @override
  String get geCiPianYi => '가사 오프셋';

  @override
  String get geCiPianYiDangQianGeQu => '가사 오프셋(이 곡)';

  @override
  String get zhiWeiTiaoZheYiShouZhengShuGeCiTiQianFuShuGeCiYa =>
      '이 곡만 미세 조정합니다. 양수 = 가사 앞당김, 음수 = 늦춤';

  @override
  String get chongZhiBenQuWeiTiao => '이 곡 미세 조정 초기화';

  @override
  String get geCiJiaZaiZhong => '가사를 불러오는 중…';

  @override
  String get zanWuGeCi => '가사가 없습니다';

  @override
  String get huiDaoZhengZaiBoFangDeNaYiXing => '재생 중인 줄로 돌아가기';

  @override
  String get huiDaoDangQianXing => '현재 줄로 돌아가기';

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
  String get neiBuDianYuanShengYu => '내부 전원 잔량';

  @override
  String get diYiShou => '첫 번째 곡';

  @override
  String get yinZhiXuanZe => '음질 선택';

  @override
  String get zhengZaiQieHuanYinZhi => '음질 전환 중…';

  @override
  String get huiSeDangWeiDangQianGeQuBuKeYong => '회색 등급은 이 곡에서 사용할 수 없습니다';

  @override
  String get weiZhiDangWeiJiangZiDongXiangXiaJianRong =>
      '알 수 없는 등급은 자동으로 아래 등급으로 대체됩니다';

  @override
  String get dangQianBoFangMvYinPinGeCiKeNengBuTongBu =>
      'MV 오디오 재생 중 · 가사가 어긋날 수 있습니다';

  @override
  String get buKeYong => '사용 불가';

  @override
  String get duiLieWeiKong => '대기열이 비어 있습니다';

  @override
  String get n15FenZhong => '15분';

  @override
  String get n30FenZhong => '30분';

  @override
  String get n60FenZhong => '60분';

  @override
  String get ziDingYi45FenZhong => '사용자 지정 45분';

  @override
  String get banBen => '버전';

  @override
  String get xingTai => '형태';

  @override
  String get dingWei => '포지셔닝';

  @override
  String get duoYinYuanDiSanFangKeHuDuan => '멀티 소스 서드파티 클라이언트';

  @override
  String get qingZunShouDangDiFaLvYuMuBiaoPingTaiFuWuTiaoKuan =>
      '현지 법률과 대상 플랫폼의 이용 약관을 지키세요. 공개 시 「KuGou」 상표를 앱 이름으로 쓰지 마세요.';

  @override
  String get tiYanTanSuoXingSheJiFengGeYuPaiBanXiTong =>
      '실험적인 디자인 언어와 타이포그래피를 시험합니다';

  @override
  String get dangQianShiYong => '사용 중';

  @override
  String get boFangBeiSu => '재생 배속';

  @override
  String get beiSuBuBaoLiuYinDiaoJinDuGeCiYuShengYuShiJianSui =>
      '음정은 유지되지 않습니다. 진행, 가사, 남은 시간이 배속에 맞춰 함께 변합니다';

  @override
  String get yuYan => '언어';

  @override
  String get jieMianYuYan => '인터페이스 언어';

  @override
  String get zaiXianYinLe => '온라인 음악';

  @override
  String get woDeYinLe => '내 음악';

  @override
  String get tongYong => '일반';

  @override
  String get xiTongSheZhi => '시스템 설정';

  @override
  String get gaiNianBan => '컨셉트 에디션';

  @override
  String get zhanKaiCeLan => '사이드바 펼치기';

  @override
  String get zheDieCeLan => '사이드바 접기';

  @override
  String qianMingBeiJuJianChaWRidMixinkeyShiFouGuoQi(Object p1) {
    return '$p1(서명 거부: w_rid / mixinKey 만료 여부 확인)';
  }

  @override
  String chuFaFengKongTuiBiChongShiHuoGengHuanWangLuo(Object p1) {
    return '$p1(요청 제한 발생: 잠시 후 재시도하거나 네트워크 변경)';
  }

  @override
  String bZhanFengKongJiaoYanShiBaiQingShaoHouChongSh(Object p1) {
    return '$p1(Bilibili 위험 검증 실패. 잠시 후 재시도하거나 로그인하세요)';
  }

  @override
  String xiangYingBuShiJsonDuiXiang(Object p1) {
    return '$p1: 응답이 JSON 객체가 아닙니다';
  }

  @override
  String xiangYingQueShaoCodeZiDuan(Object p1) {
    return '$p1: 응답에 code 필드가 없습니다';
  }

  @override
  String dataBuShiJsonDuiXiang(Object p1) {
    return '$p1: data 가 JSON 객체가 아닙니다';
  }

  @override
  String dataBuShiJsonShuZu(Object p1) {
    return '$p1: data 가 JSON 배열이 아닙니다';
  }

  @override
  String wan(Object p1) {
    return '$p1만';
  }

  @override
  String yunPanXinXiShangChuanShiBai(Object p1, Object p2) {
    return '클라우드 정보 업로드 실패($p1): $p2';
  }

  @override
  String saoMaHuiHuaChuangJianShiBaiCode(Object p1, Object p2) {
    return 'QR 세션 생성 실패 code=$p1 $p2';
  }

  @override
  String boFangDiZhiCode(Object p1) {
    return '재생 URL code=$p1';
  }

  @override
  String mvQuLiuCode(Object p1) {
    return 'MV 스트림 code=$p1';
  }

  @override
  String mvQuLiuDataCode(Object p1) {
    return 'MV 스트림 data.code=$p1';
  }

  @override
  String geCiCode(Object p1) {
    return '가사 code=$p1';
  }

  @override
  String yunPanQuLiuCode(Object p1) {
    return '클라우드 스트림 code=$p1';
  }

  @override
  String yunPanGeCiCode(Object p1) {
    return '클라우드 가사 code=$p1';
  }

  @override
  String shiBaiCode(Object p1, Object p2) {
    return '$p1 실패(code=$p2)';
  }

  @override
  String fuWuQiZanShiBuKeYongHttpQingShaoHouChongShi(Object p1) {
    return '서버를 일시적으로 사용할 수 없습니다(HTTP $p1). 잠시 후 다시 시도하세요';
  }

  @override
  String get dangQianWangLuoBeiWangGuanLanJieUrlGuoLvWuFa =>
      '네트워크가 음원을 차단하고 있습니다(게이트웨이 URL 필터링).\n모바일 핫스팟으로 전환하거나 공유기의 웹 필터를 끈 후 다시 시도하세요.';

  @override
  String yiJieDuanYuanChangDuZiFu(Object p1, Object p2) {
    return '$p1\n…(잘림, 원래 길이 $p2자)';
  }

  @override
  String appInfoDuQuBanBenShiBai(Object p1) {
    return '[app_info] 버전 읽기 실패: $p1';
  }

  @override
  String tiaoZuiJin(Object p1, Object p2) {
    return '$p1건 · 최근 $p2';
  }

  @override
  String fanYinQiDongShiBaiQingJianChaXiTongQuanXianH(Object p1) {
    return '泛音 시작 실패($p1). 시스템 권한과 실행 환경을 확인하세요.';
  }

  @override
  String chuShiHuaShiBaiHuoChaoShiYingYongYiXiangJiYu(Object p1) {
    return '$p1 초기화 실패 또는 시간 초과. 앱이 제한 모드로 동작합니다.';
  }

  @override
  String yueRi(Object p1, Object p2) {
    return '$p1월 $p2일';
  }

  @override
  String yue(Object p1) {
    return '$p1월';
  }

  @override
  String yiShanChuShouShouQueShaoWenJianBiaoZhiBeiTia(Object p1, Object p2) {
    return '$p1곡 삭제, $p2곡은 파일 식별자가 없어 건너뜀';
  }

  @override
  String danMuZuiDuoZiQingJingJianHouZaiFa(Object p1) {
    return '탄막은 최대 $p1자입니다. 줄여 주세요';
  }

  @override
  String pingLunZuiDuoZiQingJingJianHouZaiFa(Object p1) {
    return '댓글은 최대 $p1자입니다. 줄여 주세요';
  }

  @override
  String pingLunJiaZaiShiBaiStatusErr(Object p1, Object p2) {
    return '댓글 불러오기 실패(status=$p1 err=$p2)';
  }

  @override
  String xiangYingWuFaJieXi(Object p1) {
    return '$p1 응답을 해석할 수 없습니다';
  }

  @override
  String yiChangQingShaoHouChongShi(Object p1) {
    return '$p1 오류입니다. 잠시 후 다시 시도하세요';
  }

  @override
  String xuYaoDengLuHuoAnQuanJiaoYan(Object p1) {
    return '$p1에는 로그인 또는 보안 확인이 필요합니다';
  }

  @override
  String fanHuiShiBaiStatusErr(Object p1, Object p2, Object p3) {
    return '$p1 반환 실패(status=$p2 err=$p3)';
  }

  @override
  String meiRiTuiJianJiaZaiShiBaiStatusErr(Object p1, Object p2) {
    return '데일리 추천 불러오기 실패(status=$p1 err=$p2)';
  }

  @override
  String bZhanWuFenP(Object p1) {
    return 'Bilibili: $p1 에 파트가 없습니다';
  }

  @override
  String caoZuoShiBaiCode(Object p1) {
    return '작업 실패(code=$p1)';
  }

  @override
  String zhuanJiJiaZaiShiBaiYinYuanBuKeYong(Object p1) {
    return '앨범 불러오기 실패: $p1 음원 사용 불가';
  }

  @override
  String zhuanJiJiaZaiShiBai(Object p1) {
    return '앨범 불러오기 실패: $p1';
  }

  @override
  String zhuanJiDangAn(Object p1) {
    return '앨범 아카이브 · $p1';
  }

  @override
  String geShiPin(Object p1, Object p2) {
    return '동영상 $p1개 · $p2';
  }

  @override
  String get dengLuPingJuJinCunBenJiTuiChuDengLuJiQingChu =>
      '로그인 정보는 이 기기에만 저장되며 로그아웃 시 지워집니다. 게스트도 검색과 재생이 가능하고, 로그인하면 저장 폴더를 읽을 수 있습니다. Bilibili 는 클라우드 하트를 제공하지 않아 하트는 기기에만 저장됩니다.';

  @override
  String get shuoMingDengLuJinZouWangYiYunZhenShiWangGuan =>
      '안내: 로그인은 NetEase 실제 게이트웨이만 사용하며, 실패해도 가짜 계정을 만들지 않습니다.\n로그인 상태(MUSIC_U)는 이 기기에만 저장되고 로그아웃 시 지워집니다.';

  @override
  String shangChuanWanChengShouQiZhongShouMiaoChuan(Object p1, Object p2) {
    return '업로드 완료: $p1곡(그중 $p2곡 즉시 전송)';
  }

  @override
  String shangChuanWanChengShou(Object p1) {
    return '업로드 완료: $p1곡';
  }

  @override
  String shangChuanWanChengChengGongShouShiBaiShou(Object p1, Object p2) {
    return '업로드 완료: 성공 $p1곡, 실패 $p2곡';
  }

  @override
  String queRenShanChuCiCaoZuoWuFaCheXiao(Object p1) {
    return '“$p1”을(를) 삭제할까요? 되돌릴 수 없습니다.';
  }

  @override
  String shanChuShiBai(Object p1) {
    return '삭제 실패: $p1';
  }

  @override
  String yiYong(Object p1, Object p2) {
    return '$p1 / $p2 사용';
  }

  @override
  String shangChuanZhong(Object p1, Object p2, Object p3) {
    return '업로드 중 $p1 / $p2 · $p3';
  }

  @override
  String zhaoDaoShouGongShou(Object p1, Object p2) {
    return '총 $p2곡 중 $p1곡';
  }

  @override
  String gongShou(Object p1, Object p2) {
    return '총 $p1곡$p2';
  }

  @override
  String yunPanShiZhangHaoDeSiYouWenJianKu(Object p1) {
    return '클라우드는 $p1 계정의 개인 파일 보관함입니다';
  }

  @override
  String dengLuZhangHao(Object p1) {
    return '$p1 로그인';
  }

  @override
  String get wuFaDaKaiWenJianXuanZeQiLinuxQingAnZhuangZen =>
      '파일 선택기를 열 수 없습니다. Linux 에서는 zenity, kdialog 또는 qarma 를 설치하고 데스크톱 세션이 파일 대화상자에 접근할 수 있는지 확인하세요.';

  @override
  String buShiZhiChiDeYinPinWenJian(Object p1) {
    return '$p1: 지원하지 않는 오디오 파일';
  }

  @override
  String duQuShiBai(Object p1) {
    return '$p1: 읽기 실패';
  }

  @override
  String chaoGuo100mbXianZhi(Object p1) {
    return '$p1: 100MB 제한 초과';
  }

  @override
  String shiShiTanCeRoundIntervalS(Object p1, Object p2) {
    return '== 실시간 측정 round=$p1 interval=${p2}s ==';
  }

  @override
  String fanYinWangLuoRiZhi(Object p1) {
    return '== 泛音 네트워크 로그 ==\n\n$p1';
  }

  @override
  String yiFuZhiQuanBuRiZhiTiao(Object p1) {
    return '모든 로그를 복사했습니다($p1건)';
  }

  @override
  String haoShiMs(Object p1) {
    return '소요: ${p1}ms';
  }

  @override
  String zanBuZhiChiKeQieHuanQiTaYinYuanChaKan(Object p1, Object p2) {
    return '$p1은(는) “$p2”을(를) 지원하지 않습니다. 다른 음원으로 전환해 확인하세요';
  }

  @override
  String shou_2(Object p1) {
    return '$p1곡';
  }

  @override
  String meiRiFaXian(Object p1) {
    return '데일리 발견 · $p1';
  }

  @override
  String yiQieDaoXiaYiShouShengXiao(Object p1, Object p2) {
    return '$p1 · $p2 로 전환했습니다. 다음 곡부터 적용됩니다';
  }

  @override
  String dianJiKaiShiDianTaiJiKeShouLiu(Object p1, Object p2, Object p3) {
    return '$p1 · $p2 · $p3. “라디오 시작”을 누르면 재생이 시작됩니다';
  }

  @override
  String dianJiKaiShiDianTaiJiKeShouTing(Object p1) {
    return '$p1. “라디오 시작”을 누르면 청취할 수 있습니다';
  }

  @override
  String shouDaiBo(Object p1) {
    return '$p1곡 대기 중';
  }

  @override
  String xiangSiDu(Object p1) {
    return '유사도 $p1';
  }

  @override
  String laiYuanSiRenFm(Object p1, Object p2, Object p3) {
    return '출처: $p1 개인 FM · $p2$p3';
  }

  @override
  String laiYuanSiRenFm_2(Object p1) {
    return '출처: $p1 개인 FM';
  }

  @override
  String laiYuanGuanJianCiJianSuo(Object p1) {
    return '출처: 키워드 검색 · $p1';
  }

  @override
  String laiYuanGuanJianCiJianSuoFeiGeXingHua(Object p1) {
    return '출처: 키워드 검색($p1, 비개인화)';
  }

  @override
  String gongShou_2(Object p1) {
    return '총 $p1곡';
  }

  @override
  String fenZhong(Object p1) {
    return '$p1분';
  }

  @override
  String xiaoShi(Object p1) {
    return '$p1시간';
  }

  @override
  String ci(Object p1) {
    return '$p1회';
  }

  @override
  String shou_3(Object p1, Object p2) {
    return '$p1곡 ($p2%)';
  }

  @override
  String geQu_2(Object p1) {
    return '$p1곡';
  }

  @override
  String zhuanJi_2(Object p1) {
    return '$p1 앨범';
  }

  @override
  String dengLuHouJiKeTongBuYunDuanWoXiHuan(Object p1) {
    return '$p1 에 로그인하면 클라우드 좋아요를 동기화할 수 있습니다';
  }

  @override
  String shou_4(Object p1, Object p2) {
    return '$p1곡 · $p2';
  }

  @override
  String zhaoDaoWeiGongWei(Object p1, Object p2) {
    return '총 $p2명 중 $p1명';
  }

  @override
  String gongWeiGuanZhuGeShou(Object p1) {
    return '팔로우 아티스트 $p1명';
  }

  @override
  String shouDanQu(Object p1, Object p2) {
    return '$p1 · $p2곡';
  }

  @override
  String zhaoDaoZhangGongZhang(Object p1, Object p2) {
    return '총 $p2장 중 $p1장';
  }

  @override
  String gongZhangShouCangZhuanJi(Object p1) {
    return '저장한 앨범 $p1장';
  }

  @override
  String ruanJieChongKaiShiBai(Object p1) {
    return '소프트웨어 디코드 재시작 실패: $p1';
  }

  @override
  String boFangQiCuoWu(Object p1) {
    return '플레이어 오류: $p1';
  }

  @override
  String ge(Object p1) {
    return '$p1개';
  }

  @override
  String fenMiao(Object p1, Object p2) {
    return '$p1분 $p2초';
  }

  @override
  String miao(Object p1) {
    return '$p1초';
  }

  @override
  String siRenFmDianTai(Object p1) {
    return '개인 FM 방송국: $p1';
  }

  @override
  String yinPinYuanWuFaJiaZai(Object p1) {
    return '오디오 소스를 불러올 수 없습니다: $p1';
  }

  @override
  String yinPinYuanWuFaQiBo(Object p1) {
    return '오디오 소스를 재생할 수 없습니다: $p1';
  }

  @override
  String yinPinYuanJiaZaiShiBai(Object p1) {
    return '오디오 소스 불러오기 실패: $p1';
  }

  @override
  String boFangQiDongShiBai(Object p1) {
    return '재생 시작 실패: $p1';
  }

  @override
  String boFangShiBai(Object p1) {
    return '재생 실패: $p1';
  }

  @override
  String boFangTingZhiYiChongShiCiRengWeiHuiFu(Object p1) {
    return '재생 정지: $p1회 재시도에도 복구되지 않음';
  }

  @override
  String stallTingZhiYuMsDiCiZiYu(Object p1, Object p2, Object p3) {
    return '[stall] $p1 이 ${p2}ms 에서 정지, $p3번째 자동 복구';
  }

  @override
  String boFangXuYaoDengLu(Object p1) {
    return '$p1 재생에는 로그인이 필요합니다';
  }

  @override
  String jiaZaiShiBaiYinYuanBuKeYong(Object p1, Object p2) {
    return '$p1 불러오기 실패: $p2 음원 사용 불가';
  }

  @override
  String jiaZaiShiBaiJieKouBuKeYongHuoGaiIdWuGongKaiS(Object p1) {
    return '$p1 불러오기 실패: API 사용 불가 또는 이 ID 의 공개 데이터 없음';
  }

  @override
  String jiaZaiShiBai_2(Object p1) {
    return '$p1 불러오기 실패';
  }

  @override
  String shou_5(Object p1, Object p2) {
    return '$p1 / $p2곡';
  }

  @override
  String buFenZhangHaoXinXiHuoQuShiBai(Object p1) {
    return '일부 계정 정보를 가져오지 못했습니다: $p1';
  }

  @override
  String qingXianDengLuZhangHao(Object p1) {
    return '먼저 $p1 에 로그인하세요';
  }

  @override
  String zanBuZhiChiZhangHaoDengLu(Object p1) {
    return '$p1은(는) 아직 계정 로그인을 지원하지 않습니다';
  }

  @override
  String juLvHaiCha(Object p1, Object p2, Object p3) {
    return 'Lv.$p1 까지 $p2 $p3 남음';
  }

  @override
  String kaiShiDaoQi(Object p1, Object p2) {
    return '시작 $p1 · 만료 $p2';
  }

  @override
  String dengLuZhangHaoHouJiKeTongBuZiJianYuShouCangG(Object p1) {
    return '$p1 에 로그인하면 내 재생목록과 저장한 재생목록을 동기화할 수 있습니다';
  }

  @override
  String zanWuYunDuanGeDan(Object p1) {
    return '$p1 에 클라우드 재생목록이 없습니다';
  }

  @override
  String ziJian(Object p1) {
    return '내 재생목록 ($p1)';
  }

  @override
  String shou_6(Object p1, Object p2) {
    return '$p1곡$p2';
  }

  @override
  String tian(Object p1) {
    return '$p1일';
  }

  @override
  String nian(Object p1) {
    return '$p1년';
  }

  @override
  String geYue(Object p1) {
    return '$p1개월';
  }

  @override
  String nianHouDaoQi(Object p1) {
    return '$p1년 후 만료';
  }

  @override
  String geYueHouDaoQi(Object p1) {
    return '$p1개월 후 만료';
  }

  @override
  String tianHouDaoQi(Object p1) {
    return '$p1일 후 만료';
  }

  @override
  String xiaoShiHouDaoQi(Object p1) {
    return '$p1시간 후 만료';
  }

  @override
  String fenZhongHouDaoQi(Object p1) {
    return '$p1분 후 만료';
  }

  @override
  String tuiChuZhangHao(Object p1) {
    return '$p1 에서 로그아웃할까요?';
  }

  @override
  String tuiChuHouYunDuanDiGeDanWoXiHuanYuFuFeiBoFang(Object p1) {
    return '로그아웃하면 $p1 클라우드 재생목록, 좋아요, 유료 재생 권한을 사용할 수 없습니다. 기기 데이터에는 영향이 없습니다.';
  }

  @override
  String geDanDangAn(Object p1) {
    return '재생목록 아카이브 · $p1';
  }

  @override
  String shouGeXingHuaTuiJian(Object p1) {
    return '$p1곡 · 맞춤 추천';
  }

  @override
  String meiYouZhaoDaoXiangGuan(Object p1) {
    return '관련 $p1 을(를) 찾지 못했습니다';
  }

  @override
  String get duLiXuanFuChuangXianShiDangQianGeCiShiYanGon =>
      '독립 플로팅 창에 현재 가사를 표시합니다. 실험 기능: 켜면 기본 창이 응답하지 않을 수 있고 자동 시작도 하지 않습니다. 신중하게 켜세요(문제 해결: 데스크톱 가사 연동 문서 §12).';

  @override
  String sQuanJuAnGeQuDeWeiTiaoHuiZaiDieJia(Object p1, Object p2) {
    return '$p1${p2}s(전체. 곡별 미세 조정이 추가로 더해집니다)';
  }

  @override
  String xinGeMoRenAnCiJieXiBoFangZhongKeQieHuan(Object p1) {
    return '$p1 · 새 곡은 기본적으로 이 음질로 처리되며 재생 중에도 전환할 수 있습니다';
  }

  @override
  String souSuoYuWoXiHuanDeChuShiYinYuan(Object p1) {
    return '$p1 · 검색과 좋아요의 초기 음원';
  }

  @override
  String xueXiYanJiuXiangDiSanFangKeHuDuanBuTiGongYin(Object p1) {
    return '$p1 · 학습·연구용 서드파티 클라이언트\n오디오 중계나 계정 보관은 제공하지 않습니다';
  }

  @override
  String qiYongYinYuan(Object p1) {
    return '$p1 음원 사용';
  }

  @override
  String dengLuHouKeQiYong(Object p1) {
    return '$p1 로그인 후 사용할 수 있습니다';
  }

  @override
  String guanBiHouGaiYuanBuZaiChuXianZaiRuKou(Object p1) {
    return '끄면 이 음원이 “$p1” 에 나타나지 않습니다';
  }

  @override
  String yinYuanYiGuanBiCiXiangZanShiBuShengXiao(Object p1) {
    return '$p1 음원이 꺼져 있어 이 항목은 현재 적용되지 않습니다';
  }

  @override
  String kuangJiaYuanShengWeiBuHuoCuoWu(Object p1) {
    return '프레임워크 / 네이티브 / 미처리 오류 · $p1';
  }

  @override
  String faSongShiBai(Object p1) {
    return '전송 실패: $p1';
  }

  @override
  String tiao(Object p1) {
    return '$p1건';
  }

  @override
  String danQuDangAn(Object p1) {
    return '곡 아카이브 · $p1';
  }

  @override
  String tiao_2(Object p1) {
    return '$p1건';
  }

  @override
  String fanYin_2(Object p1, Object p2) {
    return '泛音 · $p1 · $p2';
  }

  @override
  String yinLiang(Object p1) {
    return '볼륨 $p1%';
  }

  @override
  String tiaoHuiFu(Object p1) {
    return '답글 $p1개';
  }

  @override
  String yinYuanYiTingYong(Object p1) {
    return '$p1 음원이 사용 중지되었습니다';
  }

  @override
  String deYiGuanBi(Object p1, Object p2) {
    return '$p1 의 “$p2” 가 꺼져 있습니다';
  }

  @override
  String benYeNeiRongYiLaiYiTingYongQiJianBuZaiQingQi(Object p1) {
    return '이 페이지 내용은 $p1에 의존합니다. 중지 중에는 해당 음원에 요청을 보내지 않으며, 이미 대기열에 있는 곡에는 영향이 없습니다.';
  }

  @override
  String yinYuanRengQiYongZhiShiZheYiXiangGongNengBei(Object p1) {
    return '$p1 음원은 계속 켜져 있고 이 기능만 개별적으로 꺼져 있습니다. 켜면 이 페이지를 사용할 수 있습니다. 이미 대기열에 있는 곡에는 영향이 없습니다.';
  }

  @override
  String benQuWeiTiaoQuanJuHeJiShengXiao(Object p1, Object p2, Object p3) {
    return '이 곡 미세 조정 $p1  전체 $p2  합계 $p3';
  }

  @override
  String shi(Object p1, Object p2) {
    return '$p1십$p2';
  }

  @override
  String boFangDuiLieShou(Object p1) {
    return '재생 대기열 · $p1곡';
  }

  @override
  String get geRenXueXiYanJiuXiangXiangMuShuJuJingGongKai =>
      '개인 학습·연구용 프로젝트입니다. 데이터는 공개 API 에서 직접 가져오며, 오디오 중계나 클라우드 계정 보관은 제공하지 않습니다. 음악 저작권은 원 플랫폼과 권리자에게 있습니다.';

  @override
  String boFangLiang(Object p1) {
    return '재생 $p1';
  }

  @override
  String fenSi_2(Object p1) {
    return '팔로워 $p1';
  }

  @override
  String geShou_2(Object p1) {
    return '아티스트 ($p1)';
  }

  @override
  String huiFu_2(Object p1) {
    return '@$p1 에 답글';
  }

  @override
  String laiYuan_3(Object p1) {
    return '출처: $p1';
  }

  @override
  String paiXuFangShi_2(Object p1, Object p2) {
    return '$p1 기준 정렬($p2)';
  }

  @override
  String qiTaBanBen_2(Object p1) {
    return '다른 버전 $p1';
  }

  @override
  String shouCang_2(Object p1) {
    return '저장 ($p1)';
  }

  @override
  String siRenFm_2(Object p1) {
    return '$p1 개인 FM';
  }

  @override
  String wangLuoCuoWu_2(Object p1) {
    return '$p1 네트워크 오류';
  }

  @override
  String yi_2(Object p1) {
    return '$p1억';
  }

  @override
  String yongHu_2(Object p1) {
    return '$p1 사용자';
  }

  @override
  String fanYinLabel(Object p1) {
    return '泛音 · $p1';
  }

  @override
  String get dianTaiJieShu => '「라디오 시작」을 누르면 청취할 수 있습니다';

  @override
  String juLiShengJi(Object p1, Object p2, Object p3) {
    return 'Lv.$p1 까지 $p2 $p3 남음';
  }

  @override
  String xiangYingWeiKong(Object p1) {
    return '$p1 응답이 비어 있습니다';
  }

  @override
  String geQu_3(Object p1) {
    return '$p1곡';
  }

  @override
  String zhuanJi_3(Object p1) {
    return '$p1 앨범';
  }

  @override
  String get quXiaoShouCang => '즐겨찾기 해제';

  @override
  String get biaoShengBang => '급상승';

  @override
  String get xinGeBang => '신곡';

  @override
  String get yuanChuangBang => '오리지널';

  @override
  String get reGeBang => '인기곡';

  @override
  String get wangYiYunShuoChangBang => 'NetEase 중국 랩';

  @override
  String get wangYiYunGuoFengBang => 'NetEase 궈펑';

  @override
  String get wangYiYunMinYaoBang => 'NetEase 포크';

  @override
  String get wangYiYunYaoGunBang => 'NetEase 록';

  @override
  String get wangYiYunDianYinBang => 'NetEase 일렉트로닉';

  @override
  String get wangYiYunGuDianBang => 'NetEase 클래식';

  @override
  String get wangYiYunAcgBang => 'NetEase ACG';

  @override
  String get wangYiYunOuMeiReGeBang => 'NetEase 서구권 인기';

  @override
  String get wangYiYunOuMeiXinGeBang => 'NetEase 서구권 신곡';

  @override
  String get ouMeiRnBBang => '서구권 R&B';

  @override
  String get wangYiYunRiYuBang => 'NetEase 일본어';

  @override
  String get wangYiYunHanYuBang => 'NetEase 한국어';

  @override
  String get meiGuoBillboardBang => '미국 빌보드';

  @override
  String get ukZhouBang => 'UK 주간';

  @override
  String get riBenOriconBang => '일본 오리콘';

  @override
  String get beatportQuanQiuBang => 'Beatport 글로벌 댄스';

  @override
  String get qiTa => '기타';

  @override
  String get wangYiGuanFangBang => 'NetEase 공식 차트';

  @override
  String get bangDanIdWuXiao => '차트 ID 가 유효하지 않습니다';

  @override
  String get geDanIdWuXiao => '재생목록 ID 가 유효하지 않습니다';

  @override
  String get yunPanShanChu => '클라우드 삭제';

  @override
  String get geDanJiaQu => '재생목록에 추가';

  @override
  String get geDanShanQu => '재생목록에서 삭제';

  @override
  String get fmXiHuan => 'FM 좋아요';

  @override
  String get quXiaoHongXin => '하트 해제';

  @override
  String get wangYiYunWeiDengLuWuFaDuQuGeDan =>
      'NetEase 에 로그인하지 않아 재생목록을 읽을 수 없습니다';

  @override
  String get wangYiYunWeiDengLuWuFaDuQuWoXiHuan =>
      'NetEase 에 로그인하지 않아 좋아요를 읽을 수 없습니다';

  @override
  String get geQuIdWuXiao => '곡 ID 가 유효하지 않습니다';

  @override
  String get saoMaHuiHuaGuoQiQingChongXinHuoQu => 'QR 세션이 만료되었습니다. 새 코드를 받으세요';

  @override
  String get xinSaoMaHuiHuaWeiQuDePingJu =>
      '새 QR 세션에서 유효한 정보를 얻지 못했습니다. 다시 스캔하세요';

  @override
  String get wangYiYunWeiDengLuWuFaDuQuZhangHaoDangAn =>
      'NetEase 에 로그인하지 않아 계정 정보를 읽을 수 없습니다';

  @override
  String get wangYiYunWeiDengLuWuFaDuQuHuiYuanXinXi =>
      'NetEase 에 로그인하지 않아 멤버십 정보를 읽을 수 없습니다';

  @override
  String get pingLunJiaZaiShiBai => '댓글을 불러오지 못했습니다';

  @override
  String get louCengJiaZaiShiBai => '스레드를 불러오지 못했습니다';

  @override
  String get pingLunChiWeiZhiWuFaJiaZaiLouCeng =>
      '댓글 풀을 알 수 없어 스레드를 불러올 수 없습니다';

  @override
  String get dengLuZhuangTaiYiShiXiaoQingChongXinDengLu =>
      '로그인 상태가 만료되었습니다. 다시 로그인하세요';

  @override
  String get caoZuoTaiPinFanQingShaoHouZaiShi => '작업이 너무 많습니다. 잠시 후 다시 시도하세요';

  @override
  String get meiYouQuanXianZhiXingGaiCaoZuo => '이 작업을 수행할 권한이 없습니다';

  @override
  String get geQuIdWeiZhiWuFaFaBiaoPingLun => '곡 ID 를 알 수 없어 댓글을 작성할 수 없습니다';

  @override
  String get geQuIdWeiZhiWuFaHuiFu => '곡 ID 를 알 수 없어 답글을 달 수 없습니다';

  @override
  String get wuXiaoDeMvLaiYuanBiaoShi => 'MV 소스 식별자가 유효하지 않습니다';

  @override
  String get zanWuPingLun => '아직 댓글이 없습니다';

  @override
  String get shuoDianShenMe => '무언가 적어 보세요…';

  @override
  String get youKe => '게스트';

  @override
  String get xuDengLu => '로그인 필요';

  @override
  String get yunDuanSiYouWenJianKu => '클라우드 개인 파일 보관함';

  @override
  String get zanWuZiJianGeDan => '내 재생목록이 없습니다';

  @override
  String get mvShouCangXinXiBuKeYong => '저장할 MV 가 없습니다';

  @override
  String get yiShouCang => '저장됨';

  @override
  String get shiPinJiaZaiShiBai => '동영상을 불러오지 못했습니다';

  @override
  String get zhengChang => '보통';

  @override
  String get quXiaoJingYin => '음소거 해제';

  @override
  String get tuiChuQuanPing => '전체 화면 종료';

  @override
  String get kuaiJin => '앞으로';

  @override
  String get kuaiTui => '뒤로';

  @override
  String get xianShiXuanFuGeCi => '플로팅 가사 표시';

  @override
  String get huiDaoPingMuDingBuJuZhongSimple => '화면 상단 중앙으로 복귀';

  @override
  String get guanBiHouSouSuoYuGongNengYeBuZaiShiYongGaiYuan =>
      '끄면 검색과 기능 페이지에서 이 음원을 사용하지 않습니다';

  @override
  String yiDengLuWithName(Object p1) {
    return '로그인됨: $p1';
  }

  @override
  String get pingLunChiWeiZhiWuFaAnZuiRePaiXu =>
      '댓글 풀을 알 수 없어 인기순 정렬을 할 수 없습니다';

  @override
  String get pingLunChiWeiZhiWuFaJiaZaiDanMu => '댓글 풀을 알 수 없어 탄막을 불러올 수 없습니다';

  @override
  String get wuFaJieXiGaiMvDeDanMuChi => '이 MV 의 탄막 풀을 해석할 수 없습니다';

  @override
  String pingLunCanShuBuWanZheng(Object p1) {
    return '댓글 파라미터가 불완전합니다($p1)';
  }

  @override
  String whatFaSongShiBai(Object p1, Object p2, Object p3) {
    return '$p1 전송 실패(status=$p2 err=$p3)';
  }

  @override
  String get jinRiZanWuFengGeTuiJian => '오늘은 스타일 추천이 없습니다';

  @override
  String get meiRiTuiJianXiangYingWeiKong => '데일리 추천 응답이 비어 있습니다';

  @override
  String get jinRiZanWuGeXingHuaTuiJian => '오늘은 맞춤 추천이 없습니다';

  @override
  String get siRenFmXiangYingWuFaJieXi => '개인 FM 응답을 해석할 수 없습니다';

  @override
  String get siRenFmZanWuTuiJian => '개인 FM 에 추천이 없습니다';

  @override
  String get siRenFmJiaZaiShiBaiShort => '개인 FM 불러오기 실패';

  @override
  String get wangLuoYiChangShort => '네트워크 오류';

  @override
  String get erWeiMaJiaZaiShiBai => 'QR 코드를 불러오지 못했습니다';

  @override
  String get zhengZaiJiaZaiGengDuoGeQu => '곡을 더 불러오는 중…';

  @override
  String get guanBiSouSuo => '검색 닫기';

  @override
  String get zhengZaiXuJieGeChi => '곡 풀을 채우는 중…';

  @override
  String get geChiZhengZaiXuJianDian => '곡 풀을 채우는 중…';

  @override
  String get shangChuanShiBaiQingShaoHouChongShi =>
      '업로드에 실패했습니다. 잠시 후 다시 시도하세요';

  @override
  String get qingShaoHouChongShi => '잠시 후 다시 시도하세요';

  @override
  String get zhengZaiBuQuan => '(보완 중…)';

  @override
  String get jieKouJuJueFangWenAccessDeny => 'API 가 접근을 거부했습니다(Access Deny)';

  @override
  String meiYouBoFangQuanXianFee(Object p1) {
    return '재생 권한이 없습니다(fee=$p1)';
  }

  @override
  String get quMuBuCunZai => '곡이 존재하지 않습니다';

  @override
  String wuBoFangDiZhiCode(Object p1) {
    return '재생 URL 이 없습니다(code=$p1)';
  }

  @override
  String get sheBeiZhuCeShiBai => '기기 등록 실패';

  @override
  String fanHuiShiBaiPlain(Object p1) {
    return '$p1 반환 실패';
  }

  @override
  String bZhanFanHuiCode(Object p1) {
    return 'Bilibili 가 code=$p1 를 반환했습니다';
  }

  @override
  String get weiZhiShort => '알 수 없음';

  @override
  String yiShuRenJiShou(Object p1, Object p2) {
    return '$p1 · $p2곡';
  }

  @override
  String geShouShuCompact(Object p1) {
    return '$p1곡';
  }

  @override
  String get gaiWeiShengXu => '오름차순으로 변경';

  @override
  String get jiangXu => '내림차순';

  @override
  String get shengXu => '오름차순';

  @override
  String get wangLuoBuKeDaHuoBeiWangGuanLanJie =>
      '네트워크에 연결할 수 없거나 게이트웨이에서 차단되었습니다. 네트워크를 확인한 후 다시 시도하세요';

  @override
  String get danMuYiKaiQiSheZhiYuFaSong => '탄막 켜짐 · 설정 및 보내기';

  @override
  String get xianShiZhong => '표시 중';

  @override
  String get buZu1FenZhong => '1분 미만';

  @override
  String get buZu1Tian => '1일 미만';

  @override
  String get zhangHaoXinXiHuoQuShiBaiQingShaoHou =>
      '계정 정보를 가져오지 못했습니다. 잠시 후 다시 시도하세요';

  @override
  String get fengGeGeDan => '스타일 재생목록';

  @override
  String get zanWuFengGeTuiJian => '스타일 추천이 없습니다';

  @override
  String get wangYiYunYongHu => 'NetEase 사용자';

  @override
  String get faBiaoPingLun => '댓글 작성';

  @override
  String get guanBiKaiGuan => '끔';

  @override
  String get touMing => '투명';

  @override
  String get huiFuYinLiang => '볼륨 복원';

  @override
  String get guanBiZhuoMianGeCi => '바탕 화면 가사 끄기';

  @override
  String get quXiaoXiHuanShort => '좋아요 취소';

  @override
  String beiSuWithLabel(Object p1) {
    return '배속 · $p1';
  }

  @override
  String get wuFaDaKaiShiPinDiZhi => '동영상 주소를 열 수 없습니다';

  @override
  String get danMuJiaZaiShiBaiQingGuanBiHouChongKai =>
      '탄막을 불러오지 못했습니다. 닫았다가 다시 열어 주세요';

  @override
  String get huanYuan => '복원';
}
