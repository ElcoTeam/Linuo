<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="WoMTLList.aspx.cs" Inherits="LiNuoMes.Mfg.WoMTLList" %>

<!DOCTYPE html>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title></title>
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
    
    <link href="../Content/adminLTE/css/index.css" rel="stylesheet" />
    <link href="../Content/scripts/plugins/jqgrid/jqgrid.css" rel="stylesheet" />
    <link rel="Shortcut icon" href="../images/favicon.ico" />
    <link href="../Content/styles/learun-ui.css" rel="stylesheet" />
    <link href="../css/my.css" rel="stylesheet" media="screen">
    <script src="../Content/scripts/plugins/layout/jquery.layout.js"></script>
    <script src="../Content/scripts/plugins/dialog/dialog.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/grid.locale-cn.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/jqgrid.min.js"></script>
    <script src="../Content/scripts/utils/learun-ui.js"></script>
    <script src="../Content/scripts/utils/learun-form.js"></script>
    <link href="../css/zTreeStyle/metro.css" rel="stylesheet" />
    <script src="../js/jquery.ztree.all-3.5.min.js"></script>
    <style>
        html, body {
            height: 100%;
            width: 100%;
        }
    </style>
</head>
<body>
    <script src="../BaseConfig/GetSetBaseConfig.js"></script>
     <script>
         var timerID = 0;
         var nCounter = 0;
         var WoId   = "";
         $(function () {
             if ($('#areascontent').height() > $(window).height()) {
                 $('#areascontent').css("margin-right", "0px");
             }
             $('#areascontent').height($(window).height());
             var areaheight = $("#areascontent").height();

             WoId = request("WoId");
             var $gridTable = $('#gridTable');
             $gridTable.jqGrid({
                 url: "./GetSetMfg.ashx",
                 postData: {
                     "Action": "MFG_WO_MTL_LIST",
                     "WoId": WoId
                 },
                 datatype: "json",
                 height: $('#areascontent').height() - 60,
                 width: $('#areascontent').width() - 10,
                 rowNum: -1,
                 jsonReader: {
                     repeatitems: false,   //此两个参数影响了是否刷新之后高亮选中记录: 如果直接设定为true, 则无论id项设定与否都可以实现高亮选中
                     id: "ID"              //此两个参数影响了是否刷新之后高亮选中记录: 需要设定为唯一字段即可,如果设定为0值, 则需要repeatitems为true才可以.
                 },
                 colModel: [
                     { label: 'ID', name: 'ID', hidden: true },
                     { label: '序号', name: 'InturnNumber', index: 'InturnNumber', width: 60, align: 'center', sortable: false },
                     { label: '行号', name: 'LineNumber', index: 'LineNumber', width: 60, align: 'center', sortable: false },
                     { label: '物料编码', name: 'ItemNumber', index: 'ItemNumber', width: 160, align: 'center', sortable: false },
                     { label: '物料描述', name: 'ItemDsca', index: 'ItemDsca', width: 350, align: 'left', sortable: false },
                     { label: '订单用量', name: 'ReqQty', index: 'ReqQty', width: 90, align: 'center', sortable: false },
                     { label: 'ERP库存', name: 'InvQty', index: 'InvQty', width: 90, align: 'center', sortable: false },
                     { label: '单位', name: 'UOM', index: 'UOM', width: 60, align: 'center', sortable: false },
                     { label: '工序编号', name: 'ProcessCode', index: 'ProcessCode', width: 80, align: 'center', sortable: false },
                     { label: '工作中心', name: 'WorkCenter', index: 'WorkCenter', width: 100, align: 'center', sortable: false },
                     { label: '库位', name: 'WHLocation', index: 'WHLocation', width: 60, align: 'center', sortable: false },
                     { label: '是否虚件', name: 'Phantom', index: 'Phantom', width: 80, align: 'center', sortable: false },
                     { label: '是否散装', name: 'Bulk', index: 'Bulk', width: 80, align: 'center', sortable: false },
                     { label: '是否反冲', name: 'Backflush', index: 'Backflush', width: 80, align: 'center', sortable: false }
                 ],
                 shrinkToFit: false,
                 autowidth: false,
                 scroll:true,
                 gridview: true
             });

             setRefreshTimer();

         });

         function getInvDataFromDB() {
             $.ajax({
                 url: "GetSetMfg.ashx",
                 data: {
                     "Action": "MFG_WO_MTL_LIST_INV",
                     "WoId": WoId
                 },
                 type: "post",
                 datatype: "json",
                 success: function (data) {
                     data = JSON.parse(data);
                     for (var i = 0; i < data.length; i++) {
                         var InvQty = data[i].InvQty;
                         var InvId  = data[i].ID;
                         var ReqQty = $('#gridTable').jqGrid('getRowData', InvId).ReqQty;
                         $('#gridTable').jqGrid('setRowData', InvId, { "InvQty": InvQty });
                         if (parseFloat(InvQty) < parseFloat(ReqQty)) {
                             $('#' + InvId).find("td").css("background-color", "#FF3333");
                         }                         
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

         function setRefreshTimer() {
             if (timerID == 0) {
                 nCounter = 0;
                 timerID = window.setInterval(refreshInvStatus, 5 * 1000);
             }
         }

         function clearRefreshTimer() {
             if (timerID != 0) {
                 window.clearInterval(timerID);
                 timerID = 0;
             }
         }

         function refreshInvStatus() {
             g_getSetParam("ERP_INVENTORY_DATA", "", "READ", RefreshInvTip);
         }

         function RefreshInvTip(Flag) {
             if      (Flag == '0') {
                 $("#msg_Rfs").html("刷新库存暂停.(" + nCounter + ")");
             }
             else if (Flag == '1') {
                 $("#msg_Rfs").html("刷新库存命令已发出...(" + nCounter + ")");
             }
             else if (Flag == '2') {
                 getInvDataFromDB();
                 $("#msg_Rfs").html("刷新库存进行中...(" + nCounter + ")");
             }
             else if (Flag == '3') {
                 clearRefreshTimer();
                 getInvDataFromDB();
                 $("#msg_Rfs").html("刷新库存完成.");
             }
             else if (Flag == '4') {
                 clearRefreshTimer();
                 $("#msg_Rfs").html("刷新库存失败!!!");
             }

             if (Flag != '3' && Flag != '4') {
                 setRefreshTimer();
             }
             nCounter++;
         }

         function AcceptClick(grid) {
            dialogClose();
            return;
         }

         function request(name) {
             var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)");
             var r = window.location.search.substr(1).match(reg);
             if (r != null) return unescape(r[2]); return null;
         }


    </script>
        <div id="areascontent" style="margin:0px; overflow: hidden;">
            <div style="border: 1px solid #e6e6e6; background-color: #fff; ">
                <div class="gridPane" style="overflow: hidden; ">
                    <table id="gridTable"></table>
                </div>
            </div>
            <div id="msg_Rfs" style="text-align:right; margin:0px; padding-right:5px; vertical-align:central; border: 1px solid #e6e6e6; background-color: #e6e6e6; "></div>
        </div>
   <style>
    .form .formTitle {
        width:65px;
        font-size:9pt;
    }
  
    </style>
</body>
</html>

