module org.example.peliculascolab {
    requires javafx.controls;
    requires javafx.fxml;

    requires org.controlsfx.controls;
    requires com.dlsc.formsfx;
    requires org.kordamp.bootstrapfx.core;

    opens org.example.peliculascolab to javafx.fxml;
    exports org.example.peliculascolab;
    requires java.sql;
}