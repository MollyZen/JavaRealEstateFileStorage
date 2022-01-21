<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*,java.util.*"%>
<%@ taglib prefix = "sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>JSP Page</title>
        <script src="../activeButton.js"></script>
        <style>
            <%@include file="navbar-styling.jsp" %>
            .map {
                height: 400px;
                width: 400px;
                float: left;
                margin: 20px;
                margin-right: 50px;
            }
            .ol-control button{ 
                background-color: #04AA6D !important;
            }
            input[type="submit"]{
                font-weight: bold;
                font-size: 20px;
                padding: 5px;
            }
            table{
                border: 1px solid black;
                border-radius:25px;
                border-spacing: 0;
                width:90%;
                margin:10px;
                margin-left:auto;
                margin-right:auto;
            }
            table th{
                text-align:center;
                border-bottom: 1px solid black;
                padding: 10px;
            }
            table td{
                padding: 10px;
            }
            table tr:last-child > td{
                border-bottom: none;
            }
        </style>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/openlayers/openlayers.github.io@master/en/v6.9.0/css/ol.css" type="text/css">
        <script src="https://cdn.jsdelivr.net/gh/openlayers/openlayers.github.io@master/en/v6.9.0/build/ol.js"></script>
        <script src="../mapWithOverlay.js"></script>
    </head>
    <%
            if (request.getParameter("obj") != null){
                request.setAttribute("obj", request.getParameter("obj").toString());
            }
            else{
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
        %>
    <body style="margin:0;" onload="activeButton(1);addMap();adjustMapNoCoords()">
        <%@include file="navbar.jsp" %>
        <%@include file="defaultPageSwitcher.jsp"%>
                    <div style="margin:10px;margin-left:auto;margin-right:auto;text-align:center;">
                <form action='/objects/editStructure/'>
                    <input type='submit' value='Редактировать объект' style="font-size:200%"/>
                    <input type='hidden' name='obj' value='${obj}' />
                </form>
            </div>
        <sql:setDataSource var = "structs" driver = "com.mysql.jdbc.Driver"
                     url = "jdbc:mysql://localhost:3306/registry"
                     user = "root" password= "07-09-2001z"/>
        <sql:query dataSource="${structs}" var="result">
            SELECT * FROM `structures` WHERE str_id=${obj} LIMIT 1;
        </sql:query>
        <c:choose>
            <c:when test="${result.rowCount==0}">
                <%
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
                %>
            </c:when>
        </c:choose>
        <sql:query dataSource="${structs}" var="cnt0">
            SELECT COUNT(*) FROM `files` WHERE str_id=${obj};
        </sql:query>
        <sql:query dataSource="${structs}" var="result1">
            SELECT * FROM `files`
            WHERE str_id=${obj}
            ORDER BY file_id DESC 
            LIMIT <c:out value="${(page-1)*10}"/>,10;
        </sql:query>  
        <c:set var="cnt" value="${cnt0.rows[0].get(cnt0.rows[0].firstKey())}" scope="request"/>
        <table style="width:40%;margin-left:50px;margin-right:50px;float:left">
            <tr>
                <th colspan="2">
                    <h3>Объект недвижимости</h3>
                </th>
            </tr>
            <tr>
                <td><strong>Адрес:</strong></td>
                <td id="faddr">${result.rows[0].addr}</td>
            </tr>
            <tr>
                <td><strong>Кадастровый номер:</strong></td>
                <td>${result.rows[0].cadastre_id}</td>
            </tr>
        </table>
        <div id="map" class="map" style="width:40%;"></div>
        <%@include file="pageSwitchFooter.jsp"%>
        <div style="text-align:center;clear:both;">
        <form method="POST" enctype="multipart/form-data">
            <div>
                <label for="file">Выберите файлы для загрузки: </label>
                <input type="file" id="file" name="file" multiple>
            </div>
            <br>
            <c:if test="${not empty errorMessage}">
                <div style="color:red">
                    Произошла ошибка: ${errorMessage}
                </div>
            </c:if>
            <input type="submit" value="Загрузить"/>
        </form>
        </div>
        <%
            if (request.getAttribute("errorMessage") != null){
                request.removeAttribute("errorMessage");
            }
            else if(request.getContentType() != null){
                final String url = "jdbc:mysql://localhost:3306/registry";
                final String user = "root";
                final String password = "07-09-2001z";
                String query = "SELECT COUNT(*) FROM `files` WHERE file_name='%s'";
                Connection con = null;
                String name;
                List<String> list = new ArrayList<String>();
                try {
                    int size = request.getParts().size();
                    Collection<Part> parts = request.getParts();
                    if (request.getParts().size() < 1){
                        return;
                    }
                    for (Part part: request.getParts()){
                        String fileName = part.getSubmittedFileName();
                        con = DriverManager.getConnection(url, user, password);
                        Statement stmt = con.createStatement();
                        ResultSet rs = stmt.executeQuery(String.format(query, fileName));
                        rs.next();
                        if (rs.getInt(1) != 0 && !list.contains(fileName)){
                            request.setAttribute("errorMessage", "Файл с названием " + fileName + 
                                    "уже существует. Файлы не было загружены");
                            request.getRequestDispatcher("/objects/?obj="+request.getAttribute("obj").toString()).forward(request,response);
                            con.close();
                            return;
                        }
                        list.add(fileName);
                    }
                } catch (SQLException ex) {
                    return;
                }
                String dest = "/home/mollyzen/kurs_files/";
                for (Part part: request.getParts()){
                    part.write(dest + part.getSubmittedFileName());
                }
                for (String el : list){
                    query = "INSERT INTO `files`(file_id,str_id,file_name) VALUES (DEFAULT, "
                            + request.getAttribute("obj").toString() + ", '" + el + "');";
                    Statement stmt = con.createStatement();
                    stmt.executeUpdate(query);   
                    request.getRequestDispatcher("/objects/?obj="+request.getAttribute("obj").toString()).forward(request,response);
                }
                con.close();
            }
        %>
        <table>
            <tr>
                <th>
                    <h3>Связанные файлы</h3>
                </th>
            </tr>
            <tr>
                <td>
                    <ul>
                        <c:forEach var="row" items = "${result1.rows}">
                            <li>
                                <a href="/files/${row.file_id}">
                                    ${row.file_name}
                                </a>
                            </li><br>
                        </c:forEach>
                    </ul>
                </td>
            </tr>
        </table>
    </body>
</html>
