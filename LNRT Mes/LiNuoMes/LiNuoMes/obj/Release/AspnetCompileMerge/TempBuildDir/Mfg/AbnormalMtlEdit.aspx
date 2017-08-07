<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AbnormalMtlEdit.aspx.cs" Inherits="LiNuoMes.Mfg.AbnormalMtlEdit" %>

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
    <script type="text/javascript" src="../js/m.js" charset="gbk"></script>
    <script src="../js/pdfobject.js" type="text/javascript"></script>
    <link href="../Content/scripts/plugins/jquery-ui/jquery-ui.min.css" rel="stylesheet" />
    <script src="../Content/scripts/plugins/jquery-ui/jquery-ui.min.js"></script>
    <!-- Bootstrap -->
    <link href="../Content/scripts/plugins/icheck/skins/square/square.css" rel="stylesheet" />
    <script src="../Content/scripts/plugins/icheck/icheck.min.js"></script>
    <link rel="stylesheet" type="text/css" href="../css/bootstrap.min.css" />
    <link href="../Content/styles/font-awesome.min.css" rel="stylesheet" />
    <%--<link href="../css/learun-ui.css" rel="stylesheet" />--%>
    <link href="../Content/adminLTE/css/index.css" rel="stylesheet" />
    <link href="../Content/scripts/plugins/jqgrid/jqgrid.css" rel="stylesheet" />
    <link rel="Shortcut icon" href="http://www.jq22.com/favicon.ico" />
    <link href="../Content/styles/learun-ui.css?v=xGgPBYcCVZtMx26lXm_bETZOl5nvwnNwIiq-fpPtywo1" rel="stylesheet" />
    <link href="../css/my.css" rel="stylesheet" media="screen">
    <script src="../Content/scripts/plugins/layout/jquery.layout.js"></script>
    <script src="../Content/scripts/plugins/dialog/dialog.js"></script>
    <script src="../Content/adminLTE/index.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/grid.locale-cn.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/jqgrid.min.js"></script>
    <script src="../Content/scripts/utils/learun-ui.js"></script>
    <script src="../Content/scripts/utils/learun-form.js"></script>
    <script src="../My97DatePicker/WdatePicker.js"></script>
    <script src="../Content/scripts/plugins/validator/validator.js"></script>
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
     var AbId = "";
     var OPtype   = "";
     var OPaction = "";
     var selectedRowIndex = "";

     $(function () {
              AbId = request('AbId');
              OPtype = request('OPtype');

              if (AbId == undefined) {
                  AbId = 0;
              }

              if (OPtype == undefined) {
                  OPtype = "CHECK";
              }

              $(":input").attr("disabled", true);
              InitPageBase();
              InitPageGrid();
              $(document).delegate(':text', "focus", function () {
              //       $(this).select();
              });

         });
     
     function InitPageBase() {
         $.ajax({
             url: "GetSetMfg.ashx",
             data: {
                 "Action": "MFG_WIP_DATA_ABNORMAL_DETAIL",
                 "AbId": AbId
             },
             type: "post",
             datatype: "json",
             success: function (data) {
                 data = JSON.parse(data);
                 $("#RFID").val(data.RFID);
                 $("#WorkOrderNumber").val(data.WorkOrderNumber);
                 $("#GoodsCode").val(data.GoodsCode);
             },
             error: function (msg) {
                 alert(msg.responseText);
             }
         });
     }

     function InitPageGrid() {
         var $gridTable = $('#gridTable');
         var panelwidth = 760;
         var panelheight = 380;
         $gridTable.jqGrid({
             url: "./GetSetMfg.ashx",
             postData: {
                 "Action": "MFG_WIP_DATA_ABNORMAL_MTL",
                 "AbId": AbId
             },
             datatype: "json",
             height: panelheight,
             width: panelwidth,
             rowNum: -1,
             jsonReader: {
                 repeatitems: false,
                 id: "ID"
             },
             colModel: [
                 { label: 'ID', name: 'ID', hidden: true },
                 { label: '原始剩余数量', name: 'OLeftQty', index: 'OLeftQty', hidden: true },
                 { label: '原始需求数量', name:'ORequireQty', index:'ORequireQty', hidden:true},
                 { label: '序号', name: 'InturnNumber', index: 'InturnNumber', width: panelwidth * 0.10, align: 'center' },
                 { label: '工序', name: 'ProcessCode', index: 'ProcessCode', width: panelwidth * 0.20, align: 'center' },
                 { label: '物料编码', name: 'ItemNumber', index: 'ItemNumber', width: panelwidth * 0.40, align: 'center' },
                 {
                     label: '剩余数量', name: 'LeftQty', index: 'LeftQty', width: panelwidth * 0.15, align: 'center',
                     editable: true,
                     editrules: {
                         number: true,
                         custom: false,
                         required: true,
                         minValue: 0,
                         maxValue: 50000
                     }
                 },
                 {
                     label: '需求数量', name: 'RequireQty', index: 'RequireQty', width: panelwidth * 0.15, align: 'center',
                     editable: true,
                     editrules: {
                         number: true,
                         custom: false,
                         required: true,
                         minValue: 0,
                         maxValue: 50000
                     }
                 },
             ],
             shrinkToFit: true,
             autowidth: true,
             scroll: true,
             multiselect: false,
             gridview: true,
             beforeSelectRow: function (rowid) {
                 if (OPtype != "CHECK") {
                     if (rowid && rowid !== selectedRowIndex) {
                         jQuery("#gridTable").saveRow(selectedRowIndex, true);
                     }
                     jQuery("#gridTable").editRow(rowid, true);
                 }
                 selectedRowIndex = rowid;
                 return false;
             },
             onSelectRow: function (rowid) { },
             gridComplete: function () {
                  if (OPtype != "CHECK") {
                      var ids = $gridTable.jqGrid("getDataIDs");
                      for (var i = ids.length-1; i >=0  ; i--) {
                          var LeftQty = $gridTable.jqGrid("getCell", ids[i], "LeftQty");
                          var RequireQty = $gridTable.jqGrid("getCell", ids[i], "RequireQty");
                  
                          $gridTable.jqGrid("setCell", ids[i], "OLeftQty", LeftQty);
                          $gridTable.jqGrid("setCell", ids[i], "ORequireQty", RequireQty);

                          //此处不要随便打开启用(尽管打开之后界面会比较酷): 因为当前选中的行不一定等于当前编辑的行, 如果有未完成编辑的行即提交会引起错误.
                          $gridTable.jqGrid("editRow", ids[i], true); 
                      }
                  }
             }
         });
     }

     function GetUpdatedListJson() {
         var tmpList = [];
         var itemRows = $('#gridTable').getRowData();
         for (i in itemRows) {

             if (   isNaN(parseFloat(itemRows[i].LeftQty))
                 || isNaN(parseFloat(itemRows[i].RequireQty))  ) {
                 dialogMsg("发现了非数字数据类型, 请核对!", -1);
                 tmpList.length = 0;
                 return tmpList;
             }

             if (   parseFloat(itemRows[i].LeftQty)    != parseFloat(itemRows[i].OLeftQty)
                 || parseFloat(itemRows[i].RequireQty) != parseFloat(itemRows[i].ORequireQty)  ) {
                 tmpList.push({
                     "ID":         itemRows[i].ID,
                     "LeftQty":    parseFloat(itemRows[i].LeftQty),
                     "RequireQty": parseFloat(itemRows[i].RequireQty)
                 });
             }
         }

         if (tmpList.length == 0) {
             dialogMsg("系统没有发现您有任何数据更新!", -1);
         }

         return tmpList;
     }

     function AcceptClick(grid) {

         if (OPtype == "CHECK")
         {
             dialogClose();
             return;
         }

         var ids = $("#gridTable").jqGrid().getDataIDs();
         for (var i = 0; i < ids.length; i++) {
             $("#gridTable").saveRow(ids[i], true);
         }

         var ListJason = GetUpdatedListJson();
         if (ListJason.length == 0) {
             return;
         }
         var ListJason = JSON.stringify(ListJason);
                  
         $.ajax({
             url: "GetSetMfg.ashx",
             data: {
                 "Action": "MFG_WIP_DATA_ABNORMAL_MTL_EDIT",
                 "ListJason": ListJason
             },
             async: true,
             type: "post",
             datatype: "json",
             success: function (data) {
                 Loading(false);
                 data = JSON.parse(data);
                 if (data.result == "success") {
                     dialogMsg("保存成功", 1);
                     dialogClose();
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
                 Loading(true, "正在保存数据");
             },
             complete: function () {
                 Loading(false);
             }
         });
     }

     function request(name) {
         var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)");
         var r = window.location.search.substr(1).match(reg);
         if (r != null) return unescape(r[2]); return null;
     }

</script>
    <div style="margin-left: 10px; margin-top: 10px; margin-right: 10px;">
        <table class="form" style="margin-top:0px;"  border="0">
            <tr>
                <td class="formTitle">MES码:</td>
                <td colspan="3">
                    <input type="text" class="form-control" id="RFID" />
                </td>

            </tr>
            <tr>
                <td class="formTitle">订单编号:</td>
                <td>
                    <input type="text" class="form-control" id="WorkOrderNumber"/>
                </td>
                <td class="formTitle">产品物料编码:</td>
                <td>
                    <input type="text" class="form-control" id="GoodsCode"  />
                </td>
            </tr>               
        </table>
    </div>
    <div class="rows" style="margin:10px; width:98%; overflow: hidden; ">
        <div class="gridPanel">
            <table id="gridTable"></table>
        </div>
    </div>

   <style>
    .editable {
           font-size:15px!important;
            font-weight:normal; 
            line-height:1.1;
            text-align:center;      
    }

    .formTitle {
        width:120px;
        font-size:9pt;
        padding:5px!important;
    }
    .formValue  {
        width:200px;
        font-size:9pt;
    }

    .form-control  {
        width:180px;
        font-size:9pt;
    }
  
    </style>
</body>
</html>

