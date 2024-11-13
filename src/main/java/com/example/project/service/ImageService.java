package com.example.project.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;
import java.util.stream.Stream;

@Service
public class ImageService {

    @Value("${custom.genFileDirPath}")  // application.yml에서 지정한 경로를 주입
    private String uploadDir;  // 이미지 업로드 디렉토리 경로

    public String uploadImage(MultipartFile file) throws IOException {
        // 파일 이름을 고유하게 만들기 위해 UUID를 사용
        String fileName = UUID.randomUUID().toString() + "_" + file.getOriginalFilename();

        // 파일을 저장할 경로
        Path path = Paths.get(uploadDir, fileName);
        File directory = new File(uploadDir);
        
        // 디렉토리가 없으면 생성
        if (!directory.exists()) {
            directory.mkdirs();
        }

        // 파일 저장
        file.transferTo(path.toFile());

        // 저장된 이미지 파일의 URL 생성 (서버의 URL 형식에 맞게)
        return "/images/" + fileName;  // 반환할 URL 형식
    }

    public void saveImage(String imageUrl, int articleId, int boardId) throws IOException {
        // article/boardId 디렉토리 생성
        Path directoryPath = Paths.get(uploadDir, "article", String.valueOf(boardId));
        if (!Files.exists(directoryPath)) {
            Files.createDirectories(directoryPath);
        }

        // HTTP로 이미지 다운로드
        InputStream in = new URL(imageUrl).openStream();

        // 파일 이름 설정: id-1.png, id-2.png, ...
        int fileIndex = getNextFileIndex(directoryPath, articleId);
        String fileExtension = getFileExtension(imageUrl); // 확장자 추출
        String fileName = articleId + "-" + fileIndex + fileExtension;

        // 파일 저장 경로
        Path filePath = directoryPath.resolve(fileName);

        // 파일 저장
        Files.copy(in, filePath, StandardCopyOption.REPLACE_EXISTING);
        in.close();
    }

    private int getNextFileIndex(Path directoryPath, int articleId) throws IOException {
        // 디렉토리에 이미 저장된 파일 목록 확인
        try (Stream<Path> files = Files.list(directoryPath)) {
            return (int) files
                    .filter(path -> path.getFileName().toString().startsWith(articleId + "-"))
                    .count() + 1; // 기존 파일 개수 + 1
        }
    }

    private String getFileExtension(String url) {
        // URL에서 확장자를 추출
        int lastDotIndex = url.lastIndexOf(".");
        if (lastDotIndex != -1) {
            return url.substring(lastDotIndex);
        }
        return ""; // 확장자가 없으면 빈 문자열 반환
    }


}
