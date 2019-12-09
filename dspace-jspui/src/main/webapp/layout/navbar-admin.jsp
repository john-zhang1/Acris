<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  - Navigation bar for admin pages
--%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ page import="java.util.LinkedList" %>
<%@ page import="java.util.List" %>

<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>

<%@ page import="org.dspace.browse.BrowseInfo" %>
<%@ page import="org.dspace.sort.SortOption" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.app.webui.util.LocaleUIHelper" %>
<%@ page import="org.dspace.eperson.EPerson" %>
<%@ page import="org.apache.commons.lang.StringUtils"%>
<%@ page import="org.dspace.core.ConfigurationManager"%>
<%@ page import="org.dspace.app.cris.model.CrisConstants"%>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%
    // Is anyone logged in?
    EPerson user = (EPerson) request.getAttribute("dspace.current.user");

    // Get the current page, minus query string
    String currentPage = UIUtil.getOriginalURL(request);
    int c = currentPage.indexOf('?');
    if (c > -1) {
        currentPage = currentPage.substring(0, c);
    }

    boolean crisModuleEnabled = ConfigurationManager.getBooleanProperty(CrisConstants.CFG_MODULE, "enabled");
    String handlePrefix = ConfigurationManager.getProperty("handle.prefix");

    boolean mintDoiToolEnabled = ConfigurationManager.getBooleanProperty("doi.admin.feature");

    // E-mail may have to be truncated
    String navbarEmail = null;
    if (user != null) {
        navbarEmail = user.getEmail();
    }

    boolean statsCleanerEnabled = ConfigurationManager.getBooleanProperty("usage-statistics", "webui.statistics.showCleaner");
    boolean isRtl = StringUtils.isNotBlank(LocaleUIHelper.ifLtr(request, "", "rtl"));

    boolean activeContent = false;
    boolean activeModule = false;
    boolean activeAccess = false;
    boolean activeSettings = false;

    if ((currentPage.endsWith("/tools/edit-communities") ? true : false) || (currentPage.endsWith("/tools/edit-item") ? true : false)
    || (currentPage.endsWith("/tools/duplicate") ? true : false) || (currentPage.endsWith("/dspace-admin/workflow") ? true : false)
    || (currentPage.endsWith("/dspace-admin/supervise") ? true : false) || (currentPage.endsWith("/dspace-admin/curate") ? true : false)
    || (currentPage.endsWith("/dspace-admin/withdrawn") ? true : false) || (currentPage.endsWith("/dspace-admin/privateitems") ? true : false)
    || (currentPage.endsWith("/dspace-admin/metadataimport") ? true : false) || (currentPage.endsWith("/dspace-admin/batchimport") ? true : false) 
    || (currentPage.endsWith("/dspace-admin/authority") ? true : false) || (currentPage.endsWith("/dspace-admin/doi") ? true : false) 
    || (currentPage.endsWith("/dspace-admin/stats-cleaner") ? true : false)) {
        activeContent = true;
    }

    if ((currentPage.endsWith("/admin/administrator.jsp") ? true : false)){
        activeModule = true;
    }

    if ((currentPage.endsWith("/dspace-admin/edit-epeople") ? true : false) || (currentPage.endsWith("/tools/group-edit") ? true : false)
    || (currentPage.endsWith("/tools/authorize") ? true : false)) {
        activeAccess = true;
    }

    if ((currentPage.endsWith("/dspace-admin/metadata-schema-registry") ? true : false) || (currentPage.endsWith("/dspace-admin/format-registry") ? true : false)
    || (currentPage.endsWith("/dspace-admin/news-edit") ? true : false) || (currentPage.endsWith("/dspace-admin/license-edit") ? true : false)) {
        activeSettings = true;
    }

%>

<div class="navbar-header">
    <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
    </button>
</div>
<nav class="collapse navbar-collapse bs-navbar-collapse navbar-default navbar-toggleable-sm bg-inverse">
    <ul id="top-menu" class="nav navbar-nav navbar-<%= isRtl ? "right" : "left"%>">
        <li class="pull-<%= isRtl ? "right" : "left"%>">
            <a class="navbar-brand" href="<%= request.getContextPath()%>/">
                <img height="45" src="<%= request.getContextPath()%>/image/logo.gif" alt="DSpace logo" />
            </a>
        </li>
        <li id="navbar-brand-title" class="pull-left" style="padding-top: 5px;">
            <h5>DSpace-CRIS</h5>
            <h5>Extension of DSpace</h5>
        </li>
    </ul>
    <div class="nav top-menu-library-div navbar-<%= isRtl ? "left" : "right"%>">
        <ul class="nav navbar-nav navbar-<%= isRtl ? "left" : "right"%>">
            <li id="library-top-menu" class="hidden-xs hidden-sm "><a href="#">Library</a></li>
            <li class="hidden-xs hidden-sm"><dspace:popup page="<%= LocaleSupport.getLocalizedMessage(pageContext, \"help.site-admin\") %>"><fmt:message key="jsp.layout.navbar-admin.help"/></dspace:popup></li>

            <li id="userloggedin-top-menu" class="dropdown">

                <a href="#" class="dropdown-toggle text-left" data-toggle="dropdown"><span class="glyphicon glyphicon-user"></span> 
                <fmt:message key="jsp.layout.navbar-default.loggedin">
                    <fmt:param><%= StringUtils.abbreviate(navbarEmail, 20)%></fmt:param>
                </fmt:message> <b class="caret"></b></a>
                <ul class="dropdown-menu">
                    <li><a href="<%= request.getContextPath()%>/subscribe"><fmt:message key="jsp.layout.navbar-default.receive"/></a></li>
                    <li><a href="<%= request.getContextPath()%>/mydspace"><fmt:message key="jsp.layout.navbar-default.users"/></a></li>
                    <li><a href="<%= request.getContextPath()%>/profile"><fmt:message key="jsp.layout.navbar-default.edit"/></a></li>

                    <li><a href="<%= request.getContextPath()%>/logout"><span class="glyphicon glyphicon-log-out"></span> 
                            <fmt:message key="jsp.layout.navbar-default.logout"/>
                        </a>
                    </li>
                </ul>
            </li>
        </ul>
    </div>
</nav>


<nav class="collapse navbar-collapse navbar-wire bs-navbar-collapse" role="navigation">
    <ul class="nav navbar-nav">
        <li class="hidden-xs hidden-sm"><a href="<%= request.getContextPath()%>/"><span class="glyphicon glyphicon-home"></span> <fmt:message key="jsp.layout.navbar-default.home"/></a></li>

        <li class="dropdown <%= activeContent ? "active" : "" %>">
            <a href="#" class="dropdown-toggle" data-toggle="dropdown"><fmt:message key="jsp.layout.navbar-admin.contents"/> <b class="caret"></b></a>
            <ul class="dropdown-menu">
                <li><a href="<%= request.getContextPath()%>/tools/edit-communities"><fmt:message key="jsp.layout.navbar-admin.communities-collections"/></a></li>
                <li class="divider"></li>
                <li><a href="<%= request.getContextPath()%>/tools/edit-item"><fmt:message key="jsp.layout.navbar-admin.items"/></a></li>
                <li><a href="<%= request.getContextPath()%>/tools/duplicate"><fmt:message key="jsp.layout.navbar-admin.duplicate"/></a></li>
                <li><a href="<%= request.getContextPath()%>/dspace-admin/workflow"><fmt:message key="jsp.layout.navbar-admin.workflow"/></a></li>
                <li><a href="<%= request.getContextPath()%>/dspace-admin/supervise"><fmt:message key="jsp.layout.navbar-admin.supervisors"/></a></li>
                <li><a href="<%= request.getContextPath()%>/dspace-admin/curate"><fmt:message key="jsp.layout.navbar-admin.curate"/></a></li>
                <li><a href="<%= request.getContextPath()%>/dspace-admin/withdrawn"><fmt:message key="jsp.layout.navbar-admin.withdrawn"/></a></li>
                <li><a href="<%= request.getContextPath()%>/dspace-admin/privateitems"><fmt:message key="jsp.layout.navbar-admin.privateitems"/></a></li>
                <li><a href="<%= request.getContextPath()%>/dspace-admin/metadataimport"><fmt:message key="jsp.layout.navbar-admin.metadataimport"/></a></li>
                <li><a href="<%= request.getContextPath()%>/dspace-admin/batchimport"><fmt:message key="jsp.layout.navbar-admin.batchimport"/></a></li>
                <li><a href="<%= request.getContextPath()%>/dspace-admin/authority"><fmt:message key="jsp.layout.navbar-admin.authority"/></a></li>
                    <% if (mintDoiToolEnabled) {%>
                <li><a href="<%= request.getContextPath()%>/dspace-admin/doi"><fmt:message key="jsp.layout.navbar-admin.doi"/></a></li>			
                    <% }
                   if (statsCleanerEnabled) {%>
                <li><a href="<%= request.getContextPath()%>/dspace-admin/stats-cleaner"><fmt:message key="jsp.layout.navbar-admin.stats-cleaner"/></a></li>					
                    <%} %>
            </ul>
        </li>
        <%
            if (crisModuleEnabled == true) {
        %>
        <li class="<%= activeModule ? "active" : "" %>"><a href="<%= request.getContextPath()%>/cris/administrator/index.htm"><fmt:message key="jsp.layout.navbar-admin.cris"/></a></li>
            <% }%>
        <li class="dropdown <%= activeAccess ? "active" : "" %>">
            <a href="#" class="dropdown-toggle" data-toggle="dropdown"><fmt:message key="jsp.layout.navbar-admin.accesscontrol"/> <b class="caret"></b></a>
            <ul class="dropdown-menu">
                <li><a href="<%= request.getContextPath()%>/dspace-admin/edit-epeople"><fmt:message key="jsp.layout.navbar-admin.epeople"/></a></li>
                <li><a href="<%= request.getContextPath()%>/tools/group-edit"><fmt:message key="jsp.layout.navbar-admin.groups"/></a></li>
                <li><a href="<%= request.getContextPath()%>/tools/authorize"><fmt:message key="jsp.layout.navbar-admin.authorization"/></a></li>
            </ul>
        </li>
        <li class="<%= currentPage.contains("/cris/stats/site.html")? "active" : "" %>"><a href="<%= request.getContextPath()%>/cris/stats/site.html?handle=<%=handlePrefix%>/0"><fmt:message key="jsp.layout.navbar-admin.statistics"/></a></li>
        <li class="dropdown <%= activeSettings ? "active" : "" %>"">
            <a href="#" class="dropdown-toggle" data-toggle="dropdown"><fmt:message key="jsp.layout.navbar-admin.settings"/> <b class="caret"></b></a>
            <ul class="dropdown-menu">

                <li><a href="<%= request.getContextPath()%>/dspace-admin/metadata-schema-registry"><fmt:message key="jsp.layout.navbar-admin.metadataregistry"/></a></li>
                <li><a href="<%= request.getContextPath()%>/dspace-admin/format-registry"><fmt:message key="jsp.layout.navbar-admin.formatregistry"/></a></li>
                <li class="divider"></li>
                <li><a href="<%= request.getContextPath()%>/dspace-admin/news-edit"><fmt:message key="jsp.layout.navbar-admin.editnews"/></a></li>
                <li class="divider"></li>
                <li><a href="<%= request.getContextPath()%>/dspace-admin/license-edit"><fmt:message key="jsp.layout.navbar-admin.editlicense"/></a></li>
            </ul>
        </li>
    </ul>
</nav>