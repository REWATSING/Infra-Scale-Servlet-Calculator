package com.example.calculator;

import javax.servlet.ServletException;
/// import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;

/** @WebServlet("/health") **/ // Use this if NOT using web.xml
public class HealthCheckServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setStatus(HttpServletResponse.SC_OK);
        response.setContentType("text/plain");

        try (PrintWriter out = response.getWriter()) {
            out.println("OK");
        }
    }
}
