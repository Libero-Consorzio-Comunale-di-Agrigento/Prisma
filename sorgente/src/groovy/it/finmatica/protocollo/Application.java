package it.finmatica.protocollo;

import groovy.transform.CompileStatic;
import it.finmatica.protocollo.hibernate.AddAuditAnnotation;
import java.io.File;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.context.embedded.ConfigurableEmbeddedServletContainer;
import org.springframework.boot.context.embedded.EmbeddedServletContainerCustomizer;
import org.springframework.boot.web.support.SpringBootServletInitializer;

@CompileStatic
@SpringBootApplication
public class Application extends SpringBootServletInitializer implements EmbeddedServletContainerCustomizer {

    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
        return application.sources(Application.class);
    }

    public static void main(String[] args) throws Exception {

        AddAuditAnnotation.addAuditAnnotations();

        SpringApplication.run(Application.class, args);
    }

    @Override
    public void customize(ConfigurableEmbeddedServletContainer container) {
        container.setDocumentRoot(new File("web-app"));
    }

    @Override
    public void onStartup(ServletContext servletContext) throws ServletException {
        try {
            AddAuditAnnotation.addAuditAnnotations();
        } catch (Exception e) {
            logger.error("Impossibile avviare envers",e);
        }
        super.onStartup(servletContext);
    }
}
