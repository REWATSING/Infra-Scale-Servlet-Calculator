package com.example.calculator;

import javax.servlet.ServletException;
// import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;

/** @WebServlet("/calculate") **/ // Use this if NOT using web.xml
public class CalculatorServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html");

        double num1, num2;
        try {
            num1 = Double.parseDouble(request.getParameter("num1"));
            num2 = Double.parseDouble(request.getParameter("num2"));
        } catch (NumberFormatException | NullPointerException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid input: Please enter valid numbers.");
            return;
        }

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
                if (num2 == 0) {
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Cannot divide by zero.");
                    return;
                }
                result = num1 / num2;
                break;
            default:
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid operator.");
                return;
        }

        try (PrintWriter out = response.getWriter()) {
            out.println("<h1>Result: " + result + "</h1>");
            out.println("<a href='index.jsp'>Back to Calculator</a>");
        }
    }
}
