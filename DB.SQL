# DB 세팅
DROP DATABASE IF EXISTS `Solo_Project`;
CREATE DATABASE `Solo_Project`;
USE `Solo_Project`;

CREATE TABLE article (
                         id INT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
                         regDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                         updateDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                         title CHAR(250) NOT NULL,
                         `body` TEXT NOT NULL,
                         memberId INT NOT NULL,
                         boardId INT NOT NULL,
                         hitCount INT NOT NULL,
                         price INT NOT NULL,
                         bid INT NOT NULL,
                         bidder_count INT NOT NULL,
                         remaining_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                         is_sold CHAR(150) NOT NULL DEFAULT 'selling',
                         goodReactionPoint INT NOT NULL
);

SELECT * FROM article;

CREATE TABLE board (
                       id INT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
                       regDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                       updateDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                       `code` CHAR(150) NOT NULL,
                       `name` CHAR(250) NOT NULL,
                       delStatus INT NOT NULL,
                       delDate DATETIME COMMENT '삭제 날짜'
);


CREATE TABLE `member`(
                         id INT(10) UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
                         regDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                         updateDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                         loginId CHAR(30) NOT NULL,
                         loginPw CHAR(100) NOT NULL,
                         `authLevel` SMALLINT(2) UNSIGNED DEFAULT 3 COMMENT '권한 레벨 (3=일반,7=관리자)',
                         `name` CHAR(20) NOT NULL,
                         nickname CHAR(20) NOT NULL,
                         cellphoneNum CHAR(20) NOT NULL,
                         email CHAR(50) NOT NULL,
                         delStatus TINYINT(1) UNSIGNED NOT NULL DEFAULT 0 COMMENT '탈퇴 여부 (0=탈퇴 전, 1=탈퇴 후)',
                         delDate DATETIME COMMENT '탈퇴 날짜'
);

# reactionPoint 테이블 생성
CREATE TABLE reactionPoint(
                              id INT(10) UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
                              regDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                              updateDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                              memberId INT(10) UNSIGNED NOT NULL,
                              relTypeCode CHAR(50) NOT NULL COMMENT '관련 데이터 타입 코드',
                              relId INT(10) NOT NULL COMMENT '관련 데이터 번호',
                              `point` INT(10) NOT NULL
);



-- board 테이블에 데이터 삽입

INSERT INTO board (regDate, updateDate, CODE, NAME, delStatus, delDate)
VALUES
    (NOW(), NOW(), 'categori', '전자제품', 0, NULL),
    (NOW(), NOW(), 'categori', '패션 및 악세서리', 0, NULL),
    (NOW(), NOW(), 'categori', '스포츠 및 레져', 0, NULL),
    (NOW(), NOW(), 'categori', '도서 및 문구', 0, NULL),
    (NOW(), NOW(), 'categori', '자동차 및 오토바이', 0, NULL),
    (NOW(), NOW(), 'categori', '홈 및 인테리어', 0, NULL),
    (NOW(), NOW(), 'categori', '수집품 및 엔티크', 0, NULL),
    (NOW(), NOW(), 'categori', '공구 및 원예', 0, NULL),
    (NOW(), NOW(), 'categori', '기타', 0, NULL);



-- 'admin', 'test1', 'test2' 사용자를 member 테이블에 삽입하는 쿼리

INSERT INTO `member` (
    regDate, updateDate, loginId, loginPw, authLevel, NAME, nickname, cellphoneNum, email, delStatus, delDate
) VALUES
      (
          NOW(), NOW(), 'admin', SHA2('admin', 256), 7, 'Admin User', 'adminNick', '010-1111-1111', 'admin@example.com', 0, NULL
      ),
      (
          NOW(), NOW(), 'test1', SHA2('test1', 256), 3, 'Test User 1', 'test1Nick', '010-2222-2222', 'test1@example.com', 0, NULL
      ),
      (
          NOW(), NOW(), 'test2', SHA2('test2', 256), 3, 'Test User 2', 'test2Nick', '010-3333-3333', 'test2@example.com', 0, NULL
      );




-- boardId 1
INSERT INTO article (regDate, updateDate, title, BODY, memberId, boardId, hitCount, price, bid, bidder_count, remaining_time, is_sold, goodReactionPoint)
VALUES
    (NOW(), NOW(), CONCAT('Title ', FLOOR(1 + (RAND() * 100000))), CONCAT('Content for article ', FLOOR(1 + (RAND() * 100000))), FLOOR(1 + (RAND() * 3)), 1, 0, 10000, 0, 0, NOW() + INTERVAL 3 DAY, 'selling', 0),
    (NOW(), NOW(), CONCAT('Title ', FLOOR(1 + (RAND() * 100000))), CONCAT('Content for article ', FLOOR(1 + (RAND() * 100000))), FLOOR(1 + (RAND() * 3)), 1, 0, 15000, 0, 0, NOW() + INTERVAL 1 DAY, 'selling', 0),
    (NOW(), NOW(), CONCAT('Title ', FLOOR(1 + (RAND() * 100000))), CONCAT('Content for article ', FLOOR(1 + (RAND() * 100000))), FLOOR(1 + (RAND() * 3)), 1, 0, 12000, 0, 0, NOW() + INTERVAL 1 DAY, 'selling', 0);

-- boardId 2
INSERT INTO article (regDate, updateDate, title, BODY, memberId, boardId, hitCount, price, bid, bidder_count, remaining_time, is_sold, goodReactionPoint)
VALUES
    (NOW(), NOW(), CONCAT('Title ', FLOOR(1 + (RAND() * 100000))), CONCAT('Content for article ', FLOOR(1 + (RAND() * 100000))), FLOOR(1 + (RAND() * 3)), 2, 0, 10000, 0, 0, NOW() + INTERVAL 1 DAY, 'selling', 0),
    (NOW(), NOW(), CONCAT('Title ', FLOOR(1 + (RAND() * 100000))), CONCAT('Content for article ', FLOOR(1 + (RAND() * 100000))), FLOOR(1 + (RAND() * 3)), 2, 0, 15000, 0, 0, NOW() + INTERVAL 1 DAY, 'selling', 0),
    (NOW(), NOW(), CONCAT('Title ', FLOOR(1 + (RAND() * 100000))), CONCAT('Content for article ', FLOOR(1 + (RAND() * 100000))), FLOOR(1 + (RAND() * 3)), 2, 0, 12000, 0, 0, NOW() + INTERVAL 1 DAY, 'selling', 0);

-- boardId 3
INSERT INTO article (regDate, updateDate, title, BODY, memberId, boardId, hitCount, price, bid, bidder_count, remaining_time, is_sold, goodReactionPoint)
VALUES
    (NOW(), NOW(), CONCAT('Title ', FLOOR(1 + (RAND() * 100000))), CONCAT('Content for article ', FLOOR(1 + (RAND() * 100000))), FLOOR(1 + (RAND() * 3)), 3, 0, 10000, 0, 0, NOW() + INTERVAL 1 DAY, 'selling', 0),
    (NOW(), NOW(), CONCAT('Title ', FLOOR(1 + (RAND() * 100000))), CONCAT('Content for article ', FLOOR(1 + (RAND() * 100000))), FLOOR(1 + (RAND() * 3)), 3, 0, 15000, 0, 0, NOW() + INTERVAL 1 DAY, 'selling', 0),
    (NOW(), NOW(), CONCAT('Title ', FLOOR(1 + (RAND() * 100000))), CONCAT('Content for article ', FLOOR(1 + (RAND() * 100000))), FLOOR(1 + (RAND() * 3)), 3, 0, 12000, 0, 0, NOW() + INTERVAL 1 DAY, 'selling', 0);

-- boardId 4
INSERT INTO article (regDate, updateDate, title, BODY, memberId, boardId, hitCount, price, bid, bidder_count, remaining_time, is_sold, goodReactionPoint)
VALUES
    (NOW(), NOW(), CONCAT('Title ', FLOOR(1 + (RAND() * 100000))), CONCAT('Content for article ', FLOOR(1 + (RAND() * 100000))), FLOOR(1 + (RAND() * 3)), 4, 0, 10000, 0, 0, NOW() + INTERVAL 1 DAY, 'selling', 0),
    (NOW(), NOW(), CONCAT('Title ', FLOOR(1 + (RAND() * 100000))), CONCAT('Content for article ', FLOOR(1 + (RAND() * 100000))), FLOOR(1 + (RAND() * 3)), 4, 0, 15000, 0, 0, NOW() + INTERVAL 1 DAY, 'selling', 0),
    (NOW(), NOW(), CONCAT('Title ', FLOOR(1 + (RAND() * 100000))), CONCAT('Content for article ', FLOOR(1 + (RAND() * 100000))), FLOOR(1 + (RAND() * 3)), 4, 0, 12000, 0, 0, NOW() + INTERVAL 1 DAY, 'selling', 0);

-- boardId 5
INSERT INTO article (regDate, updateDate, title, BODY, memberId, boardId, hitCount, price, bid, bidder_count, remaining_time, is_sold, goodReactionPoint)
VALUES
    (NOW(), NOW(), CONCAT('Title ', FLOOR(1 + (RAND() * 100000))), CONCAT('Content for article ', FLOOR(1 + (RAND() * 100000))), FLOOR(1 + (RAND() * 3)), 5, 0, 10000, 0, 0, NOW() + INTERVAL 1 DAY, 'selling', 0),
    (NOW(), NOW(), CONCAT('Title ', FLOOR(1 + (RAND() * 100000))), CONCAT('Content for article ', FLOOR(1 + (RAND() * 100000))), FLOOR(1 + (RAND() * 3)), 5, 0, 15000, 0, 0, NOW() + INTERVAL 1 DAY, 'selling', 0),
    (NOW(), NOW(), CONCAT('Title ', FLOOR(1 + (RAND() * 100000))), CONCAT('Content for article ', FLOOR(1 + (RAND() * 100000))), FLOOR(1 + (RAND() * 3)), 5, 0, 12000, 0, 0, NOW() + INTERVAL 1 DAY, 'selling', 0);

-- boardId 6
INSERT INTO article (regDate, updateDate, title, BODY, memberId, boardId, hitCount, price, bid, bidder_count, remaining_time, is_sold, goodReactionPoint)
VALUES
    (NOW(), NOW(), CONCAT('Title ', FLOOR(1 + (RAND() * 100000))), CONCAT('Content for article ', FLOOR(1 + (RAND() * 100000))), FLOOR(1 + (RAND() * 3)), 6, 0, 10000, 0, 0, NOW() + INTERVAL 1 DAY, 'selling', 0),
    (NOW(), NOW(), CONCAT('Title ', FLOOR(1 + (RAND() * 100000))), CONCAT('Content for article ', FLOOR(1 + (RAND() * 100000))), FLOOR(1 + (RAND() * 3)), 6, 0, 15000, 0, 0, NOW() + INTERVAL 1 DAY, 'selling', 0),
    (NOW(), NOW(), CONCAT('Title ', FLOOR(1 + (RAND() * 100000))), CONCAT('Content for article ', FLOOR(1 + (RAND() * 100000))), FLOOR(1 + (RAND() * 3)), 6, 0, 12000, 0, 0, NOW() + INTERVAL 1 DAY, 'selling', 0);

-- boardId 7
INSERT INTO article (regDate, updateDate, title, BODY, memberId, boardId, hitCount, price, bid, bidder_count, remaining_time, is_sold, goodReactionPoint)
VALUES
    (NOW(), NOW(), CONCAT('Title ', FLOOR(1 + (RAND() * 100000))), CONCAT('Content for article ', FLOOR(1 + (RAND() * 100000))), FLOOR(1 + (RAND() * 3)), 7, 0, 10000, 0, 0, NOW() + INTERVAL 1 DAY, 'selling', 0),
    (NOW(), NOW(), CONCAT('Title ', FLOOR(1 + (RAND() * 100000))), CONCAT('Content for article ', FLOOR(1 + (RAND() * 100000))), FLOOR(1 + (RAND() * 3)), 7, 0, 15000, 0, 0, NOW() + INTERVAL 1 DAY, 'selling', 0),
    (NOW(), NOW(), CONCAT('Title ', FLOOR(1 + (RAND() * 100000))), CONCAT('Content for article ', FLOOR(1 + (RAND() * 100000))), FLOOR(1 + (RAND() * 3)), 7, 0, 12000, 0, 0, NOW() + INTERVAL 1 DAY, 'selling', 0);

-- boardId 8
INSERT INTO article (regDate, updateDate, title, BODY, memberId, boardId, hitCount, price, bid, bidder_count, remaining_time, is_sold, goodReactionPoint)
VALUES
    (NOW(), NOW(), CONCAT('Title ', FLOOR(1 + (RAND() * 100000))), CONCAT('Content for article ', FLOOR(1 + (RAND() * 100000))), FLOOR(1 + (RAND() * 3)), 8, 0, 10000, 0, 0, NOW() + INTERVAL 1 DAY, 'selling', 0),
    (NOW(), NOW(), CONCAT('Title ', FLOOR(1 + (RAND() * 100000))), CONCAT('Content for article ', FLOOR(1 + (RAND() * 100000))), FLOOR(1 + (RAND() * 3)), 8, 0, 15000, 0, 0, NOW() + INTERVAL 1 DAY, 'selling', 0),
    (NOW(), NOW(), CONCAT('Title ', FLOOR(1 + (RAND() * 100000))), CONCAT('Content for article ', FLOOR(1 + (RAND() * 100000))), FLOOR(1 + (RAND() * 3)), 8, 0, 12000, 0, 0, NOW() + INTERVAL 1 DAY, 'selling', 0);

-- boardId 9
INSERT INTO article (regDate, updateDate, title, BODY, memberId, boardId, hitCount, price, bid, bidder_count, remaining_time, is_sold, goodReactionPoint)
VALUES
    (NOW(), NOW(), CONCAT('Title ', FLOOR(1 + (RAND() * 100000))), CONCAT('Content for article ', FLOOR(1 + (RAND() * 100000))), FLOOR(1 + (RAND() * 3)), 9, 0, 10000, 0, 0, NOW() + INTERVAL 1 DAY, 'selling', 0),
    (NOW(), NOW(), CONCAT('Title ', FLOOR(1 + (RAND() * 100000))), CONCAT('Content for article ', FLOOR(1 + (RAND() * 100000))), FLOOR(1 + (RAND() * 3)), 9, 0, 15000, 0, 0, NOW() + INTERVAL 1 DAY, 'selling', 0),
    (NOW(), NOW(), CONCAT('Title ', FLOOR(1 + (RAND() * 100000))), CONCAT('Content for article ', FLOOR(1 + (RAND() * 100000))), FLOOR(1 + (RAND() * 3)), 9, 0, 12000, 0, 0, NOW() + INTERVAL 1 DAY, 'selling', 0);

