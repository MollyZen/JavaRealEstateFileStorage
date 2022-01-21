<%@page contentType="text/html" pageEncoding="UTF-8"%>
        <%
            if (request.getParameter("page") != null){
                try{
                    long page0 = Long.parseLong(request.getParameter("page"));
                    long cnt = (long)request.getAttribute("cnt");
                    if (page0 < 1){
                        request.setAttribute("page",(long)1);
                    }
                    else if (page0 > (long)Math.ceil(cnt/10.)) {
                        request.setAttribute("page", (long)Math.ceil(cnt/10.));
                    }
                    else{
                        request.setAttribute("page", page0);
                    }
                }catch(Exception e){
                    request.setAttribute("page", (long)1);
                }
            }
            else{
                request.setAttribute("page", (long)1);
            }
        %>