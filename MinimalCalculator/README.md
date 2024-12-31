# Minimal Calculator Application

This is a minimal Java servlet-based calculator application for basic arithmetic operations.

## Features
- Add, subtract, multiply, divide two numbers
- Deployed on Tomcat, CI/CD with GitHub Actions, and hosted on AWS EC2

## Project Structure
```
MinimalCalculator
├── README.md
├── pom.xml
└── src
    └── main
        ├── java
        │   └── com
        │       └── example
        │           └── calculator
        │               └── CalculatorServlet.java
        └── webapp
            ├── WEB-INF
            │   └── web.xml
            └── index.jsp

8 directories, 5 files
```

## Deployment
1. Configure your AWS EC2 credentials as GitHub secrets.
2. Push changes to the main branch, and the app will deploy automatically.
