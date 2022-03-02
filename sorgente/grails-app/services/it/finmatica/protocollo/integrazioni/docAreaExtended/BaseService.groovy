package it.finmatica.protocollo.integrazioni.docAreaExtended

import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j
import it.finmatica.protocollo.integrazioni.DocAreaExtendedHelperService
import org.apache.commons.lang3.time.DateUtils
import org.apache.commons.lang3.time.FastDateFormat
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

import javax.validation.ValidationException
import javax.xml.bind.JAXBContext

@Transactional
@Service
@Slf4j
@CompileStatic
abstract class BaseService implements DocAreaExtendedService {

    private final String DATE_PATTERN = 'dd/MM/yyyy'
    protected final FastDateFormat dateFormat = FastDateFormat.getInstance(DATE_PATTERN)
    protected final DocAreaExtendedHelperService docAreaExtenedHelperService
    protected JAXBContext jc

    BaseService(DocAreaExtendedHelperService docAreaExtenedHelperService) {
        this.docAreaExtenedHelperService = docAreaExtenedHelperService
        docAreaExtenedHelperService.register(this)
    }

    abstract String getXsdName()

    abstract String execute(String user, Node xml, boolean ignoraCompetenze)

    protected Date getDate(String date) throws ValidationException {
        try {
            if(date) {
                return DateUtils.parseDate(date, DATE_PATTERN)
            } else {
                return null
            }
        } catch (Exception e) {
            throw new ValidationException("Data errata: '${date}'", e)
        }
    }

    protected Date setAtBeginning(Date date) {
        if(date != null) {
            return date.clearTime()
        } else {
            return null
        }
    }

    protected Date setAtEnd(Date date) {
        if(date != null) {
            Calendar cal = Calendar.getInstance()
            cal.time = date
            cal.set(Calendar.HOUR_OF_DAY,23)
            cal.set(Calendar.MINUTE,59)
            cal.set(Calendar.SECOND,59)
            cal.set(Calendar.MILLISECOND,999)
            return cal.time
        } else {
            return null
        }
    }

    protected String toXml(Object result) {
        def res = new StringWriter()
        jc.createMarshaller().marshal(result, res)
        return res.toString()
    }

    protected String formatDate(Date d) {
        return d ? dateFormat.format(d) : ''
    }

    protected Integer getInteger(String num) {
        if(num) {
            return Integer.valueOf(num)
        } else {
            return null
        }
    }

    protected String formatBoolean(boolean value) {
        value ? 'S': 'N'
    }

    protected String toXmlString(Node xml) {
        def text = new StringWriter()
        XmlNodePrinter p = new XmlNodePrinter(new PrintWriter(text))
        p.preserveWhitespace = false
        p.print(xml)
        return text.toString()
    }

    protected Result getErrorResult(String message) {
        Result err = new Result()
        err.RESULT = 'KO'
        err.MESSAGE = message
        return err
    }
}