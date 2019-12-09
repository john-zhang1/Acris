<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page import="java.io.File" %>
<%@ page import="java.util.Enumeration"%>
<%@ page import="java.util.Locale"%>
<%@ page import="javax.servlet.jsp.jstl.core.*" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<%@ page import="org.dspace.core.I18nUtil" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.app.webui.components.RecentSubmissions" %>
<%@ page import="org.dspace.content.Community" %>
<%@ page import="org.dspace.core.ConfigurationManager" %>
<%@ page import="org.dspace.core.NewsManager" %>
<%@ page import="org.dspace.browse.ItemCounter" %>
<%@ page import="org.dspace.content.Metadatum" %>
<%@ page import="org.dspace.content.Item" %>
<%@ page import="org.dspace.discovery.configuration.DiscoveryViewConfiguration" %>
<%@page import="org.dspace.app.webui.components.MostViewedBean"%>
<%@page import="org.dspace.app.webui.components.MostViewedItem"%>
<%@page import="org.dspace.discovery.SearchUtils"%>
<%@page import="org.dspace.discovery.IGlobalSearchResult"%>
<%@page import="org.dspace.core.Utils"%>
<%@page import="org.dspace.content.Bitstream"%>
<%@page import="org.apache.commons.lang.StringUtils"%>
<%@page import="org.dspace.app.webui.util.LocaleUIHelper"%>

<script src="<%= request.getContextPath()%>/static/js/leaflet/CircularQueue.js"></script>
<script src="http://maximeh.github.io/leaflet.bouncemarker/bouncemarker.js"></script>
<link href="<%= request.getContextPath()%>/static/css/leaflet/readship.css" rel="stylesheet">

<div class="container">
    <div class="row">
        <div class="col-md-9">
            <div class="rdr rdr-dc">
                <div class="infoCard top">
                    <div class="rdr__infoPanel">
                        <div id="readerinfo" data-index="4" class="rdr__infoCard"></div>
                    </div>
                    <div class="rdr__controls">
                        <ul class="control_icons">
                            <li class="rdr__js-prev" title="Previous"><i class="fa-chevron-left" onclick="prevMarker()"></i></li>
                            <li class="rdr__js-liveToggle rdr__isActive" title="Pause"><i id="playswitch" class="fa-pause" onclick="togglePlayPause()" style="display:block;"></i></li>
                            <li class="rdr__js-next rdr__isActive" title="Next"><i class="fa-chevron-right" onclick="nextMarker()"></i></li>
                        </ul>
                    </div>
                </div>        
            </div>
        </div>
    </div>
    <div class="row">
        <div class="col-md-9">
            <div class="panel panel-default">
                <div class="panel-body">
                    <div id="leafletmap" style="height:300px;"></div>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <table class="table table-striped" style="font-size: 11px;">
                <tbody>
                    <tr>
                        <td>Item views in past month</td>
                        <td><strong><span id="currentVal">0</span> of <span id="totalPastDayVal">0</span></strong></td>
                    </tr>
                    <tr>
                        <td>Total Views</td>
                        <td><strong><span id="totalViewVal">0</span></strong></td>
                    </tr>
                    <tr>
                        <td>Monthly Views</td><td></td>
                    </tr>
                    <tr>
                        <td id="fourthMonth" style="text-align: center;"></td>
                        <td><strong><span id="fourthMonthVal">0</span></strong></td>
                    </tr>
                    <tr>
                        <td id="thirdMonth" style="text-align: center;"></td>
                        <td><strong><span id="thirdMonthVal">0</span></strong></td>
                    </tr>
                    <tr>
                        <td id="secondMonth" style="text-align: center;"></td>
                        <td><strong><span id="secondMonthVal">0</span></strong></td>
                    </tr>
                    <tr>
                        <td id="firstMonth" style="text-align: center;"></td>
                        <td><strong><span id="firstMonthVal">0</span></strong></td>
                    </tr>
                    <tr>
                        <td>Total Downloads</td>
                        <td><strong><span id="totalDownloadVal">0</span></strong></td>
                    </tr>
                    <tr>
                        <td>Total Items</td>
                        <td><strong><span id="totalItemVal">0</span></strong></td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
</div>


<script type="text/javascript">
    var jsonpath = "<%= request.getContextPath()%>/static/json/geos.json";
    var haloIconPath = "<%= request.getContextPath()%>/static/css/leaflet/images/haloicon.png";
    var dotIconPath = "<%= request.getContextPath()%>/static/css/leaflet/images/doticon.png";
    var downloadFilePath = "<%= request.getContextPath()%>/static/json/downloads.json";
    var itemFilePath = "<%= request.getContextPath()%>/static/json/items.json";
    var viewItemFilePath = "<%= request.getContextPath()%>/static/json/item-view-total.json";
    var viewItemMonthlyFilePath = "<%= request.getContextPath()%>/static/json/item-view-monthly.json";
    var geoData, queue = null;
    var savedHead = 0, headStatus = false;
    var timer;
    var timerInterval = 4 * 1000;
    var currentValue = 0;
    var oneDaylength = 0;
    var iconMarker = null;

    $.ajaxSetup({cache: false});

    var map = L.map('leafletmap').setView([27.9, 13.4], 2);
    map.setMaxBounds(map.getBounds());
    var layer = L.tileLayer('https://{s}.basemaps.cartocdn.com/light_nolabels/{z}/{x}/{y}{r}.png?access_token={accessToken}', {
        attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> ',
        maxZoom: 18,
        minZoom: 2,
        id: 'lib-zzd.cig7yktpl0489unlx2e5ielz9',
        accessToken: 'pk.eyJ1IjoibGliLXp6ZCIsImEiOiJjaWc3eWt2MWEwNDZ6dXprb2Z6dzk5cTJrIn0.MGKAAmkhNF35HHG-yEjh5Q'
    }).addTo(map);

    L.Icon.Default.prototype.options.shadowSize = [0, 0];

    $.getJSON(downloadFilePath, function (data) {
        var totalNumOfDownloads = data.response.numFound;
        setTotalDownloadVal(totalNumOfDownloads);
    });

    $.getJSON(itemFilePath, function (data) {
        var totalNumOfItems = data.response.numFound;
        setTotalItemVal(totalNumOfItems);
    });

    $.getJSON(viewItemFilePath, function (data) {
        var totalNumOfViews = data.response.numFound;
        setTotalViewVal(totalNumOfViews);
    });

    $.getJSON(viewItemMonthlyFilePath, function (data) {
        var monthlyViews = data.facet_counts.facet_ranges.time.counts;
        setMonthlyViewVal(monthlyViews);
    });

    $.getJSON(jsonpath, function (data) {
        queue = loadQueue(data);
        oneDaylength = data.length;
        setTotalPastDayVal(data.length);
        $("#readerinfo").append(outputReadInfo(queue.storage[queue.head]));
        bounceMarker();
        currentValue++;
        setCurrentVal(currentValue);
    });

    function loadQueue(data) {
        var queue = new CircularQueue(data.length);
        for (i in data) {
            queue.enqueue(data[i]);
        }
        return queue;
    }

    function setCurrentVal(currentVal) {
        $("#currentVal").text(currentVal);
    }

    function setTotalPastDayVal(totalVal) {
        $("#totalPastDayVal").text(totalVal);
    }

    function setTotalDownloadVal(totalVal) {
        $("#totalDownloadVal").text(totalVal);
    }

    function setTotalItemVal(totalVal) {
        $("#totalItemVal").text(totalVal);
    }

    function setTotalViewVal(totalVal) {
        $("#totalViewVal").text(totalVal);
    }

    function setMonthlyViewVal(Val) {
        $("#firstMonth").text(getMonth(Val[0]));
        $("#firstMonthVal").text(Val[1]);
        $("#secondMonth").text(getMonth(Val[2]));
        $("#secondMonthVal").text(Val[3]);
        $("#thirdMonth").text(getMonth(Val[4]));
        $("#thirdMonthVal").text(Val[5]);
        $("#fourthMonth").text(getMonth(Val[6]));
        $("#fourthMonthVal").text(Val[7]);
    }

    function setReaderInfo(info) {
        $("#readerinfo").children().remove();
        $("#readerinfo").append(info);
    }

    function forwardHead() {
        var len = queue.storage.length;
        var head = queue.head + 1;
        if (head > len) {
            return head % len;
        } else {
            return head;
        }
    }

    function backwardHead() {
        var len = queue.storage.length;
        var head = queue.head - 1;
        if (head < 0) {
            return head + len;
        } else {
            return head;
        }
    }

    function startAutoMap() {
        timer = setInterval(function () {
            if (queue != null) {
                forwardMarker();
            }
        }, timerInterval);
    }

    startAutoMap();

    var haloIcon = new L.icon({
        iconUrl: haloIconPath,
        iconSize: [20, 20]
    });

    var dotIcon = new L.icon({
        iconUrl: dotIconPath,
        iconSize: [10, 10]
    });

    function bounceMarker() {
        iconMarker = L.marker([queue.storage[queue.head].latitude, queue.storage[queue.head].longitude],
                {
                    icon: haloIcon,
                    bounceOnAdd: true,
                    bounceOnAddOptions: {duration: 500, height: 100, loop: 2},
                    bounceOnAddCallback: function () {
                        console.log("done");
                    }
                }).addTo(map);
        setReaderInfo(outputReadInfo(queue.storage[queue.head]));
    }

    function forwardMarker() {
        if (currentValue < oneDaylength) {
            stayMarker();
            queue.head = forwardHead();
            currentValue++;
            bounceMarker();
            setCurrentVal(currentValue);
            setFaStatus();
            if(currentValue == oneDaylength){
                $(".rdr__js-liveToggle").removeClass('rdr__isActive');                
            }
        }
    }

    function stayMarker() {
        if (iconMarker != null) {
            map.removeLayer(iconMarker);
        }
        L.marker([queue.storage[queue.head].latitude, queue.storage[queue.head].longitude],
                {
                    icon: dotIcon,
                }).addTo(map);
    }

    function backwardMarker() {
        if (currentValue > 1) {
            currentValue--;
            queue.head = backwardHead();
            bounceMarker();
            setCurrentVal(currentValue);
        }
    }

    function nextMarker() {
        if($(".rdr__js-next").hasClass('rdr__isActive')) {
            forwardMarker();
            stopAutoMap();
        }
    }

    function prevMarker() {
        if($(".rdr__js-prev").hasClass('rdr__isActive')) {
            stopAutoMap();
            if (!headStatus) {
                savedHead = queue.head;
                headStatus = true;
            }
            stayMarker();
            backwardMarker();
            setFaStatus();
        }
    }

    function stopAutoMap() {
        if ($("#playswitch").hasClass("fa-pause")) {
            $("#playswitch").addClass('fa-play').removeClass('fa-pause');
        }
        clearInterval(timer);
    }

    function setFaStatus() {
        if(currentValue > 1) {
            $(".rdr__js-prev").addClass('rdr__isActive');
        } else {
            $(".rdr__js-prev").removeClass('rdr__isActive');
        }
        if(currentValue < oneDaylength) {
            $(".rdr__js-next").addClass('rdr__isActive');
        } else {
            $(".rdr__js-next").removeClass('rdr__isActive');
        }
    }

    function togglePlayPause() {
        if($(".rdr__js-liveToggle").hasClass('rdr__isActive')) {
            if ($("#playswitch").hasClass("fa-pause")) {
                clearInterval(timer);
                $("#playswitch").addClass('fa-play').removeClass('fa-pause');
            } else if ($("#playswitch").hasClass("fa-play")) {
                if (headStatus) {
                    queue.head = savedHead;
                    headStatus = false;
                    currentValue = savedHead + 1;
                }
                forwardMarker();
                startAutoMap();
                $("#playswitch").addClass('fa-pause').removeClass('fa-play');
            }
        }
    }

    function getMonth(datetime) {
        var arr = datetime.split("-");
        return arr[0] + "-" + arr[1];
    }

    function outputReadInfo(info) {
        var readerinfo =
                "<span class='rdr__infoCard-download'>" +
                "<span class='rdr__infoCard-downloadLocation'>" +
                "<strong>Reader from: </strong>" +
                "<span class='flag-wrapper'>" +
                "<span class='img-thumbnail flag flag-icon-background flag-icon-" + info.countryCode.toLowerCase() + "' style='margin-right: 5px;top: 3px;position: relative;'></span>" +
                "</span>" +
                "<span>" + info.city + ", " + info.countryName + "</span>" +
                "</span>" +
                "<a href='" + info.itemUrls[0] +"' target='_blank' title='Opens in new window.'>" +
                "<span class='rdr__infoCard-article'>" +
                "<span class='rdr__infoCard-title'>" + info.itemTitles[0] + "</span>" +
                "<span class='rdr__infoCard-authors' >" + info.authors + "</span>" +
                "<span class='rdr__infoCard-head'>" + info.collectionTitles + "</span>" +
                "</span>" +
                "</a>" +
                "</span>";

        return readerinfo;
    }

</script>
