package com.example.UserService.dynamodb;

import com.example.UserService.model.User;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.dynamodb.DynamoDbClient;
import software.amazon.awssdk.services.dynamodb.model.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class QueryUser {

    public static User execute(String[] args) {
        final String usage = """

                Usage:
                    <tableName> <userId>

                Where:
                    tableName - The Amazon DynamoDB table from which a user item is retrieved (for example, Users).\s
                    userId - The unique identifier of the user to retrieve.
                """;
        if (args.length != 2) {
            System.out.println(usage);
            System.exit(1);
        }

        String tableName = args[0];
        String userId = args[1];
        System.out.println("Querying user with ID: " + userId + " from table: " + tableName);
        // Set up your DynamoDB client and region
        Region region = Region.US_EAST_2;
        DynamoDbClient ddb = DynamoDbClient.builder()
                .region(region)
                .build();

        // Call the method to query the user item from DynamoDB
        return getUserItemByIdFromDynamoDB(ddb, tableName, userId);
    }

    public static User getUserItemByIdFromDynamoDB(DynamoDbClient ddb, String tableName, String userId) {
        // Set up mapping of the partition name with the value.
        HashMap<String, String> attrNameAlias = new HashMap<>();
        attrNameAlias.put("#userId", "userId");

        // Set up mapping of the partition name with the value.
        HashMap<String, AttributeValue> attrValues = new HashMap<>();
        attrValues.put(":userId", AttributeValue.builder().s(userId).build());

        QueryRequest queryRequest = QueryRequest.builder()
                .tableName(tableName)
                .keyConditionExpression("#userId = :userId")
                .expressionAttributeNames(attrNameAlias)
                .expressionAttributeValues(attrValues)
                .build();

        try {
            QueryResponse response = ddb.query(queryRequest);
            List<Map<String, AttributeValue>> items = response.items();

            if (items.isEmpty()) {
                System.out.format("No item found with the userId: %s!\n", userId);
                return null;
            } else {
                // Assuming userId is unique, take the first item from the list
                Map<String, AttributeValue> item = items.get(0);
                // Construct and return the User object
                return mapToUser(item);
            }
        } catch (DynamoDbException e) {
            System.err.println(e.getMessage());
            // Handle the exception according to your application's requirements
            return null;
        }
    }

    private static User mapToUser(Map<String, AttributeValue> item) {
        // Construct and return the User object based on the item attributes
        return new User(
                item.get("userId").s(),
                item.get("firstName").s(),
                item.get("lastName").s(),
                item.get("username").s(),
                item.get("password").s(),
                item.get("email").s(),
                item.get("createdAt").s()
        );
    }
}
