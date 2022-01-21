<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    long cnt = (long)request.getAttribute("cnt");
    long page0 = (long)request.getAttribute("page");
    StringBuilder sb = new StringBuilder();
    if (page0 > 1){
        sb.append("<a href='/objects?page="+(page0-1)+"'>" + "<<Предыдущая [" + (page0-1) + "]</a> ");
    }
    else{
        sb.append("<<Предыдущая ");
    }
    sb.append("<strong>[" + page0 + "]</strong>");
    if (page0 < (long)Math.ceil(cnt/10.)){
        sb.append("<a href='/objects?page="+(page0+1)+"'>[" + (page0+1) +"] Следующая>></a>");
    }
    else{
        sb.append("Следующая>>");
    }
    request.setAttribute("pages", sb.toString());
%>
