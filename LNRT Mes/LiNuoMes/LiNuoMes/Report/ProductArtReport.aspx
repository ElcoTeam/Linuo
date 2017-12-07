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
            CreateSelect();

            $("#DeviceName").change(function () {
                $("#ArtName").empty();
                var optionstring1 = "";
                var DeviceName = $("#DeviceName").val();
                $.ajax({
                    url: "ProductArtReport.aspx/GetArtName",
                    type: "post",
                    dataType: "json",
                    data: "{deviceid:'" + DeviceName + "'}",
                    async: false,
                    contentType: "application/json;charset=utf-8",
                    success: function (data) {
                        var data1 = eval('(' + data.d + ')');
                        var i = 0;
                        for (i in data1) {
                            optionstring1 += "<option value=\"" + data1[i].ArtName + "\" >" + data1[i].ArtName.trim() + "</option>";
                        }
                        $("#ArtName").html("<option value=''>请选择...</option> " + optionstring1);
                    },
                    error: function (msg) {
                        alert("数据访问异常");
                    }
                });
            })
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
                height: $('#areascontent').height()-200,
                colModel: [
                    { label: '主键', name: 'ID', hidden: true },
                    { label: '序号', name: 'Number', index: 'Number', width: 50, align: 'center' },
                    { label: '设备名称', name: 'DeviceName', index: 'DeviceName', width: 300, align: 'left' },
                    { label: '操作者', name: 'UserName', index: 'UserName', width: 200, align: 'left' },
                    { label: '生产工艺', name: 'ProductArt', index: 'ProductArt', width: 300, align: 'left' },
                    { label: '值', name: 'Value', index: 'Value', width: 200, align: 'left' },
                    {
                        label: '记录时间', name: 'Time', index: 'Time', width: 250, align: 'center'
                    },
                    { label: '生产订单', name: 'WorkOrder', index: 'WorkOrder', width: 200, align: 'left' },
                    { label: 'MES码', name: 'RFID', index: 'RFID', width: 200, align: 'left' },
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
                var ProductArt = $("#ArtName").val();
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
                    $("#DeviceName").html("<option value=''>请选择...</option> " + optionstring);
                },
                error: function (msg) {
                    dialogMsg("数据访问异常", -1);
                }
            });

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
            ExportJQGridDataToExcel('#gridTable', '设备生产工艺报表');
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
                        <div class="lr-layout-tool">
                               <div class="lr-layout-tool-left">
                                   <div class="lr-layout-tool-item">
                                       <span class="formTitle">设备名称：</span>
                                       <select class="form-control" id="DeviceName" style="width: 220px;"></select>
                                       <span class="formTitle">生产工艺：</span>
                                       <select class="form-control" id="ArtName" style="width: 220px;"></select>
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
                  </div>
              </div>
         </div>
    </div>
    <style>
         .timeselect {
            width: 150px;
            height: 35px;
            font-size: 20px;
         }
    </style>
</body>
</html>


