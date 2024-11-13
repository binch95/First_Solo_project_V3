<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:set var="pageTitle" value="WRITE"></c:set>
<%@ include file="../common/head.jspf" %>
<%@ include file="../common/toastUiEditorLib.jspf" %>
<hr/>

<script>
    function ArticleWrite__submit(form) {
        form.title.value = form.title.value.trim();

        if (form.title.value.length === 0) {
            alert('제목을 입력해 주세요.');
            return;
        }

        // 에디터 객체 가져오기
        const editor = toastui.Editor.factory({
            el: document.querySelector('#editor')
        });

        const markdown = editor.getMarkdown().trim();

        if (markdown.length === 0) {
            alert('내용을 입력해 주세요.');
            return;
        }

        // 폼의 body 필드에 에디터 내용을 저장
        form.body.value = markdown;

        // 이미지 URL들을 hidden 필드에 추가
        const imageUrls = [];
        document.querySelectorAll('.editor-image-url').forEach(function(img) {
            imageUrls.push(img.src);  // 업로드된 이미지 URL을 배열에 저장
        });

        // 이미지 URL들을 hidden input 필드에 저장
        form.imageUrls.value = imageUrls.join(',');  // 쉼표로 구분하여 전송

        // 서버로 폼 전송
        form.submit();
    }
</script>
<style>
    .toastui-editor-popup.toastui-editor-popup-add-image {
        display: none !important;  /* 기본 팝업 숨기기 */
    }
</style>

<section class="mt-24 text-xl px-4">
    <div class="mx-auto">
        <form onsubmit="ArticleWrite__submit(this); return false;" action="../article/doWrite" method="POST">
            <input type="hidden" name="body"/>
            <input type="hidden" name="imageUrls"/> <!-- 이미지 URL들을 전송할 hidden 필드 추가 -->

            <table class="table" border="1" cellspacing="0" cellpadding="5" style="width: 100%; border-collapse: collapse;">
                <tbody>
                <tr>
                    <th>게시판</th>
                    <td style="text-align: center;">
                        <select name="boardId">
                            <option value="" selected disabled>카테고리를 선택해주세요.</option>
                            <option value="1">전자제품</option>
                            <option value="2">패션 및 악세서리</option>
                            <option value="3">스포츠 및 레저</option>
                            <option value="4">도서 및 문구</option>
                            <option value="5">자동차 및 오토바이</option>
                            <option value="6">홈 및 인테리어</option>
                            <option value="7">공구 및 원예</option>
                            <option value="8">수집품 및 엔티크</option>
                            <option value="9">기타</option>
                        </select>
                    </td>
                </tr>
                <tr>
                    <th>제목</th>
                    <td style="text-align: center;">
                        <input class="input input-bordered input-primary input-sm w-full max-w-xs" name="title" autocomplete="off" type="text" placeholder="제목을 입력해 주세요"/>
                    </td>
                </tr>
                <tr>
                    <th>즉시구매가</th>
                    <td style="text-align: center;">
                        <input class="input input-bordered input-primary input-sm w-full max-w-xs" name="price" autocomplete="off" type="number" min="0" placeholder="가격을 입력해 주세요"/>
                    </td>
                </tr>
                <tr>
                    <th>입찰가</th>
                    <td style="text-align: center;">
                        <input class="input input-bordered input-primary input-sm w-full max-w-xs" name="bid" autocomplete="off" type="number" min="0" placeholder="입찰가를 입력해 주세요"/>
                    </td>
                </tr>
                <tr>
                    <th>내용</th>
                    <td style="text-align: center;">
                        <div id="editor"></div>
                    </td>
                </tr>

                <tr>
                    <th></th>
                    <td style="text-align: center;">
                        <button class="btn btn-primary">작성</button>
                    </td>
                </tr>
                </tbody>
            </table>
        </form>
        <div class="btns">
            <button class="btn" type="button" onclick="history.back()">뒤로가기</button>
        </div>
    </div>

    <script>
        const editor = new toastui.Editor({
            el: document.querySelector('#editor'),
            height: '500px',
            initialEditType: 'markdown',
            previewStyle: 'vertical',
            hooks: {
                addImageBlobHook: function (blob, callback) {
                    // 이미지 파일을 업로드하는 FormData 생성
                    const formData = new FormData();
                    formData.append('file', blob);

                    // 서버로 이미지를 업로드 (여러 이미지를 처리할 수 있도록 변경)
                    fetch('/api/images/upload', {
                        method: 'POST',
                        body: formData,
                    })
                        .then(response => response.json())
                        .then(data => {
                            if (data.url) {
                                // 업로드된 이미지 URL을 에디터에 삽입
                                callback(data.url, '');
                            } else {
                                console.error('Image upload failed: ', data);
                            }
                        })
                        .catch(error => {
                            console.error('Error uploading image:', error);
                        });

                    return false;  // 기본 이미지 업로드 동작 방지
                }
            }
        });

        // 이미지 업로드 기능을 활성화하기 위해 클릭 시 파일 선택
        document.querySelector(".image")

            .addEventListener("click", function() {

            const imageInput = document.createElement('input');
            imageInput.type = 'file';
            imageInput.accept = 'image/*';
            imageInput.multiple = true;  // 여러 개의 이미지 파일 선택 가능

            imageInput.addEventListener('change', function(event) {
                const files = event.target.files;
                if (files && files.length > 0) {
                    Array.from(files).forEach(file => {
                        const formData = new FormData();
                        formData.append('file', file);

                        fetch('/api/images/upload', {
                            method: 'POST',
                            body: formData,
                        })
                            .then(response => response.json())
                            .then(data => {
                                if (data.url) {
                                    // 업로드된 이미지 URL을 에디터에 삽입
                                    editor.insertText('![](' + data.url + ')');
                                } else {
                                    console.error('Image upload failed: ', data);
                                }
                            })
                            .catch(error => {
                                console.error('Error uploading image:', error);
                            });
                    });
                }
            });

            imageInput.click();  // 파일 선택 창 강제 팝업
        });
    </script>
</section>

<%@ include file="../common/foot.jspf" %>
