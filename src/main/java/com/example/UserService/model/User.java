package com.example.UserService.model;

import io.swagger.v3.oas.annotations.media.Schema;

public class User {
    @Schema(description = "")
    private String userId; // Assuming ID is of type Long

    @Schema(description = "")
    private String username;

    @Schema(description = "")
    private String password;

    @Schema(description = "")
    private String email;

    @Schema(description = "")
    private String createdAt;

    // Getter and setter for ID
    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    // Getters and setters for other fields
    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }
}
