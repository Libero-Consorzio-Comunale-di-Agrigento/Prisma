<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <title>Pagina di amministrazione / assistenza</title>
</head>
<body>

<g:if test="${flash.message}">
    <div class="message" style="display: block">${flash.message}</div>
</g:if>

<g:form controller="admin" action="submit">
    <g:actionSubmit value="Aggiorna Azioni"             action="aggiornaAzioni" />
    <g:actionSubmit value="Elimina Azioni vecchie"      action="eliminaAzioni" />
    <g:actionSubmit value="Aggiorna Tipi Modello Testo" action="aggiornaTipiModelloTesto" />
    <g:actionSubmit value="Attiva JOB Notturno"         action="attivaJob" />
</g:form>

<!-- Correggi azioni -->
<g:form controller="admin">
    <label>Azioni Vecchie in uso:
    <g:select name="azioneVecchia" from="${azioniVecchie}" multiple="true" optionKey="id" optionValue="nome" />
    </label>
    <g:textField name="filtroAzioniNuove" value="${filtroAzioniNuove}"/>
    <g:actionSubmit value="Cerca" action="cercaAzioniNuove"/>
    <g:select name="azioneNuova" from="${azioniNuove}" optionKey="id" optionValue="nome"/>
    <g:actionSubmit value="Sostituisci Vecchie Azioni con Nuova" action="sostituisciVecchioConNuovo"/>
</g:form>
</body>
</html>