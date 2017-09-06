<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ProcessBeatReport.aspx.cs" Inherits="LiNuoMes.Report.ProcessBeatReport" %>

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

            //if ($('#areascontent').height() > $(window).height() - 20) {
            //    $('#areascontent').css("margin-right", "0px");
            //}
            $('#areascontent').height($(window).height() - 106);
            var areaheight = $("#areascontent").height();
            $(window).resize(function (e) {
                window.setTimeout(function () {
                    $('#gridTable').setGridWidth(($('.gridPanel').width()));
                    $('#areascontent').height($(window).height() - 106);
                }, 200);
            });

            InitPage();

            CreateProcessList();

            $("#ProcessName").change(function () {
                CreateDeviceList();
            })
        });

        //加载表格
        function InitPage() {
            //layout布局
            $('#layout').layout({
                applyDemoStyles: true,
                west: {
                    size: $(window).width() * 0.45
                },
                onresize: function () {
                    $(window).resize()
                }
            });

            var selectedRowIndex = 0;
            var $gridTable = $('#gridTable');
            var panelwidth = $('.gridPanel').width();
            $gridTable.jqGrid({
                url: "GetReportInfo.ashx",
                postData: { Action: "ProcessBeatReport" },
                loadonce: true,
                datatype: "local",
                height: $('#areascontent').height() * 0.62,
                colModel: [
                    {   label: '日期', name: 'Date', index: 'Date', width: panelwidth * 0.15, align: 'center' },
                    {
                        label: '工位', name: 'Process', index: 'Process', width: panelwidth * 0.2, align: 'center'
                    },
                    {
                        label: '设备名称', name: 'DeviceName', index: 'DeviceName', width: panelwidth * 0.25, align: 'center'
                    },
                    {
                        label: '节拍最小值', name: 'BeatMin', index: 'BeatMin', width: panelwidth * 0.1, align: 'center'
                    },
                    {
                        label: '节拍最大值', name: 'BeatMax', index: 'BeatMax', width: panelwidth * 0.1, align: 'center'
                    },
                    {
                        label: '节拍平均值', name: 'BeatPer', index: 'BeatPer', width: panelwidth * 0.05, align: 'center'
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
                }
            });

            //查询事件
            $("#spn_Search").click(function () {
                
                if ($("#currentdate").val() == "") {
                    dialogMsg("请选择查询日期", 0);
                    return false;
                }

                $gridTable.jqGrid('setGridParam', {
                    datatype: 'json',
                    postData: {
                        Action: "ProcessBeatReport",
                        SelectDate: $("#currentdate").val(),
                        ProcessCode: $("#ProcessName").val(),
                        DeviceName: $("#DeviceName").val()
                    }
                }).trigger('reloadGrid');

                $.ajax({
                    url: "GetReportInfo.ashx",
                    data: {
                        Action: "ProcessBeatChart",
                        SelectDate: $("#currentdate").val(),
                        ProcessCode: $("#ProcessName").val(),
                        DeviceName: $("#DeviceName").val()
                    },
                    type: "post",
                    datatype: "json",
                    success: function (data) {
                        paint(JSON.parse(data));
                        console.log(JSON.parse(data));
                    },
                    error: function (msg) {
                        dialogMsg("数据访问异常", -1);
                    }
                });
            });

        }

        //加载工序列表
        function CreateProcessList() {
            $("#ProcessName").empty();
            var optionstring = "";
            $.ajax({
                url: "FirstLevelInspectionReport.aspx/GetProcessInfo",
                type: "post",
                dataType: "json",
                data: "{deviceid:''}",
                contentType: "application/json;charset=utf-8",
                success: function (data) {
                    var data1 = eval('(' + data.d + ')');
                    var i = 0;
                    for (i in data1) {
                        optionstring += "<option value=\"" + data1[i].ProcessCode + "\" >" + data1[i].ProcessName.trim() + "</option>";

                    }
                    $("#ProcessName").html("<option value=''>请选择...</option> " + optionstring);


                },
                error: function (msg) {
                    dialogMsg("数据访问异常", -1);
                }
            });

        }

        function CreateDeviceList() {
            //加载设备列表
            $("#DeviceName").empty();
            var optionstring1 = "";
            $.ajax({
                url: "FirstLevelInspectionReport.aspx/GetDeviceInfo",
                type: "post",
                dataType: "json",
                data: "{deviceid:'" + $("#ProcessName").val() + "'}",
                contentType: "application/json;charset=utf-8",
                success: function (data) {
                    if (data.d != '') {
                        var data1 = eval('(' + data.d + ')');
                        var i = 0;
                        for (i in data1) {
                            optionstring1 += "<option value=\"" + data1[i].DeviceCode + "\" >" + data1[i].DeviceName.trim() + "</option>";
                        }
                        $("#DeviceName").html(optionstring1);
                    }
                    else {
                        $("#DeviceName").html("");
                    }

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
                    text: '节拍统计图'
                },
              
                xAxis: {
                    categories: []
                },
                yAxis: {
                    title: {
                        text: '节拍 (s)'
                    },
                    labels: {
                        formatter: function () {
                            return this.value + 's';
                        }
                    }
                },
                
                series: [{
                    type: 'column',
                    name: '最小值',
                    data: serice[0].datavalue
                }, {
                    type: 'column',
                    name: '最大值',
                    data: serice[1].datavalue,
                }, {
                    type: 'column',
                    name: '平均值',
                    data: serice[3].datavalue
                }, {
                    type: 'spline',
                    name: '产线录入节拍值',
                    data: serice[2].datavalue,
                    marker: {
                        lineWidth: 2,
                        lineColor: Highcharts.getOptions().colors[3],
                        fillColor: 'white'
                    },
                    dashStyle:'dash'
                }]
            });
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
        //function btn_export(event) {

        //    ExportJQGridDataToExcel('#gridTable', '能源统计报表');
        //}

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
                                    <th><i class="fa fa-bar-chart fa-lg" style="padding-right: 5px;"></i><strong style="font-size:20px;">节拍统计报表</strong></th>
                                    <td></td>
                                </tr>
                            </table>
                        </div>
                        <div class="panel-body" style="text-align:left">
                            <table id="form1" class="form" border="0">
                                <tr>
                                    <th class="formTitle" >查询日期：</th>
                                    <td class="formValue" >
                                        <input id="currentdate"  type="text"  onfocus="WdatePicker({dateFmt:'yyyy-MM-dd'})"   class="Wdate form-control" style="width:200px;" readonly />
                                    </td>
                                    <th class="formTitle" >工序名称：</th>
                                    <td class="formValue" style="width:300px;" >
                                        <select class="form-control" id="ProcessName"></select>
                                    </td>
                                    <th class="formTitle" >设备名称：</th>
                                    <td class="formValue" colspan="2" >
                                        <select class="form-control" id="DeviceName"></select>
                                    </td>
                                    
                                    <td class="formValue">                                     
                                        <a id="spn_Search" class="btn btn-primary"><i class="fa fa-search"></i>&nbsp;查询</a>  
                                    </td>
                                </tr> 
                            </table>
                           
                        </div>
                    </div>
                </div>
            </div>
        </div>
         
       
        <div class="ui-layout" id="layout" style="height: 85%; width: 100%;">

        <!--统计信息列表-->
        <div class="ui-layout-west">
            <div class="west-Panel">
                <div class="panel-Title">统计信息列表</div>
                <div class="titlePanel">
                <div class="toolbar">
                  <div class="btn-group">
                      <a id="lr-print" class="btn btn-default" onclick="btn_print(event)"><i class="fa fa-print"></i>&nbsp;打印</a>
                      <a id="lr-export" class="btn btn-default trigger-default" onclick="btn_export(event)"><i class="fa fa-plus"></i>&nbsp;导出</a>
                  </div>
                </div>
                </div>
                <div class="ui-report" style="margin-top:0.5%; overflow: hidden; ">
                <div class="gridPanel" id="gridPanel">
                      <div class="printArea">
                          <table id="gridTable"></table>                      
                      </div>
                </div>
                </div>
            </div>
        </div>

        <!--统计信息折线图-->
        <div class="ui-layout-center">
            <div class="center-Panel">
                <div class="panel-Title">统计信息图</div>
                 <div id="container" style="width: 100%; height: 670px; text-align:center;  margin: 0 auto">
           
                 </div>
            </div>
        </div>
        </div>

    </div>
</body>
</html>







