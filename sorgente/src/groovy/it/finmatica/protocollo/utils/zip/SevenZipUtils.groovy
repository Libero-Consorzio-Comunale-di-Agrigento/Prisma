package it.finmatica.protocollo.utils.zip

import net.sf.sevenzipjbinding.ISequentialOutStream
import net.sf.sevenzipjbinding.SevenZip
import net.sf.sevenzipjbinding.SevenZipException
import net.sf.sevenzipjbinding.impl.InArchiveImpl
import net.sf.sevenzipjbinding.impl.RandomAccessFileInStream
import net.sf.sevenzipjbinding.simple.ISimpleInArchiveItem
import org.apache.commons.io.FileUtils
import org.apache.commons.io.IOUtils

class SevenZipUtils {

    private File tmpUnzipFile;

    /**
     * Restituisce la lista dei file contenuti nello zip
     * Se presenti dei folder, il nome della cartella precederà
     * i nomi dei file che essa contiene, separato con l'apposito parametro
     * */
    public List<String> flatUnzipFile(File fileZip, String pathSeparator) {
        List<String> listaFile = new ArrayList<String>()
        RandomAccessFile randomAccessFile = new RandomAccessFile(fileZip, "r");
        InArchiveImpl inArchive = SevenZip.openInArchive(null, new RandomAccessFileInStream(randomAccessFile))

        for (ISimpleInArchiveItem item : inArchive.getSimpleInterface().getArchiveItems()) {
            if (item.isFolder()) {
                continue
            }

            String nomeItem
            nomeItem = item.getPath()
            if (pathSeparator != null) {
                nomeItem = nomeItem.replaceAll("\\\\", pathSeparator)
            }

            listaFile.add(nomeItem)
        }

        inArchive.close()
        randomAccessFile.close()

        return listaFile
    }

    /**
     * Estrae dallo zip una mappa <nomeOriginale,fileEstratto> per ogni nomeOriginale contenuto nel parametro nomiFile
     * il pathSeparator serve per conoscere il "flatname" dato ai file che sono contenuti
     * dentro le directory
     * */
    public Map<String, File> extractFromZipFile(File fileZip, List<String> nomiFile, String pathSeparator) {
        Map<String, File> mappaFile = new HashMap<String, File>()
        RandomAccessFile randomAccessFile = new RandomAccessFile(fileZip, "r");
        InArchiveImpl inArchive = SevenZip.openInArchive(null, new RandomAccessFileInStream(randomAccessFile))

        try {
            for (ISimpleInArchiveItem item : inArchive.getSimpleInterface().getArchiveItems()) {
                if (item.isFolder()) {
                    continue
                }

                String nomeItem
                nomeItem = item.getPath()
                if (pathSeparator != null) {
                    nomeItem = nomeItem.replaceAll("\\\\", pathSeparator)
                }

                if (nomiFile.contains(nomeItem)) {
                    tmpUnzipFile = java.io.File.createTempFile("tempUnzipfile", "");
                    InputStream isFile = getItemInputStream(item)
                    mappaFile.put(nomeItem,new File(tmpUnzipFile.getAbsolutePath()))
                }
            }
        }
        catch (Exception e) {
            //Qualsiasi sia l'eccezione cancello tutti i file temporanei già creati e pulisco la lista
            for (item in mappaFile) {
                FileUtils.deleteQuietly(item.getKey())
            }
            mappaFile.clear()
            throw e
        }

        inArchive.close()
        randomAccessFile.close()

        return mappaFile
    }

    private InputStream getItemInputStream(ISimpleInArchiveItem item) throws SevenZipException {
        FileOutputStream out = new FileOutputStream(tmpUnzipFile)
        item.extractSlow(new ISequentialOutStream() {
            @Override
            public int write(byte[] data) throws SevenZipException {
                IOUtils.copy(new ByteArrayInputStream(data), out)
                return data.length;
            }
        });
        out.close()

        return null;
    }
}
