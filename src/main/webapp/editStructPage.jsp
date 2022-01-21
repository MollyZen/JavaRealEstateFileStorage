<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*"%>
<%@ taglib prefix = "c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix = "sql" uri="http://java.sun.com/jsp/jstl/sql" %>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>JSP Page</title>
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
        </style>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/openlayers/openlayers.github.io@master/en/v6.9.0/css/ol.css" type="text/css">
        <script src="https://cdn.jsdelivr.net/gh/openlayers/openlayers.github.io@master/en/v6.9.0/build/ol.js"></script>
        <script src="/mapWithOverlay.js"></script>
        <script src="/activeButton.js"></script>
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
    <body style="margin:0" onload="addMap();activeButton(1);addClickListener();addAddrAdjuster();adjustMapNoCoords()">
        <%@include file="navbar.jsp" %>
        <c:if test="${empty addr}">
            <sql:setDataSource var = "structs" driver = "com.mysql.jdbc.Driver"
                url = "jdbc:mysql://localhost:3306/registry"
                user = "root" password= "07-09-2001z"/>
            <sql:query dataSource="${structs}" var="result">
                SELECT * FROM `structures` WHERE str_id=${obj} LIMIT 1;
            </sql:query>
            <c:set var="addr" value="${result.rows[0].addr}"/>
            <c:set var="cad" value="${result.rows[0].cadastre_id}"/>
        </c:if>
        
        <div style="float:left;margin:20px;margin-left:50px;width:45%;text-align:center">
            <form method="POST">
                <div style="border: solid 1px black;padding:20px">
                    <label for="faddr"><strong>Адрес объекта:</strong></label><br>
                    <textarea required id="faddr" name="faddr" 
                              rows="3" cols="50" maxlength="400" 
                              style="resize:none"><c:if test="${not empty addr}">${addr}</c:if></textarea>
                              <br><br>
                    <button type="button" onclick="fillCadastre();">Заполнить кадастровый номер по адресу</button><br><br>
                    <label for="fcad"><strong>Кадастровый номер(необязательное поле):</strong></label><br>
                    <input type="text" id="fcad" name="fcad"
                        <c:if test="${not empty cad}">
                            value="${cad}"
                        </c:if>><br><br>
                    <button type="button" onclick="fillAddress();">Заполнить адрес по кадастровому номеру</button><br><br><br>
                </div>
                <div style="text-align:center;">
                <c:if test="${not empty errorMessage}">
                    <div style="color:red">
                        Произошла ошибка: ${errorMessage}
                    </div>
                </c:if>
                    <br>
                    <input type="submit" name="submit" value="Обновить запись">
                </div>
            </form>
            <%
                if (request.getAttribute("errorMessage") != null){
                    request.removeAttribute("errorMessage");
                }
                else if(request.getParameter("submit") != null){
                    final String url = "jdbc:mysql://localhost:3306/registry";
                    final String user = "root";
                    final String password = "07-09-2001z";
                    String obj = request.getParameter("obj").toString();
                    Connection con = DriverManager.getConnection(url, user, password);
                    String addr = (String)request.getParameter("faddr");
                    String cadastre = (String)request.getParameter("fcad");
                    String query = String.format("SELECT COUNT(*) FROM `structures` WHERE addr='%s' AND str_id!=%s LIMIT 1;", addr, obj);
                    Statement stmt = con.createStatement();
                    ResultSet rs = stmt.executeQuery(query);
                    rs.next();
                    if (rs.getInt(1)==0){
                        query = String.format("SELECT COUNT(*) FROM `structures` WHERE cadastre_id='%s' AND str_id!=%s LIMIT 1;", cadastre, obj);
                        stmt = con.createStatement();
                        rs = stmt.executeQuery(query);
                        rs.next();
                        if (rs.getInt(1)==0){
                            query = String.format("UPDATE `structures` SET addr='%s', cadastre_id='%s' WHERE str_id=%s",addr,cadastre, obj);
                            stmt = con.createStatement();
                            stmt.executeUpdate(query);
                            response.sendRedirect(response.encodeRedirectURL("/objects/?obj="+obj));
                        }
                        else{
                            request.setAttribute("errorMessage", "Запись с таким кадастровым номером уже существует");
                            request.setAttribute("addr", addr);
                            request.setAttribute("cad", cadastre);
                            request.getRequestDispatcher("newStructure").forward(request,response);
                        }

                    }
                    else{
                        request.setAttribute("errorMessage", "Запись с таким адресом уже существует");
                        request.setAttribute("addr", addr);
                        request.setAttribute("cad", cadastre);
                        request.getRequestDispatcher("newStructure").forward(request,response);
                    }
                    con.close();
                }
                %>
        </div>
        <div id="map" class="map" style="width:40%;">
            <div style="border: solid 1px black;text-align:center"><em>Выберите место на карте для автоматического заполнения полей</em></div>
        </div>
    </body>
</html>
