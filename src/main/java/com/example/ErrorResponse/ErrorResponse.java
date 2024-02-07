package com.example.ErrorResponse;

public class ErrorResponse {
    private String errorMessage;
    private String details;

    // Default constructor
    public ErrorResponse() {
    }

    // Constructor with parameters
    public ErrorResponse(String errorMessage, String details) {
        this.errorMessage = errorMessage;
        this.details = details;
    }

    // Getter and setter methods

    public String getErrorMessage() {
        return errorMessage;
    }

    public void setErrorMessage(String errorMessage) {
        this.errorMessage = errorMessage;
    }

    public String getDetails() {
        return details;
    }

    public void setDetails(String details) {
        this.details = details;
    }
}
