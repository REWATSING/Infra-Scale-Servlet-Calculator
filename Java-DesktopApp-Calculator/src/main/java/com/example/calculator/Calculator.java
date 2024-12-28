package com.example.calculator;

// Java Swing Calculator Desktop Application
import javax.swing.*;
import java.awt.*;
import java.awt.event.*;

public class Calculator {

    private JFrame frame;
    private JTextField textField;
    private String operator = "";
    private double num1, num2, result;

    public Calculator() {
        frame = new JFrame("Calculator");
        textField = new JTextField();
        textField.setBounds(30, 40, 280, 30);
        textField.setHorizontalAlignment(SwingConstants.RIGHT);
        textField.setEditable(false);

        JButton[] numberButtons = new JButton[10];
        for (int i = 0; i < 10; i++) {
            numberButtons[i] = new JButton(String.valueOf(i));
            numberButtons[i].addActionListener(new NumberAction());
        }

        JButton addButton = new JButton("+");
        JButton subButton = new JButton("-");
        JButton mulButton = new JButton("*");
        JButton divButton = new JButton("/");
        JButton eqButton = new JButton("=");
        JButton clrButton = new JButton("C");

        addButton.addActionListener(new OperatorAction());
        subButton.addActionListener(new OperatorAction());
        mulButton.addActionListener(new OperatorAction());
        divButton.addActionListener(new OperatorAction());
        eqButton.addActionListener(e -> evaluate());
        clrButton.addActionListener(e -> clear());

        JPanel panel = new JPanel();
        panel.setBounds(30, 80, 280, 300);
        panel.setLayout(new GridLayout(4, 4, 10, 10));

        panel.add(numberButtons[7]);
        panel.add(numberButtons[8]);
        panel.add(numberButtons[9]);
        panel.add(divButton);
        panel.add(numberButtons[4]);
        panel.add(numberButtons[5]);
        panel.add(numberButtons[6]);
        panel.add(mulButton);
        panel.add(numberButtons[1]);
        panel.add(numberButtons[2]);
        panel.add(numberButtons[3]);
        panel.add(subButton);
        panel.add(numberButtons[0]);
        panel.add(clrButton);
        panel.add(eqButton);
        panel.add(addButton);

        frame.add(textField);
        frame.add(panel);
        frame.setSize(350, 450);
        frame.setLayout(null);
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setVisible(true);
    }

    private class NumberAction implements ActionListener {
        @Override
        public void actionPerformed(ActionEvent e) {
            String input = e.getActionCommand();
            textField.setText(textField.getText() + input);
        }
    }

    private class OperatorAction implements ActionListener {
        @Override
        public void actionPerformed(ActionEvent e) {
            operator = e.getActionCommand();
            num1 = Double.parseDouble(textField.getText());
            textField.setText("");
        }
    }

    private void evaluate() {
        num2 = Double.parseDouble(textField.getText());
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
                result = num2 != 0 ? num1 / num2 : 0;
                break;
        }
        textField.setText(String.valueOf(result));
    }

    private void clear() {
        textField.setText("");
        num1 = num2 = result = 0;
        operator = "";
    }

    public static void main(String[] args) {
        new Calculator();
    }
}
