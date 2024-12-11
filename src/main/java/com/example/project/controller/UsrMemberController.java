package com.example.project.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.example.project.Util.Ut;
import com.example.project.service.MemberService;
import com.example.project.vo.Member;
import com.example.project.vo.ResultData;
import com.example.project.vo.Rq;

import jakarta.servlet.http.HttpServletRequest;


@Controller
public class UsrMemberController {
	
	@Autowired
	MemberService memberService;
	
	@Autowired
	private Rq rq;
		
	@RequestMapping("/usr/member/loginOrsign")
	public String showLogin(HttpServletRequest req) {
		return "/usr/member/login&sign";
	}
	

	@RequestMapping("/usr/member/doSign")
	@ResponseBody
	public String doSign(HttpServletRequest req, String loginId, String loginPw, String name,String nickName,  String cellphoneNum, String email) {

		if (Ut.isEmptyOrNull(loginId)) {
			return Ut.jsHistoryBack("F-1", "loginId 입력 x");
		}
		if (Ut.isEmptyOrNull(loginPw)) {
			return Ut.jsHistoryBack("F-2", "loginPw 입력 x");
		}
		if (Ut.isEmptyOrNull(name)) {
			return Ut.jsHistoryBack("F-3", "name 입력 x");
		}
		if (Ut.isEmptyOrNull(nickName)) {
			return Ut.jsHistoryBack("F-3", "nickName 입력 x");
		}
		if (Ut.isEmptyOrNull(cellphoneNum)) {
			return Ut.jsHistoryBack("F-5", "cellphoneNum 입력 x");
		}
		if (Ut.isEmptyOrNull(email)) {
			return Ut.jsHistoryBack("F-6", "email 입력 x");
		}

		ResultData signRd = memberService.sign(loginId, loginPw, name, nickName,  email,cellphoneNum);

		if (signRd.isFail()) {
			return Ut.jsHistoryBack(signRd.getResultCode(), signRd.getMsg());
		}

		Member member = memberService.getMemberById((int) signRd.getData1());

		return Ut.jsReplace(signRd.getResultCode(), signRd.getMsg(), "../member/loginOrsign");
	}
	
	@RequestMapping("/usr/member/doLogin")
	@ResponseBody
	public String doLogin(HttpServletRequest req, String loginId, String loginPw, String afterLoginUri) {

		Rq rq = (Rq) req.getAttribute("rq");

		if (Ut.isEmptyOrNull(loginId)) {
			return Ut.jsHistoryBack("F-1", "loginId 입력 x");
		}
		if (Ut.isEmptyOrNull(loginPw)) {
			return Ut.jsHistoryBack("F-2", "loginPw 입력 x");
		}
		
		Member member = memberService.getMemberByLoginId(loginId);
		
		if (member == null) {
			return Ut.jsHistoryBack("F-3", Ut.f("%s는(은) 존재 x", loginId));
		}

		if (member.getLoginPw().equals(Ut.sha256(loginPw)) == false) {
			return Ut.jsHistoryBack("F-4", Ut.f("비밀번호가 일치하지 않습니다!!!!!"));
		}
		
		rq.login(member);
		
		if (afterLoginUri.length() > 0) {
			return Ut.jsReplace("S-1", Ut.f("%s님 환영합니다", member.getName()), afterLoginUri);
		}

		return Ut.jsReplace("S-1", Ut.f("%s님 환영합니다", member.getName()), "/");
	}
	
	@RequestMapping("/usr/member/doLogout")
	@ResponseBody
	public String doLogout(HttpServletRequest req) {

		rq.logout();

		return Ut.jsReplace("S-1", Ut.f("로그아웃 성공"), "/");
	}

	@RequestMapping("/usr/member/myPage")
	public String showmyPage() {
		return "usr/member/myPage";
	}

	@RequestMapping("/usr/member/modify")
	public String showmyModify() {
		return "usr/member/modify";
	}

	@RequestMapping("/usr/member/checkPw")
	public String showCheckPw() {
		return "usr/member/checkPw";
	}

	@RequestMapping("/usr/member/doCheckPw")
	@ResponseBody
	public String doCheckPw(String loginPw) {
		if (Ut.isEmptyOrNull(loginPw)) {
			return Ut.jsHistoryBack("F-1", "비밀번호를 입력해주세요.");
		}

		if (rq.getLoginedMember().getLoginPw().equals(Ut.sha256(loginPw)) == false) {
			return Ut.jsHistoryBack("F-2", "비밀번호가 틀렸습니다.");
		}

		return Ut.jsReplace("S-1", Ut.f("비밀번호 확인 성공"), "modify");
	}


	@RequestMapping("/usr/member/doModify")
	@ResponseBody
	public String doModify(HttpServletRequest req, String loginPw, String name, String nickname, String cellphoneNum, String email) {

		Rq rq = (Rq) req.getAttribute("rq");

		// 비번을 입력하지 않아도 회원정보 수정이 가능하도록 만들어야 함.(비번은 바꾸기 싫을때.)
		// 비번은 안바꾸는거 가능(사용자 입장). 비번 null 체크 X

		if (Ut.isEmptyOrNull(name)) {
			return Ut.jsHistoryBack("F-3", Ut.f("%d(을)를 제대로 입력해주세요.", name));
		}
		if (Ut.isEmptyOrNull(nickname)) {
			return Ut.jsHistoryBack("F-4", Ut.f("%d(을)를 제대로 입력해주세요.", nickname));
		}
		if (Ut.isEmptyOrNull(cellphoneNum)) {
			return Ut.jsHistoryBack("F-5", Ut.f("%d(을)를 제대로 입력해주세요.", cellphoneNum));
		}
		if (Ut.isEmptyOrNull(email)) {
			return Ut.jsHistoryBack("F-6", Ut.f("%d(을)를 제대로 입력해주세요.", email));
		}

		ResultData modifyRd;

		if (Ut.isEmptyOrNull(loginPw)) {

			modifyRd = memberService.modifyWithoutPw(rq.getLoginedMemberId(), name, nickname, cellphoneNum, email);

		} else {
			modifyRd = memberService.modify(rq.getLoginedMemberId(), loginPw, name, nickname, cellphoneNum, email);
		}


		return Ut.jsReplace(modifyRd.getResultCode(), modifyRd.getMsg(), "../member/myPage");
	}
	
}
