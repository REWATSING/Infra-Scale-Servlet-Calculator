#!/bin/bash

# Project structure
PROJECT_NAME="MinimalCalculator"
SRC_DIR="$PROJECT_NAME/src/main/java/com/example/calculator"
WEBAPP_DIR="$PROJECT_NAME/src/main/webapp/WEB-INF"
GITHUB_WORKFLOW_DIR="$PROJECT_NAME/.github/workflows"

# Create directories
echo "Creating project structure..."
mkdir -p "$SRC_DIR" "$WEBAPP_DIR" "$PROJECT_NAME/src/main/webapp" "$GITHUB_WORKFLOW_DIR"

# Create CalculatorServlet.java
echo "Creating CalculatorServlet.java..."
cat > "$SRC_DIR/CalculatorServlet.java" <<EOL
package com.example.calculator;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/calculate")
public class CalculatorServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html");

        double num1 = Double.parseDouble(request.getParameter("num1"));
        double num2 = Double.parseDouble(request.getParameter("num2"));
        String operator = request.getParameter("operator");

        double result;
        switch (operator) {
            case "+":
                result = num1 + num2;
                break;
            case "-":
                result = num1 - num2;
                break;
            case "*":
                result = num1 * num2;
                break;
            case "/":
                result = num1 / num2;
                break;
            default:
                throw new IllegalArgumentException("Invalid operator");
        }

        PrintWriter out = response.getWriter();
        out.println("<h1>Result: " + result + "</h1>");
        out.println("<a href='index.jsp'>Back to Calculator</a>");
    }
}
EOL

# Create web.xml
echo "Creating web.xml..."
cat > "$WEBAPP_DIR/web.xml" <<EOL
<web-app xmlns="http://java.sun.com/xml/ns/javaee" version="3.0">
    <servlet>
        <servlet-name>CalculatorServlet</servlet-name>
        <servlet-class>com.example.calculator.CalculatorServlet</servlet-class>
    </servlet>
    <servlet-mapping>
        <servlet-name>CalculatorServlet</servlet-name>
        <url-pattern>/calculate</url-pattern>
    </servlet-mapping>
</web-app>
EOL

# Create index.jsp
echo "Creating index.jsp..."
cat > "$PROJECT_NAME/src/main/webapp/index.jsp" <<EOL
<!DOCTYPE html>
<html>
<head>
    <title>Calculator</title>
</head>
<body>
    <h1>Calculator</h1>
    <form method="post" action="calculate">
        <input type="number" name="num1" placeholder="Enter number 1" required>
        <select name="operator">
            <option value="+">+</option>
            <option value="-">-</option>
            <option value="*">*</option>
            <option value="/">/</option>
        </select>
        <input type="number" name="num2" placeholder="Enter number 2" required>
        <button type="submit">Calculate</button>
    </form>
</body>
</html>
EOL

# Create pom.xml
echo "Creating pom.xml..."
cat > "$PROJECT_NAME/pom.xml" <<EOL
<project xmlns="http://maven.apache.org/POM/4.0.0">
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.example</groupId>
    <artifactId>MinimalCalculator</artifactId>
    <version>1.0-SNAPSHOT</version>
    <packaging>war</packaging>

    <dependencies>
        <dependency>
            <groupId>javax.servlet</groupId>
            <artifactId>javax.servlet-api</artifactId>
            <version>4.0.1</version>
            <scope>provided</scope>
        </dependency>
    </dependencies>

    <build>
        <finalName>MinimalCalculator</finalName>
    </build>
</project>
EOL

# Create GitHub Actions workflow file
echo "Creating GitHub Actions workflow..."
cat > "$GITHUB_WORKFLOW_DIR/deploy.yml" <<EOL
name: Deploy to EC2

on:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Set up JDK
        uses: actions/setup-java@v3
        with:
          java-version: '11'

      - name: Build with Maven
        run: mvn package

      - name: Upload artifact
        uses: actions/upload-artifact@v3
        with:
          name: calculator-app
          path: target/MinimalCalculator.war

  deploy:
    runs-on: ubuntu-latest
    needs: build

    steps:
      - name: Download artifact
        uses: actions/download-artifact@v3
        with:
          name: calculator-app

      - name: Deploy to EC2
        env:
          EC2_USER: \${{ secrets.EC2_USER }}
          EC2_HOST: \${{ secrets.EC2_HOST }}
          EC2_KEY: \${{ secrets.EC2_KEY }}
        run: |
          scp -i \$EC2_KEY MinimalCalculator.war \$EC2_USER@\$EC2_HOST:/home/ubuntu/
          ssh -i \$EC2_KEY \$EC2_USER@\$EC2_HOST <<EOF
          sudo mv /home/ubuntu/MinimalCalculator.war /var/lib/tomcat/webapps/
          sudo systemctl restart tomcat
          EOF
EOL

# Create README.md
echo "Creating README.md..."
cat > "$PROJECT_NAME/README.md" <<EOL
# Minimal Calculator Application

This is a minimal Java servlet-based calculator application for basic arithmetic operations.

## Features
- Add, subtract, multiply, divide two numbers
- Deployed on Tomcat, CI/CD with GitHub Actions, and hosted on AWS EC2

## Project Structure
\`\`\`
$(tree "$PROJECT_NAME")
\`\`\`

## Deployment
1. Configure your AWS EC2 credentials as GitHub secrets.
2. Push changes to the main branch, and the app will deploy automatically.
EOL

# Completion message
echo "Project setup completed! Navigate to the '$PROJECT_NAME' directory to view your files."
