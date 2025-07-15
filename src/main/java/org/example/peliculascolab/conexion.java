package org.example.peliculascolab;

import java.sql.*;
import java.util.Properties;

public class conexion {
    // Variables de conexión
    private static final String WALLET_PATH = "G:\\1-UTEZ\\3-Cuatrimestre\\POO\\Trabajos\\Semana11\\BaseDatosJavaFX\\src\\Wallet";
    private static final String JDBC_URL = "jdbc:oracle:thin:@icl8aqfau8e0bzlc_high";
    private static final String USERNAME = "ADMIN";
    private static final String PASSWORD = "Biblioteca01";

    // Método para obtener conexión
    public static Connection getConnection() throws SQLException {
        try {
            // Configurar propiedades para la conexión
            Properties props = new Properties();
            props.put("user", USERNAME);
            props.put("password", PASSWORD);
            props.put("oracle.net.tns_admin", WALLET_PATH);
            props.put("oracle.net.ssl_server_dn_match", "true");
            props.put("oracle.net.ssl_version", "1.2");

            // Registrar el driver
            Class.forName("oracle.jdbc.OracleDriver");

            // Establecer conexión
            Connection connection = DriverManager.getConnection(JDBC_URL, props);
            System.out.println("Conexión exitosa a Oracle Database");
            return connection;
        } catch (ClassNotFoundException e) {
            throw new SQLException("Driver JDBC no encontrado", e);
        } catch (SQLException e) {
            System.err.println("Error al conectar a la base de datos:");
            e.printStackTrace();
            throw new SQLException("No se pudo establecer conexión con la base de datos. Verifique:\n" +
                    "- Credenciales correctas\n" +
                    "- Wallet en la ubicación: " + WALLET_PATH + "\n" +
                    "- Servicio disponible", e);
        }
    }

    // Método para ejecutar consultas y obtener resultados
    public static ResultSet ejecutarConsulta(String query) throws SQLException {
        Connection connection = null;
        Statement stmt = null;
        try {
            connection = getConnection();
            stmt = connection.createStatement();
            return stmt.executeQuery(query);
        } catch (SQLException e) {
            cerrarRecursos(null, stmt, connection);
            throw e;
        }
    }

    // Método para ejecutar operaciones de actualización (INSERT, UPDATE, DELETE)
    public static int ejecutarActualizacion(String sql) throws SQLException {
        Connection connection = null;
        Statement stmt = null;
        try {
            connection = getConnection();
            stmt = connection.createStatement();
            return stmt.executeUpdate(sql);
        } finally {
            cerrarRecursos(null, stmt, connection);
        }
    }

    // Método para cerrar recursos
    public static void cerrarRecursos(ResultSet rs, Statement stmt, Connection conn) {
        try {
            if (rs != null && !rs.isClosed()) rs.close();
        } catch (SQLException e) {
            System.err.println("Error al cerrar ResultSet: " + e.getMessage());
        }
        try {
            if (stmt != null && !stmt.isClosed()) stmt.close();
        } catch (SQLException e) {
            System.err.println("Error al cerrar Statement: " + e.getMessage());
        }
        try {
            if (conn != null && !conn.isClosed()) conn.close();
        } catch (SQLException e) {
            System.err.println("Error al cerrar Connection: " + e.getMessage());
        }
    }
}