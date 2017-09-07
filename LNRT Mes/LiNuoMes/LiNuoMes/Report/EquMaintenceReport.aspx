<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EquMaintenceReport.aspx.cs" Inherits="LiNuoMes.Report.EquMaintenceReport" %>

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
            CreateSelect();
          
        });

        //加载表格
        function GetGrid() {
            var selectedRowIndex = 0;
            var $gridTable = $('#gridTable');
            $gridTable.jqGrid({
                url: "../Equipment/hs/GetEquMaintenceMan.ashx",
                loadonce: true,
                datatype: "json",
                height: $('#areascontent').height() *0.55,
                colModel: [
                    { label: '主键', name: 'ID', hidden: true },
                    { label: '保养规范编号', name: 'PmSpecCode', hidden: true },
                    {
                        label: '工序名称', name: 'ProcessName', index: 'ProcessName', width: 150, align: 'left', sortable: false
                    },
                    { label: '保养类别', name: 'PmType', index: 'PmType', width: 100, align: 'left', sortable: false },
                    { label: '保养类型', name: 'PmLevel', index: 'PmLevel', width: 100, align: 'left', sortable: false },
                    { label: '设备名称', name: 'DeviceName', index: 'DeviceName', width: 150, align: 'left', sortable: false },
                    { label: '保养规范名称', name: 'PmSpecName', index: 'PmSpecName', width: 250, align: 'left', sortable: false },
                    { label: '保养计划名称', name: 'PmPlanName', index: 'PmPlanName', width: 250, align: 'left', sortable: false },
                    {
                        label: '计划内次数', name: 'PmPlanCount', index: 'PmPlanCount', width: 100, align: 'left', sortable: false,
                        formatter: function (cellvalue, options, rowObject) {
                            if (rowObject[3] == '计划内保养') {
                                return '第' + cellvalue + '次';
                            }
                            else {
                                return '';
                            }
                        }
                    },
                    { label: '执行情况', name: 'PmStatus', index: 'PmStatus', width: 100, align: 'left', sortable: false },
                    { label: '计划保养日期', name: 'PmPlanDate', index: 'PmPlanDate', width: 150, align: 'left', sortable: false },

                    { label: '保养人', name: 'PmOper', index: 'PmOper', width: 100, align: 'left', sortable: false },
                    { label: '处理时间', name: 'UpdateTime', index: 'UpdateTime', width: 250, align: 'left', sortable: false },
                ],
                viewrecords: true,
                rowNum: 30,
                rownumWidth: 100,
                rowList: [30, 50, 100],
                pager: "#gridPager",
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
                var processName = $("#ProcessName").val();
                var deviceName = $("#DeviceName").val();

                var PmType = $("#PmType").val();
                var PmLevel = $("#PmLevel").val();
                var Status = $("#Status").val(); 
                var PmSpecName= $("#PmSpecName").val(); 
                var PmPlanName= $("#PmPlanName").val(); 
                var PmStartDate= $("#PmStartDate").val(); 
                var PmFinishDate = $("#PmFinishDate").val();
                //var PmFinishDateStart = $("#PmFinishDateStart").val();
                //var PmFinishDateEnd = $("#PmFinishDateEnd").val();

                $gridTable.jqGrid('setGridParam', {
                    datatype: 'json',
                    postData: {
                        ProcessName: processName,
                        DeviceName: deviceName,
                        PmType: PmType,
                        PmLevel: PmLevel,
                        Status: Status,
                        PmSpecName: PmSpecName,
                        PmPlanName: PmPlanName,
                        PmStartDate: PmStartDate,
                        PmFinishDate: PmFinishDate
                    }, page: 1
                }).trigger('reloadGrid');

            });
            //查询回车
            //$('#orderno').bind('keypress', function (event) {
            //    if (event.keyCode == "13") {
            //        $('#btn_Search').trigger("click");
            //    }
            //});

            //保养次数统计
            $("#btn_Statistics").click(function () {
                dialogOpen({
                    id: "Form",
                    title: '设备保养总统计表',
                    url: '../Report/EquTotalReport.aspx',
                    width: "750px",
                    height: "500px",
                    btn: null
                });
            });

        }

        //构造select
        function CreateSelect() {
            $("#ProcessName").empty();
            var optionstring = "";
            $.ajax({
                url: "../Equipment/EquDeviceInfo.aspx/GetProcessInfo",
                type: "post",
                dataType: "json",
                data: "{deviceid:''}",
                contentType: "application/json;charset=utf-8",
                success: function (data) {
                    var data1 = eval('(' + data.d + ')');
                    var i = 0;
                    for (i in data1) {
                        optionstring += "<option value=\"" + data1[i].ProcessName + "\" >" + data1[i].ProcessName.trim() + "</option>";
                    }
                    $("#ProcessName").html("<option value=''>请选择...</option> " + optionstring);  
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
            ExportJQGridDataToExcel('#gridTable', '设备保养报表');
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
                        <div class="panel-heading"><i class="fa fa-bar-chart fa-lg" style="padding-right: 5px;"></i><strong style="font-size:20px;">设备保养报表</strong></div>
                        <div class="panel-body">
                            <table id="form1" class="form">
                                <tr>
                                    <th class="formTitle">工序名称：</th>
                                    <td class="formValue">
                                       <select class="form-control" id="ProcessName">
                                       </select>
                                    </td>
                                    <th class="formTitle">设备名称：</th>
                                    <td class="formValue">
                                        <input type="text" class="form-control" id="DeviceName" placeholder="请输入设备名称">
                                    </td>
                                    <th class="formTitle">保养类别：</th>
                                    <td class="formValue">
                                       <select class="form-control" id="PmType">
                                           <option value=''>请选择...</option>
                                           <option value='计划内保养'>计划内保养</option>
                                           <option value='计划外保养'>计划外保养</option>
                                       </select>
                                    </td>
                                    
                                </tr>
                               
                                <tr>
                                    <th class="formTitle">保养类型：</th>
                                    <td class="formValue">
                                       <select class="form-control" id="PmLevel">
                                           <option value=''>请选择...</option>
                                           <option value='一级保养'>一级保养</option>
                                           <option value='二级保养'>二级保养</option>
                                       </select>
                                    </td>
                                    <th class="formTitle">执行情况：</th>
                                    <td class="formValue">
                                        <select class="form-control" id="Status">
                                           <option value=''>请选择...</option>
                                           <option value='已完成'>已完成</option>
                                           <option value='未完成'>未完成</option>
                                       </select>
                                    </td>
                                    <th class="formTitle">保养规范名称：</th>
                                    <td class="formValue">
                                        <input type="text" class="form-control" id="PmSpecName" placeholder="请输入保养规范名称">
                                    </td>
                                </tr>
                                <tr>
                                    <th class="formTitle">保养计划名称：</th>
                                    <td class="formValue">
                                       <input type="text" class="form-control" id="PmPlanName" placeholder="请输入保养计划名称">
                                    </td>
                                    <th class="formTitle">计划起止日期：</th>
                                    <td class="formValue" colspan="2">
                                          <input id="PmStartDate"  type="text" onFocus="WdatePicker({maxDate:'#F{$dp.$D(\'PmFinishDate\')}'})" class="Wdate timeselect" />&nbsp;至&nbsp;
                                          <input id="PmFinishDate"  type="text" onFocus="WdatePicker({minDate:'#F{$dp.$D(\'PmStartDate\')}'})" class="Wdate timeselect" /> 
                                    </td>
                                    <td class="formValue">
                                          <a id="btn_Search" class="btn btn-primary"><i class="fa fa-search"></i>&nbsp;查询</a>
                                          <a id="btn_Statistics" class="btn btn-primary"><i class="fa fa-search"></i>&nbsp;保养次数统计</a>                                                
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
                      <div id="gridPager"></div>                    
                  </div>
              </div>
         </div>
    </div>
   <style>
      .timeselect{
          width: 200px;
      }
   </style> 
</body>
  
</html>




