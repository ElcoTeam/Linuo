<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EnergyReport.aspx.cs" Inherits="LiNuoMes.Report.EnergyReport" %>
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
    <script type="text/javascript" src="../js/m.js" charset="gbk"></script>
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
            
            InitPage();
            
            //统计方式选择
            $("#StatisticsType").change(function () {
                $("#currentdate").val("");
                $("#endDate").val("");
                
            });
        });

        //加载表格
        function InitPage() {
            //layout布局
            $('#layout').layout({
                applyDemoStyles: true,
                west: {
                    size: $(window).width() * 0.35
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
                postData: { Action: "EnergyConsumpReport" },
                loadonce: true,
                datatype: "local",
                height: $('#areascontent').height() *0.7,
                colModel: [
                    { label: '序号', name: 'Number', index: 'Number', width: panelwidth * 0.1, align: 'center', sortable: false },
                    { label: '时间', name: 'Date', index: 'Date', width: panelwidth * 0.35, align: 'center' },
                    {
                        label: '消耗电量', name: 'CostValue', index: 'CostValue', width: panelwidth * 0.15, align: 'center'
                    },
                    {
                        label: '显示电量', name: 'DisplayValue', index: 'DisplayValue', width: panelwidth * 0.15, align: 'center'
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
                var selecttype = $("#StatisticsType").val()
                var selectdate = $("#currentdate").val();
                var selectdate1 = $("#endDate").val();
                if (selectdate == "")
                {
                    dialogMsg("请选择查询日期", 0);
                    return false;
                }

                $gridTable.jqGrid('setGridParam', {
                    datatype: 'json',
                    postData: {
                        Action: "EnergyConsumpReport",
                        selecttype: selecttype,
                        selectdate: selectdate,
                        selectdate1: selectdate1
                    }
                }).trigger('reloadGrid');

                $.ajax({
                    url: "GetReportInfo.ashx",
                    data: {
                        Action: "GetEnergyChart",
                        selecttype: selecttype,
                        selectdate: selectdate,
                        selectdate1: selectdate1
                    },
                    type: "post",
                    datatype: "json",
                    success: function (data) {
                        //chart.series[0].setData[data.Date];
                        paint(data);
                    },
                    error: function (msg) {
                        dialogMsg("数据访问异常", -1);
                    }
                });
            });

        }

        function paint(serice) {
            var datavalue = JSON.parse(serice).datavalue;
            var charts = new Highcharts.chart('container', {
                chart: {
                    type: 'line'
                },
                title: {
                    text: '能源统计图'
                },
                //subtitle: {
                //    text: 'Source: WorldClimate.com'
                //},
                xAxis: {
                    categories: []
                },
                yAxis: {
                    title: {
                        text: '电量 (kwh)'
                    },
                    labels: {
                        formatter: function () {
                            return this.value + 'kwh';
                        }
                    }
                },
                tooltip: {
                    crosshairs: true,
                    shared: true
                },
                plotOptions: {
                    line: {
                        dataLabels: {
                            enabled: true          // 开启数据标签
                        }
                        //enableMouseTracking: false // 关闭鼠标跟踪，对应的提示框、点击事件会失效
                    },
                    spline: {
                        marker: {
                            radius: 4,
                            lineColor: '#666666',
                            lineWidth: 1
                        }
                    }
                },
                series: [{
                    name: '消耗电量',
                    data: datavalue
                }]
            });
            //charts.series[0].data=JSON.parse(serice).datavalue;
            charts.xAxis[0].setCategories(JSON.parse(serice).catagory);
            
        }

        //选择日期
        function selectdate() {
            //WdatePicker({ maxDate: '#F{$dp.$D(\'endDate\')}' })
            //按月
            if ($("#StatisticsType").val() == 2) {
                //console.log($("#StatisticsType").val());
                WdatePicker({ maxDate: '#F{$dp.$D(\'endDate\')}', dateFmt: 'yyyy-MM' });
            }
            else {
                WdatePicker({ maxDate: '#F{$dp.$D(\'endDate\')}', dateFmt: 'yyyy-MM-dd' });
            }
        }

        //选择日期
        function selectenddate() {
            //WdatePicker({ minDate: '#F{$dp.$D(\'currentdate\')}' })

            //按月
            if ($("#StatisticsType").val() == 2) {
                //console.log($("#StatisticsType").val());
                WdatePicker({ minDate: '#F{$dp.$D(\'currentdate\')}', dateFmt: 'yyyy-MM' });
            }
            else {
                WdatePicker({ minDate: '#F{$dp.$D(\'currentdate\')}', dateFmt: 'yyyy-MM-dd' });
            }
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
            
            ExportJQGridDataToExcel('#gridTable','能源统计报表');
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
                                    <th><i class="fa fa-bar-chart fa-lg" style="padding-right: 5px;"></i><strong style="font-size:20px;">能耗统计报表</strong></th>
                                    <td></td>
                                </tr>
                            </table>
                        </div>
                        <div class="panel-body" style="text-align:left">
                            <table id="form1" class="form" border="0">
                                <tr>
                                    <th class="formTitle" >统计方式：</th>
                                    <td class="formValue">
                                        <select class="form-control" id="StatisticsType">
                                       
                                           <option value='0'>按小时</option>
                                           <option value='1'>按天</option>
                                           <option value='2'>按月</option>
                                       </select>
                                    </td>

                                    <th class="formTitle" >查询日期：</th>
                                    <td class="formValue" colspan="2" >
                                        <input id="currentdate"  type="text" onfocus="selectdate()"  class="Wdate" readonly /><span id="tag">至</span>
                                        <input id="endDate"  type="text"   onfocus="selectenddate()"    class="Wdate" readonly /> 
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
         
       
        <div class="ui-layout" id="layout" style="height: 100%; width: 100%;">

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
                <div class="panel-Title">统计信息折线图</div>
                 <div id="container" style="width: 80%; height: 740px; text-align:center;  margin: 0 auto">
           
                 </div>
            </div>
        </div>
        </div>

        
           
    </div>
</body>
</html>



