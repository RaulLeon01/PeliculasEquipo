package org.example.peliculascolab;

import javafx.fxml.FXML;
import javafx.scene.control.Label;

public class RegistroController {
    @FXML
    private Label welcomeText;

    @FXML
    protected void onHelloButtonClick() {
        welcomeText.setText("Welcome to JavaFX Application!");
    }
}