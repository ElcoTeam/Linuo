<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SecondLevelInspectionReport.aspx.cs" Inherits="LiNuoMes.Report.SecondLevelInspectionReport" %>

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

   <%-- <link href="../Content/adminLTE/css/index.css" rel="stylesheet" />--%>
    <link href="../Content/scripts/plugins/jqgrid/jqgrid.css" rel="stylesheet" />
    <link rel="Shortcut icon" href="../images/favicon.ico" />
    <link href="../Content/styles/learun-ui.css" rel="stylesheet" />
    <link href="../css/my.css" rel="stylesheet" media="screen">
   <%-- <link href="../Content/scripts/plugins/printTable/learun-report.css" rel="stylesheet" />--%>
    <link href="../Content/styles/learun-report.css" rel="stylesheet" />
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
            $('#areascontent').height($(window).height() - 106);
            var areaheight = $("#areascontent").height();
            $(window).resize(function (e) {
                window.setTimeout(function () {
                    $('#gridTable').setGridWidth(($('.gridPanel').width()));
                    $('#gridTable1').setGridWidth(($('.gridPanel').width()));
                    $('#gridTable2').setGridWidth(($('.gridPanel').width()));
                    $('#areascontent').height($(window).height() - 106);
                }, 200);
            });
            InitPage();
           
        });

        //加载表格
        function InitPage() {
            var selectedRowIndex = 0;
            var $gridTable = $('#gridTable');
            var $gridTable1 = $('#gridTable1');
            var $gridTable2 = $('#gridTable2');
            var panelwidth = $('.gridPanel').width();
            $gridTable.jqGrid({
                url: "GetReportInfo.ashx",
                postData: { Action: "SecondLevelInspectionReport" },
                loadonce: true,
                datatype: "local",
                height: $('#areascontent').height() * 0.3,
                colModel: [
                      { label: '日期', name: 'PmDate', index: 'PmDate', width: 100, align: 'left', sortable: false },
                      { label: '设备', name: 'DeviceCode', index: 'DeviceCode', width: 100, align: 'left', sortable: false },
                      { label: '设备名称', name: 'DeviceName', index: 'DeviceName', width: 200, align: 'left', sortable: false },
                      { label: '规格型号', name: 'DeviceKind', index: 'DeviceKind', width: 100, align: 'left', sortable: false },
                      { label: '电源线绝缘', name: 'PowerLine', index: 'PowerLine', width: 100, align: 'left', sortable: false },
                      { label: '接地线', name: 'GroundLead', index: 'GroundLead', width: 100, align: 'left', sortable: false },
                      { label: '保养工时', name: 'MaintenceTime', index: 'MaintenceTime', width: 100, align: 'left', sortable: false },
                      { label: '保养前存在问题', name: 'InspectionProblem', index: 'InspectionProblem', width: 400, align: 'left', sortable: false },
                      { label: '维护保养人员', name: 'PmOper', index: 'PmOper', width: 120, align: 'center', sortable: false },
                      { label: '验收确认', name: 'ConfirmPerson', index: 'ConfirmPerson', width: 100, align: 'center', sortable: false },
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


            $gridTable1.jqGrid({
                url: "GetReportInfo.ashx",
                postData: { Action: "SecondLevelInspectionContent" },
                loadonce: true,
                datatype: "local",
                height: $('#areascontent').height() * 0.25,
                colModel: [
                    {
                        label: '保养部位及内容', name: 'MaintenceContent', index: 'MaintenceContent', width: panelwidth * 0.9, align: 'left', sortable: false
                    },
                    {
                        label: '检查', name: 'IsActive', index: 'IsActive', width: panelwidth * 0.05, align: 'center', sortable: false,
                        formatter: function (cellvalue, options, rowObject) {
                            return cellvalue == 1 ? "<i class=\"fa fa-check\" style=\"color:#00CD00\"></i>" : "<i>&nbsp;</i>";
                        }
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

            $gridTable2.jqGrid({
                url: "GetReportInfo.ashx",
                postData: { Action: "SecondLevelInspectionReplace" },
                loadonce: true,
                datatype: "local",
                height: $('#areascontent').height() * 0.23,
                colModel: [
                   { label: '日期', name: 'PmDate', index: 'PmDate', width: 100, align: 'left', sortable: false },
                   { label: '设备', name: 'DeviceCode', index: 'DeviceCode', width: 100, align: 'left', sortable: false },
                   { label: '设备名称', name: 'DeviceName', index: 'DeviceName', width: 300, align: 'left', sortable: false },
                   { label: '部位', name: 'ReplacePart', index: 'ReplacePart', width: 300, align: 'left', sortable: false },
                   { label: '名称', name: 'ReplaceName', index: 'ReplaceName', width: 300, align: 'left', sortable: false },
                   { label: '件数', name: 'ReplaceCount', index: 'ReplaceCount', width: 100, align: 'left', sortable: false },

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

                //点检设备信息
                $gridTable.jqGrid('setGridParam', {
                    datatype: 'json',
                    postData: {
                        StartTime: $("#StartTime").val(),
                        EndTime: $("#EndTime").val()
                    }
                }).trigger('reloadGrid');

                //点检表保养部位
                $gridTable1.jqGrid('setGridParam', {
                    datatype: 'json'
                }).trigger('reloadGrid');

                //点检表更换配件信息
                $gridTable2.jqGrid('setGridParam', {
                    datatype: 'json',
                    postData: {
                        StartTime: $("#StartTime").val(),
                        EndTime: $("#EndTime").val()
                    }
                }).trigger('reloadGrid');

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
        //function btn_export(event) {
        //    var title = $("#title").html();
        //    ExportJQGridDataToExcel('#gridTable', title);
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
                                        <input id="StartTime"  type="text" onFocus="WdatePicker({maxDate:'#F{$dp.$D(\'EndTime\')}'})"  class="Wdate timeselect" isvalid="yes" checkexpession="NotNull" />&nbsp;至&nbsp;
                                        <input id="EndTime"  type="text" onFocus="WdatePicker({minDate:'#F{$dp.$D(\'StartTime\')}'})"  class="Wdate timeselect" isvalid="yes" checkexpession="NotNull" /> 
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
        <div class="ui-report"> 
        <div class="titlePanel">
        <div class="toolbar">
            <div class="btn-group">
                <a id="lr-print" class="btn btn-default" onclick="btn_print(event)"><i class="fa fa-print"></i>&nbsp;打印</a>
                <%--<a id="lr-export" class="btn btn-default trigger-default" onclick="btn_export(event)"><i class="fa fa-plus"></i>&nbsp;导出</a>--%>
            </div>
         </div>
         </div>
         <div class="gridPanel" id="gridPanel">
             <div class="printArea">
                  <div class="grid-title">
                        <h4 style="text-align:center;" >设备维护保养记录</h4> 
                  </div>  
                 <table id="gridTable" style="width:100%;"></table>       
             </div>
             <div class="printArea"> 
                 <div class="grid-title">
                       
                 </div>        
                 <table id="gridTable1"></table>   
             </div>
             <div class="printArea">    
                 <div class="grid-title">
                     <h4 style="text-align:center;" >保养需换配件明细</h4> 
                 </div>      
                 <table id="gridTable2"></table>  
                 <div class="grid-foot">
                     填表人: <label id="DeviceCodeLabel"  style="width: 400px;"  ></label> 
                     部门负责人: <label id="DeviceNameLabel"  style="width: 200px;"  ></label>
                 </div> 
             </div>
         </div>
         </div>
    </div>
</body>
</html>








