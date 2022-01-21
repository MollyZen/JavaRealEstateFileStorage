<%@page contentType="text/html" pageEncoding="UTF-8"%>

.navbar{
}
ul.navbar {
    position: -webkit-sticky;
    position: sticky;
    top: 0;
    left: 0;
    margin: 0;
    padding: 0;
    list-style-type: none;
    overflow: hidden;
    background-color: #333;
    width: 100%;
}
ul.navbar li{
    float: left;
    border-right: 1px solid #bbb;
}
ul.navbar li:last-child {
    border-right: none;
}
ul.navbar li a{
    display: block;
    color: white;
    text-align: center;
    padding: 14px 16px;
    text-decoration: none;
    background-color: transparent;
}
ul.navbar li a:hover:not(.active){
    background-color: #000;
}
ul.navbar li a.active{
    background-color: :#04AA6D;
}