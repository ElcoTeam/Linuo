<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AttaDetailEdit.aspx.cs" Inherits="LiNuoMes.BaseConfig.AttaDetailEdit" %>

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
         var GoodsCode = "";
         var MainItem  = "";

         $(function () {
             GoodsCode = request('GoodsCode');
             MainItem  = request('MainItem');
         });
         
         //保存表单
         function AcceptClick(grid) {
             
             var ItemNumber = $("#ItemNumber").val().trim();
             var ItemDsca   = $("#ItemDsca").val().trim();
             var RatioQty   = $("#RatioQty").val().trim();


             if (ItemNumber.length == 0) {
                 dialogMsg("请物料料号!", -1);
                 $("#ItemNumber").focus();
                 return;
             }

             if (ItemDsca.length == 0) {
                 dialogMsg("请录入物料描述!", -1);
                 $("#ItemDsca").focus();
                 return;
             }

             if (RatioQty.length == 0) {
                 dialogMsg("请录入物料的用料比例!", -1);
                 $("#RatioQty").focus();
                 return;
             }

             $.ajax({
                 url: "../BaseConfig/GetSetBaseConfig.ashx",
                 data: {
                     Action: "MES_MTL_PULL_ITEM_ATTACHED_ADD",
                     GoodsCode: GoodsCode,
                     MainItem : MainItem,
                     ItemNumber: ItemNumber,
                     ItemDsca: ItemDsca,
                     RatioQty: RatioQty
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
                         grid.trigger("reloadGrid");
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
    <div style="margin-left: 10px; margin-top: 20px; margin-right: 10px;">
            <table class="form" id="ruleinfo" style="margin-top:0px;" border="0">
                <tr>
                    <th class="formTitle">物料料号<font face="宋体">*</font></th>
                    <td class="formValue">
                        <input type="text" class="form-control"  id="ItemNumber" isvalid="yes" checkexpession="NotNull" />
                    </td>
                 </tr>
                <tr>
                    <th class="formTitle">物料描述<font face="宋体">*</font></th>
                    <td class="formValue">
                        <input type="text" class="form-control"  id="ItemDsca" isvalid="yes" checkexpession="NotNull" />
                    </td>
                </tr>
                <tr>
                    <th class="formTitle">用料比例<font face="宋体">*</font></th>
                    <td class="formValue">
                        <input type="text" class="form-control"  id="RatioQty" isvalid="yes" checkexpession="NotNull" />
                    </td>
                </tr>
               
            </table>
    </div>
   <style>
    .form .formTitle {
        width:65px;
        font-size:9pt;
    }
  
    </style>
</body>
</html>

