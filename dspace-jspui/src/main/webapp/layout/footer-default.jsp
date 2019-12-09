<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  - Footer for home page
  --%>

<%@page import="org.dspace.core.ConfigurationManager"%>
<%@page import="org.apache.commons.lang3.StringUtils"%>
<%@page import="org.dspace.eperson.EPerson"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<%@ page import="org.dspace.core.NewsManager" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.app.webui.util.LocaleUIHelper" %>

<%
	String footerNews = NewsManager.readNewsFile(LocaleSupport.getLocalizedMessage(pageContext, "news-footer.html"));
    String sidebar = (String) request.getAttribute("dspace.layout.sidebar");
	String[] mlinks = new String[0];
	String mlinksConf = ConfigurationManager.getProperty("cris","navbar.cris-entities");
	if (StringUtils.isNotBlank(mlinksConf)) {
		mlinks = StringUtils.split(mlinksConf, ",");
	}

	boolean showCommList = ConfigurationManager.getBooleanProperty("community-list.show.all",true);
	boolean isRtl = StringUtils.isNotBlank(LocaleUIHelper.ifLtr(request, "","rtl"));
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
<br/>
</main>
            <%-- Page footer --%>
        <footer class="container navbar navbar-inverse navbar-bottom">
            <div class="row">
                <div class="col-md-4 col-sm-6">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <h6 class="panel-title"><fmt:message key="jsp.layout.footer-default.explore"/></h6>
                        </div>
                        <div class="panel-body">
                        <ul>
                <% 	if(showCommList){ %>
                <li><a href="<%= request.getContextPath() %>/community-list"><fmt:message key="jsp.layout.navbar-default.communities-collections"/></a></li>
                <%	}
                    for (String mlink : mlinks) {
                %>
                <c:set var="fmtkey">
                jsp.layout.navbar-default.cris.<%= mlink.trim() %>
                </c:set>
                <li><a href="<%= request.getContextPath() %>/cris/explore/<%= mlink.trim() %>"><fmt:message key="${fmtkey}"/></a></li>
                    <% } %>
                        </ul>
                    </div>
                </div>
                </div>

                <div class="col-md-4 col-sm-6">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <h6 class="panel-title">Useful Links</h6>
                        </div>
                        <div class="panel-body">
                        <ul>
                                <li><a target="_blank" href="#">About</a></li>
                                <li><a target="_blank" href="#">News & Events</a></li>
                                <li><a target="_blank" href="#">Digital Learning</a></li>
                                <li><a target="_blank" href="#">Digital Research</a></li>
                            </ul>
                        </div>
                    </div>
                </div>

                <div class="col-md-4 col-sm-6">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <h6 class="panel-title">Submit an Item</h6>
                        </div>
                        <div class="panel-body">
                            <div>Submit work you want to share</div><br/>
                        </div>
                    </div>
                </div>
            </div>
            <%-- <div class="col-md-9 col-sm-6">
                <%= footerNews %>
            </div> --%>
        </footer>
    </body>
</html>