# PRISMA

Protocollo informatico e flussi documentali

## Descrizione

PRISMA soddisfa i requisiti richiesti e necessari per consentire la protocollazione, la gestione di tutti i processi di inserimento, ricerca, fascicolazione e archiviazione dei documenti in conformità a quanto previsto dal DPR 445/2000, dal DPCM 3/12/2013, dal codice dell’amministrazione digitale e dalle regole tecniche di settore. 

Tale prodotto è realizzato sulle componenti architetturali “struttura organizzativa”, “scrivania virtuale” e “gestione documentale”. 

Il sistema, inoltre, è integrato con le funzionalità di gestione dell’albo on line e del registro delle notifiche.

## Struttura del Repository

Il repository è suddiviso nelle seguente cartelle:

 - source contiene il codice sorgente e le risorse statiche incluse nella webapp.
 - scriptDB contiene gli script PL/SQL per la creazione della struttura dello schema database.
 - diagrammiER contiene i diagrammi Entità-Relazione in formato Portable Document Format (PDF)

## Prerequisiti e dipendenze

### Prerequisiti

- AD4: Amministrazione Database di Finmatica S.p.A.
- SO4: Struttura Amministrativa di Finmatica S.p.A.
- AS4: Anagrafe Soggetti di Finmatica S.p.A.
- GDM: Gestione Documentale Modulistica di Finmatica S.p.A.
- Si4CS: Smart Communicator System di Finmatica S.p.A.
- JSign: Firma Digitale di Finmatica S.p.A.
- SmartDesktop: Scrivania Virtuale di Finmatica S.p.A.
- Java JDK versione 7 o superiore
- Apache Tomcat versione 7 o superiore
- Database Oracle versione 10 o superiore

### Dipendenze
- Apache ANT versione 1.6 o superiore per la compilazione dei sorgenti
- Libreria ojdbc.jar driver oracle per Java di Oracle

## Istruzioni per l’installazione:
- Lanciare gli script della cartella scriptDB per generate lo schema e popolare i dati
- Lanciare il comando ant dalla cartella sorgenti per generare la webapp e copiare i file nel contesto di
tomcat.

## Stato del progetto
Stabile

## Amministrazione committente
Libero Consorzio Comunale di Agrigento

## Incaricati del mantenimento del progetto open source
Finmatica S.p.A. Via della Liberazione, 15 40128 Bologna

## Indirizzo e-mail a cui inviare segnalazioni di sicurezza
sicurezza@ads.it
