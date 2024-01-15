//// SwaggerConfig.java
//package com.example.UserService.config;
//
//import org.springframework.context.annotation.Bean;
//import org.springframework.context.annotation.Configuration;
//import springfox.documentation.builders.RequestHandlerSelectors;
//import springfox.documentation.service.ApiInfo;
//import springfox.documentation.service.Contact;
//import springfox.documentation.spi.DocumentationType;
//import springfox.documentation.spring.web.plugins.Docket;
//import springfox.documentation.swagger2.annotations.EnableSwagger2;
//
//import java.util.Collections;
//
//@Configuration
//@EnableSwagger2
//public class SwaggerConfig {
//
//    @Bean
//    public Docket api() {
//        return new Docket(DocumentationType.OAS_30) // Use OAS_30 for OpenAPI 3.0
//                .select()
//                .apis(RequestHandlerSelectors.basePackage("com.example.UserService.controller"))
//                .build()
//                .apiInfo(apiInfo());
//    }
//
//    private ApiInfo apiInfo() {
//        return new ApiInfo(
//                "User Service API",
//                "API for managing user-related operations",
//                "1.0.0",
//                null,
//                new Contact("Your Name", null, "your.email@example.com"),
//                null,
//                null,
//                Collections.emptyList()
//        );
//    }
//}
