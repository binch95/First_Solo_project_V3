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
        // 상대 경로를 실제 파일 시스템 경로로 변환
        Path sourcePath = Paths.get(uploadDir, imageUrl.startsWith("/images/") ? imageUrl.substring(8) : imageUrl);
        if (!Files.exists(sourcePath)) {
            throw new IOException("이미지 파일이 존재하지 않습니다: " + sourcePath);
        }

        // article/boardId 디렉토리 생성
        Path directoryPath = Paths.get(uploadDir, "article", String.valueOf(boardId));
        if (!Files.exists(directoryPath)) {
            Files.createDirectories(directoryPath);
        }

        // 새 파일 이름 설정: id-1.png, id-2.png, ...
        int fileIndex = getNextFileIndex(directoryPath, articleId);
        String fileExtension = getFileExtension(sourcePath.toString()); // 확장자 추출
        String newFileName = articleId + "-" + fileIndex + fileExtension;

        // 새 파일 경로
        Path destinationPath = directoryPath.resolve(newFileName);

        // 파일 이동
        Files.move(sourcePath, destinationPath);
    }

    private int getNextFileIndex(Path directoryPath, int articleId) throws IOException {
        try (Stream<Path> files = Files.list(directoryPath)) {
            return (int) files
                    .filter(path -> path.getFileName().toString().startsWith(articleId + "-"))
                    .count() + 1;
        }
    }

    private String getFileExtension(String filePath) {
        int lastDotIndex = filePath.lastIndexOf(".");
        if (lastDotIndex != -1) {
            return filePath.substring(lastDotIndex);
        }
        return ""; // 확장자가 없으면 빈 문자열 반환
    }


}
