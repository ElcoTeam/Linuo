<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="KeyEquOEEReport.aspx.cs" Inherits="LiNuoMes.Report.KeyEquOEEReport" %>
<!DOCTYPE html>
<html>
<head>
    <title>力诺瑞特平板集热器</title>
     <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="renderer" content="webkit">
    
    <script src="../Content/scripts/jquery-1.11.1.min.js"></script>
    <script src="../Content/scripts/bootstrap/bootstrap.min.js"></script>
    
    <script src="../js/pdfobject.js" type="text/javascript"></script>
    <link href="../Content/scripts/plugins/jquery-ui/jquery-ui.min.css" rel="stylesheet" />
    <script src="../Content/scripts/plugins/jquery-ui/jquery-ui.min.js"></script>
    <!-- Bootstrap -->
    <link rel="stylesheet" type="text/css" href="../css/bootstrap.min.css" />
    <link href="../Content/styles/font-awesome.min.css" rel="stylesheet" />
    <link href="../css/learun-ui.css" rel="stylesheet" />
    <link href="../Content/adminLTE/css/index.css" rel="stylesheet" />
    <link href="../Content/scripts/plugins/jqgrid/jqgrid.css" rel="stylesheet" />
    <link rel="Shortcut icon" href="../images/favicon.ico" />
    <link href="../Content/styles/learun-ui.css" rel="stylesheet" />
    <link href="../css/my.css" rel="stylesheet" media="screen">
    <link href="../Content/scripts/plugins/printTable/learun-report.css" rel="stylesheet" />
    <script src="../Content/scripts/plugins/layout/jquery.layout.js"></script>
    <script src="../Content/scripts/plugins/dialog/dialog.js"></script>
    <script src="../Content/adminLTE/index.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/grid.locale-cn.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/jqgrid.min.js"></script>
    <script src="../Content/scripts/utils/learun-ui.js"></script>
    <script src="../Content/scripts/utils/learun-form.js"></script>
    <script src="../My97DatePicker/WdatePicker.js"></script>
    <script src="../Content/scripts/plugins/printTable/jquery.printTable.js"></script>
    <script src="ExportGridToExcel.js"></script>
    <script src="../js/highchart.js" type="text/javascript"></script>

    <script>
        $(function () {

            if ($('#areascontent').height() > $(window).height() - 20) {
                $('#areascontent').css("margin-right", "0px");
            }
            $('#areascontent').height($(window).height()-106);
            var areaheight = $("#areascontent").height();
            $(window).resize(function (e) {
                window.setTimeout(function () {
                    $('#gridTable').setGridWidth(($('.gridPanel').width()));
                    $('#areascontent').height($(window).height()-106);
                }, 200);
            });
            //GetGrid();
            CreateSelect();
            //fnDate();
            //单一设备OEE  点击查询按钮 
            $("#btn_SearchSingleDevice").click(function () {
                GetChart();
            });

            $("#lr-query-btn").click(function () {
                GetAllChart();
            });
        });

        //加载表格
        function GetGrid() {
            //layout布局
            $('#layout').layout({
                applyDemoStyles: true,
                west: {
                    size: $(window).width() * 0.5
                },
                onresize: function () {
                    $(window).resize()
                }
            });

            var selectedRowIndex = 0;
            var $gridTable = $('#gridTable');
            $gridTable.jqGrid({
                url: "GetReportInfo.ashx",
                loadonce: true,
                datatype: "json",
                postData: {
                    Action: "KeyEquOEEReport",
                    DeviceName: $("#DeviceName").val(),
                    StartTime: $("#StartTime").val(),
                    EndTime: $("#EndTime").val()
                },
                height: $('#areascontent').height() *0.3,
                colModel: [
                    { label: '主键', name: 'ID', hidden: true },
                    { label: '序号', name: 'Number', index: 'Number', width: 50, align: 'center' },
                    {
                        label: '日期', name: 'DATE', index: 'DATE', width: 150, align: 'center'
                    },
                    { label: '设备名称', name: 'DeviceName', index: 'DeviceName', width: 200, align: 'center' },
                    { label: '日历时间', name: 'Calendar', index: 'Calendar', width: 100, align: 'center' },
                    { label: '生产停止时间', name: 'StopTime', index: 'StopTime', width: 150, align: 'center' },
                    {
                        label: '负荷时间', name: 'LoadTime', index: 'LoadTime', width: 100, align: 'center'
                    },
                    { label: '开动率', name: 'UtilizationRate', index: 'UtilizationRate', width: 100, align: 'center' },
                    { label: '设备停机时间', name: 'EquStopTime', index: 'EquStopTime', width: 150, align: 'center' },
                    { label: '运转时间', name: 'RunTime', index: 'RunTime', width: 100, align: 'center' },
                    { label: '时间稼动率', name: 'TimeUtilizationRate', index: 'TimeUtilizationRate', width: 100, align: 'center' },
                    { label: '理论加工周期', name: 'TheoryCycle', index: 'TheoryCycle', width: 150, align: 'center' },
                    { label: '加工数量', name: 'ProcessQty', index: 'ProcessQty', width: 100, align: 'center' },
                    { label: '性能稼动率', name: 'EfficientRate', index: 'EfficientRate', width: 100, align: 'center' },
                    { label: '不良品数量', name: 'DefectiveQty', index: 'DefectiveQty', width: 100, align: 'center' },
                    { label: '良品率', name: 'YieldRate', index: 'YieldRate', width: 100, align: 'center' },
                    { label: 'OEE', name: 'OEE', index: 'OEE', width: 100, align: 'center' },
                ],
                viewrecords: true,
                rowNum: "10000",
                shrinkToFit: false,
                autowidth: true,
                scrollrows: true,
                gridview: true,
                onSelectRow: function () {
                    selectedRowIndex = $("#" + this.id).getGridParam('selrow');
                },
                gridComplete: function () {
                    $("#" + this.id).setSelection(selectedRowIndex, false);
                }
            });

            //查询事件
            $("#btn_Search").click(function () {
                var deviceName = $("#DeviceName").val();
                var StartTime = $("#StartTime").val();
                var EndTime = $("#EndTime").val();

                if (deviceName =="") {
                    dialogAlert("请选择设备名称",0);
                }

                $("#StartTime1").val(StartTime);
                $("#EndTime1").val(EndTime);
                $("#DeviceName1").val(deviceName);

                $gridTable.jqGrid('setGridParam', {
                    datatype: 'json',
                    postData: {
                        Action: "KeyEquOEEReport",
                        DeviceName: deviceName,
                        StartTime: StartTime,
                        EndTime: EndTime
                    }
                }).trigger('reloadGrid');

                GetChart();
            });
        }

        //构造select
        function CreateSelect() {
            $("#DeviceName").empty();
            var optionstring = "";
            $.ajax({
                url: "../Equipment/EquDeviceInfo.aspx/GetDeviceName",
                type: "post",
                dataType: "json",
                data: "{deviceid:''}",
                contentType: "application/json;charset=utf-8",
                success: function (data) {
                    var data1 = eval('(' + data.d + ')');
                    var i = 0;
                    for (i in data1) {
                        optionstring += "<option value=\"" + data1[i].DeviceCode + "\" >" + data1[i].DeviceName.trim() + "</option>";
                    }
                    $("#DeviceName").html(optionstring);
                    $("#DeviceName1").html(optionstring);
                    fnDate();
                    
                },
                error: function (msg) {
                    dialogMsg("数据访问异常", -1);
                }
            });
        }

        //设置默认时间选择
        function fnDate() {
            var xhr = null;
            if (window.XMLHttpRequest) {
                xhr = new window.XMLHttpRequest();
            } else { // ie
                xhr = new ActiveObject("Microsoft")
            }
            // 通过get的方式请求当前文件
            xhr.open("get", "/");
            xhr.send(null);
            // 监听请求状态变化
            xhr.onreadystatechange = function () {
                var time = null,
                    curDate = null;
                if (xhr.readyState === 2) {
                    var seperator1 = "-";
                    // 获取请求头里的时间戳
                    time = xhr.getResponseHeader("Date");
                    //console.log(xhr.getAllResponseHeaders())
                    curDate = new Date(time);
                    var oneweekdate = new Date(curDate.getTime() - 7 * 24 * 3600 * 1000);
                    //当前时间
                    var month = curDate.getMonth() + 1;
                    var strDate = curDate.getDate();
                    if (month >= 1 && month <= 9) {
                        month = "0" + month;
                    }
                    if (strDate >= 0 && strDate <= 9) {
                        strDate = "0" + strDate;
                    }

                    var currentdate = curDate.getFullYear() + seperator1 + month + seperator1 + strDate;

                    //一周前时间
                    var month = oneweekdate.getMonth() + 1;
                    var strDate = oneweekdate.getDate();
                    if (month >= 1 && month <= 9) {
                        month = "0" + month;
                    }
                    if (strDate >= 0 && strDate <= 9) {
                        strDate = "0" + strDate;
                    }
                    var oneweekagodate = oneweekdate.getFullYear() + seperator1 + month + seperator1 + strDate;

                    $("#StartTime").val(oneweekagodate);
                    $("#EndTime").val(currentdate);
                    $("#todayTime").val(currentdate);
                    $("#StartTime1").val(oneweekagodate);
                    $("#EndTime1").val(currentdate);

                    GetGrid();
                    GetChart();
                    GetAllChart();
                }
            }
        }

        //加载单个设备OEE 折线图
        function GetChart() {
            $.ajax({
                url: "GetReportInfo.ashx",
                data: {
                    Action: "KeyEquOEEChart",
                    DeviceName: $("#DeviceName1").val(),
                    StartTime: $("#StartTime1").val(),
                    EndTime: $("#EndTime1").val()
                },
                type: "post",
                datatype: "json",
                success: function (data) {
                    //console.log(data);
                    paint(JSON.parse(data));
                },
                error: function (msg) {
                    dialogMsg("数据访问异常", -1);
                }
            });
        }

        //选择时间内  单个设备OEE统计图
        function paint(serice) {
            //var datavalue = JSON.parse(serice).datavalue;
            var charts = new Highcharts.chart('container1', {
                title: {
                    text: '同一设备不同日期OEE统计图'
                },
                credits: {
                    enabled: false
                },
                xAxis: {
                    categories: []
                },
                yAxis: {
                    title: {
                        text: 'OEE数值'
                    },
                    plotLines: [{
                        value: 0,
                        width: 1,
                        color: '#808080'
                    }]
                },

                //legend: {
                //    layout: 'vertical',
                //    align: 'top',
                //    verticalAlign: 'middle',
                //    borderWidth: 0
                //},
                series: [{
                    name: $("#DeviceName").find("option:selected").text(),
                    data: serice.datavalue
                }]
            });
            //charts.series[0].data=JSON.parse(serice).datavalue;
            charts.xAxis[0].setCategories(serice.catagory);

        }


        //加载多个设备OEE 折线图
        function GetAllChart() {
            $.ajax({
                url: "GetReportInfo.ashx",
                data: {
                    Action: "KeyEquAllOEEChart",
                    todayTime: $("#todayTime").val()
                },
                type: "post",
                datatype: "json",
                success: function (data) {
                    
                    paintAllChart(data);
                },
                error: function (msg) {
                    dialogMsg("数据访问异常", -1);
                }
            });
        }


        //选择时间内  多个设备OEE柱状图
        function paintAllChart(serice) {
            var data = JSON.parse(serice)
            //console.log(JSON.parse(serice));
            //var serice = [{ "name": "数控冲孔翻边旋压机", "y": 32 }, { "name": "数控盘管无屑开料机", "y": 0 }, { "name": "火焰焊机", "y": 0 }, { "name": "双工位激光焊接机", "y": 0 }, { "name": "底板上料机", "y": 0 }, { "name": "玻璃板上料机", "y": 0 }, { "name": "热缩机", "y": 0 }, { "name": "打包机", "y": 0 }, { "name": "单组份涂胶机", "y": 0 }, { "name": "组框、压合设备", "y": 0 }, { "name": "ABB玻璃板涂胶机器人", "y": 0 }, { "name": "ABB铜管加工中心机器人", "y": 32 }, { "name": "ABB铜管压弯机器人", "y": 0 }, { "name": "ABB底板涂胶机器人", "y": 0 }, { "name": "ABB码垛机器人", "y": 0 }, { "name": "气密性检测仪", "y": 0 }];
            var charts = new Highcharts.chart('container', {
                chart: {
                    type: 'column'
                },
                title: {
                    text: '不同设备OEE'
                },
                credits: {
                    enabled: false
                },
                xAxis: {
                    type: 'category'
                },
                yAxis: {
                    title: {
                        text: 'OEE数值'
                    }
                },
                legend: {
                    enabled: false
                },
                plotOptions: {
                    series: {
                        borderWidth: 0,
                        dataLabels: {
                            enabled: true,
                            format: '{point.y:.1f}%'
                        }
                    }
                },
                tooltip: {
                    headerFormat: '<span style="font-size:11px">{series.name}</span><br>',
                    pointFormat: ' <span style="color:{point.color}">{point.name}</span>: <b>{point.y:.2f}%</b> of total<br/>'
                },
                series: [{
                    name: '设备OEE',
                    colorByPoint: true,
                    data: []
                }]
            });
            charts.series[0].setData(data);

        }
        //打印
        function btn_print(event) {
            try {
                $("#gridPanel").printTable(gridPanel);
            } catch (e) {
                dialogMsg("Exception thrown: " + e, -1);
            }
        }

        //导出
        function btn_export(event)
        {
            ExportJQGridDataToExcel('#gridTable', '关键设备OEE报表');
        }

    </script>
</head>
<body data-spy="scroll" data-target=".navbar-example" id="body">
    
    <!--nav-->
    <div class="navbar navbar-inverse navbar-fixed-top" id="nav">
        
    </div>
    <!--end nav-->
   
    <!--导航栏-->
    <div class="yn jz container-fluid nav-bgn m0" id="menu_wrap">
      
    </div>

    <!--主体-->
    <div id="areascontent" style="margin:50px 10px 0 10px; margin-bottom: 0px; overflow: auto;">
         <div class="rows" style="margin-top:0.5%; margin-bottom: 0.8%; overflow: hidden;">
            <div style="float: left; width: 100%;">
                <div style="height:20%; border: 1px solid #e6e6e6; background-color: #fff;">
                    <div class="panel panel-default">
                        <div class="panel-heading"><i class="fa fa-bar-chart fa-lg" style="padding-right: 5px;"></i><strong style="font-size:20px;">关键设备OEE报表</strong></div>
                        <div class="lr-layout-tool">
                               <div class="lr-layout-tool-left">
                                   <div class="lr-layout-tool-item">
                                       <span class="formTitle">设备名称：</span>
                                       <select class="form-control" id="DeviceName" style="width: 220px;"></select>
                                       <span class="formTitle">查询日期：</span>
                                       <input id="StartTime"  type="text" onFocus="WdatePicker({maxDate:'#F{$dp.$D(\'EndTime\')}'})" class="Wdate timeselect" />&nbsp;至&nbsp;
                                       <input id="EndTime"  type="text" onFocus="WdatePicker({minDate:'#F{$dp.$D(\'StartTime\')}'})" class="Wdate timeselect" /> 
                                   </div>
                                   <div class="lr-layout-tool-item" id="multiple_condition_query_item">
                                        <div id="multiple_condition_query" class="lr-query-wrap">
                                            <div class="lr-query-btn" id="btn_Search" style="font-size:10px;">
                                                <i class="fa fa-search"></i>&nbsp;查询
                                            </div>
                                            
                                        </div>
                                   </div>
                                </div>
                                <div class=" lr-layout-tool-right">
                                     <div class="btn-group">
                                         <a id="lr-print" class="btn btn-default" onclick="btn_print(event)"><i class="fa fa-print"></i>&nbsp;打印</a>
                                         <a id="lr-export" class="btn btn-default trigger-default" onclick="btn_export(event)"><i class="fa fa-plus"></i>&nbsp;导出</a>
                                     </div>
                                 </div>
                           </div>
                    </div>
                </div>
            </div>
        </div>
       
         <div class="ui-report" style="margin-top:2.5%; overflow: hidden; ">
              <div class="gridPanel" id="gridPanel">
                  <div class="printArea">
                      <table id="gridTable"></table>  
                      <div id="gridPager"></div>                    
                  </div>
              </div>
         </div>

        <div class="ui-layout" id="layout" style="height: 48%; width: 100%;">

        <!--统计信息折线图-->
        <div class="ui-layout-west">
            <div class="west-Panel" style="margin-left:0px; margin-top: 5px;">
                <%--<div class="panel-Title">统计信息折线图</div>--%>
                <div class="lr-layout-tool">
                     <div class="lr-layout-tool-left">
                          <div class="lr-layout-tool-item">
                              <span class="formTitle">查询日期：</span>
                              <input id="todayTime"  type="text" onFocus="WdatePicker()" class="Wdate timeselect" /> 
                          </div> 
                          <div class="lr-layout-tool-item" id="multiple_condition_query_item1">
                              <div id="multiple_condition_query1" class="lr-query-wrap">
                                  <div class="lr-query-btn" id="btn_SearchAllDevice" style="font-size:10px;">
                                      <i class="fa fa-search"></i>&nbsp;查询
                                  </div>
                                  
                              </div>
                           </div>
                      </div>            
                </div>
                <div id="container" style="width: 100%; height: 350px; text-align:center;  margin: 0 auto; margin-top: 50px;">
           
                </div>
            </div>
        </div>

        <!--统计信息折线图-->
        <div class="ui-layout-center">
            <div class="center-Panel" style="margin-right:0px; margin-top: 5px;">
               <%-- <div class="panel-Title">统计信息折线图</div>--%>
              <div class="lr-layout-tool" style="margin: 0px;">
                     <div class="lr-layout-tool-left">
                         <div class="lr-layout-tool-item">
                             <span class="formTitle">设备名称：</span>
                             <select class="form-control" id="DeviceName1" style="width: 220px;"></select>
                             <span class="formTitle">查询日期：</span>
                             <input id="StartTime1"  type="text" onFocus="WdatePicker({maxDate:'#F{$dp.$D(\'EndTime\')}'})" class="Wdate timeselect" />&nbsp;至&nbsp;
                             <input id="EndTime1"  type="text" onFocus="WdatePicker({minDate:'#F{$dp.$D(\'StartTime\')}'})" class="Wdate timeselect" /> 
                         </div>
                         <div class="lr-layout-tool-item" id="multiple_condition_query_item2">
                              <div id="multiple_condition_query2" class="lr-query-wrap">
                                  <div class="lr-query-btn" id="btn_SearchSingleDevice" style="font-size:10px;">
                                      <i class="fa fa-search"></i>&nbsp;查询
                                  </div>
                                  
                              </div>
                           </div>
                      </div>
                               
                </div>
                <div id="container1" style="width: 100%; height: 350px; text-align:center;  margin: 0 auto; margin-top: 50px;">
           
                </div>
            </div>
        </div>
        </div>
    </div>
   
</body>
</html>

