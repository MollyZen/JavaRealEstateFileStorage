<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*,java.util.*,java.lang.*"%>
<%@ taglib prefix = "c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix = "sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Список файлов</title>
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
    <body style="margin:0" onload="activeButton(2);">
        <%@include file="navbar.jsp" %>
        <sql:setDataSource var = "structs" driver = "com.mysql.jdbc.Driver"
                           url = "jdbc:mysql://localhost:3306/registry"
                           user = "root" password= "07-09-2001z"/>
        <sql:query dataSource="${structs}" var="cnt0">
            SELECT COUNT(*) FROM `files` ORDER BY file_id DESC;
        </sql:query>
        <c:set var="cnt" value="${cnt0.rows[0].get(cnt0.rows[0].firstKey())}" scope="request"/>
        <%@include file="defaultPageSwitcher.jsp"%>
        <sql:query dataSource="${structs}" var="result">
            SELECT * FROM `files` f JOIN `structures` s 
            ON f.str_id=s.str_id 
            ORDER BY f.file_id DESC 
            LIMIT <c:out value="${(page-1)*10}"/>,10;
        </sql:query>
        <table>
            <tr>
                <td>
                    <ul>
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
                    </ul>
                </td>
            </tr>
        </table>
        <div style='margin:10px;text-align:center'>
            <%@include file="pageSwitchFooter.jsp"%>
            ${pages}
        </div>
    </body>
</html>
