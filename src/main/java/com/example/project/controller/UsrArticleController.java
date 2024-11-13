package com.example.project.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartRequest;

import com.example.project.Util.Ut;
import com.example.project.service.ArticleService;
import com.example.project.service.BoardService;
import com.example.project.service.FileStorageService;
import com.example.project.service.ImageService;
import com.example.project.service.ReactionPointService;
import com.example.project.vo.Article;
import com.example.project.vo.Board;
import com.example.project.vo.ResultData;
import com.example.project.vo.Rq;

import jakarta.servlet.http.HttpServletRequest;

import org.springframework.ui.Model;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;



@Controller
public class UsrArticleController {

	@Autowired
	private FileStorageService fileStorageService;
	
	@Autowired
	private Rq rq;

	@Autowired
	private ArticleService articleService;
	
	@Autowired
	private ReactionPointService reactionPointService;
	
	@Autowired
	private BoardService boardService;
	
	 @Autowired
	    private ImageService imageService;  // ImageService를 주입
	
	@RequestMapping("/usr/article/list")
	public String showList(HttpServletRequest req, Model model, @RequestParam(defaultValue = "0") int boardId,
			@RequestParam(defaultValue = "1") int page,
			@RequestParam(defaultValue = "title,body") String searchKeywordTypeCode,
			@RequestParam(defaultValue = "") String searchKeyword) throws IOException {

		Rq rq = (Rq) req.getAttribute("rq");
		
			Board board = boardService.getBoardById(boardId);

		
		int articlesCount = articleService.getArticlesCount(boardId, searchKeywordTypeCode, searchKeyword);

		// 한페이지에 글 10개
		// 글 20개 -> 2page
		// 글 25개 -> 3page
		int itemsInAPage = 20;

		int pagesCount = (int) Math.ceil(articlesCount / (double) itemsInAPage);

		List<Article> articles = articleService.getForPrintArticles(boardId, itemsInAPage, page, searchKeywordTypeCode,
				searchKeyword);

		if (board == null && searchKeyword == "") {
			return rq.historyBackOnView("없는 게시판임");
		}
		
		
		model.addAttribute("articles", articles);
		model.addAttribute("articlesCount", articlesCount);
		model.addAttribute("pagesCount", pagesCount);
		model.addAttribute("board", board);
		model.addAttribute("page", page);
		model.addAttribute("searchKeywordTypeCode", searchKeywordTypeCode);
		model.addAttribute("searchKeyword", searchKeyword);
		model.addAttribute("boardId", boardId);

		return "usr/article/list";
	}
	
	
	@RequestMapping("/usr/article/detail")
	public String showDetail(HttpServletRequest req, Model model, int id) {
		Rq rq = (Rq) req.getAttribute("rq");

		Article article = articleService.getForPrintArticle(rq.getLoginedMemberId(), id);

		ResultData usersReactionRd = reactionPointService.usersReaction(rq.getLoginedMemberId(), id);

		if (usersReactionRd.isSuccess()) {
			model.addAttribute("userCanMakeReaction", usersReactionRd.isSuccess());
		}


		model.addAttribute("article", article);

		model.addAttribute("isAlreadyAddGoodRp",
				reactionPointService.isAlreadyAddGoodRp(rq.getLoginedMemberId(), id));

		return "usr/article/detail";
	}
	
	@RequestMapping("/usr/article/doIncreaseHitCountRd")
	@ResponseBody
	public ResultData doIncreaseHitCount(int id) {

		ResultData increaseHitCountRd = articleService.increaseHitCount(id);

		if (increaseHitCountRd.isFail()) {
			return increaseHitCountRd;
		}

		ResultData rd = ResultData.newData(increaseHitCountRd, "hitCount", articleService.getArticleHitCount(id));

		rd.setData2("조회수가 증가된 게시글의 id", id);

		return rd;
	}
	
	@RequestMapping("/usr/article/doDelete")
	@ResponseBody
	public String doDelete(HttpServletRequest req, int id) {

		Rq rq = (Rq) req.getAttribute("rq");

		Article article = articleService.getArticleById(id);

		if (article == null) {
			return Ut.jsHistoryBack("F-1", Ut.f("%d번 게시글은 없습니다", id));
		}

		ResultData userCanDeleteRd = articleService.userCanDelete(rq.getLoginedMemberId(), article);

		if (userCanDeleteRd.isFail()) {
			return Ut.jsHistoryBack(userCanDeleteRd.getResultCode(), userCanDeleteRd.getMsg());
		}

		if (userCanDeleteRd.isSuccess()) {
			articleService.deleteArticle(id);
		}

		return Ut.jsReplace(userCanDeleteRd.getResultCode(), userCanDeleteRd.getMsg(), "../article/list");
	}
	
	@RequestMapping("/usr/article/write")
	public String showWrite(Model model) {

		int currentId = articleService.getCurrentArticleId();

		model.addAttribute("currentId", currentId);

		return "usr/article/write";
	}
	
    // 글 작성 시 이미지 업로드
    @PostMapping("/usr/article/doWrite")
    @ResponseBody
    public String doWrite(HttpServletRequest req, String boardId, String title, String body, int price, int bid,
						  @RequestParam("imageUrls") String imageUrls, @RequestParam Map<String, Object> param) {

        Rq rq = (Rq) req.getAttribute("rq");

        if (Ut.isEmptyOrNull(title)) {
            return Ut.jsHistoryBack("F-1", "제목을 입력해주세요");
        }
        if (Ut.isEmptyOrNull(body)) {
            return Ut.jsHistoryBack("F-2", "내용을 입력해주세요");
        }
        if (Ut.isEmptyOrNull(boardId)) {
            return Ut.jsHistoryBack("F-3", "게시판을 선택해주세요");
        }

        ResultData writeArticleRd = articleService.writeArticle(rq.getLoginedMemberId(), title, body, boardId,price,bid);

        int id = (int) writeArticleRd.getData1();
        Article article = articleService.getArticleById(id);

		// 이미지 URL들을 처리 (쉼표로 구분된 URL들)
		String[] images = imageUrls.split(",");
		// images 배열을 사용하여 처리
		System.out.println("kdnsaklf ㄴㄹㄴㅇㅁㄹ : " + imageUrls);
        // 파일 업로드
		if (images != null && images.length > 0) {
			try {
				// images 배열을 순차적으로 처리
				for (String imageUrl : images) {
					System.out.println("");
					// 각 이미지 URL을 처리 (예: DB에 저장하거나, 다른 서비스에 저장)
					imageService.saveImage(imageUrl, id, article.getBoardId());  // 이미지 업로드
				}
			} catch (IOException e) {
				return Ut.jsHistoryBack("F-4", "이미지 업로드 중 오류 발생.");
			}
		}

        return Ut.jsReplace(writeArticleRd.getResultCode(), writeArticleRd.getMsg(), "../article/detail?id=" + id);
    }

	// 이미지 업로드 처리 (중복된 uploadImage 메소드 제거)
	@PostMapping("/article/uploadImage")
	@ResponseBody
	public ResponseEntity<Map<String, String>> uploadImage(@RequestParam("file") MultipartFile file) {
		Map<String, String> response = new HashMap<>();

		if (file.isEmpty()) {
			response.put("message", "파일이 업로드되지 않았습니다.");
			return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
		}

		try {
			// 이미지 업로드
			String fileUrl = imageService.uploadImage(file);  // ImageService 사용
			response.put("url", fileUrl);  // 클라이언트에게 반환할 이미지 URL
			return ResponseEntity.ok(response);
		} catch (IOException e) {
			response.put("message", "파일 업로드 중 오류 발생.");
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
		}
	}
	
	@RequestMapping("/usr/article/modify")
	public String showModify(HttpServletRequest req, Model model, int id) {

		Rq rq = (Rq) req.getAttribute("rq");

		Article article = articleService.getForPrintArticle(rq.getLoginedMemberId(), id);

		if (article == null) {
			return Ut.jsHistoryBack("F-1", Ut.f("%d번 게시글은 없습니다", id));
		}

		model.addAttribute("article", article);

		return "/usr/article/modify";
	}
	
	// 로그인 체크 -> 유무 체크 -> 권한 체크 -> 수정
		@RequestMapping("/usr/article/doModify")
		@ResponseBody
		public String doModify(HttpServletRequest req, int id, String title, String body) {

			Rq rq = (Rq) req.getAttribute("rq");

			Article article = articleService.getArticleById(id);

			if (article == null) {
				return Ut.jsHistoryBack("F-1", Ut.f("%d번 게시글은 없습니다", id));
			}

			ResultData userCanModifyRd = articleService.userCanModify(rq.getLoginedMemberId(), article);

			if (userCanModifyRd.isFail()) {
				return Ut.jsHistoryBack(userCanModifyRd.getResultCode(), userCanModifyRd.getMsg());
			}

			if (userCanModifyRd.isSuccess()) {
				articleService.modifyArticle(id, title, body);
			}

			article = articleService.getArticleById(id);

			return Ut.jsReplace(userCanModifyRd.getResultCode(), userCanModifyRd.getMsg(), "../article/detail?id=" + id);
		}
		

}
