<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MaterialBkfItemEdit.aspx.cs" Inherits="LiNuoMes.Mfg.MaterialBkfItemEdit" %>

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
    <link href="../Content/scripts/plugins/icheck/skins/square/square.css" rel="stylesheet" />
    <script src="../Content/scripts/plugins/icheck/icheck.min.js"></script>
    <link rel="stylesheet" type="text/css" href="../css/bootstrap.min.css" />
    <link href="../Content/styles/font-awesome.min.css" rel="stylesheet" />
    <%--<link href="../css/learun-ui.css" rel="stylesheet" />--%>
    <link href="../Content/adminLTE/css/index.css" rel="stylesheet" />
    <link href="../Content/scripts/plugins/jqgrid/jqgrid.css" rel="stylesheet" />
    <link rel="Shortcut icon" href="http://www.jq22.com/favicon.ico" />
    <link href="../Content/styles/learun-ui.css" rel="stylesheet" />
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
         var ItemId = "";
         var OPtype   = "";
         var OPaction = "";
         $(function () {
                
                ItemId = request('ItemId');
                OPtype = request('OPtype');

                if (ItemId == undefined) {
                    ItemId = 0;
                }

                if (OPtype == undefined) {
                    OPtype = "CHECK";
                }

                if (OPtype == "EDIT") {
                    OPaction = "MFG_WIP_DATA_ABNORMAL_EDIT";
                }
                else if (OPtype == "ADD") {
                    OPaction = "MFG_WIP_DATA_ABNORMAL_ADD";
                }

                if (OPtype == "EDIT") {
                    InitialPage();
                }
                
         });

         function InitialPage() {

             $.ajax({
                 url: "GetSetMfg.ashx",
                 data: {
                     "Action": "MFG_WIP_BKF_ITEM_DETAIL",
                     "ItemId": ItemId
                 },
                 type: "post",
                 datatype: "json",
                 success: function (data) {
                     InitDataItems(JSON.parse(data));
                 },

                 error: function (msg) {
                     alert(msg.responseText);
                 }
             });
         }

         function InitDataItems(data) {
             $("#ItemNumber").val(data.ItemNumber);
             $("#ItemDsca").val(data.ItemDsca);
             $("#UOM").val(data.UOM);
         }
        

         function AcceptClick(grid) {

             var ItemNumber = $("#ItemNumber").val().trim();
             var ItemDsca   = $("#ItemDsca").val().trim();
             var UOM        = $("#UOM").val().trim();

             if (ItemNumber.length == 0) {
                 dialogMsg("请录入料号!", -1);
                 $("#ItemNumber").focus();
                 return;
             }

             if (ItemDsca.length == 0) {
                 dialogMsg("请录入料号描述!", -1);
                 $("#ItemDsca").focus();
                 return;
             }

             if (UOM.length == 0) {
                 dialogMsg("请录入单位!", -1);
                 $("#UOM").focus();
                 return;
             }

             $.ajax({
                 url: "GetSetMfg.ashx",
                 data: {
                     "Action"   : OPaction,
                     "ItemId"   : ItemId,
                     "ItemDsca" : AbnormalPoint,
                     "UOM"      : AbnormalProduct,
                 },
                 async: true,
                 type: "post",
                 datatype: "json",
                 success: function (data) {
                     Loading(false);
                     data = JSON.parse(data);
                     if (data.result == "success") {
                         dialogMsg("保存成功", 1);
                         grid.trigger("reloadGrid");
                      //   dialogClose();
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
            <table class="form" style="margin-top:2px; padding:5px"  border="0"  >
                <tr>
                    <td class="formTitle">物料编码:</td>
                    <td>
                        <input type="text" class="form-control" id="ItemNumber"  />
                    </td>
                </tr>               
                <tr>
                    <td class="formTitle">物料描述:</td>
                    <td>
                        <input type="text" class="form-control" id="ItemDsca"  />
                    </td>
                </tr>               
                <tr>
                    <td class="formTitle">单位:</td>
                    <td>
                        <input type="text" class="form-control" id="UOM"  />
                    </td>
                </tr>               
            </table>
    </div>
   <style>
     table td{padding:2px;}
    .formTitle {
        width:60px;
        font-size:9pt;
        padding:5px!important;
    }

    .rTitle {
        width:110px;
        font-size:9pt;
        font-weight:normal;
        color:blueviolet; 
        text-align:left;
        padding:5px!important;
    }

    .pTitle {
        width:68px;
        font-size:9pt;
        font-weight:normal;
        color:blueviolet; 
        text-align:left;
        padding:5px!important;
    }

    .liTitle {
        width:250px;
        font-size:9pt;
        padding-left:5px;
        padding-bottom:5px;
        font-weight:normal;
        text-align:left;
    }

    .formValue  {
        width:160px;
        font-size:9pt;
    }

    .form-control  {
        width:280px;
        font-size:9pt;
    }
  
    </style>
</body>
</html>

