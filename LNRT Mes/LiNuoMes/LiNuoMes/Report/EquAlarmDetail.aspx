<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EquAlarmDetail.aspx.cs" Inherits="LiNuoMes.Report.EquAlarmDetail" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
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
    <script src="../Content/scripts/plugins/jqgrid/grid.locale-cn.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/jqgrid.min.js"></script>
    <script src="../Content/scripts/utils/learun-ui.js"></script>
    <script src="../Content/scripts/utils/learun-form.js"></script>

    <style>
        html, body {
            height: 100%;
            width: 100%;
        }
    </style>
</head>
<body>
    <script>        //var equid = request('equid');        var equid = "<%=Request.QueryString["equid"]%>";              var ProcessName = request('ProcessName');        var DeviceName = request('DeviceName');        var DealWithResult = request('DealWithResult');        var AlarmStartTime = request('AlarmStartTime');        var AlarmEndTime = request('AlarmEndTime');        var DealWithStartTime = request('DealWithStartTime');        var DealWithEndTime = request('DealWithEndTime');        var AlarmItem = request('AlarmItem');        $(function () {
            if ($('#areascontent').height() > $(window).height() - 20) {
                $('#areascontent').css("margin-right", "0px");
            }
            $('#areascontent').height($(window).height());
            //$('#gridTable').setGridWidth(($('.gridPanel').width()));
            var areaheight = $("#areascontent").height();
            $(window).resize(function (e) {
                window.setTimeout(function () {
                    $('#gridTable').setGridWidth(($('.gridPanel').width()));
                    $('#areascontent').height($(window).height());
                }, 200);
            });
            GetGrid();
        });        //加载表格
        function GetGrid() {
            var selectedRowIndex = 0;
            var $gridTable = $('#gridTable');
            $gridTable.jqGrid({
                url: "GetReportInfo.ashx",
                datatype: "json",
                postData: {
                    Action: "EquAlarmDetail",
                    PlcName: decodeURI(equid),
                    ProcessName: ProcessName,
                    DeviceName: DeviceName,
                    DealWithResult: DealWithResult,
                    AlarmStartTime: AlarmStartTime,
                    AlarmEndTime: AlarmEndTime,
                    DealWithStartTime: DealWithStartTime,
                    DealWithEndTime: DealWithEndTime,
                    AlarmItem: AlarmItem
                },
                height: $('#areascontent').height(),
                colModel: [
                  {
                      label: '设备名称', name: 'DeviceName', index: 'DeviceName', width: 200, align: 'left', sortable: false
                  },
                  {
                      label: '报警时间', name: 'AlarmTime', index: 'AlarmTime', width: 200, align: 'left', sortable: false
                  },
                  {
                      label: '报警项', name: 'AlarmItem', index: 'AlarmItem', width: 100, align: 'left', sortable: false
                  }
                ],
                viewrecords: true,
                rowNum: "10000",
                rownumbers: true,
                rownumWidth: 100,
                shrinkToFit: false,
                autowidth: true,
                gridview: true,
                onSelectRow: function () {
                    selectedRowIndex = $("#" + this.id).getGridParam('selrow');
                },
                gridComplete: function () {
                    $("#" + this.id).setSelection(selectedRowIndex, false);

                }
            });

            $gridTable.jqGrid('setLabel', 'rn', '序号', {
                'text-align': 'center'
            });

        }    </script>

    <div id="areascontent" style="margin:0px 10px 0px 10px; margin-bottom: 0px; overflow: auto;">
    
     <div class="rows" style="margin-top:0.5%; overflow: hidden; ">
         
          <div class="gridPanel">
               <table id="gridTable"></table>
          </div>
     </div>
     </div>
  
</body>
</html>
