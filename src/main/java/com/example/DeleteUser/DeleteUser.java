package com.example.DeleteUser;

import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.dynamodb.DynamoDbClient;
import software.amazon.awssdk.services.dynamodb.model.AttributeValue;
import software.amazon.awssdk.services.dynamodb.model.DeleteItemRequest;
import software.amazon.awssdk.services.dynamodb.model.DynamoDbException;
import java.util.HashMap;

public class DeleteUser {

    public static void execute(String[] args) {
        final String usage = """
                Usage:
                    <tableName> <key> <keyval>

                Where:
                    tableName - The Amazon DynamoDB table to delete the item from.
                    key - The key used in the Amazon DynamoDB table.
                    keyval - The key value that represents the item to delete.
                """;

        if (args.length != 3) {
            System.out.println(usage);
            System.exit(1);
        }

        String tableName = args[0];
        String key = args[1];
        String keyVal = args[2];

        Region region = Region.US_EAST_2;
        DynamoDbClient ddb = DynamoDbClient.builder()
                .region(region)
                .build();

        try {
            deleteUser(ddb, tableName, key, keyVal);
            System.out.format("Item \"%s\" deleted successfully from table \"%s\"\n", keyVal, tableName);
        } catch (DynamoDbException e) {
            System.err.println("Error deleting item: " + e.getMessage());
        } finally {
            ddb.close();
        }
    }

    public static void deleteUser(DynamoDbClient ddb, String tableName, String key, String keyVal) {
        HashMap<String, AttributeValue> keyToDelete = new HashMap<>();
        keyToDelete.put(key, AttributeValue.builder().s(keyVal).build());

        DeleteItemRequest deleteRequest = DeleteItemRequest.builder()
                .tableName(tableName)
                .key(keyToDelete)
                .build();

        ddb.deleteItem(deleteRequest);
    }
}