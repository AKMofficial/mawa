package com.mawa;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class MawaApplication {

    public static void main(String[] args) {
        SpringApplication.run(MawaApplication.class, args);
        System.out.println(" Mawa Backend is running on http://localhost:8080 Alhamdulillah");
    }
}