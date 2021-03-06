﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EquAlarm.aspx.cs" Inherits="LiNuoMes.Equipment.EquAlarm" %>

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
    <script src="../Content/scripts/plugins/dialog/dialog.js"></script>
    <script src="../Content/adminLTE/index.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/grid.locale-cn.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/jqgrid.min.js"></script>
    <script src="../Content/scripts/utils/learun-ui.js"></script>
    <script src="../Content/scripts/utils/learun-form.js"></script>
    <script src="../My97DatePicker/WdatePicker.js"></script>

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
                url: "hs/GetEquAlarm.ashx",
                postData: { 
                    AlarmStartTime: $("#AlarmStartTime").val(),
                    AlarmEndTime: $("#AlarmEndTime").val()
                },
                datatype: "json",
                height: $('#areascontent').height() -200,
                colModel: [
                    { label: '主键', name: 'ID', hidden: true },
                    {
                        label: '工序名称', name: 'ProcessName', index: 'ProcessName', width: 200, align: 'left', sortable: false
                    },
                    { label: '设备名称', name: 'DeviceName', index: 'DeviceName', width: 200, align: 'left', sortable: false },
                    { label: '报警时间', name: 'AlarmTime', index: 'AlarmTime', width: 250, align: 'left', sortable: false },
                    { label: '报警项', name: 'AlarmItem', index: 'AlarmItem', width: 250, align: 'left', sortable: false },
                    {
                        label: '处理情况', name: 'DealWithResult', index: 'DealWithResult', width: 100, align: 'left', sortable: false,
                        formatter: function (cellvalue, options, rowObject) {
                            if (rowObject[5] == 'R') {
                                return '已处理';
                            }
                            else {
                                return '未处理';
                            }
                        }
                    },
                    { label: '处理完成时间', name: 'DealWithTime', index: 'DealWithTime', width: 250, align: 'left', sortable: false },
                    { label: '处理人', name: 'DealWithOper', index: 'DealWithOper', width: 100, align: 'left', sortable: false },
                    {
                        label: '操作', name: '', index: '', width: 200, align: 'center', sortable: false,
                        formatter: function (cellvalue, options, rowObject) {
                            if (rowObject[5]=='1') {
                                return '<span onclick=\"btn_search(\'' + rowObject[0] + '\')\" class=\"label label-success\" style=\"cursor: pointer;\"><i class="fa fa-eye"></i>查看</span>' + '<span onclick=\"btn_edit(\'' + rowObject[0] + '\')\" class=\"label label-success\" style=\"cursor: pointer;margin-left:10px;\"><i class="fa fa-edit"></i>修改</span>' + '<span onclick=\"btn_delete(\'' + rowObject[0] + '\')\" class=\"label label-success\" style=\"cursor: pointer;margin-left:10px;\"><i class="fa fa-trash-o"></i>删除</span>';
                            }
                            else {
                                return '<span onclick=\"btn_search(\'' + rowObject[0] + '\')\" class=\"label label-success\" style=\"cursor: pointer;\"><i class="fa fa-eye"></i>查看</span>' + '<span onclick=\"btn_handle(\'' + rowObject[0] + '\')\" class=\"label label-success\" style=\"cursor: pointer;margin-left:10px;\"><i class="fa fa-edit"></i>处理</span>' + '<span onclick=\"btn_delete(\'' + rowObject[0] + '\')\" class=\"label label-success\" style=\"cursor: pointer;margin-left:10px;\"><i class="fa fa-trash-o"></i>删除</span>';
                            }
                                
                        }
                    },
                ],
                viewrecords: true,
                rowNum: 30,
                rowList: [30, 50, 100],
                pager: "#gridPager",
                rownumbers: true,
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
                var processName = $("#ProcessName").val();
                var deviceName = $("#DeviceName").val();
                var DealWithResult = $("#DealWithResult").val();
                var AlarmStartTime = $("#AlarmStartTime").val();
                var AlarmEndTime = $("#AlarmEndTime").val();
                var DealWithStartTime = $("#DealWithStartTime").val();
                var DealWithEndTime = $("#DealWithEndTime").val();
                var DealWithOper = $("#DealWithOper").val();
              
                $gridTable.jqGrid('setGridParam', {
                    postData: {
                        ProcessName: processName,
                        DeviceName: deviceName,
                        DealWithResult: DealWithResult,
                        AlarmStartTime: AlarmStartTime,
                        AlarmEndTime: AlarmEndTime,
                        DealWithStartTime: DealWithStartTime,
                        DealWithEndTime: DealWithEndTime,
                        DealWithOper: DealWithOper
                    }, page: 1
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
                url: "EquDeviceInfo.aspx/GetProcessInfo",
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

        //查看报警  1:查看
        function btn_search(equid) {
            if (equid == undefined) {
                equid = $("#gridTable").jqGridRowValue("ID");
            }
            dialogOpen({
                id: "Form",
                title: '设备报警处理维护--查看',
                url: '../Equipment/EquAlarmEdit.aspx?actionname=1&equid=' + equid + '',
                width: "750px",
                height: "500px",
                btn: null
            });
        }

        //编辑报警  2：编辑
        function btn_edit(equid) {
            if (equid == undefined) {
                equid = $("#gridTable").jqGridRowValue("ID");
            }
            dialogOpen({
                id: "Form",
                title: '设备报警处理维护--修改',
                url: '../Equipment/EquAlarmEdit.aspx?actionname=2&equid=' + equid + '',
                width: "750px",
                height: "500px",
                callBack: function (iframeId) {
                    top.frames[iframeId].AcceptClick($("#gridTable"));
                }
            });
        }

        //处理报警  3：处理
        function btn_handle(equid) {
            if (equid == undefined) {
                equid = $("#gridTable").jqGridRowValue("ID");
            }
            dialogOpen({
                id: "Form",
                title: '设备报警处理维护--处理',
                url: '../Equipment/EquAlarmEdit.aspx?actionname=3&equid=' + equid + '',
                width: "750px",
                height: "500px",
                callBack: function (iframeId) {
                    top.frames[iframeId].AcceptClick($("#gridTable"));
                }
            });
        }


        //删除报警
        function btn_delete(equid) {
            if (equid == undefined) {
                equid = $("#gridTable").jqGridRowValue("ID");
            }
            dialogConfirm("注：您确定要删除吗？该操作将无法恢复", function (r) {
                if (r) {
                    Loading(true, "正在删除数据...");
                    window.setTimeout(function () {
                        $.ajax({
                            url: "EquAlarm.aspx/DeleteEquAlarm",
                            data: "{EquID:'" + equid + "'}",
                            type: "post",
                            dataType: "json",
                            contentType: "application/json;charset=utf-8",
                            success: function (data) {
                                if (data.d == "success") {
                                    Loading(false);
                                    dialogMsg("删除成功", 1);
                                    $("#gridTable").trigger("reloadGrid");
                                }
                                else if (data.d == "falut") {
                                    dialogMsg("删除失败", -1);
                                }
                            },
                            error: function (XMLHttpRequest, textStatus, errorThrown) {
                                Loading(false);
                                dialogMsg(errorThrown, -1);
                            },
                            beforeSend: function () {
                                Loading(true, "正在删除数据");
                            },
                            complete: function () {
                                Loading(false);
                            }
                        });
                    }, 500);
                }
            });
        }

        //设置默认时间选择
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
                    var seperator1 = "-";
                    // 获取请求头里的时间戳
                    time = xhr.getResponseHeader("Date");
                    //console.log(xhr.getAllResponseHeaders())
                    curDate = new Date(time);
                    var oneweekdate = new Date(curDate.getTime() - 7 * 24 * 3600 * 1000);
                    //当前时间
                    var month = curDate.getMonth() + 1;
                    var strDate = curDate.getDate();
                    if (month >= 1 && month <= 9) {
                        month = "0" + month;
                    }
                    if (strDate >= 0 && strDate <= 9) {
                        strDate = "0" + strDate;
                    }
                    var currentdate = curDate.getFullYear() + seperator1 + month + seperator1 + strDate;
                    //一周前时间
                    var month = oneweekdate.getMonth() + 1;
                    var strDate = oneweekdate.getDate();
                    if (month >= 1 && month <= 9) {
                        month = "0" + month;
                    }
                    if (strDate >= 0 && strDate <= 9) {
                        strDate = "0" + strDate;
                    }
                    var oneweekagodate = oneweekdate.getFullYear() + seperator1 + month + seperator1 + strDate;
                    $("#AlarmEndTime").val(currentdate);
                    $("#AlarmStartTime").val(oneweekagodate);
                    GetGrid();
                }
            }
        }

        //设置开始时间
        function setStartTime() {
            if ($("#AlarmEndTime").val() == "") {
                dialogMsg("请选择结束日期", 0);
            }
            else {
                $('#lr_btn_querySearch').trigger("click");
            }
        }

        //设置结束时间
        function setEndTime() {
            if ($("#AlarmStartTime").val() == "") {
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
                        <div class="panel-heading"><i class="fa fa-bar-chart fa-lg" style="padding-right: 5px;"></i><strong style="font-size:20px;">设备报警管理</strong></div>
                         <div class="lr-layout-tool">
                               <div class="lr-layout-tool-left">
                                       <div class="lr-layout-tool-item">
                                           <span class="formTitle">报警时间：</span>
                                            <input id="AlarmStartTime"  type="text" onFocus="WdatePicker({maxDate:'#F{$dp.$D(\'AlarmEndTime\')}',onpicked:setStartTime})" class="Wdate timeselect" />&nbsp;至&nbsp;
                                            <input id="AlarmEndTime"  type="text" onFocus="WdatePicker({minDate:'#F{$dp.$D(\'AlarmStartTime\')}',onpicked:setEndTime})" class="Wdate timeselect" /> 
                                       </div>
                                       <div class="lr-layout-tool-item" id="multiple_condition_query_item">
                                            <div id="multiple_condition_query" class="lr-query-wrap">
                                                <div class="lr-query-btn" id="btn_Search" style="font-size:10px;">
                                                    <i class="fa fa-search"></i>&nbsp;多条件查询
                                                </div>
                                                <div class="lr-query-content" style="width:800px;height:200px;" id="content">
                                                    <div class="lr-query-formcontent" style="display:block"></div>
                                                    <div class="lr-query-arrow">
                                                        <div class="lr-query-inside"></div>
                                                    </div>
                                                    <div class="lr-query-content-bottom">
                                                         <%--<a id="lr_btn_queryReset" class="btn btn-default">&nbsp;重&nbsp;&nbsp;置</a>--%>
                                                         <a id="lr_btn_querySearch" class="btn btn-primary">&nbsp;查&nbsp;&nbsp;询</a>
                                                    </div>
                                                     <div class=" col-xs-12 lr-form-item" >                                                        <div class="lr-form-item-title" style="width:120px;">工序名称：</div>                                                         <select class="form-control" id="ProcessName" style="margin-left:30px;"></select>                                                    </div>                                                    <div class=" col-xs-12 lr-form-item">                                                        <div class="lr-form-item-title" style="width:120px;">设备名称：</div>                                                        <input type="text" class="form-control" id="DeviceName" placeholder="请输入设备名称" style="margin-left:30px;">                                                    </div>                                                    <div class=" col-xs-12 lr-form-item">                                                        <div class="lr-form-item-title" style="width:120px;">处理人：</div>                                                        <input type="text" class="form-control" id="DealWithOper" placeholder="请输入处理人" style="margin-left:30px;">                                                       </div>                                                    <div class=" col-xs-12 lr-form-item">                                                        <div class="lr-form-item-title" style="width:120px;">处理情况：</div>                                                        <select class="form-control" id="DealWithResult" style="margin-left:30px;">
                                                             <option value=''>请选择...</option>
                                                             <option value='已处理'>已处理</option>
                                                             <option value='未处理'>未处理</option>
                                                       </select>                                                    </div>                                                    <div class=" col-xs-12 lr-form-item">                                                        <div class="lr-form-item-title" style="width:120px;">处理完成时间：</div>                                                         <input id="DealWithStartTime"  type="text" onFocus="WdatePicker({maxDate:'#F{$dp.$D(\'DealWithEndTime\')}'})" class="Wdate form-control" style="margin-left:30px;display:inline;" />&nbsp;至&nbsp;
                                                         <input id="DealWithEndTime"  type="text" onFocus="WdatePicker({minDate:'#F{$dp.$D(\'DealWithStartTime\')}'})" class="Wdate form-control" style="display:inline;" />                                                     </div>
                                                </div>
                                            </div>
                                       </div>
                                    </div>
                           </div>
                    </div>
                </div>
            </div>
        </div>

         <div class="rows" style="margin-top:3.5%; overflow: hidden; ">
             
              <div class="gridPanel">
                   <table id="gridTable"></table>
                   <div id="gridPager"></div>
              </div>
         </div>
    </div>

   
</body>
</html>




