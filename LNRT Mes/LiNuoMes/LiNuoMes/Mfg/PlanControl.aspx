<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PlanControl.aspx.cs" Inherits="LiNuoMes.Mfg.PlanControl" %>

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
    
    <script src="../BaseConfig/GetSetBaseConfig.js"></script>
     <script>
         var timerID = 0;
         var nCounter = 0;
         var nWaitMTL = 0;
         var selectedRowIndex0 = 0;
         var selectedRowIndex1 = 0;
         $(function () {
             if ($('#areascontent').height() > $(window).height() - 20) {
                 $('#areascontent').css("margin-right", "0px");
             }
             $('#areascontent').height($(window).height() - 106);
             var areaheight = $("#areascontent").height();
             $(window).resize(function (e) {
                 window.setTimeout(function () {
                     $('#areascontent').height($(window).height() - 106);
              //       $('#areascontent').width($(window).width() - 20);
                     $('#gridTable0').setGridWidth(($('#areascontent').width()) - 10);
              //       $('#gridTable1').setGridWidth(($('#areascontent').width()) - 10);
              //       $('#gridTable0').setGridHeight($('#areascontent').height() * 0.30);
              //       $('#gridTable1').setGridHeight($('#areascontent').height() * 0.30);
                 }, 200);
             });

             InitPage0();
             InitButtons();
             refreshWOStatus();

        });

        function InitButtons() {
            $("#btn_Rfs").bind("click", onRefresh);
            $("#btn_Mtl").bind("click", onMVT);
            $("#btn_Roc").bind("click", onRoc);
            $("#btn_Add").bind("click", onWoAdd);
        }

        function onRefresh() {
            nCounter = 0; 
            RefreshWOTip('1');
            setRefreshTimer();
            g_getSetParam("ERP_ORDER_DETAIL", "1", "WRITE", null);
        }

        function setRefreshTimer()
        {
            if (timerID == 0) {
                nCounter = 0; 
                timerID = window.setInterval(refreshWOStatus, 1 * 1000);
            }
        }

        function clearRefreshTimer() {
            if (timerID != 0) {
                window.clearInterval(timerID);
                timerID = 0;
            }
        }


        function refreshWOStatus() {
            g_getSetParam("ERP_ORDER_DETAIL", "", "READ", RefreshWOTip);
        }

        function RefreshWOTip(Flag) {
            if     (Flag == '0') {
                $("#btn_Rfs").hide();
                $("#msg_Rfs").html("暂停刷新.(" + nCounter + ")");
            }
            
            else if (Flag == '1') {
                $("#btn_Rfs").hide();
                $("#msg_Rfs").html("等待刷新...(" + nCounter + ")");
            }
            else if (Flag == '2') {
                $("#btn_Rfs").hide();
                $("#msg_Rfs").html("刷新进行中...(" + nCounter + ")");
            }
            else if (Flag == '3') {
                if (timerID == 0) {
                    $("#btn_Rfs").show();
                    $("#msg_Rfs").html("");
                }
                else {
                    $("#btn_Rfs").hide();
                    $("#msg_Rfs").html("导入进行中...(" + nCounter + ")");
                }
            }
            else if( Flag == '4')
            {
                $("#btn_Rfs").show();
                $("#msg_Rfs").html("刷新失败!!!");
            }

            if (Flag == '4') {
                nWaitMTL = 0;
                clearRefreshTimer();
            }
            else if (Flag == '3') {
               //设置第一次进行导入计数标志, 并且重新计时. 
               if (nWaitMTL == 0) {
                    nWaitMTL = 1;
                    nCounter = 0;
               }
               if (nCounter == 5 * 60) {
                   nWaitMTL = 0;
                   $("#btn_Rfs").show();
                   $("#msg_Rfs").html("刷新完成");
                   clearRefreshTimer();
                   $("#gridTable0").trigger("reloadGrid");
               }
            }
            else {
                nWaitMTL = 0;
                setRefreshTimer();
            }
            nCounter++;
        }

        function onMVT(event) {
            window.location.href = "./WoMtlMVT.aspx";
        }

        function onWoAdd(event) {
            window.location.href = "./SubPlanControl.aspx";
        }

        function onRoc(event) {
            window.location.href = "./ReportOrderComplete.aspx";
        }

        function InitPage0() {
            var strBtnStyle = "cursor:pointer;margin-left:5px;font-weight:700;padding:.2em .6em .3em;font-size:14px;";
            var $gridTable0 = $('#gridTable0');
            $gridTable0.jqGrid({
                url: "./GetSetMfg.ashx",
                postData: { Action: "MFG_WO_LIST" },
                datatype: "json",
                height: $('#areascontent').height() - 195,
                width: $('#areascontent').width,
                rowNum: -1,
                jsonReader: {
                    repeatitems: false,   //此两个参数影响了是否刷新之后高亮选中记录: 如果直接设定为true, 则无论id项设定与否都可以实现高亮选中
                    id: "ID"              //此两个参数影响了是否刷新之后高亮选中记录: 需要设定为唯一字段即可,如果设定为0值, 则需要repeatitems为true才可以.
                },
                colModel: [
                    { label: 'ID',          name: 'ID', hidden: true },
                    { label: '序号', name: 'InturnNumber', index: 'InturnNumber', width: 50, align: 'center', sortable: false },
                    { label: '订单编号', name: 'WorkOrderNumber', index: 'WorkOrderNumber', width: 100, align: 'center', sortable: false },
                    { label: '产品物料编码', name: 'GoodsCode', index: 'GoodsCode', width: 120, align: 'center', sortable: false },
                    { label: '产品物料描述', name: 'GoodsDsca', index: 'GoodsDsca', width: 360, align: 'center', sortable: false },
                    {
                        label: '订单类型', name: 'WorkOrderType', index: 'WorkOrderType', width: 80, align: 'center', sortable: false,
                        formatter: function (cellvalue, options, rowObject) {
                            return  cellvalue == "0" ? "正常订单"
                                  : cellvalue == "1" ? "下线补单"
                                  : "";
                        }
                    },
                    { label: '计划开始时间', name: 'PlanStartTime', index: 'PlanStartTime', width: 150, align: 'center', sortable: false },
                    { label: '计划完成时间', name: 'PlanFinishTime', index: 'PlanFinishTime', width: 150, align: 'center', sortable: false },
                    { label: '预计耗时', name: 'CostTime', index: 'CostTime', width: 50, align: 'center', sortable: false },
                    { label: '订单数量', name: 'PlanQty', index: 'PlanQty', width: 50, align: 'center', sortable: false },
                    { label: '完成数量', name: 'FinishQty', index: 'FinishQty', width: 50, align: 'center', sortable: false },
                    {
                        label: '订单状态', name: 'Status', index: 'Status', width: 88, align: 'center', sortable: false,
                        formatter: function (cellvalue, options, rowObject) {
                            return  cellvalue == "0" ? "待生产"
                                  : cellvalue == "1" ? "产前调整中"
                                  : cellvalue == "2" ? "生产进行中"
                                  : cellvalue == "3" ? "已完成"
                                  : "";                            
                        }
                    },
                    {
                        label: '排序调整', width: 160, align: 'center', sortable: false,
                        formatter: function (cellvalue, options, rowObject) {
                            var str="";
                            if( rowObject.Status == 0) {
                                str += '<button myObj onclick=\"onWOListInturnAdjust(\'PREV\', \'' + options.rowId + '\')\" class=\"btn btn-success\" style=\"' + strBtnStyle + '\"><i class="fa fa-arrow-up"  ></i>上升</button>'
                                    +  '<button myObj onclick=\"onWOListInturnAdjust(\'NEXT\', \'' + options.rowId + '\')\" class=\"btn btn-success\" style=\"' + strBtnStyle + '\"><i class="fa fa-arrow-down"></i>下降</button>';
                            }
                            return str;
                        }
                    },
                    {
                        label: '操 作', width: 160, align: 'center', sortable: false,
                        formatter: function (cellvalue, options, rowObject) {
                            var str = "";
                            var strEnable = "";
                            if ( rowObject.Status == 0){   
                                  if (rowObject.WorkOrderType == 0) {
                                      strEnable = "disabled";
                                  }
                                  str += '<button myObj                   onclick=\"showdlg(\'EDIT\',  \'' + rowObject.ID + '\')\" class=\"btn btn-success\" style=\"' + strBtnStyle + '\"><i class="fa fa-edit"   ></i>修改</button>';
                                  str += '<button myObj ' + strEnable + ' onclick=\"onDelete(          \'' + rowObject.ID + '\')\" class=\"btn btn-danger\"  style=\"' + strBtnStyle + '\"><i class="fa fa-trash-o"></i>删除</button>';
                                //计划此处加入 单个订单 的确认按钮
                            }
                            return str;
                        }
                    },
                    {
                        label: '查 看', width: 180, align: 'center', sortable: false,
                        formatter: function (cellvalue, options, rowObject) {
                            var str ="";
                            str += '<button onclick=\"showdlg(\'CHECK\',  \'' + rowObject.ID + '\')\" class=\"btn btn-success\" style=\"' + strBtnStyle + '"><i class="fa fa-eye"    ></i>查看   </button>'
                            str += '<button onclick=\"showdlg(\'MTLLIST\',\'' + rowObject.ID + '\')\" class=\"btn btn-info\"    style=\"' + strBtnStyle + '"><i class="fa fa-list-ol"></i>物料清单</button>';
                            return str;
                        }
                    },
                ],
                shrinkToFit: false,
                autowidth: true,
                scroll: true,
                multiselect: false,
                gridview: true,
                onSelectRow: function (rowid) {
                    selectedRowIndex0 = $("#gridTable0").jqGrid("getGridParam", "selrow");
                },
                gridComplete: function () {
                    $("#gridTable0").setSelection(selectedRowIndex0, true);
                }
            });
        }
        
        //排序调整
        function onWOListInturnAdjust(adjdirection, rowid) {
            var WOID = "0";
            var NBID = "0";

            WOID = $("#gridTable0").getRowData(rowid).ID;
            if (WOID == undefined) {
                WOID = '0';
            }

            //首先取出所有行的rowid, 然后遍历当前行所在的角标, 等待后续根据数组角标来确定交换的ID值
            var Ids = $("#gridTable0").getDataIDs();
            var rowindex = Ids.indexOf(rowid);
            var rowStatus;

            if (adjdirection == 'PREV') {
                if (rowindex > 0) {
                    rowindex--;
                    rowStatus = $("#gridTable0").jqGrid('getRowData', Ids[rowindex]).Status;
                    if(rowStatus=="待生产"){
                        NBID = $("#gridTable0").jqGrid('getRowData', Ids[rowindex]).ID;
                    }
                    else {
                        dialogMsg("不可以继续前移了, 请刷新后核对重试!", -1);
                        return;
                    }
                }
            }
            else if (adjdirection == 'NEXT') {
                if (rowindex < Ids.length - 1) {
                    rowindex++;
                    rowStatus = $("#gridTable0").jqGrid('getRowData', Ids[rowindex]).Status;

                    if(rowStatus=="待生产"){
                        NBID = $("#gridTable0").jqGrid('getRowData', Ids[rowindex]).ID;
                    }
                    else {
                        dialogMsg("不可以继续后移了, 请刷新后核对重试!", -1);
                        return;
                    }
                }
            }

            $.ajax({
                url: "GetSetMfg.ashx",
                data: {
                    Action: "MFG_WO_LIST_INTURN_ADJUST",
                    ADJDIRECTION: adjdirection,
                    WOID: WOID,
                    NBID: NBID
                },
                type: "post",
                datatype: "json",
                success: function (data) {
                    data = JSON.parse(data);
                    if (data.result == "success") {
                       $("#gridTable0").trigger("reloadGrid");
                    }
                    else if (data.result == "failed") {
                        dialogMsg(data.msg, -1);
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    dialogMsg(errorThrown, -1);
                },
                beforeSend: function () {
                },
                complete: function () {
                }
            }); 
        }
        
        //编辑信息
        function showdlg(OPtype, WoId) {
            if (WoId == undefined) {
                WoId = $("#gridTable").jqGridRowValue("ID");
            }

            if (OPtype == undefined) {
                OPtype = "CHECK";
            }

            var sTitle = "";
            var sUrl = "";
            var sWidth = "600px";
            var sHeight = "480px"
            if (OPtype == "CHECK") {
                sTitle = "查看生产计划";
                sUrl = "WoDetailEdit.aspx?";
            }
            else if (OPtype == "EDIT") {
                sTitle = "修改生产计划";
                sUrl = "WoDetailEdit.aspx?";
            }
            else if (OPtype == "ADD") {
                sTitle = "新增生产计划";
                sUrl = "WoDetailEdit.aspx?";
            }
            else if (OPtype == "MTLLIST") {
                sTitle = "查看订单的物料清单";
                sUrl = "WoMTLList.aspx?";
                sWidth = "980px";
                sHeight = "600px"
            }

            dialogOpen({
                id: "Form",
                title: sTitle,
                url: sUrl + "OPtype=" + OPtype + "&WoId=" + WoId,
                width: sWidth,
                height: sHeight,
                callBack: function (iframeId) {
                    top.frames[iframeId].AcceptClick($("#gridTable0"));
                }
            });
        }
        
        //删除信息
        function onDelete(WoId) {
            if (WoId == undefined) {
                WoId = $("#gridTable0").jqGridRowValue("ID");
            }
            dialogConfirm("注：您确定要删除吗？该操作将无法恢复", function (r) {
                if (r) {
                    Loading(true, "正在删除数据...");
                    window.setTimeout(function () {
                        $.ajax({
                            url: "GetSetMfg.ashx",
                            data: {
                                Action: "MFG_WO_LIST_DELETE",
                                WoId: WoId
                            },
                            type: "post",
                            datatype: "json",
                            success: function (data) {
                                data = JSON.parse(data);
                                if (data.result == "success") {
                                    Loading(false);
                                    dialogMsg("删除成功", 1);
                                    $("#gridTable0").trigger("reloadGrid");
                                }
                                else if (data.result == "failed") {
                                    dialogMsg(data.msg, -1);
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
                        <div class="panel-heading" >
                            <table id="panelheading" border="0" style="width:100%">
                                <tr>
                                    <th><i class="fa fa-bell-o fa-lg" style="padding-right: 5px;"></i><strong style="font-size:20px">生产排程</strong></th>
                                    <td></td>
                                </tr>
                            </table>
                        </div>
                        <div class="panel-body" style="text-align:left">
                            <table class="form" border="0">
                                <tr>
                                    <th class="formTitle" style="width:180px;font-weight:bold;text-align:right">当日生产排程</th>                                    
                                    <td class="formValue" style="text-align:right">                                           
                                        <strong id="msg_Rfs"  style="font-size:14px;padding:5px; vertical-align:central; text-align:right"></strong>
                                        <a id="btn_Rfs"     class="btn btn-primary"><i class="fa fa-refresh"></i>&nbsp;刷新订单</a>
                                        <a id="btn_Mtl"     class="btn btn-primary"><i class="fa fa-shopping-cart"></i>&nbsp;按单发料</a>
                                        <a id="btn_Roc"     class="btn btn-primary"><i class="fa fa-check"></i>&nbsp;报&nbsp;&nbsp;工</a>
                                        <a id="btn_Add"     class="btn btn-primary"><i class="fa fa-plus"></i>&nbsp;补&nbsp;&nbsp;单</a>
                                    </td>
                                </tr>
                            </table>
                        </div>
                        <div class="rows" style="margin-top:0.5%; width:100%; overflow: hidden; ">
                              <div class="gridPanel">
                                   <table id="gridTable0"></table>
                              </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <style>
        *{
            font-size:15px; 
         }

        @media screen and (max-width: 1400px) { 
           .formTitle {
               font-size:15px;
               width:200px;
           } 
           #form1{
               margin:0px 0px 0px 5px;
           }
       } 
       @media screen and (min-width: 1400px) { 
          .formTitle {
              font-size:30px;
              width:300px;
          } 
           #form1{
               margin: 0px 0px 0px 5px;
           }
       } 
     </style>
    
</body>
</html>
