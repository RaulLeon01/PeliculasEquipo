package org.example.peliculascolab;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class conexion {
    private static final String WALLET_PATH = "/home/alex/Documentos/Utez/3ro/Poo/BaseDatos/src/Wallet";
    private static final String JDBC_URL = "jdbc:oracle:thin:@icl8aqfau8e0bzlc_high";
    private static final String USERNAME = "ADMIN";
    private static final String PASSWORD = "Biblioteca01";

    static {
        System.setProperty("oracle.net.tns_admin", WALLET_PATH);
    }

    public List<String> obtenerAutores() {
        List<String> autores = new ArrayList<>();

        try {
            Connection conexion = DriverManager.getConnection(JDBC_URL, USERNAME, PASSWORD);
            Statement stmt = conexion.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT * FROM AUTORES");

            while (rs.next()) {
                String autor = rs.getString(1) + " - " + rs.getString(2);
                autores.add(autor);
            }

            rs.close();
            stmt.close();
            conexion.close();

        } catch (Exception e) {
            System.out.println("Error al obtener autores");
            e.printStackTrace();
        }

        return autores;
    }
}

