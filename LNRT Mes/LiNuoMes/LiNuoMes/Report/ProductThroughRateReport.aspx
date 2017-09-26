<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ProductThroughRateReport.aspx.cs" Inherits="LiNuoMes.Report.ProductThroughRateReport" %>

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

            fnDate();
            //InitPage();
        });

        //加载表格
        function GetGrid() {
            var selectedRowIndex = 0;
            var $gridTable = $('#gridTable');
            var panelwidth = $('.gridPanel').width();
            $gridTable.jqGrid({
                url: "GetReportInfo.ashx",
                postData: {
                    Action: "ProductThroughRateReport",
                    StartTime: $("#StartTime").val(),
                    EndTime: $("#EndTime").val()
                },
                loadonce: true,
                datatype: "json",
               
                height: $('#areascontent').height() -290,
                colModel: [
                    {
                        label: '日期', name: 'Date', index: 'Date', width: panelwidth * 0.15, align: 'center'
                    },
                    {
                        label: '工序名称', name: 'ProcessName', index: 'ProcessName', width: panelwidth * 0.15, align: 'center'
                    },
                    {
                        label: '加工数量', name: 'ProcessQty', index: 'ProcessQty', width: panelwidth * 0.1, align: 'center'
                    },
                    {
                        label: '报废数量', name: 'ScrapQty', index: 'ScrapQty', width: panelwidth * 0.1, align: 'center'
                    },
                    {
                        label: '未完工数量', name: 'UnFinishQty', index: 'UnFinishQty', width: panelwidth * 0.1, align: 'center'
                    },
                    {
                        label: '补修数量', name: 'RepairQty', index: 'RepairQty', width: panelwidth * 0.1, align: 'center'
                    },
                    {
                        label: '合格率', name: 'PassRate', index: 'PassRate', width: panelwidth * 0.1, align: 'center'
                    },
                    {
                        label: '当日产品直通率', name: 'DailyThroughRate', index: 'DailyThroughRate', width: panelwidth * 0.1, align: 'center'
                    },
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
                    //$("#" + this.id).setSelection(selectedRowIndex, false);
                    //合并单元格
                    var gridName = "gridTable";
                    Merger(gridName, 'Date');
                    //Merger(gridName, 'DailyThroughRate');
                }
            });

            //查询事件
            $("#spn_Search").click(function () {  
                  $gridTable.jqGrid('setGridParam', {
                      datatype: 'json',
                      postData: {
                          Action: "ProductThroughRateReport",
                          StartTime: $("#StartTime").val(),
                          EndTime: $("#EndTime").val()
                      }
                  }).trigger('reloadGrid');
                  
                  GetChart();
            });

            //查询回车
            //$('#ItemName').bind('keypress', function (event) {
            //    if (event.keyCode == "13") {
            //        $('#spn_Search').trigger("click");
            //    }
            //});
            //$('#DATE').bind('onpicking', function (event) {
            //    alert(111);
            //    $('#spn_Search').trigger("click");
            //});
        }

        function Merger(gridName, CellName) {
            //得到显示到界面的id集合  
            var mya = $("#" + gridName + "").getDataIDs();
            //数据总行数  
            var length = mya.length;
            //定义合并行数  
            var rowSpanTaxCount = 1;
            for (var i = 0; i < length; i += rowSpanTaxCount) {
                //从当前行开始比对下面的信息  
                var before = $("#" + gridName + "").jqGrid('getRowData', mya[i]);
                rowSpanTaxCount = 1;
                for (j = i + 1; j <= length; j++) {
                    //和上边的信息对比 如果值一样就合并行数+1 然后设置rowspan 让当前单元格隐藏  
                    var end = $("#" + gridName + "").jqGrid('getRowData', mya[j]);
                    if (before[CellName] == end[CellName]) {
                        rowSpanTaxCount++;
                        $("#" + gridName + "").setCell(mya[j], CellName, '', { display: 'none' });
                    } else {
                        break;
                    }
                }
                $("#" + gridName + "").setCell(mya[i], CellName, '', '', { rowspan: rowSpanTaxCount });
            }
        }

        //加载折线图
        function GetChart()
        {
            $.ajax({
                url: "GetReportInfo.ashx",
                data: {
                    Action: "ProductThroughRateChart",
                    StartTime: $("#StartTime").val(),
                    EndTime: $("#EndTime").val()
                },
                type: "post",
                datatype: "json",
                success: function (data) {
                    paint(JSON.parse(data));
                },
                error: function (msg) {
                    dialogMsg("数据访问异常", -1);
                }
            });
        }

        function paint(serice) {
            //var datavalue = JSON.parse(serice).datavalue;
            var charts = new Highcharts.chart('container', {
               
                title: {
                    text: '产品直通率统计图'
                },
                credits: {
                    enabled: false
                },
                xAxis: {
                    categories: []
                },
                yAxis: {
                    title: {
                        text: '加工数量'
                    },
                    plotLines: [{
                        value: 0,
                        width: 1,
                        color: '#808080'
                    }]
                },
              
                legend: {
                    layout: 'vertical',
                    align: 'right',
                    verticalAlign: 'middle',
                    borderWidth: 0
                },
                series: [{
                    name: serice[0].name,
                    data: serice[0].datavalue
                }, {
                    name: serice[1].name,
                    data: serice[1].datavalue
                }, {
                    name: serice[2].name,
                    data: serice[2].datavalue
                }, {
                    name: serice[3].name,
                    data: serice[3].datavalue
                }]
            });
            //charts.series[0].data=JSON.parse(serice).datavalue;
            charts.xAxis[0].setCategories(serice[0].catagory);

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
        function btn_export(event) {

            var title = $("#title").html();
            ExportJQGridDataToExcel('#gridTable', title);
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
                    $("#EndTime").val( currentdate);
                    GetGrid();
                    GetChart();
                }
            }
        }

    </script>
</head>
<body data-spy="scroll" data-target=".navbar-example" id="body1" class="body">

    <!--nav-->
    <div class="navbar navbar-inverse navbar-fixed-top" id="nav"></div>
    <!--end nav-->
   
    <!--导航栏-->
    <div class="yn jz container-fluid nav-bgn m0" id="menu_wrap"></div>

    <!--主体-->
    <div id="areascontent" style="margin:50px 10px 0px 10px; margin-bottom: 0px; overflow: auto;">
         <div class="rows" style="margin-top:0.5%; margin-bottom: 0.8%; overflow: hidden;">
            <div style="float: left; width: 100%;">
                <div style="height:20%; border: 1px solid #e6e6e6; background-color: #fff;">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <table id="panelheading" border="0" style="width:100%">
                                <tr>
                                    <th><i class="fa fa-bar-chart fa-lg" style="padding-right: 5px;"></i><strong style="font-size:20px;">产品直通率报表</strong></th>
                                    <td></td>
                                </tr>
                            </table>
                        </div>
                         <div class="lr-layout-tool">
                              
                                <div class="lr-layout-tool-left">
                                    <div class="lr-layout-tool-item">
                                        <span class="formTitle">查询日期：</span>
                                        <input id="StartTime"  type="text" onFocus="WdatePicker({maxDate:'#F{$dp.$D(\'EndTime\')}'})" class="Wdate timeselect" readonly />&nbsp;至&nbsp;
                                        <input id="EndTime"  type="text" onFocus="WdatePicker({minDate:'#F{$dp.$D(\'StartTime\')}'})" class="Wdate timeselect" readonly />
                                    </div>
                                    <div class="lr-layout-tool-item" id="multiple_condition_query_item">
                                        <div class="lr-query-btn" id="spn_Search" style="font-size:10px;width:50px;">
                                            <i  class="fa fa-search"></i>&nbsp;查询</>  
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


       <div class="ui-layout" id="layout" style="height: 85%; width: 100%; margin-top:60px;">

        <!--统计信息列表-->
        <div class="ui-layout-west" >
            <div class="west-Panel" style="margin-left:0px;">
                <div class="panel-Title">统计信息列表</div>
                
                <div class="ui-report" style="margin-top:0.5%; overflow: hidden; ">
                <div class="gridPanel" id="gridPanel">
                    <div class="printArea">
                        <div class="grid-title"> 
                            <h2 style="text-align:center;" id="title">产品直通率报表</h2> 
                        </div> 
                        <table id="gridTable"></table>                      
                    </div>
                </div>
                </div>
            </div>
        </div>

        <!--统计信息折线图-->
        <div class="ui-layout-center">
            <div class="center-Panel">
                <div class="panel-Title">统计信息折线图</div>
                 <div id="container" style="width: 100%; height: 680px; text-align:center;  margin: 0 auto">
           
                 </div>
            </div>
        </div>
        </div>
    </div>
    <style>
         .timeselect {
            width: 200px;
            height: 35px;
            font-size: 25px;
            padding-left: 10px;
         }
    </style>
</body>
</html>





