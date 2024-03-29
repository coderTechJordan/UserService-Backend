package com.example.CreateUser;

import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.dynamodb.DynamoDbClient;
import software.amazon.awssdk.services.dynamodb.model.AttributeValue;
import software.amazon.awssdk.services.dynamodb.model.DynamoDbException;
import software.amazon.awssdk.services.dynamodb.model.PutItemRequest;
import software.amazon.awssdk.services.dynamodb.model.PutItemResponse;
import software.amazon.awssdk.services.dynamodb.model.ResourceNotFoundException;

import java.util.HashMap;

public class PutUserItem {
    private static final String USAGE =
            "Usage:\n" +
                    "    <tableName> <userId> <firstName> <lastName> <username> <password> <email> <createdAt>\n\n" +
                    "Where:\n" +
                    "    tableName - The Amazon DynamoDB table (for example, jordan-user-service).\n" +
                    "    userId - The user ID (UUID).\n" +
                    "    firstName - The first name.\n" +
                    "    lastName - The last name.\n" +
                    "    username - The username.\n" +
                    "    password - The password.\n" +
                    "    email - The email.\n" +
                    "    createdAt - The timestamp when the user was created.\n" +
                    "**Warning** This program will place a user item that you specify into a table!\n";


    public void execute(String[] args) {
        if (args.length != 8) {
            System.out.println(USAGE);
            System.exit(1);
        }

        String tableName = args[0];
        String userId = args[1];
        String firstName = args[2];
        String lastName = args[3];
        String username = args[4];
        String password = args[5];
        String email = args[6];
        String createdAt = args[7];

        Region region = Region.US_EAST_2;
        DynamoDbClient ddb = DynamoDbClient.builder()
                .region(region)
                .build();

        putUserItemInTable(ddb, tableName, userId, firstName, lastName, username, password, email, createdAt);
        System.out.println("Done!");
        ddb.close();
    }

    public static void putUserItemInTable(DynamoDbClient ddb,
                                          String tableName,
                                          String userId,
                                          String firstName,
                                          String lastName,
                                          String username,
                                          String password,
                                          String email,
                                          String createdAt) {

        HashMap<String, AttributeValue> itemValues = new HashMap<>();
        itemValues.put("userId", AttributeValue.builder().s(userId).build());
        itemValues.put("firstName", AttributeValue.builder().s(firstName).build());
        itemValues.put("lastName", AttributeValue.builder().s(lastName).build());
        itemValues.put("username", AttributeValue.builder().s(username).build());
        itemValues.put("password", AttributeValue.builder().s(password).build());
        itemValues.put("email", AttributeValue.builder().s(email).build());
        itemValues.put("createdAt", AttributeValue.builder().s(createdAt).build());

        PutItemRequest request = PutItemRequest.builder()
                .tableName(tableName)
                .item(itemValues)
                .build();

        try {
            PutItemResponse response = ddb.putItem(request);
            System.out.println(tableName + " was successfully updated. The request id is " + response.responseMetadata().requestId());

        } catch (ResourceNotFoundException e) {
            System.err.format("Error: The Amazon DynamoDB table \"%s\" can't be found.\n", tableName);
            System.err.println("Be sure that it exists and that you've typed its name correctly!");
            System.exit(1);
        } catch (DynamoDbException e) {
            System.err.println("Error putting item in DynamoDB");
            System.err.println(e.getMessage());
            e.printStackTrace();
            System.exit(1);
        }
    }
}
