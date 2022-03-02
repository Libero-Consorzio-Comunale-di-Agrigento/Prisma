package it.finmatica.protocollo.integrazioni

import groovy.transform.CompileStatic
import it.finmatica.protocollo.documenti.ProtocolloStoricoService
import net.sf.jasperreports.engine.JasperCompileManager
import net.sf.jasperreports.engine.JasperFillManager
import net.sf.jasperreports.engine.JasperPrint
import net.sf.jasperreports.engine.JasperReport
import net.sf.jasperreports.engine.export.JRPdfExporter
import net.sf.jasperreports.engine.util.JRLoader
import net.sf.jasperreports.export.SimpleExporterInput
import net.sf.jasperreports.export.SimpleOutputStreamExporterOutput
import org.springframework.stereotype.Service

import javax.servlet.ServletContext
import javax.sql.DataSource
import java.util.concurrent.ConcurrentHashMap

/**
 * Bean per la creazione delle stampe jasper.
 *
 * Compila al volo i jasper se il compilato non viene trovato in cache.
 */
@CompileStatic
@Service
class JasperReportsService {

    // directory in cui si trovano i report
    private static final String REPORT_DIR = "WEB-INF/reports"

    private final ProtocolloStoricoService protocolloStoricoService
    private final ServletContext servletContext
    private final ConcurrentHashMap<String, String> jasperCache
    private final DataSource dataSource

    JasperReportsService(ProtocolloStoricoService protocolloStoricoService, ServletContext servletContext, DataSource dataSource) {
        this.protocolloStoricoService = protocolloStoricoService
        this.servletContext = servletContext
        this.dataSource = dataSource
        this.jasperCache = new ConcurrentHashMap<String, String>()
    }

    void creaStampaRegistroGiornalieroModifiche(Date dal, Date al, OutputStream outputStream) {
        Map<String, Object> parametriReport = [:]
        String reportPath = servletContext.getRealPath("${REPORT_DIR}/registrogiornalieromodifiche")
        parametriReport.REPORT_PATH = reportPath + "/"
        parametriReport.DATA_DA = dal.clearTime().format("dd/MM/yyyy")
        parametriReport.DATA_A = al.clearTime().format("dd/MM/yyyy")

        creaStampaJasperPdf("${reportPath}/registro_giornaliero_modifiche.jrxml", parametriReport, outputStream)
    }

    private void creaStampaJasperPdf(String jrxmlAbsolutePath, Map<String, Object> parametriReport, OutputStream outputStream) {
        JasperReport report = loadJasper(jrxmlAbsolutePath)
        JasperPrint print = JasperFillManager.fillReport(report, parametriReport, dataSource.getConnection())

        JRPdfExporter pdfExporter = new JRPdfExporter()
        pdfExporter.setExporterInput(new SimpleExporterInput(print))
        pdfExporter.setExporterOutput(new SimpleOutputStreamExporterOutput(outputStream))
        pdfExporter.exportReport()
    }

    private JasperReport loadJasper(String jrxmlAbsolutePath) {

        // normalizzo il path:
        String normalizedPath = new File(jrxmlAbsolutePath).getAbsolutePath()

        // cerco il report nella cache:
        // nota bene: cercando prima nella cache, significa che se anche il file è già presente su filesystem,
        // il report viene ricompilato ad ogni riavvio di tomcat.
        String jasperAbsolutePath = jasperCache.get(normalizedPath)

        // se trovo il jasper nella cache, ritorno la stampa già pronta:
        if (jasperAbsolutePath != null) {

            // mi assicuro che il file esista
            File jasperFile = new File(jasperAbsolutePath)
            if (jasperFile.exists()) {
                return (JasperReport) JRLoader.loadObject(jasperFile)
            }
        }

        // altrimenti compilo tutti i jasper
        // se il file non esiste, ricompilo tutti i jasper presenti nella directory:
        File jrxmlDirectory = new File(jrxmlAbsolutePath).getParentFile()
        List<File> jrxmls = Arrays.asList(jrxmlDirectory.listFiles(new FilenameFilter() {
            @Override
            boolean accept(File dir, String name) {
                return name.endsWith(".jrxml")
            }
        }))

        for (File jrxmlFile : jrxmls) {
            File jasperFile = new File(jrxmlFile.parentFile, jrxmlFile.name.substring(0, jrxmlFile.name.length() - 6) + ".jasper")
            JasperCompileManager.compileReportToFile(jrxmlFile.absolutePath, jasperFile.absolutePath)
            jasperCache.put(jrxmlFile.absolutePath, jasperFile.absolutePath)
        }

        jasperAbsolutePath = jasperCache.get(normalizedPath)
        return (JasperReport) JRLoader.loadObject(new File(jasperAbsolutePath))
    }
}
