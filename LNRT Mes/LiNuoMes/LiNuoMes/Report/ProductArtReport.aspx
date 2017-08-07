<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ProductArtReport.aspx.cs" Inherits="LiNuoMes.Report.ProductArtReport" %>

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
            $gridTable.jqGrid({
                url: "GetReportInfo.ashx",
                postData: { Action: "ProductArtReport" },
                loadonce: true,
                datatype: "local",
                height: $('#areascontent').height() *0.7,
                colModel: [
                    { label: '主键', name: 'ID', hidden: true },
                    { label: '序号', name: 'Number', index: 'Number', width: 50, align: 'center' },
                    { label: '设备名称', name: 'DeviceName', index: 'DeviceName', width: 200, align: 'center' },
                    { label: '生产工艺', name: 'ProductArt', index: 'ProductArt', width: 100, align: 'center' },
                    { label: '值', name: 'Value', index: 'Value', width: 100, align: 'center' },
                    {
                        label: '记录时间', name: 'Time', index: 'Time', width: 150, align: 'center'
                    },
                    { label: '生产订单', name: 'WorkOrder', index: 'WorkOrder', width: 200, align: 'left' },
                    { label: 'RFID码', name: 'RFID', index: 'RFID', width: 200, align: 'left' },
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
                var ProductArt = $("#ProductArt").val();
                var StartTime = $("#StartTime").val();
                var EndTime = $("#EndTime").val();

                if (!$('#form1').Validform()) {
                    return false;
                }

                $gridTable.jqGrid('setGridParam', {
                    datatype: 'json',
                    postData: {
                        Action: "ProductArtReport",
                        DeviceName: deviceName,
                        Product: ProductArt,
                        StartTime: StartTime,
                        EndTime: EndTime
                    }
                }).trigger('reloadGrid');
            });

            //查询回车
            //$('#orderno').bind('keypress', function (event) {
            //    if (event.keyCode == "13") {
            //        $('#btn_Search').trigger("click");
            //    }
            //});
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
            ExportJQGridDataToExcel('#gridTable', '生产工艺报表');
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
                        <div class="panel-heading"><i class="fa fa-bar-chart fa-lg" style="padding-right: 5px;"></i><strong style="font-size:20px;">设备生产工艺报表</strong></div>
                        <div class="panel-body">
                            <table id="form1" class="form">
                                <tr>
                                    <th class="formTitle">设备名称<font face="宋体">*</font></th>
                                    <td class="formValue">
                                        <input type="text" class="form-control" id="DeviceName" placeholder="请输入设备名称" isvalid="yes" checkexpession="NotNull">
                                    </td>
                                    <th class="formTitle">生产工艺<font face="宋体">*</font></th>
                                    <td class="formValue">
                                        <input type="text" class="form-control" id="ProductArt" placeholder="请输入设备名称" isvalid="yes" checkexpession="NotNull">
                                    </td>
                                </tr>
                               
                                 <tr>
                                    <th class="formTitle">查询日期</th>
                                    <td class="formValue" colspan="2">
                                          <input id="StartTime"  type="text" onFocus="WdatePicker({maxDate:'#F{$dp.$D(\'EndTime\')}'})"  class="Wdate timeselect" />&nbsp;至&nbsp;
                                          <input id="EndTime"  type="text" onFocus="WdatePicker({minDate:'#F{$dp.$D(\'StartTime\')}'})"  class="Wdate timeselect" /> 
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
                      <table id="gridTable"></table>                      
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


