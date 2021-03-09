<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  - Home page JSP
  -
  - Attributes:
  -    communities - Community[] all communities in DSpace
  -    recent.submissions - RecetSubmissions
  --%>

<%@page import="org.dspace.core.factory.CoreServiceFactory"%>
<%@page import="org.dspace.core.service.NewsService"%>
<%@page import="org.dspace.content.service.CommunityService"%>
<%@page import="org.dspace.content.factory.ContentServiceFactory"%>
<%@page import="org.dspace.content.service.ItemService"%>
<%@page import="org.dspace.core.Utils"%>
<%@page import="org.dspace.content.Bitstream"%>
<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page import="java.io.File" %>
<%@ page import="java.util.Enumeration"%>
<%@ page import="java.util.Locale"%>
<%@ page import="java.util.List"%>
<%@ page import="javax.servlet.jsp.jstl.core.*" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ page import="org.dspace.core.I18nUtil" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.app.webui.components.RecentSubmissions" %>
<%@ page import="org.dspace.content.Community" %>
<%@ page import="org.dspace.browse.ItemCounter" %>
<%@ page import="org.dspace.content.Item" %>
<%@ page import="org.dspace.services.ConfigurationService" %>
<%@ page import="org.dspace.services.factory.DSpaceServicesFactory" %>

<%
    List<Community> communities = (List<Community>) request.getAttribute("communities");

    Locale sessionLocale = UIUtil.getSessionLocale(request);
    Config.set(request.getSession(), Config.FMT_LOCALE, sessionLocale);
    NewsService newsService = CoreServiceFactory.getInstance().getNewsService();
    String topNews = newsService.readNewsFile(LocaleSupport.getLocalizedMessage(pageContext, "news-top.html"));
    String sideNews = newsService.readNewsFile(LocaleSupport.getLocalizedMessage(pageContext, "news-side.html"));

    ConfigurationService configurationService = DSpaceServicesFactory.getInstance().getConfigurationService();
    
    boolean feedEnabled = configurationService.getBooleanProperty("webui.feed.enable");
    String feedData = "NONE";
    if (feedEnabled)
    {
        // FeedData is expected to be a comma separated list
        String[] formats = configurationService.getArrayProperty("webui.feed.formats");
        String allFormats = StringUtils.join(formats, ",");
        feedData = "ALL:" + allFormats;
    }
    
    ItemCounter ic = new ItemCounter(UIUtil.obtainContext(request));

    RecentSubmissions submissions = (RecentSubmissions) request.getAttribute("recent.submissions");
    ItemService itemService = ContentServiceFactory.getInstance().getItemService();
    CommunityService communityService = ContentServiceFactory.getInstance().getCommunityService();
%>



<dspace:layout locbar="nolink" titlekey="jsp.home.title" feedData="<%= feedData %>">

	<div class="jumbotron news-home">
		<%= topNews %>
	</div>
	
	<!-- <h3 class="proj">Projects</h3>
	<div class="projects-dissco">
		<a href="https://dissco-kb.naturkundemuseum.berlin/jspui/handle/123456789/7"><img  class="p-diss" width="130" src="<%= request.getContextPath() %>/image/dissco-prepare.jpg" alt="Card image cap"></a>
		<a href="https://dissco-kb.naturkundemuseum.berlin/jspui/handle/123456789/9"><img class="p-diss" width="130" src="<%= request.getContextPath() %>/image/envri.jpg" alt="Card image cap"></a>
		<a href="https://dissco-kb.naturkundemuseum.berlin/jspui/handle/123456789/4"><img class="p-diss" width="130" src="<%= request.getContextPath() %>/image/icedig-eu.jpg" alt="Card image cap"></a>
		<a href="https://dissco-kb.naturkundemuseum.berlin/jspui/handle/123456789/8"><img class="p-diss" width="130" src="<%= request.getContextPath() %>/image/mobilise.jpg" alt="Card image cap"></a>
		<a href="https://dissco-kb.naturkundemuseum.berlin/jspui/handle/123456789/6"><img class="p-diss" width="130" src="<%= request.getContextPath() %>/image/synthesys-1.jpg" alt="Card image cap"></a>
		
	  </div> -->
	<!-- <h3>You can also use the <a href="<%= request.getContextPath() %>/advanced-search"><fmt:message key="jsp.layout.navbar-default.advanced"/></a></h3> -->

	<div class="row dissco-main ">
		<%
if (submissions != null && submissions.count() > 0)
{
%>
		<div class="col-md-8 flex-subm sub-none">
			<div class="submi">
				<h3 class="lts-sub">Check here the latest submissions!</h3>
				<img class="arrow-img" height="93" src="<%= request.getContextPath() %>/image/arrow-svg-sub.png" alt="DiSSCo logo" />
			</div>
			<div class="panel panel-primary">
				<div id="recent-submissions-carousel" class="panel-heading carousel slide">
					<h3 class="carous-subm"> Submissions
						<!-- <fmt:message key="jsp.collection-home.recentsub"/> -->
						<%
    if(feedEnabled)
    {
	    	String[] fmts = feedData.substring(feedData.indexOf(':')+1).split(",");
	    	String icon = null;
	    	int width = 0;
	    	for (int j = 0; j < fmts.length; j++)
	    	{
	    		if ("rss_1.0".equals(fmts[j]))
	    		{
	    		   icon = "rss1.gif";
	    		   width = 80;
	    		}
	    		else if ("rss_2.0".equals(fmts[j]))
	    		{
	    		   icon = "rss2.gif";
	    		   width = 80;
	    		}
	    		else
	    	    {
	    	       icon = "rss.gif";
	    	       width = 36;
	    	    }
	%>
						<a href="<%= request.getContextPath() %>/feed/<%= fmts[j] %>/site"><img class="rss-feed"
								src="<%= request.getContextPath() %>/image/<%= icon %>" alt="RSS Feed"
								width="<%= width %>" height="15" style="margin: 3px 0 3px" /></a>
						<%
	    	}
	    }
	%>
					</h3>

					<!-- Wrapper for slides -->
					<div class="carousel-inner">
						<%
		    boolean first = true;
		    for (Item item : submissions.getRecentSubmissions())
		    {
		        String displayTitle = itemService.getMetadataFirstValue(item, "dc", "title", null, Item.ANY);
		        if (displayTitle == null)
		        {
		        	displayTitle = "Untitled";
		        }
		        String displayAbstract = itemService.getMetadataFirstValue(item, "dc", "description", "abstract", Item.ANY);
		        if (displayAbstract == null)
		        {
		            displayAbstract = "";
		        }
		%>
						<div style="padding-bottom: 50px; min-height: 200px;" class="item <%= first?"active":""%>">
							<div style="padding-left: 80px; padding-right: 80px; display: inline-block;">
								<%= Utils.addEntities(StringUtils.abbreviate(displayTitle, 400)) %>
								<a href="<%= request.getContextPath() %>/handle/<%=item.getHandle() %>"
									class="btn btn-success">See</a>
								<p><%= Utils.addEntities(StringUtils.abbreviate(displayAbstract, 500)) %></p>
							</div>
						</div>
						<%
				first = false;
		     }
		%>
					</div>

					<!-- Controls -->
					<a class="left carousel-control" href="#recent-submissions-carousel" data-slide="prev">
						<span class="icon-prev"></span>
					</a>
					<a class="right carousel-control" href="#recent-submissions-carousel" data-slide="next">
						<span class="icon-next"></span>
					</a>

					<ol class="carousel-indicators">
						<li data-target="#recent-submissions-carousel" data-slide-to="0" class="active"></li>
						<% for (int i = 1; i < submissions.count(); i++){ %>
						<li data-target="#recent-submissions-carousel" data-slide-to="<%= i %>"></li>
						<% } %>
					</ol>
				</div>
			</div>
		</div>
		<%
}
%>
		<!-- <div class="col-md-4">
    <%= sideNews %>
</div> -->

	</div>
	<div class="container row container-div">
<%
if (communities != null && communities.size() != 0)
{
%>
	<div class="col-md-4">		
               <h3 class="proj-kb">
				   <fmt:message key="jsp.home.com1"/>
				</h3>
                <p class="proj2-kb"><fmt:message key="jsp.home.com2"/></p>
				<div class="list-group">
<%
	boolean showLogos = configurationService.getBooleanProperty("jspui.home-page.logos", true);
    for (Community com : communities)
    {
%><div class="list-group-item proj-boxes row">
<%  
		Bitstream logo = com.getLogo();
		if (showLogos && logo != null) { %>
	<div class="col-md-3 image-home" >
        <img alt="Logo" class="img-responsive" src="<%= request.getContextPath() %>/retrieve/<%= logo.getID() %>" /> 
	</div>
	<div class="col-md-9">
<% } else { %>
	<div class="col-md-12">
<% }  %>		
		<h4 class="list-group-item-heading"><a href="<%= request.getContextPath() %>/handle/<%= com.getHandle() %>"><%= com.getName() %></a>
			<span class="badge pull-right"><%= ic.getCount(com) %></span>
<%
        if (configurationService.getBooleanProperty("webui.strengths.show"))
        {
%>
		
<%
        }

%>
		</h4>
		<p class="none-home"><%= communityService.getMetadata(com, "short_description") %></p>
    </div>
</div>                            
<%
    }
%>
	</div>
	</div>
<%
}
%>
	<!-- <%
    	int discovery_panel_cols = 8;
    	int discovery_facet_cols = 4;
    %> -->
	<!-- <%@ include file="discovery/static-sidebar-facet.jsp" %> -->
</div>

<!-- <div class="row">
	<%@ include file="discovery/static-tagcloud-facet.jsp" %>
</div> -->
	
</div>
	<script>
		// Get the modal
		var modal = document.getElementById("myModal");

		// Get the button that opens the modal
		var btn = document.getElementById("myBtn");

		// Get the <span> element that closes the modal
		var span = document.getElementsByClassName("close")[0];

		// When the user clicks on the button, open the modal
		btn.onclick = function () {
			modal.style.display = "block";
		}

		// When the user clicks on <span> (x), close the modal
		span.onclick = function () {
			modal.style.display = "none";
		}

		// When the user clicks anywhere outside of the modal, close it
		window.onclick = function (event) {
			if (event.target == modal) {
				modal.style.display = "none";
			}
		}
	</script>
</dspace:layout>