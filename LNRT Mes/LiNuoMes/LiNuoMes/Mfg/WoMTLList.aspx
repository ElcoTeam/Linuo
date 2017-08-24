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
     <script>
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
                 height: $('#areascontent').height() - 50,
                 width: $('#areascontent').width() - 10,
                 rowNum: -1,
                 colModel: [
                     { label: 'ID', name: 'ID', hidden: true },
                     { label: '序号', name: 'InturnNumber', index: 'InturnNumber', width: 60, align: 'center', hidden: true, sortable: false },
                     { label: '行号', name: 'LineNumber', index: 'LineNumber', width: 60, align: 'center', sortable: false },
                     { label: '物料编码', name: 'ItemNumber', index: 'ItemNumber', width: 160, align: 'center', sortable: false },
                     { label: '物料描述', name: 'ItemDsca', index: 'ItemDsca', width: 350, align: 'left', sortable: false },
                     { label: '数量', name: 'Qty', index: 'Qty', width: 90, align: 'center', sortable: false },
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

         });

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
        </div>
   <style>
    .form .formTitle {
        width:65px;
        font-size:9pt;
    }
  
    </style>
</body>
</html>

