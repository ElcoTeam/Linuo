<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ProductionStatisticeReport.aspx.cs" Inherits="LiNuoMes.Report.ProductionStatisticeReport" %>

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
    <script src="../Content/scripts/plugins/validator/validator.js"></script>

    <script>
        $(function () {
            var n = 1;
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
            GetGrid();
            
        });

        //加载表格
        function GetGrid() {
            var selectedRowIndex = 0;
            var $gridTable = $('#gridTable');
            var $gridTable1 = $('#gridTable1');
            var $gridTable2 = $('#gridTable2');
            var $gridTable3 = $('#gridTable3');
            var panelwidth = $('.gridPanel').width();

            //订单生产情况
            $gridTable.jqGrid({
                url: "GetReportInfo.ashx",
                postData: { Action: "OrderProductInfo" },
                loadonce: true,
                datatype: "local",
                height: $('#areascontent').height() *0.5,
                colModel: [
                    { label: '序号', name: 'Number', index: 'Number', width: 50, align: 'center' },
                    { label: '订单编号', name: 'WorkOrderNumber', index: 'WorkOrderNumber', width: 200, align: 'center' },
                    {
                        label: '订单类型', name: 'WorkOrderVersion', index: 'WorkOrderVersion', width: 100, align: 'center',
                        formatter: function (cellvalue, options, rowObject) {
                            if (rowObject.WorkOrderVersion == 0) {
                                return "正常订单";
                            }
                            else
                                return "下线补单";
                        }
                    },
                    { label: '开始时间', name: 'StartTime', index: 'StartTime', width: 200, align: 'center' },
                    { label: '完成时间', name: 'FinishTime', index: 'FinishTime', width: 200, align: 'center' },
                    {
                        label: '产品物料编码', name: 'ItemNumber', index: 'ItemNumber', width: 150, align: 'center'
                    },
                    { label: '产品物料描述', name: 'ItemDsca', index: 'ItemDsca', width: 250, align: 'left' },
                    { label: '单位', name: 'UOM', index: 'UOM', width: 100, align: 'center' },
                    { label: '订单数量', name: 'ErpPlanQty', index: 'ErpPlanQty', width: 100, align: 'center' },
                    { label: '完成数量', name: 'MesFinishQty', index: 'MesFinishQty', width: 100, align: 'center' },
                    { label: '欠产数量', name: 'UnFinishQty', index: 'UnFinishQty', width: 100, align: 'center' },
                    { label: '返工数量', name: 'BackQty', index: 'BackQty', width: 100, align: 'center' },
                    { label: '预算完成率', name: 'FinishRate', index: 'FinishRate', width: 100, align: 'center' },
                ],
                viewrecords: true,
                rowNum: "10000",
                shrinkToFit: false,
                autowidth: true,
                scrollrows: true,
                gridview: true
            });

            //下线情况
            $gridTable1.jqGrid({
                url: "GetReportInfo.ashx",
                postData: { Action: "AbnormalInfo" },
                loadonce: true,
                datatype: "local",
                height: $('#areascontent').height() * 0.23,
                colModel: [
                    { label: '工序名称', name: 'ProcessName', index: 'ProcessName', width: panelwidth*0.2, align: 'center' },
                    { label: '报废数量', name: 'RejectQty', index: 'RejectQty', width: panelwidth * 0.2, align: 'center' },
                    { label: '未完工数量', name: 'UnFinishQty', index: 'UnFinishQty', width: panelwidth * 0.2, align: 'center' },
                    { label: '补修数量', name: 'RepairQty', index: 'RepairQty', width: panelwidth * 0.2, align: 'center' },
                    {
                        label: '总下线数量', name: 'SumAbnormalQty', index: 'SumAbnormalQty', width: panelwidth * 0.2, align: 'center'
                    },
                ],
                viewrecords: true,
                rowNum: "10000",
                shrinkToFit: false,
                autowidth: true,
                scrollrows: true,
                gridview: true
            });

            //设备报警情况
            $gridTable2.jqGrid({
                url: "GetReportInfo.ashx",
                postData: { Action: "EquAlarmInfo" },
                loadonce: true,
                datatype: "local",
                height: $('#areascontent').height() * 0.3,
                colModel: [
                    { label: '工序名称', name: 'ProcessName', index: 'ProcessName', width: panelwidth * 0.2, align: 'center' },
                    { label: '设备名称', name: 'DeviceName', index: 'DeviceName', width: panelwidth * 0.2, align: 'center' },
                    { label: '报警项', name: 'AlarmItem', index: 'AlarmItem', width: panelwidth * 0.2, align: 'center' },
                    { label: '报警次数', name: 'AlarmTimes', index: 'AlarmTimes', width: panelwidth * 0.2, align: 'center' },
                   
                ],
                viewrecords: true,
                rowNum: "10000",
                shrinkToFit: false,
                autowidth: true,
                scrollrows: true,
                gridview: true
            });

            //物料拉动情况
            $gridTable3.jqGrid({
                url: "GetReportInfo.ashx",
                postData: { Action: "MaterialPullInfo" },
                loadonce: true,
                datatype: "local",
                height: $('#areascontent').height() * 0.3,
                colModel: [
                    { label: '工序名称', name: 'ProcessName', index: 'ProcessName', width: panelwidth * 0.2, align: 'center' },
                    { label: '物料名称', name: 'ItemName', index: 'ItemName', width: panelwidth * 0.2, align: 'center' },
                    { label: '拉动次数', name: 'PullTimes', index: 'PullTimes', width: panelwidth * 0.2, align: 'center' },
                    { label: '超时次数', name: 'OverTimes', index: 'OverTimes', width: panelwidth * 0.2, align: 'center' },
                ],
                viewrecords: true,
                rowNum: "10000",
                shrinkToFit: false,
                autowidth: true,
                scrollrows: true,
                gridview: true
            });

            //查询事件
            $("#btn_Search").click(function () {

                if (!$('#form1').Validform()) {
                    return false;
                }

                var StartTime = $("#StartTime").val();
                var EndTime = $("#EndTime").val();
                $("#title").html(StartTime + '至' + EndTime + '生产统计报表');

                $gridTable.jqGrid('setGridParam', {
                    datatype: 'json',
                    postData: {
                        StartTime: StartTime,
                        EndTime: EndTime
                    }
                }).trigger('reloadGrid');

                $gridTable1.jqGrid('setGridParam', {
                    datatype: 'json',
                    postData: {
                        StartTime: StartTime,
                        EndTime: EndTime
                    }
                }).trigger('reloadGrid');

                $gridTable2.jqGrid('setGridParam', {
                    datatype: 'json',
                    postData: {
                        StartTime: StartTime,
                        EndTime: EndTime
                    }
                }).trigger('reloadGrid');

                $gridTable3.jqGrid('setGridParam', {
                    datatype: 'json',
                    postData: {
                        StartTime: StartTime,
                        EndTime: EndTime
                    }
                }).trigger('reloadGrid');
            });
        }
        
        function settitle() {
            $('.poptip').remove();
            $('.input-error').remove();
        }

        //打印
        function btn_print(event) {
            try {
                $("#gridPanel").printTable();
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
                        <div class="panel-heading"><i class="fa fa-bar-chart fa-lg" style="padding-right: 5px;"></i><strong style="font-size:20px;">生产统计报表</strong></div>
                        <div class="panel-body">
                            <table id="form1" class="form">
                                 <tr>
                                    <th class="formTitle">查询日期：</th>
                                    <td class="formValue" colspan="2">
                                          <input id="StartTime"  type="text" onFocus="WdatePicker({onpicked:settitle,maxDate:'#F{$dp.$D(\'EndTime\')}'})"  class="Wdate timeselect" isvalid="yes" checkexpession="NotNull" />&nbsp;至&nbsp;
                                          <input id="EndTime"  type="text" onFocus="WdatePicker({onpicked:settitle,minDate:'#F{$dp.$D(\'StartTime\')}'})"  class="Wdate timeselect" isvalid="yes" checkexpession="NotNull" /> 
                                    </td> 
                                    <td class="formValue">
                                        <a id="btn_Search" class="btn btn-primary"><i class="fa fa-search"></i>&nbsp;查询</a>                        
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
                      <div class="panel-Title">订单生产情况</div>
                      <table id="gridTable"></table>                 
                  </div>
                  <div class="panel-Title">下线情况</div>
                  <div class="printArea">           
                       <table id="gridTable1"></table>   
                  </div>
                  <div class="panel-Title">设备报警情况</div>
                  <div class="printArea">           
                       <table id="gridTable2"></table>   
                  </div>
                  <div class="panel-Title">物料拉动情况</div>
                   <div class="printArea">           
                       <table id="gridTable3"></table>   
                  </div>
              </div>
         </div>
    </div>
    <style>
         .timeselect {
            width: 250px;
            height: 35px;
            font-size: 25px;
         }
    </style>
</body>
</html>



