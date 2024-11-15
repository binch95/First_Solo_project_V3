<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:set var="pageTitle" value="DETAIL"></c:set>
<%@ include file="../common/head.jspf" %>
<%@ include file="../common/toastUiEditorLib.jspf" %>
<hr/>

<!-- 변수 -->
<script>
    const params = {};
    params.id = parseInt('${param.id}');
    params.memberId = parseInt('${loginedMemberId}')


    var isAlreadyAddGoodRp = ${isAlreadyAddGoodRp};
</script>

<!-- 조회수 -->
<script>
    function ArticleDetail__doIncreaseHitCount() {
        const localStorageKey = 'article__' + params.id + '__alreadyOnView';

        if (localStorage.getItem(localStorageKey)) {
            return;
        }

        localStorage.setItem(localStorageKey, true);

        $.get('../article/doIncreaseHitCountRd', {
            id: params.id,
            ajaxMode: 'Y'
        }, function (data) {
            $('.article-detail__hit-count').empty().html(data.data1);
        }, 'json')
    }

    $(function () {
        // 		ArticleDetail__doIncreaseHitCount();
        setTimeout(ArticleDetail__doIncreaseHitCount, 2000);
    })
</script>

<script>
    <!-- 좋아요 버튼 -->

    $(function () {
        userCanReaction = ${userCanMakeReaction	};
        $('.like-button').click(function () {
            if (userCanReaction == -2) {
                alert("이용할수 없습니다 로그인 해주세요");
                location.href = '../member/login';
                return false;
            }

            params.comid = $(this).attr('id');
            params.updown = 1;
            params.type = $(this).attr('name');
            console.log(params.comid);
            $('.doNotlike-button').removeClass('clickOn');
            $.get('../article/doInOutLikeCountRd', {
                id: params.id,
                upAnddown: 1,
                comid: params.comid,
                relTypeCode: params.type,
                ajaxMode: 'Y'
            }, function (data) {

                if ($('.like-button' + params.type).hasClass('clickOn')) {
                    $('.like-button' + params.type).removeClass('clickOn');
                }
                if (!data.fail) {
                    $('.like-button' + params.type).addClass('clickOn');
                }
                const selector = params.type == 'article' ? `.goodReactionPoint` + params.type : `.goodReactionPointcomment` + params.comid;
                $(selector).empty().html(data.data1);
            }, 'json');
        });
    });
</script>
<script>
    // 종료 시간 값 (서버에서 전달받은 값을 JS로 파싱)
    const endTime = new Date('${article.remaining_time.replace(" ", "T")}'); // 문자열을 JavaScript의 Date 객체로 변환

    // 남은 시간을 계산하는 함수
    function updateRemainingTime() {
        const now = new Date(); // 현재 시간
        const diff = endTime - now; // 남은 시간 (밀리초)

        if (diff <= 0) {
            document.getElementById('remainingTime').innerText = "마감되었습니다.";
            clearInterval(timer); // 타이머 종료
            return;
        }

        // 남은 시간을 일, 시, 분, 초로 계산
        const days = Math.floor(diff / (1000 * 60 * 60 * 24));
        const hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
        const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
        const seconds = Math.floor((diff % (1000 * 60)) / 1000);

        // 화면에 업데이트
        document.getElementById('remainingTime').innerText =
            `남은 시간 : ` + days + `일` + hours + `시간`  + minutes + `분` + seconds + `초`;
    }

    // 1초마다 업데이트
    const timer = setInterval(updateRemainingTime, 1000);

    // 페이지 로드 시 바로 한 번 실행
    updateRemainingTime();
</script>

<section class="container">

    <button class="btn btn-outline" onclick="history.back()">🔙 뒤로가기</button>

    <div class="main-info flex border p-4 rounded-lg shadow-md">
        <!-- 왼쪽: 메인 이미지 -->
        <div class="main-image w-1/5 max-w-xs max-h-64">
            <img src="${rq.getImgUri(article.boardId, article.id)}-1.png"
                 alt="상품 이미지"
                 class="w-full h-full object-contain rounded-lg">
        </div>

        <!-- 오른쪽: 제목 및 주요 정보 -->
        <div class="details w-2/3 pl-6">
            <!-- 상품 번호 -->
            <p class="text-gray-600 mb-4">상품 번호: ${article.id}</p>

            <!-- 상품 제목 -->
            <h1 class="text-3xl font-bold mb-2">${article.title}</h1>

            <!-- 현재가 및 즉시구매가 -->
            <div class="mb-4">
                <p class="text-xl">현재가: <span class="font-semibold text-gray-700">${article.bid}</span></p>
                <p class="text-2xl font-bold text-red-600">즉시구매가: ₩${article.price}</p>
            </div>

            <!-- 기타 정보 -->
            <div class="text-gray-700 mb-4">
                <p>입찰수: ${article.bidder_count}회</p>
                <p id="remainingTime"></p>
                <p>(종료: ${article.remaining_time})</p>
            </div>

            <!-- 버튼 섹션 -->
            <div class="flex space-x-4 mt-6">
                <button class="bg-orange-500 text-white py-2 px-4 rounded-md hover:bg-orange-600">입찰하기</button>
                <button class="bg-red-500 text-white py-2 px-4 rounded-md hover:bg-red-600">구매하기</button>
                <button class="bg-gray-300 text-black py-2 px-4 rounded-md hover:bg-gray-400">관심상품등록</button>
            </div>
        </div>
    </div>


    <!-- 세부 정보 섹션 -->
    <div class="additional-info mt-8">
        <table class="table-auto border-collapse w-full text-left">
            <thead>
            <tr class="bg-gray-200">
                <th class="px-4 py-2">항목</th>
                <th class="px-4 py-2">내용</th>
            </tr>
            </thead>
            <tbody>
            <tr>
                <td class="border px-4 py-2">ID</td>
                <td class="border px-4 py-2">${article.id}</td>
            </tr>
            <tr>
                <td class="border px-4 py-2">게시판 ID</td>
                <td class="border px-4 py-2">${article.boardId}</td>
            </tr>
            <tr>
                <td class="border px-4 py-2">마지막 수정일</td>
                <td class="border px-4 py-2">${article.updateDate}</td>
            </tr>
            <tr>
                <td class="border px-4 py-2">본문</td>
                <td>
                    <div class="toast-ui-viewer">
                        <script type="text/html">${article.body}</script>
                    </div>
                </td>
            </tr>
            </tbody>
        </table>
    </div>


    <%@ include file="../common/foot.jspf" %>
