<div id="home-carousel" class="carousel slide" data-ride="carousel">
    <!-- Indicators -->
    <ol class="carousel-indicators">
        <li data-target="#home-carousel" data-slide-to="0" class=""></li>
        <li data-target="#home-carousel" data-slide-to="1" class=""></li>
        <li data-target="#home-carousel" data-slide-to="2" class="active"></li>
        <%--<li data-target="#home-carousel" data-slide-to="3" class=""></li>--%>
    </ol>
    <!-- Wrapper for slides -->
    <div class="carousel-inner" role="listbox">
        <div class="item active">
            <img src="<%= request.getContextPath()%>/image/home-carousel/img-1.jpg">
        </div>
        <div class="item">
            <img src="<%= request.getContextPath()%>/image/home-carousel/img-2.jpg">
        </div>
        <div class="item">
            <img src="<%= request.getContextPath()%>/image/home-carousel/img-3.jpg">
        </div>
        <%--<div class="item">
            <img src="<%= request.getContextPath()%>/image/home-carousel/img-4.jpg">
        </div>--%>
    </div>
    <!-- Controls -->
    <a class="left carousel-control" href="#home-carousel" role="button" data-slide="prev">
        <span class="glyphicon glyphicon-chevron-left" aria-hidden="true"></span>
        <span class="sr-only">Previous</span>
    </a>
    <a class="right carousel-control" href="#home-carousel" role="button" data-slide="next">
        <span class="glyphicon glyphicon-chevron-right" aria-hidden="true"></span>
        <span class="sr-only">Next</span>
    </a>
</div>