<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  - Footer for home page
  --%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ page import="java.net.URLEncoder" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>

<%
    String sidebar = (String) request.getAttribute("dspace.layout.sidebar");
%>

            <%-- Right-hand side bar if appropriate --%>
<%
    if (sidebar != null)
    {
%>
	</div>
	<div class="col-md-3">
                    <%= sidebar %>
    </div>
    </div>       
<%
    }
%>
</div>
</main>
            <%-- Page footer --%>
             <footer class="navbar navbar-inverse navbar-bottom">
             <div id="designedby" class="container text-muted">
            <a href="http://ww"><img
                                    src="<%= request.getContextPath() %>/image/eosc-logo.png"
                                   height="30px" alt="Logo CINECA" /></a>
			                                  
                                <!-- <p class="text-muted"><fmt:message key="jsp.layout.footer-default.text"/>&nbsp;-
                                <a target="_blank" href="<%= request.getContextPath() %>/feedback"><fmt:message key="jsp.layout.footer-default.feedback"/></a>
                                <a href="<%= request.getContextPath() %>/htmlmap"></a></p> -->
                                <a href="http://ww" id="eu"><img
                                    src="<%= request.getContextPath() %>/image/european-union-logo.png"
                                   height="44px" margin-left="18px" alt="Logo EU" /></a>    
                            
            </div>
            <div id="designedby-2" class="container text-muted">
            <p>H2020-INFRADEV-2019-2020 – Grant Agreement No. 871043.</p>
                            <p>Funded by the Horizon 2020 Framework Programme of the European Union</p>
                        </div>
    </footer>
    </body>
</html>