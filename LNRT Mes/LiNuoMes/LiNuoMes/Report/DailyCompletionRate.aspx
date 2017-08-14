
<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DailyCompletionRate.aspx.cs" Inherits="LiNuoMes.Report.DailyCompletionRate" %>

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
            fnDate();
            
        });

        //加载表格
        function InitPage() {
            var selectedRowIndex = 0;
            var $gridTable = $('#gridTable');
            var panelwidth = $('.gridPanel').width();
            $gridTable.jqGrid({
                url: "GetReportInfo.ashx",
                postData: { Action: "DailyCompletionRateReport" },
                loadonce: true,
                datatype: "local",
                height: $('#areascontent').height() *0.64,
                colModel: [
                    { label: '序号', name: 'Number', index: 'Number', width: 50, align: 'center' },
                    { label: '日期', name: 'Date', index: 'Date', width: panelwidth*0.15, align: 'center' },
                    {
                        label: '当日SAP派工数量', name: 'DispatchNum', index: 'DispatchNum', width: panelwidth * 0.1, align: 'center'
                    },
                    {
                        label: '当日SAP派工过账数量', name: 'SAPPostNum', index: 'SAPPostNum', width: panelwidth * 0.1, align: 'center'
                    },
                    {
                        label: '当日过账数量', name: 'PostNum', index: 'PostNum', width: panelwidth * 0.1, align: 'center'
                    },
                    {
                        label: '订单准确率', name: 'OrderAccuracy', index: 'OrderAccuracy', width: panelwidth * 0.1, align: 'center'
                    },
                    {
                        label: '订单及时率', name: 'TimelyRate', index: 'TimelyRate', width: panelwidth * 0.1, align: 'center'
                    },
                    {
                        label: '出勤人数', name: 'AttendanceNum', index: 'AttendanceNum', width: panelwidth * 0.1, align: 'center'
                    },
                    {
                        label: '当日工作时间', name: 'WorkHour', index: 'WorkHour', width: panelwidth * 0.1, align: 'center'
                    },
                    {
                        label: '出勤时间', name: 'AttendanceTime', index: 'AttendanceTime', width: panelwidth * 0.1, align: 'center'
                    },
                    {
                        label: '有效生产时间', name: 'EffectiveTime', index: 'EffectiveTime', width: panelwidth * 0.1, align: 'center'
                    },
                    {
                        label: '有效生产时间效率', name: 'EffectiveRate', index: 'EffectiveRate', width: panelwidth * 0.1, align: 'center'
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
                          YEAR: $("#YEAR").val(),
                          MONTH: $("#MONTH").val()
                      }
                  }).trigger('reloadGrid');
              
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
                    // 获取请求头里的时间戳
                    time = xhr.getResponseHeader("Date");
                    //console.log(xhr.getAllResponseHeaders())
                    curDate = new Date(time);
                    var month = curDate.getMonth() + 1;
                    if (month >= 1 && month <= 9) {
                        month = "0" + month;
                    }
                   
                    $('#YEAR').val(curDate.getFullYear());
                    $('#MONTH').val(month);

                    var year = $("#YEAR").val();
                    var month = $("#MONTH").val();
                    $("#title").html(year + '年' + month + '月' + '每日生产完成率报表');
                }
            }

        }

        function settitle()
        {
            var year = $("#YEAR").val();
            var month = $("#MONTH").val();
            $("#title").html(year + '年' + month + '月' + '每日生产完成率报表');

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
                                    <th><i class="fa fa-bar-chart fa-lg" style="padding-right: 5px;"></i><strong style="font-size:20px;">每日生产完成率报表</strong></th>
                                    <td></td>
                                </tr>
                            </table>
                        </div>
                        <div class="panel-body" style="text-align:left">
                            <table id="form1" class="form" border="0">
                                <tr>
                                    <th class="formTitle" >查询日期：</th>
                                    <td class="formValue" colspan="2" >
                                        <input  id="YEAR" type="text"  class="Wdate timeselect"  onfocus="WdatePicker({dateFmt:'yyyy',onpicked:settitle})" readonly/>&nbsp;年&nbsp;
                                        <input  id="MONTH" type="text" class="Wdate timeselect"  onfocus="WdatePicker({dateFmt:'MM',onpicked:settitle})" readonly/> &nbsp;月&nbsp;
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
    </div>
</body>
</html>


