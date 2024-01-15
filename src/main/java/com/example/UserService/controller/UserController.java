package com.example.UserService.controller;

import com.example.UserService.dynamodb.PutUserItem;
import com.example.UserService.model.User;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/users")
public class UserController {

    private final List<User> userList = new ArrayList<>();

    @PostMapping
    public User createUser(@RequestBody User user) {
        try {
            // Generate userId (you can use UUID.randomUUID().toString() or any other method)
            String userId = UUID.randomUUID().toString();

            // Generate createdAt timestamp (you can use LocalDateTime.now() or any other method)
            String createdAt = LocalDateTime.now().toString();

            // Set generated values in the user object
            user.setUserId(userId);
            user.setCreatedAt(createdAt);

            // Placeholder logic to save the user to a database
            userList.add(user);

            // Call the method to put the user item in DynamoDB
            PutUserItem putUserItem = new PutUserItem();
            putUserItem.execute(new String[]{"jordan-user-service", user.getUserId(), user.getUsername(), user.getPassword(), user.getEmail(), user.getCreatedAt()});

            // Log information
            System.out.println("User created and added to the userList: " + user);

            // Return the created user
            return user;
        } catch (Exception e) {
            // Log and handle the exception
            System.err.println("Error creating user: " + e.getMessage());
            throw new RuntimeException("Error creating user", e);
        }
    }

    @GetMapping
    public List<User> listUsers() {
        try {
            // Log information
            System.out.println("Returning list of users: " + userList);

            // Return the list of users (simulated from the userList)
            return userList;
        } catch (Exception e) {
            // Log the exception
            System.err.println("Error listing users: " + e.getMessage());
            // You may want to throw a custom exception or handle it in a way that suits your application
            throw new RuntimeException("Error listing users", e);
        }
    }

    @GetMapping("/{userId}")
    public User getUserById(@PathVariable String userId) {
        try {
            // Log information
            System.out.println("Getting user by ID: " + userId);

            // Placeholder logic to retrieve a user by ID from the database (simulated from the userList)
            return userList.stream()
                    .filter(u -> u.getUserId().equals(userId))
                    .findFirst()
                    .orElse(null);
        } catch (Exception e) {
            // Log the exception
            System.err.println("Error getting user by ID: " + e.getMessage());
            // You may want to throw a custom exception or handle it in a way that suits your application
            throw new RuntimeException("Error getting user by ID", e);
        }
    }

    @PutMapping("/{userId}")
    public User updateUser(@PathVariable String userId, @RequestBody User updatedUser) {
        try {
            // Placeholder logic to update a user by ID in the database (simulated from the userList)
            userList.removeIf(u -> u.getUserId().equals(userId));
            updatedUser.setUserId(userId); // Set the new userId
            userList.add(updatedUser);

            // Log information
            System.out.println("User updated: " + updatedUser);

            // Return the updated user
            return updatedUser;
        } catch (Exception e) {
            // Log the exception
            System.err.println("Error updating user: " + e.getMessage());
            // You may want to throw a custom exception or handle it in a way that suits your application
            throw new RuntimeException("Error updating user", e);
        }
    }

    @DeleteMapping("/{userId}")
    public void deleteUser(@PathVariable String userId) {
        try {
            // Placeholder logic to delete a user by ID from the database (simulated from the userList)
            userList.removeIf(u -> u.getUserId().equals(userId));

            // Log information
            System.out.println("User deleted with ID: " + userId);
        } catch (Exception e) {
            // Log the exception
            System.err.println("Error deleting user: " + e.getMessage());
            // You may want to throw a custom exception or handle it in a way that suits your application
            throw new RuntimeException("Error deleting user", e);
        }
    }


    // Other endpoint methods for authentication, password change, etc.
}
