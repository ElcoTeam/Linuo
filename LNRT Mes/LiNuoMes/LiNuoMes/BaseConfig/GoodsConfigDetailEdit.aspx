<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="GoodsConfigDetailEdit.aspx.cs" Inherits="LiNuoMes.BaseConfig.GoodsConfigDetailEdit" %>

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
    <script src="../Content/adminLTE/index.js"></script>
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
         var GoodsId  = "";
         var OPtype   = "";
         var OPaction = "";

         $(function () {
             GoodsId = request('GoodsId');
             OPtype  = request('OPtype');

             if (GoodsId == undefined) {
                 GoodsId = 0;
             }
         
             if (OPtype == undefined) {
                 OPtype = "CHECK";
             }

             if (OPtype == "CHECK") {
                 OPaction = "MES_GOODS_CONFIG_DETAIL";
             }
             else if (OPtype == "EDIT") {
                 OPaction = "MES_GOODS_CONFIG_EDIT";
             }
             else if (OPtype == "ADD") {
                 OPaction = "MES_GOODS_CONFIG_ADD";
             }
             else {
                 return;
             }
             InitialPage();             
         });
         
         function InitialPage() {
             if (OPtype == "CHECK") {
                 $(".form-control").attr("disabled", true);           
             }

             $.ajax({
                 url: "GetSetBaseConfig.ashx",
                 data: {
                     "Action": "MES_GOODS_CONFIG_DETAIL",
                     "GoodsId": GoodsId
                 },
                 type: "post",
                 datatype: "json",
                 success: function (data) {
                     data = JSON.parse(data);
                     $("#GoodsCode").val(data.GoodsCode);
                     $("#GoodsDsca").val(data.GoodsDsca);
                     $("#DimLength").val(data.DimLength);
                     $("#DimHeight").val(data.DimHeight);
                     $("#DimWidth").val(data.DimWidth);
                     $("#UnitCostTime").val(data.UnitCostTime);
                 },
                 error: function (msg) {
                     alert(msg.responseText);
                 }
             });
         }

         //保存表单
         function AcceptClick(grid) {
             
             if (OPtype == "CHECK")
             {
                 dialogClose();
                 return;
             }

             var GoodsCode = $("#GoodsCode").val().trim().toUpperCase();
             var GoodsDsca = $("#GoodsDsca").val().trim();
             var DimLength = $("#DimLength").val().trim();
             var DimHeight = $("#DimHeight").val().trim();
             var DimWidth  = $("#DimWidth").val().trim();
             var UnitCostTime = $("#UnitCostTime").val().trim();

             $("#GoodsCode").val(GoodsCode);

             if (GoodsCode.length == 0) {
                 dialogMsg("请录入产品物料编号!", -1);
                 $("#GoodsCode").focus();
                 return;
             }

             if (GoodsDsca.length == 0) {
                 dialogMsg("请录入产品物料编码说明!", -1);
                 $("#GoodsDsca").focus();
                 return;
             }

             if (DimLength.length == 0) {
                 dialogMsg("请录入长度!", -1);
                 $("#DimLength").focus();
                 return;
             }

             if (!parseInt(DimLength, 10)) {
                 dialogMsg("长度参数必须整型数字!", -1);
                 return;
             }

             if (DimWidth.length == 0) {
                 dialogMsg("请录入宽度!", -1);
                 $("#DimWidth").focus();
                 return;
             }

             if (!parseInt(DimWidth, 10)) {
                 dialogMsg("宽度参数必须整型数字!", -1);
                 return;
             }

             if (DimHeight.length == 0) {
                 dialogMsg("请录入高度!", -1);
                 $("#DimHeight").focus();
                 return;
             }

             if (!parseInt(DimHeight, 10)) {
                 dialogMsg("高度参数必须整型数字!", -1);
                 return;
             }

             if (UnitCostTime.length == 0) {
                 dialogMsg("请录入单位生产耗时!", -1);
                 $("#UnitCostTime").focus();
                 return;
             }

             if (!parseInt(UnitCostTime, 10)) {
                 dialogMsg("单位生产耗时参数必须整型数字!", -1);
                 return;
             }

             $.ajax({
                 url: "GetSetBaseConfig.ashx",
                 data: {
                     Action        : OPaction,
                     GoodsId       : GoodsId,
                     GoodsCode     : GoodsCode,
                     GoodsDsca     : GoodsDsca,
                     DimLength     : DimLength,
                     DimHeight     : DimHeight,
                     DimWidth      : DimWidth,
                     UnitCostTime  : UnitCostTime
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
            <table class="form" id="ruleinfo" border="0" style="margin-top:0px;">
                <tr>
                    <th class="formTitle">产品物料编码<font face="宋体">*</font></th>
                    <td class="formValue">
                        <input type="text" class="form-control" id="GoodsCode" isvalid="yes" checkexpession="NotNull" />
                    </td>
                </tr>
                <tr>
                    <th class="formTitle">长<font face="宋体">*</font></th>
                    <td class="formValue" >
                        <input type="text" class="form-control" id="DimLength" isvalid="yes" checkexpession="NotNull" />
                    </td>
                </tr>
                <tr>
                    <th class="formTitle">宽<font face="宋体">*</font></th>
                    <td class="formValue" >
                        <input type="text" class="form-control"  id="DimWidth" isvalid="yes" checkexpession="NotNull" />
                    </td>
                 </tr>
                 <tr>
                    <th class="formTitle">高<font face="宋体">*</font></th>
                    <td class="formValue" >
                        <input type="text" class="form-control"  id="DimHeight" isvalid="yes" checkexpession="NotNull" />
                    </td>
                <tr>
                    <th class="formTitle">单位生产耗时<font face="宋体">*</font></th>
                    <td class="formValue" >
                        <input type="text" class="form-control" id="UnitCostTime" isvalid="yes" checkexpession="NotNull" placeholder="默认2分钟"/>
                    </td>
                </tr>
               <tr>
                    <th class="formTitle" style="vertical-align:top">产品物料编码说明</th>
                    <td class="formValue" >
                        <textarea id="GoodsDsca"  class="form-control" style="height: 180px;"></textarea>
                    </td>
                </tr>
               
            </table>
    </div>
   <style>
    .form .formTitle {
        width:36px;
        font-size:9pt;
    }
    .form .formValue {
        width:125px;
        font-size:9pt;
    }
  
    </style>
</body>
</html>

