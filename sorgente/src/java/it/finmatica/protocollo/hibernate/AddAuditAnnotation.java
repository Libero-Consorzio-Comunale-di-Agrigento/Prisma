package it.finmatica.protocollo.hibernate;

import javassist.CannotCompileException;
import javassist.ClassClassPath;
import javassist.ClassPool;
import javassist.CtClass;
import javassist.CtField;
import javassist.NotFoundException;
import javassist.bytecode.AnnotationsAttribute;
import javassist.bytecode.ClassFile;
import javassist.bytecode.ConstPool;
import javassist.bytecode.annotation.Annotation;
import javassist.bytecode.annotation.EnumMemberValue;

/**
 * Questa classe orribile serve perché con Envers non è possibile aggiungere programmaticamente delle nuove domain-class
 * al log ma è possibile aggiungerle solo con @Audit.
 *
 * Siccome molte domain derivano da Jar (ad es quelle di gestione-documenti), utilizzo Javassist per aggiungere a
 * runtime le annotation necessarie in modo che envers venga configurato correttamente.
 */
public class AddAuditAnnotation {

    public static void addAuditAnnotations() throws Exception {

        new AuditEnhancer("it.finmatica.gestioneiter.motore.WkfIter")
            .addAuditToClass()
            .logOnlyValue("utenteIns")
            .logOnlyValue("utenteUpd")
            .logOnlyValue("stepCorrente")
            .logOnlyValue("ente")
            .logOnlyValue("cfgIter")
            .build();

        new AuditEnhancer("it.finmatica.gestionedocumenti.commons.AbstractDomain")
            .addAuditToClass()
            .logOnlyValue("utenteIns")
            .logOnlyValue("utenteUpd")
            .build();

        new AuditEnhancer("it.finmatica.gestionedocumenti.commons.AbstractDomainMultiEnte")
            .addAuditToClass()
            .logOnlyValue("ente")
            .build();

        new AuditEnhancer("it.finmatica.gestionedocumenti.documenti.FileDocumento")
            .addAuditToClass()
            .logOnlyValue("modelloTesto")
            .noAudit("firmatari")
            // non voglio più loggare la revisione perché la vado ad impostare "a mano" con la classe RevisioneStoricoPostUpdateEnversListenerImpl
            .noAudit("revisione")
            .build();

        new AuditEnhancer("it.finmatica.gestionedocumenti.documenti.Documento")
            .addAuditToClass()
            .logOnlyValue("iter")
            .logOnlyValue("tipoOggetto")
            .noAudit("soggetti")
            .build();

        new AuditEnhancer("it.finmatica.gestionedocumenti.soggetti.DocumentoSoggetto")
            .addAuditToClass()
            .logOnlyValue("unitaSo4")
            .logOnlyValue("utenteAd4")
            .build();

        new AuditEnhancer("it.finmatica.gestionedocumenti.documenti.Allegato")
            .addAuditToClass()
            .logOnlyValue("tipoAllegato")
            .build();

        new AuditEnhancer("it.finmatica.gestionedocumenti.documenti.DocumentoCollegato")
            .addAuditToClass()
            .logOnlyValue("tipoCollegamento")
            .build();
    }

    static class AuditEnhancer {

        private final CtClass ctClass;
        private final ClassPool pool;
        private final ClassFile classFile;
        private final ConstPool constPool;

        public AuditEnhancer(String className) throws NotFoundException {
            pool = ClassPool.getDefault();
            pool.appendClassPath(new ClassClassPath(AddAuditAnnotation.class));
            ctClass = pool.get(className);
            classFile = ctClass.getClassFile();
            constPool = classFile.getConstPool();
        }

        public AuditEnhancer addAuditToClass() {
            AnnotationsAttribute attr = (AnnotationsAttribute) classFile.getAttribute(AnnotationsAttribute.visibleTag);
            if (attr == null) {
                attr = new AnnotationsAttribute(constPool, AnnotationsAttribute.visibleTag);
            }

            Annotation newAnnotation = new Annotation("org.hibernate.envers.Audited", constPool);
            attr.addAnnotation(newAnnotation);

            ctClass.getClassFile().addAttribute(attr);

            return this;
        }

        public AuditEnhancer logOnlyValue(String fieldName) throws NotFoundException, ClassNotFoundException {
            CtField field = ctClass.getField(fieldName);
            AnnotationsAttribute attr = (AnnotationsAttribute) field.getFieldInfo()
                .getAttribute(AnnotationsAttribute.visibleTag);

            if (attr == null) {
                attr = new AnnotationsAttribute(constPool, AnnotationsAttribute.visibleTag);
            }

            Annotation auditAnnotation = new Annotation("org.hibernate.envers.Audited", constPool);
            EnumMemberValue emv = new EnumMemberValue(constPool);
            emv.setType("org.hibernate.envers.RelationTargetAuditMode");
            emv.setValue("NOT_AUDITED");
            auditAnnotation.addMemberValue("targetAuditMode", emv);
            attr.addAnnotation(auditAnnotation);
            field.getFieldInfo().addAttribute(attr);
            return this;
        }

        public Class build() throws CannotCompileException {
            return ctClass.toClass();
        }

        public AuditEnhancer noAudit(String fieldName) throws NotFoundException {
            CtField field = ctClass.getField(fieldName);
            AnnotationsAttribute attr = (AnnotationsAttribute) field.getFieldInfo()
                .getAttribute(AnnotationsAttribute.visibleTag);

            if (attr == null) {
                attr = new AnnotationsAttribute(constPool, AnnotationsAttribute.visibleTag);
            }

            Annotation auditAnnotation = new Annotation("org.hibernate.envers.NotAudited", constPool);
            attr.addAnnotation(auditAnnotation);
            field.getFieldInfo().addAttribute(attr);
            return this;
        }
    }
}
