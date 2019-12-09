package org.dspace.statistics.util;

import com.google.gson.Gson;
import com.google.gson.annotations.SerializedName;
import org.apache.commons.cli.*;
import org.apache.log4j.Logger;
import org.dspace.core.Context;

import java.io.*;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.TreeMap;
import org.dspace.services.ConfigurationService;
import org.dspace.utils.DSpace;

public class GeoSolrExport {
    private final Logger log = Logger.getLogger(GeoSolrExport.class);

    private static ConfigurationService config = new DSpace().getConfigurationService();
    Gson gson = new Gson();
    private List<GeoMapData> geos = new ArrayList<>();

    public static void main(String[] args) throws SQLException, FileNotFoundException, IOException
    {
        CommandLineParser parser = new PosixParser();

        Options options = new Options();

        options.addOption("i", "in", true, "source file ('-' or omit for standard input)");

        CommandLine line;
        try
        {
            line = parser.parse(options, args);
        }
        catch (ParseException pe)
        {
            System.err.println("Error parsing command line arguments: " + pe.getMessage());
            System.exit(1);
            return;
        }

        Context context = new Context();
        context.turnOffAuthorisationSystem();
        GeoSolrExport gse = new GeoSolrExport();

        String itemViewFile = "item-view.json";
        String itemFile = "items.json";
        String collectionFile = "collections.json";

        List<ItemViewRecord> views = gse.getItemViewFromJson(itemViewFile);
        List<ItemRecord> its = gse.getItemFromJson(itemFile);
        List<CollectionRecord> cols = gse.getCollectionFromJson(collectionFile);

//        List<ItemViewRecord> filteredViews = gse.filterItemView(views);
        List<GeoMapData> lgmd = new ArrayList<>();

        for(ItemViewRecord view : views) {
            GeoMapData gmd = new GeoMapData();
            String city = view.getCity();
            if(city == null) {
                city = "undefined";
            }
            gmd.setCity(city);
            gmd.setIp(view.getIp());
            String cc = view.getCountryCode();
            String countryName = LocationUtils.getCountryName(view.getCountryCode(), Locale.getDefault());
            if(cc.equalsIgnoreCase("tw")) {
                cc = "CN";
                countryName = countryName + ", China";
            }
            if(cc.equalsIgnoreCase("hk")) {
                countryName = countryName + ", China";
            }
            if(cc.equalsIgnoreCase("mo")) {
                countryName = countryName + ", China";
            }
            gmd.setCountryCode(cc);
            gmd.setCountryName(countryName);
            gmd.setLatitude(view.getLatitude());
            gmd.setLongitude(view.getLongitude());
            gmd.setTime(view.getTime());
            Map<String, Object> itemData = gse.getItemInfo(view.getId(),its);
            gmd.setItemTitles((List<String>)itemData.get("titles"));
            gmd.setAuthors((List<String>)itemData.get("authors"));
            gmd.setItemUrls((List<String>)itemData.get("uris"));
            List<String> collectionTitles = gse.getCollectionTitles(view.getOwningColl(),cols);
            gmd.setCollectionTitles(collectionTitles);
            lgmd.add(gmd);
        }
        String jsonString = gse.toJson(lgmd);

        String savedFileName = "geos.json";
        gse.writeGeoMapData(gse.getFilePath(savedFileName), jsonString);
    }

    public List<ItemViewRecord> getItemViewFromJson(String in) throws FileNotFoundException, IOException {
        Reader reader = new FileReader(getFilePath(in));
        ResponseItemView riv = gson.fromJson(reader, ResponseItemView.class);
        ResponseItemViewRecord rivObject = riv.getResponse();
        List<ItemViewRecord> views = rivObject.getDocs();
        reader.close();

        return views;
    }

    public List<ItemRecord> getItemFromJson(String in) throws FileNotFoundException, IOException {
        Reader reader = new FileReader(getFilePath(in));
        ResponseItem ri = gson.fromJson(reader, ResponseItem.class);
        ResponseItemRecord rirObject = ri.getResponse();
        List<ItemRecord> items = rirObject.getDocs();
        reader.close();

        return items;
    }

    public List<CollectionRecord> getCollectionFromJson(String in) throws FileNotFoundException, IOException {
        Reader reader = new FileReader(getFilePath(in));
        ResponseCollection rc = gson.fromJson(reader, ResponseCollection.class);
        ResponseCollectionRecord rcrObject = rc.getResponse();
        List<CollectionRecord> collections = rcrObject.getDocs();
        reader.close();

        return collections;
    }

    protected String getFilePath (String in) {
        File baseDir = ensureGeosDir();
        return baseDir.getAbsolutePath() + "/" + in;
    }

    // Remove repeated views from same IP and item
    protected List<ItemViewRecord> filterItemView(List<ItemViewRecord> views) {
        List<ItemViewRecord> list = new ArrayList<>();
        Map<String, String> items = new TreeMap<>();
        for(ItemViewRecord ivr : views) {
            String ip = ivr.getIp();
            int id = ivr.getId();
            String key = ip + ":" + Integer.toString(id);
            if(items.get(key) == null) {
                items.put(key, ip);
                list.add(ivr);
            }
        }
        
        return list;
    }

    public void writeGeoMapData(String outFile, String jsonString) {
        try 
        {
            BufferedWriter out = new BufferedWriter(new FileWriter(outFile));
            out.write(jsonString);
            out.flush();
            out.close();
        } 
        catch (IOException e) 
        {
            System.out.println("Unable to write to output file " + outFile);
            System.exit(0);
        }

    }

    public String toJson(List<GeoMapData> lgmd) {
        Gson gson = new Gson();
        return gson.toJson(lgmd);
    }    

    private Map<String, Object> getItemInfo(int id, List<ItemRecord> lir) {
        Map<String, Object> data = new HashMap<>();
        List<String> itemTitles = new ArrayList<>();
        List<String> itemAuthors = new ArrayList<>();
        List<String> itemUris = new ArrayList<>();

        for(ItemRecord ir : lir) {
            int resourceId = ir.getResourceid();
            if(id == resourceId) {
                itemTitles = ir.getTitles();
                itemAuthors = ir.getAuthors();
                itemUris = ir.getUris();
                data.put("titles", itemTitles);
                data.put("authors", itemAuthors);
                data.put("uris", itemUris);
                break;
            }
        }
        return data;
    }

    private List<String> getCollectionTitles(List<Integer> owningCol, List<CollectionRecord> lcr) {
        List<String> collectionTitles = new ArrayList<>();
        for(int colId : owningCol) {
            for(CollectionRecord cr : lcr) {
                int resourceId = cr.getResourceid();
                if(colId == resourceId) {
                    collectionTitles.addAll(cr.getTitles());
                    break;
                }
            }
             
        }
        return collectionTitles;
    } 


    protected File ensureGeosDir() {
        String dir = config.getProperty("geo.json.dir");
        File baseDir = new File(dir);
        if (!baseDir.exists() && !baseDir.mkdirs()) {
            throw new IllegalStateException("Unable to create directories");
        }

        return baseDir;
    }

    public class ResponseItemView {
        private ResponseItemViewRecord response;

        public ResponseItemViewRecord getResponse() {
            return response;
        }
    }

    public class ResponseItemViewRecord {
        private String numFound;
        private String start;
        List<ItemViewRecord> docs;

        public List<ItemViewRecord> getDocs() {
            return docs;
        }
    }

    public class ItemViewRecord {

        private int id;
        private String ip;
        private String latitude;
        private String longitude;
        private String time;
        private String city;
        private String countryCode;
        private List<Integer> owningColl;

        public int getId() {
            return id;
        }

        public void setId(int id) {
            this.id = id;
        }

        public String getIp() {
            return ip;
        }

        public void setIp(String ip) {
            this.ip = ip;
        }

        public String getLatitude() {
            return latitude;
        }

        public void setLatitude(String latitude) {
            this.latitude = latitude;
        }

        public String getLongitude() {
            return longitude;
        }

        public void setLongitude(String longitude) {
            this.longitude = longitude;
        }

        public String getTime() {
            return time;
        }

        public void setTime(String time) {
            this.time = time;
        }

        public String getCity() {
            return city;
        }

        public void setCity(String city) {
            this.city = city;
        }

        public String getCountryCode() {
            return countryCode;
        }

        public void setCountryCode(String countryCode) {
            this.countryCode = countryCode;
        }

        public List<Integer> getOwningColl() {
            return owningColl;
        }

        public void setOwningColl(List<Integer> owningColl) {
            this.owningColl = owningColl;
        }

    }

    public class ResponseCollection {
        private ResponseCollectionRecord response;

        public ResponseCollectionRecord getResponse() {
            return response;
        }

    }

    public class ResponseCollectionRecord {
        private String numFound;
        private String start;
        List<CollectionRecord> docs;

        public List<CollectionRecord> getDocs() {
            return docs;
        }

    }

    public class CollectionRecord {
        @SerializedName("search.resourceid")
        private int resourceid;
        private String handle;
        @SerializedName("dc.title")
        private List<String> titles;

        public int getResourceid() {
            return resourceid;
        }

        public void setResourceid(int resourceid) {
            this.resourceid = resourceid;
        }

        public String getHandle() {
            return handle;
        }

        public void setHandle(String handle) {
            this.handle = handle;
        }

        public List<String> getTitles() {
            return titles;
        }

        public void setTitles(List<String> titles) {
            this.titles = titles;
        }
    }

    public class ResponseItem {
        private ResponseItemRecord response;

        public ResponseItemRecord getResponse() {
            return response;
        }
    }

    public class ResponseItemRecord {
        private String numFound;
        private String start;
        List<ItemRecord> docs;

        public List<ItemRecord> getDocs() {
            return docs;
        }
    }

    public class ItemRecord {
        @SerializedName("dc.contributor.author")
        private List<String> authors;
        @SerializedName("dc.title")
        private List<String> titles;
        @SerializedName("search.resourceid")
        private int resourceid;
        @SerializedName("dc.identifier.uri")
        private List<String> uris;
        @SerializedName("dc.creator")
        private List<String> creators;

        public List<String> getAuthors() {
            return authors;
        }

        public void setAuthors(List<String> authors) {
            this.authors = authors;
        }

        public List<String> getTitles() {
            return titles;
        }

        public void setTitles(List<String> titles) {
            this.titles = titles;
        }

        public int getResourceid() {
            return resourceid;
        }

        public void setResourceid(int resourceid) {
            this.resourceid = resourceid;
        }

        public List<String> getUris() {
            return uris;
        }

        public void setUris(List<String> uris) {
            this.uris = uris;
        }

        public List<String> getCreators() {
            return creators;
        }

        public void setCreators(List<String> creators) {
            this.creators = creators;
        }
    }

    public static class GeoMapData {
        private String latitude;
        private String longitude;
        private String time;
        private String ip;
        private String city;
        private String countryCode;
        private String countryName;
        private List<String> itemUrls;
        private List<String> itemTitles;
        private List<String> authors; 
        private List<String> collectionTitles;

//        "time": "1570981671",

        public GeoMapData() {
        }

        public String getLatitude() {
            return latitude;
        }

        public void setLatitude(String latitude) {
            this.latitude = latitude;
        }

        public String getLongitude() {
            return longitude;
        }

        public void setLongitude(String longitude) {
            this.longitude = longitude;
        }

        public String getTime() {
            return time;
        }

        public void setTime(String time) {
            this.time = time;
        }

        public String getIp() {
            return ip;
        }

        public void setIp(String ip) {
            this.ip = ip;
        }

        public String getCity() {
            return city;
        }

        public void setCity(String city) {
            this.city = city;
        }

        public String getCountryCode() {
            return countryCode;
        }

        public void setCountryCode(String countryCode) {
            this.countryCode = countryCode;
        }

        public String getCountryName() {
            return countryName;
        }

        public void setCountryName(String countryName) {
            this.countryName = countryName;
        }

        public List<String> getItemUrls() {
            return itemUrls;
        }

        public void setItemUrls(List<String> itemUrls) {
            this.itemUrls = itemUrls;
        }

        public List<String> getItemTitles() {
            return itemTitles;
        }

        public void setItemTitles(List<String> itemTitles) {
            this.itemTitles = itemTitles;
        }

        public List<String> getAuthors() {
            return authors;
        }

        public void setAuthors(List<String> authors) {
            this.authors = authors;
        }

        public List<String> getCollectionTitles() {
            return collectionTitles;
        }

        public void setCollectionTitles(List<String> collectionTitles) {
            this.collectionTitles = collectionTitles;
        }

    }
}
