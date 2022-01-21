<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%@ page import = "java.io.*,java.util.*,java.sql.*"%>
<%@ page import = "jakarta.servlet.http.*,jakarta.servlet.*" %>
<%@ taglib prefix = "c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix = "sql" uri="http://java.sun.com/jsp/jstl/sql" %>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>БД кадастровых файлов</title>
        <script src="activeButton.js"></script>
        <style>
            <%@include file="navbar-styling.jsp" %>
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
            }
            table th{
                border-bottom: 1px solid black;
                padding: 10px;
            }
            table tr:last-child > td{
                border-bottom: none;
            }
        </style>
    </head>
    
    <body style="margin:0;" onload="activeButton(0);">
        <%@include file="navbar.jsp" %>
        <sql:setDataSource var = "structs" driver = "com.mysql.jdbc.Driver"
                           url = "jdbc:mysql://localhost:3306/registry"
                           user = "root" password= "07-09-2001z"/>
        <sql:query dataSource="${structs}" var="result">
            SELECT * FROM `structures` ORDER BY str_id DESC LIMIT 10;
        </sql:query>
            <div style="margin:10px;margin-left:auto;margin-right:auto;text-align:center;">
                <form action='/objects/newStructure'>
                    <input type='submit' value='Добавить новый объект' style="font-size:200%"/>
                </form>
            </div>
        <table>
            <tr>
                <th>
                    <h3>Последние добавленные объекты недвижимости</h3>
                </th>
            </tr>
            <tr>
                <td>
                    <ol>
                        <c:forEach var="row" items = "${result.rows}">
                            <li>
                                <a href="/objects/?obj=${row.str_id}">
                                    ${row.addr}
                                </a>
                            </li><br>
                        </c:forEach>
                    </ol>
                </td>
            </tr>
        </table>
        <sql:query dataSource="${structs}" var="result">
            SELECT * FROM `files` f JOIN `structures` s ON f.str_id=s.str_id ORDER BY f.file_id DESC LIMIT 10;
        </sql:query>
        <br>
        <table>
            <tr>
                <th>
                    <h3>Последние добавленные файлы</h3>
                </th>
            </tr>
            <tr>
                <td>
                    <ol>
                        <c:forEach var="row" items = "${result.rows}">
                            <li>
                                <a href="/files/${row.file_id}">
                                    ${row.file_name}
                                </a> - 
                                <a href="objects/?obj=${row.str_id}">
                                    ${row.addr}
                                </a>
                            </li><br>
                        </c:forEach>
                    </ol>
                </td>
            </tr>
        </table>
    </body>
</html>
