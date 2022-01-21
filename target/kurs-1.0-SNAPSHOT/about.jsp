<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>О сайте</title>
        <script src="activeButton.js"></script>
        <style>
            <%@include file="navbar-styling.jsp" %>
        </style>
    </head>
    <body style="margin:0;" onload="activeButton(3);"> 
        <%@include file="navbar.jsp" %>
        <div style="text-align:center;margin-left:auto;margin-right:auto;width:75%;font-size:150%">
            <h1>О сайте</h1>
            <div>
                Этот сайт предназначен для <strong>хранения файлов, связанных с объектами недвижимости</strong>
            </div><br>
            <div>
                <strong>Добавить новый объект недвижимости</strong> можно либо на главной странице, либо на странице
                "Объекты" верхней навигационной панели. На этой же странице можно  посмотреть список
                всех добавленных записей
            </div><br>
            <div>
                Чтобы <strong>добавить новый файл</strong> необходимо зайти на страницу объекта 
            </div><br>
            <div>
                На странице "Файлы" верхней навигационной панели можно <strong>посмотреть добавленные файлы
                    и адреса объектов, к которым они относятся</strong>
            </div><br>
        </div>
    </body>
</html>
