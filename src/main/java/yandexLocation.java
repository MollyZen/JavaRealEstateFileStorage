import jakarta.json.Json;
import jakarta.json.JsonObject;
import jakarta.json.JsonReader;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import static jakarta.ws.rs.core.HttpHeaders.USER_AGENT;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.io.StringReader;
import java.net.HttpURLConnection;
import java.net.URL;

//небольшая обёртка для сервисов геолокации яндекса, ибо пользователь, вообще говоря, видеть api-ключ не должен
@WebServlet(urlPatterns = {"/api/location"})
public class yandexLocation extends HttpServlet {
    String yandexKey = "d3dd88e6-f6a0-433d-a2a6-6971a2ef3e4f";
    String preset = "https://geocode-maps.yandex.ru/1.x/?apikey=%s&format=json&geocode=%s,%s&results=1";
    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        String longit = request.getParameter("long");
        String lat = request.getParameter("lat");
        URL url = new URL(String.format(preset, yandexKey, longit, lat));
        HttpURLConnection con = (HttpURLConnection)url.openConnection();
        con.setRequestMethod("GET");
        con.setRequestProperty("User-Agent", USER_AGENT);
        
        StringBuffer resp;
        try (BufferedReader in = new BufferedReader(
                new InputStreamReader(con.getInputStream()))) {
            String inputLine;
            resp = new StringBuffer();
            while ((inputLine = in.readLine()) != null) {
                resp.append(inputLine);
            }
        }
        
        JsonReader reader = Json.createReader(new StringReader(resp.toString()));
        JsonObject struct = reader.read().asJsonObject();
        String addr = struct.getJsonObject("response").getJsonObject("GeoObjectCollection")
                .getJsonArray("featureMember").getJsonObject(0).getJsonObject("GeoObject")
                .getJsonObject("metaDataProperty").getJsonObject("GeocoderMetaData")
                .getJsonObject("Address").getString("formatted");
        JsonObject json = Json.createObjectBuilder().add("addr", addr).build();
        
        PrintWriter out = response.getWriter();
        out.print(json);
        out.flush();
    }
    
    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }
    
    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }
    
    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>
    
}
