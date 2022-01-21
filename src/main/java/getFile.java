import jakarta.servlet.ServletException;
import jakarta.servlet.ServletOutputStream;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "getFile", urlPatterns = {"/files/*"})
public class getFile extends HttpServlet {
    
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
        String id = request.getPathInfo().replaceFirst("/", "");
        final String url = "jdbc:mysql://localhost:3306/registry";
        final String user = "root";
        final String password = "07-09-2001z";
        String query = String.format("SELECT file_name FROM `files` WHERE file_id=%s",id);
        Connection con;
        String name;
        try {
            con = DriverManager.getConnection(url, user, password);
            Statement stmt = con.createStatement();
            ResultSet rs = stmt.executeQuery(query);
            if(!rs.next()){
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            name = rs.getString(1);
        } catch (SQLException ex) {
            Logger.getLogger(getFile.class.getName()).log(Level.SEVERE, null, ex);
            return;
        }
        String src = "/home/mollyzen/kurs_files/"+ name;
        int lastIndex = name.lastIndexOf(".");
        String type;
        if(lastIndex>-1 && lastIndex!=name.length()-1){
            type = name.substring(lastIndex+1, name.length());
        }
        else{
            type = "";
        }
        switch(type){
            case "jpg":;
            case "jpeg":;
            case "png": type = "image/" + type; break;
            case "pdf": type = "application/" + type; break;
            case "mp4":;
            case "webm": type = "video/" + type; break;
            default: type = "";
        }
        if (!type.equals("")){
            response.setContentType(type);
        }
        else{
            response.setContentType("APPLICATION/OCTET-STREAM");
            response.setHeader("Content-Disposition", "attachment; filename=\"" + name + "\"");
        }
        try(ServletOutputStream sos = response.getOutputStream()){
            response.setContentLength(Math.toIntExact(new File(src).length()));
            try (java.io.FileInputStream fis = new java.io.FileInputStream(src)) {
                int i;
                byte[] bufferData = new byte[1024];
                while ((i = fis.read(bufferData))!=-1){
                    sos.write(bufferData,0,i);
                }
                sos.flush();
                sos.close();
                fis.close();
            }
        }
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
