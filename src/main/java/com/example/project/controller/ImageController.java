package com.example.project.controller;

import com.example.project.service.ImageService;
import com.example.project.vo.ImageUploadResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/images")
public class ImageController {

    @Autowired
    private ImageService imageService;

    @PostMapping("/upload")
    public ResponseEntity<ImageUploadResponse> uploadImage(@RequestParam("file") MultipartFile file) {
        try {
            // 이미지 업로드 처리
            String imageUrl = imageService.uploadImage(file);
            ImageUploadResponse response = new ImageUploadResponse(imageUrl);

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.status(500).body(new ImageUploadResponse("Upload failed"));
        }
    }


}
