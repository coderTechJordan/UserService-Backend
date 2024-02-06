package com.example.UserService.service;

import com.amazonaws.services.lambda.runtime.LambdaLogger;
import com.example.UserService.dynamodb.GetAllUsers;
import com.example.UserService.dynamodb.PutUserItem;
import com.example.UserService.model.User;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import software.amazon.awssdk.services.dynamodb.model.DynamoDbException;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.UUID;

@Service
public class UserService {
    private static final Logger logger = LoggerFactory.getLogger(UserService.class);
    private LambdaLogger lambdaLogger;

    private final List<User> userList = new ArrayList<>();
    private static final String TABLE_NAME = "jordan-user-service";

    public void setLambdaLogger(LambdaLogger lambdaLogger) {
        this.lambdaLogger = lambdaLogger;
    }

    public User createUser(User user) {
        try {
            String userId = UUID.randomUUID().toString();
            String createdAt = LocalDateTime.now().toString();

            user.setUserId(userId);
            user.setCreatedAt(createdAt);

            logger.info("User before putting into database: {}", user.toString());
            if (lambdaLogger != null) {
                lambdaLogger.log("User before putting into database: " + user.toString());
            }

            PutUserItem putUserItem = new PutUserItem();

            putUserItem.execute(new String[]{"jordan-user-service", user.getUserId(), user.getFirstName(), user.getLastName(), user.getUsername(), user.getPassword(), user.getEmail(), user.getCreatedAt()});

            logger.info("User created and added to the userList: {}", user.toString());
            if (lambdaLogger != null) {
                lambdaLogger.log("User created and added to the userList: " + user.toString());
            }

            return user;
        } catch (Exception e) {
            logger.error("Error creating user", e);
            if (lambdaLogger != null) {
                lambdaLogger.log("Error creating user: " + e.getMessage());
            }
            throw new RuntimeException("Error creating user", e);
        }
    }


    public List<User> listUsers() {
        try {
            return GetAllUsers.execute(new String[]{TABLE_NAME});
        } catch (DynamoDbException e) {
            logger.error("Error listing users from DynamoDB", e);
            if (lambdaLogger != null) {
                lambdaLogger.log("Error listing users from DynamoDB: " + e.getMessage());
            }
            throw new RuntimeException("Error listing users from DynamoDB", e);
        }
    }


    public User getUserById(String userId) {
        try {
            logger.info("Getting user by ID: {}", userId);
            if (lambdaLogger != null) {
                lambdaLogger.log("Getting user by ID: " + userId);
            }
            return userList.stream()
                    .filter(u -> u.getUserId().equals(userId))
                    .findFirst()
                    .orElse(null);
        } catch (Exception e) {
            logger.error("Error getting user by ID", e);
            if (lambdaLogger != null) {
                lambdaLogger.log("Error getting user by ID: " + e.getMessage());
            }
            throw new RuntimeException("Error getting user by ID", e);
        }
    }

    public User updateUser(String userId, User updatedUser) {
        try {
            userList.removeIf(u -> u.getUserId().equals(userId));
            userList.add(updatedUser);

            logger.info("User updated: {}", updatedUser);
            if (lambdaLogger != null) {
                lambdaLogger.log("User updated: " + updatedUser);
            }
            return updatedUser;
        } catch (Exception e) {
            logger.error("Error updating user", e);
            if (lambdaLogger != null) {
                lambdaLogger.log("Error updating user: " + e.getMessage());
            }
            throw new RuntimeException("Error updating user", e);
        }
    }

    public void deleteUser(String userId) {
        try {
            userList.removeIf(u -> u.getUserId().equals(userId));
            logger.info("User deleted with ID: {}", userId);
            if (lambdaLogger != null) {
                lambdaLogger.log("User deleted with ID: " + userId);
            }
        } catch (Exception e) {
            logger.error("Error deleting user", e);
            if (lambdaLogger != null) {
                lambdaLogger.log("Error deleting user: " + e.getMessage());
            }
            throw new RuntimeException("Error deleting user", e);
        }
    }
}