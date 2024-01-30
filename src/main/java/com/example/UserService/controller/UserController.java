package com.example.UserService.controller;

import com.example.UserService.ErrorResponse.ErrorResponse;
import com.example.UserService.model.User;
import com.example.UserService.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/users")
@CrossOrigin(origins = "*")
public class UserController {
    private final UserService userService;

    @Autowired
    public UserController(UserService userService) {
        this.userService = userService;
    }

    @PostMapping
    public ResponseEntity<?> createUser(@RequestBody User user) {
        try {
            System.out.println("Received request to create user: " + user);

            User createdUser = userService.createUser(user);

            System.out.println("User created successfully: " + createdUser);

            HttpHeaders headers = new HttpHeaders();
            headers.add("Access-Control-Allow-Origin", "*");

            return ResponseEntity.ok().headers(headers).body(createdUser);
        } catch (Exception e) {
            System.err.println("Error creating user: " + e.getMessage());
            e.printStackTrace();

            ErrorResponse errorResponse = new ErrorResponse("Error creating user", e.getMessage());
            HttpHeaders headers = new HttpHeaders();
            headers.add("Access-Control-Allow-Origin", "*");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).headers(headers).body(errorResponse);
        }
    }

    @GetMapping
    public ResponseEntity<?> listUsers() {
        try {
            System.out.println("Received request to list users");

            List<User> userList = (List<User>) userService.listUsers();

            System.out.println("Returning list of users: " + userList);

            HttpHeaders headers = new HttpHeaders();
            headers.add("Access-Control-Allow-Origin", "*");

            return ResponseEntity.ok().headers(headers).body(userList);
        } catch (Exception e) {

            System.err.println("Error listing users: " + e.getMessage());
            e.printStackTrace();

            ErrorResponse errorResponse = new ErrorResponse("Error listing users", e.getMessage());
            HttpHeaders headers = new HttpHeaders();
            headers.add("Access-Control-Allow-Origin", "*");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).headers(headers).body(errorResponse);
        }
    }

    @GetMapping("/{userId}")
    public ResponseEntity<?> getUserById(@PathVariable String userId) {
        try {
            System.out.println("Received request to get user by ID: " + userId);

            User user = userService.getUserById(userId);

            System.out.println("User found: " + user);

            HttpHeaders headers = new HttpHeaders();
            headers.add("Access-Control-Allow-Origin", "*");

            return ResponseEntity.ok().headers(headers).body(user);
        } catch (Exception e) {

            System.err.println("Error getting user by ID: " + e.getMessage());
            e.printStackTrace();

            ErrorResponse errorResponse = new ErrorResponse("Error getting user by ID", e.getMessage());
            HttpHeaders headers = new HttpHeaders();
            headers.add("Access-Control-Allow-Origin", "*");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).headers(headers).body(errorResponse);
        }
    }

    @PutMapping("/{userId}")
    public ResponseEntity<?> updateUser(@PathVariable String userId, @RequestBody User updatedUser) {
        try {
            System.out.println("Received request to update user with ID " + userId + ": " + updatedUser);

            User user = userService.updateUser(userId, updatedUser);

            System.out.println("User updated successfully: " + user);

            HttpHeaders headers = new HttpHeaders();
            headers.add("Access-Control-Allow-Origin", "*");

            return ResponseEntity.ok().headers(headers).body(user);
        } catch (Exception e) {
            System.err.println("Error updating user: " + e.getMessage());
            e.printStackTrace();

            ErrorResponse errorResponse = new ErrorResponse("Error updating user", e.getMessage());
            HttpHeaders headers = new HttpHeaders();
            headers.add("Access-Control-Allow-Origin", "*");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).headers(headers).body(errorResponse);
        }
    }

    @DeleteMapping("/{userId}")
    public ResponseEntity<?> deleteUser(@PathVariable String userId) {
        try {
            System.out.println("Received request to delete user with ID: " + userId);

            userService.deleteUser(userId);

            System.out.println("User deleted successfully with ID: " + userId);

            HttpHeaders headers = new HttpHeaders();
            headers.add("Access-Control-Allow-Origin", "*");

            return ResponseEntity.ok().headers(headers).build();
        } catch (Exception e) {
            System.err.println("Error deleting user: " + e.getMessage());
            e.printStackTrace();
            
            ErrorResponse errorResponse = new ErrorResponse("Error deleting user", e.getMessage());
            HttpHeaders headers = new HttpHeaders();
            headers.add("Access-Control-Allow-Origin", "*");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).headers(headers).body(errorResponse);
        }
    }
}
