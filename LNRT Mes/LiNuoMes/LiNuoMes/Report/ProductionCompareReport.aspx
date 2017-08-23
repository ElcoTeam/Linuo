<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ProductionCompareReport.aspx.cs" Inherits="LiNuoMes.Report.ProductionCompareReport" %>

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
           
        });

        //加载表格
        function InitPage() {
            var selectedRowIndex = 0;
            var $gridTable = $('#gridTable');
            var panelwidth = $('.gridPanel').width();
            $gridTable.jqGrid({
                url: "GetReportInfo.ashx",
                postData: { Action: "ProductionCompareReport" },
                loadonce: true,
                datatype: "local",
                height: $('#areascontent').height() *0.16,
                colModel: [
                    { label: '年度', name: 'Date', index: 'Date', width: panelwidth*0.08, align: 'center' },
                    {
                        label: '1月产量', name: '1', index: '1', width: panelwidth * 0.07, align: 'center'
                    },
                    {
                        label: '2月产量', name: '2', index: '2', width: panelwidth * 0.07, align: 'center'
                    },
                    {
                        label: '3月产量', name: '3', index: '3', width: panelwidth * 0.07, align: 'center'
                    },
                    {
                        label: '4月产量', name: '4', index: '4', width: panelwidth * 0.07, align: 'center'
                    },
                    {
                        label: '5月产量', name: '5', index: '5', width: panelwidth * 0.07, align: 'center'
                    },
                    {
                        label: '6月产量', name: '6', index: '6', width: panelwidth * 0.07, align: 'center'
                    },
                    {
                        label: '7月产量', name: '7', index: '7', width: panelwidth * 0.07, align: 'center'
                    },
                    {
                        label: '8月产量', name: '8', index: '8', width: panelwidth * 0.07, align: 'center'
                    },
                    {
                        label: '9月产量', name: '9', index: '9', width: panelwidth * 0.07, align: 'center'
                    },
                    {
                        label: '10月产量', name: '10', index: '10', width: panelwidth * 0.07, align: 'center'
                    },
                    {
                        label: '11月产量', name: '11', index: '11', width: panelwidth * 0.07, align: 'center'
                    },
                    {
                        label: '12月产量', name: '12', index: '12', width: panelwidth * 0.07, align: 'center'
                    },
                    {
                        label: '汇总产量', name: 'sumcount', index: 'sumcount', width: panelwidth * 0.08, align: 'center'
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

                  $gridTable.jqGrid('setGridParam', {
                      datatype: 'json',
                      postData: {
                          StartYear : $("#StartYear").val(),
                          EndYear: $("#EndYear").val()
                      }
                  }).trigger('reloadGrid');

                  $.ajax({
                      url: "GetReportInfo.ashx",
                      data: {
                          Action: "ProductionCompareChart",
                          StartYear: $("#StartYear").val(),
                          EndYear: $("#EndYear").val()
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
              
            });

        }


        function paint(serice) {
            //var datavalue = JSON.parse(serice).datavalue;
            var charts = new Highcharts.chart('container', {
                chart: {
                    type: 'column'
                },
                title: {
                    text: '年度产量对比统计图'
                },
                credits: {
                    enabled: false
                },
                xAxis: {
                    categories: []
                },
                yAxis: {
                    min: 0,
                    title: {
                        text: '产量'
                    }
                },
                tooltip: {
                    headerFormat: '<span style="font-size:10px">{point.key}</span><table>',
                    pointFormat: '<tr><td style="color:{series.color};padding:0">{series.name}: </td>' +
                    '<td style="padding:0"><b>{point.y:.1f} </b></td></tr>',
                    footerFormat: '</table>',
                    shared: true,
                    useHTML: true
                },
                plotOptions: {
                    column: {
                        pointPadding: 0.2,
                        borderWidth: 0
                    }
                },
                series: [{
                    name: $("#StartYear").val(),
                    data: serice.datavalueFirst
                }, {
                    name: $("#EndYear").val(),
                    data: serice.datavalueSecond
                }]
            });
            //charts.series[0].data=JSON.parse(serice).datavalue;
            charts.xAxis[0].setCategories(serice.catagory);

        }


        function settitle()
        {
            var startYear = $("#StartYear").val();
            var endYear = $("#EndYear").val();
            $("#title").html(startYear + '年与' + endYear + '年年度产量对比报表');
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
                                    <th><i class="fa fa-bar-chart fa-lg" style="padding-right: 5px;"></i><strong style="font-size:20px;">年度产量对比报表</strong></th>
                                    <td></td>
                                </tr>
                            </table>
                        </div>
                        <div class="panel-body" style="text-align:left">
                            <table id="form1" class="form" border="0">
                                <tr>
                                    <th class="formTitle" >对比年份1：</th>
                                    <td class="formValue">
                                        <input  id="StartYear" type="text"  class="Wdate timeselect"  onfocus="WdatePicker({dateFmt:'yyyy',onpicked:settitle,maxDate:'#F{$dp.$D(\'EndYear\')}'})" readonly/>
                                    </td>
                                    <th class="formTitle" >对比年份2：</th>
                                    <td class="formValue">
                                        <input  id="EndYear" type="text"  class="Wdate timeselect"  onfocus="WdatePicker({dateFmt:'yyyy',onpicked:settitle,minDate:'#F{$dp.$D(\'StartYear\')}'})" readonly/>
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
                      <div class="grid-title"> 
                          <h2 style="text-align:center;" id="title"></h2> 
                     </div> 
                      <table id="gridTable"></table>                      
                  </div>
              </div>
         </div>

          <div class="center-Panel">
                <div class="panel-Title">统计信息柱状图</div>
                 <div id="container" style="width: 100%; height: 400px; text-align:center;  margin: 0 auto">
           
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
