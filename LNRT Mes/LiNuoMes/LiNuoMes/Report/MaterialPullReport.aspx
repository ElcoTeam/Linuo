﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MaterialPullReport.aspx.cs" Inherits="LiNuoMes.Report.MaterialPullReport" %>

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

            $("#btn_Search").click(function () {
                if (!$("#content").hasClass("active")) {
                    $("#content").addClass("active")

                } else {
                    $("#content").removeClass("active")

                }
            });
            CreateSelect();
            fnDate();
        });

        //加载表格
        function GetGrid() {
            var selectedRowIndex = 0;
            var $gridTable = $('#gridTable');
            $gridTable.jqGrid({
                url: "GetReportInfo.ashx",
                postData: {
                    Action: "MaterialPullReport",
                    PullTimeStart: $("#PullTimeStart").val(),
                    PullTimeEnd: $("#PullTimeEnd").val()
                },
                loadonce: true,
                datatype: 'json',
                height: $('#areascontent').height()-230,
                colModel: [
                    { label: '主键', name: 'ID', hidden: true },
                    { label: '序号', name: 'Number', index: 'Number', width: 50, align: 'center' },
                    {
                        label: '订单编号', name: 'WorkOrderNumber', index: 'WorkOrderNumber', width: 150, align: 'center'
                    },
                    {
                        label: '订单类型', name: 'WorkOrderVersion', index: 'WorkOrderVersion', width: 100, align: 'left',
                        formatter: function (cellvalue, options, rowObject) {
                            if (cellvalue == 0) {
                                return '正常订单';
                            }
                            else {
                                return '补单订单';
                            }
                        }
                     },
                    { label: '工序名称', name: 'Procedure_Name', index: 'Procedure_Name', width: 150, align: 'center' },
                    { label: '物料编码', name: 'ItemNumber', index: 'ItemNumber', width: 150, align: 'center' },
                    {
                        label: '物料描述', name: 'ItemDsca', index: 'ItemDsca', width: 150, align: 'center'
                    },
                    { label: '拉动数量', name: 'Qty', index: 'Qty', width: 100, align: 'center' },
                    { label: '拉动时间', name: 'PullTime', index: 'PullTime', width: 200, align: 'center' },
                    {
                        label: '发送情况', name: 'Status', index: 'Status', width: 100, align: 'center',
                        formatter: function (cellvalue, options, rowObject) {
                            if (cellvalue == 0) {
                                return '待响应';
                            }
                            else if (cellvalue == 1) {
                                return '待确认';
                            }
                            else if (cellvalue == 2) {
                                return '已完成';
                            }
                        }
                    },
                    { label: '响应时间', name: 'ActionTime', index: 'ActionTime', width: 200, align: 'center' },
                    { label: '响应人', name: 'ActionUser', index: 'ActionUser', width: 100, align: 'center' },
                    { label: '确认时间', name: 'ConfirmTime', index: 'ConfirmTime', width: 200, align: 'center' },
                    { label: '确认人', name: 'ConfirmUser', index: 'ConfirmUser', width: 100, align: 'center' },
                    {
                        label: '是否超时', name: 'OTFlag', index: 'OTFlag', width: 100, align: 'center',
                        formatter: function (cellvalue, options, rowObject) {
                            if (cellvalue == 0) {
                                return '未超时';
                            }
                            else if (cellvalue == 1) {
                                return '超时';
                            }
                            else {
                                return '';
                            }
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
                    $("#" + this.id).setSelection(selectedRowIndex, false);
                }
            });

            //查询事件
            $("#lr_btn_querySearch").click(function () {
                var orderno = $("#orderno").val();
                var materialCode = $("#materialcode").val();
                var produce = $("#produce").val();
                var Status = $("#Status").val();
                var PullTimeStart = $("#PullTimeStart").val();
                var PullTimeEnd = $("#PullTimeEnd").val();
                var OTFlag = $("#OTFlag").val();
                var ActionTimeStart = $("#ActionTimeStart").val();
                var ActionTimeEnd = $("#ActionTimeEnd").val();
                var ActionUser = $("#ActionUser").val();
                var ConfirmTimeStart = $("#ConfirmTimeStart").val();
                var ConfirmTimeEnd = $("#ConfirmTimeEnd").val();
                var ConfirmUser = $("#ConfirmUser").val();

                $gridTable.jqGrid('setGridParam', {
                    datatype: 'json',
                    postData: {
                        Action: "MaterialPullReport",
                        Orderno: orderno, MaterialCode: materialCode, Produce: produce,
                        Status: Status, PullTimeStart: PullTimeStart, PullTimeEnd: PullTimeEnd,
                        OTFlag: OTFlag, ActionTimeStart: ActionTimeStart, ActionTimeEnd: ActionTimeEnd,
                        ActionUser: ActionUser, ConfirmTimeStart: ConfirmTimeStart, ConfirmTimeEnd: ConfirmTimeEnd,
                        ConfirmUser: ConfirmUser
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
                        optionstring += "<option value=\"" + data1[i].ProcessCode + "\" >" + data1[i].ProcessName.trim() + "</option>";
                    }
                    $("#produce").html("<option value=''>请选择...</option> " + optionstring);
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
            ExportJQGridDataToExcel('#gridTable', '物料拉动报表');
        }

        //初始化拉动时间
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
                    preDate = null,
                    curDate = null;
                if (xhr.readyState === 2) {
                    var seperator1 = "-";
                    // 获取请求头里的时间戳
                    time = xhr.getResponseHeader("Date");
                    //console.log(xhr.getAllResponseHeaders())
                    curDate = new Date(time);
                    preDate = new Date(curDate.getTime() - 24 * 60 * 60 * 1000);
                    var month = curDate.getMonth() + 1;
                    var premonth = preDate.getMonth() + 1;
                    var strDate = curDate.getDate();
                    var strDate1 = preDate.getDate();
                    if (month >= 1 && month <= 9) {
                        month = "0" + month;
                    }
                    if (strDate >= 0 && strDate <= 9) {
                        strDate = "0" + strDate;
                    }
                    var currentdate = curDate.getFullYear() + seperator1 + month + seperator1 + strDate;
                    var predate = preDate.getFullYear() + seperator1 + premonth + seperator1 + strDate1;
                    $("#PullTimeStart").val(predate);
                    $("#PullTimeEnd").val(currentdate);
                    GetGrid();
                }
            }
        }

        //设置开始时间
        function setStartTime() {
            if ($("#PullTimeEnd").val() == "") {
                dialogMsg("请选择结束日期", 0);
            }
            else {
                $('#lr_btn_querySearch').trigger("click");
            }
        }

        //设置结束时间
        function setEndTime() {
            if ($("#PullTimeStart").val() == "") {
                dialogMsg("请选择开始日期", 0);
            }
            else {
                $('#lr_btn_querySearch').trigger("click");
            }
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
                        <div class="panel-heading"><i class="fa fa-bar-chart fa-lg" style="padding-right: 5px;"></i><strong style="font-size:20px;">物料拉动报表</strong></div>
                        <div class="lr-layout-tool">
                             <div class="lr-layout-tool-left">
                                 <div class="lr-layout-tool-item">
                                     <span class="formTitle">拉动时间：</span>
                                     <input id="PullTimeStart"  type="text" onFocus="WdatePicker({maxDate:'#F{$dp.$D(\'PullTimeEnd\')}',onpicked:setStartTime})" class="Wdate timeselect" />&nbsp;至&nbsp;
                                     <input id="PullTimeEnd"  type="text" onFocus="WdatePicker({minDate:'#F{$dp.$D(\'PullTimeStart\')}',onpicked:setEndTime})" class="Wdate timeselect" /> 
                                 </div>
                                 <div class="lr-layout-tool-item" id="multiple_condition_query_item">
                                      <div id="multiple_condition_query" class="lr-query-wrap">
                                          <div class="lr-query-btn" id="btn_Search" style="font-size:10px;">
                                              <i class="fa fa-search"></i>&nbsp;多条件查询
                                          </div>
                                          <div class="lr-query-content" style="width:800px;height:300px;" id="content">
                                              <div class="lr-query-formcontent" style="display:block"></div>
                                              <div class="lr-query-arrow">
                                                  <div class="lr-query-inside"></div>
                                              </div>
                                              <div class="lr-query-content-bottom">
                                                   <%--<a id="lr_btn_queryReset" class="btn btn-default">&nbsp;重&nbsp;&nbsp;置</a>--%>
                                                   <a id="lr_btn_querySearch" class="btn btn-primary">&nbsp;查&nbsp;&nbsp;询</a>
                                              </div>
                                              <div class=" col-xs-12 lr-form-item">                                                  <div class="lr-form-item-title" >订单编号：</div>                                                  <input type="text" class="form-control" id="orderno" placeholder="请输入订单编号">                                              </div>
                                              <div class=" col-xs-12 lr-form-item">                                                  <div class="lr-form-item-title" >物料编号：</div>                                                  <input type="text" class="form-control" id="materialcode" placeholder="请输入物料编号">                                              </div>                                              <div class=" col-xs-12 lr-form-item">                                                  <div class="lr-form-item-title" >工序名称：</div>                                                   <select class="form-control" id="produce"></select>                                              </div>
                                              <div class=" col-xs-12 lr-form-item">                                                  <div class="lr-form-item-title" >发送情况：</div>                                                    <select class="form-control" id="Status">
                                                          <option value=''>请选择...</option>
                                                          <option value='0'>待响应</option>
                                                          <option value='1'>待确认</option>
                                                          <option value='2'>已完成</option>
                                                    </select>                                              </div>
                                              <div class=" col-xs-12 lr-form-item">                                                  <div class="lr-form-item-title" >是否超时：</div>                                                   <select class="form-control" id="OTFlag">
                                                         <option value=''>请选择...</option>
                                                         <option value='1'>是</option>
                                                         <option value='0'>否</option>
                                                   </select>                                              </div>
                                              <div class=" col-xs-12 lr-form-item">                                                     <div class="lr-form-item-title">响应人：</div>                                                     <input type="text" class="form-control" id="ActionUser" placeholder="请输入响应人">                                              </div>
                                              <div class=" col-xs-12 lr-form-item">                                                     <div class="lr-form-item-title">确认人：</div>                                                     <input type="text" class="form-control" id="ConfirmUser" placeholder="请输入确认人">                                              </div>
                                              <div class=" col-xs-12 lr-form-item">                                                    <div class="lr-form-item-title">响应时间：</div>                                                    <input id="ActionTimeStart"  type="text" onFocus="WdatePicker({maxDate:'#F{$dp.$D(\'ActionTimeEnd\')}'})" class="Wdate form-control" style="display:inline;" />&nbsp;至&nbsp;
                                                    <input id="ActionTimeEnd"  type="text" onFocus="WdatePicker({minDate:'#F{$dp.$D(\'ActionTimeStart\')}'})" class="Wdate form-control" style="display:inline;"/>                                                </div>
                                               <div class=" col-xs-12 lr-form-item">                                                    <div class="lr-form-item-title">确认时间：</div>                                                    <input id="ConfirmTimeStart"  type="text" onFocus="WdatePicker({maxDate:'#F{$dp.$D(\'ActionTimeEnd\')}'})" class="Wdate form-control" style="display:inline;" />&nbsp;至&nbsp;
                                                    <input id="ConfirmTimeEnd"  type="text" onFocus="WdatePicker({minDate:'#F{$dp.$D(\'ActionTimeStart\')}'})" class="Wdate form-control" style="display:inline;"/>                                                </div>
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

         <div class="ui-report" style="margin-top:3.5%; overflow: hidden; ">
              <div class="gridPanel" id="gridPanel">
                  <div class="printArea">
                      <table id="gridTable"></table>                      
                  </div>
              </div>
         </div>
    </div>
   
</body>
</html>


