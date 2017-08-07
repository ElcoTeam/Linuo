<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="WoDetailEdit.aspx.cs" Inherits="LiNuoMes.Mfg.WoDetailEdit" %>

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
         var WoId   = "";
         var OPtype   = "";
         var OPaction = "";
         var originalCustomerID = "0";

         $(function () {
                WoId = request('WoId');
                OPtype = request('OPtype');

                if (WoId == undefined) {
                    WoId = 0;
                }
         
                if (OPtype == undefined) {
                    OPtype = "CHECK";
                }

                if (OPtype == "CHECK") {
                    OPaction = "MFG_WO_LIST_DETAIL";
                }
                else if (OPtype == "EDIT") {
                    OPaction = "MFG_WO_LIST_EDIT";
                }
                else if (OPtype == "ADD") {
                    OPaction = "MFG_WO_LIST_ADD";
                }
                else {
                    return;
                }
                listOptions();
                InitialPage();
                $("#btn_MaintainCustomer").bind("click", onMaintainCustomer);
         });
         
         function InitialPage() {
             if (OPtype == "CHECK") {
                 $(".form-control,#PlanStartTime,#PlanFinishTime").attr("disabled", true);
                 $("#btn_upload").attr("disabled", true);
             }
             $("#WorkOrderNumber,#GoodsCode,#WorkOrderType,#PlanQty").attr("disabled", true);

             $("#btn_upload").height($("[text]").height());
             $("#PlanStartTime").bind("change", setFinishTime);             
             $("#PlanFinishTime").bind("change", setStartTime);
             $("#CostTime").bind("change", setFinishTime);
             $("#UnitCostTime").bind("change", setCostTime);

             $.ajax({
                 url: "GetSetMfg.ashx",
                 data: {
                     "Action": "MFG_WO_LIST_DETAIL",
                     "WoId": WoId
                 },
                 type: "post",
                 datatype: "json",
                 success: function (data) {
                     data = JSON.parse(data);
                     $("#WorkOrderNumber").val(data.WorkOrderNumber);
                     $("#GoodsCode").val(data.GoodsCode);
                     $("#WorkOrderType").val(
                           data.WorkOrderType == "0" ? "正常订单"
                         : data.WorkOrderType == "1" ? "下线补单"
                         : "" );
                     $("#PlanQty").val(data.PlanQty);
                     $("#UnitCostTime").val(data.UnitCostTime);
                     $("#CostTime").val(data.CostTime);
                     $("#PlanStartTime").val(data.PlanStartTime);
                     $("#PlanFinishTime").val(data.PlanFinishTime);
                     $("#CustomerID").val(data.CustomerID);
                     $("#OrderComment").val(data.OrderComment);
                 },

                 error: function (msg) {
                     alert(msg.responseText);
                 }
             });
         }
        
         function setFinishTime()
         {
             var startTime = new Date($("#PlanStartTime").val());
             var costTime = parseInt($("#CostTime").val(), 10);
             var finishTime = new Date(startTime.getTime() + costTime * 60 * 1000);
             $("#PlanFinishTime").val(finishTime.format("yyyy-MM-dd hh:mm") );
         }

         function setStartTime() {
             var finishTime = new Date($("#PlanFinishTime").val());
             var costTime = parseInt($("#CostTime").val(), 10);
             var startTime = new Date(finishTime.getTime() - costTime * 60 * 1000);
             $("#PlanStartTime").val(startTime.format("yyyy-MM-dd hh:mm"));
         }

         function setCostTime() {
             var unitCostTime = parseInt($("#UnitCostTime").val(), 10);
             var planQty = parseInt($("#PlanQty").val(), 10);
             var costTime = unitCostTime * planQty;
             $("#CostTime").val(costTime);
             $("#CostTime").trigger("change");;
         }

         //取得当前时间并转换成YYYY-MM-DD HH:MM格式
         function getNowDateTime(){
             var myDate = new Date();
             str = myDate.format("yyyy-MM-dd hh:mm");
             return str;
         }

         Date.prototype.format = function(format){
             var o = {
                 "M+" : this.getMonth()+1, //month
                 "d+" : this.getDate(),    //day
                 "h+" : this.getHours(),   //hour
                 "m+" : this.getMinutes(), //minute
                 "s+" : this.getSeconds(), //second
                 "q+" : Math.floor((this.getMonth()+3)/3), //quarter
                 "S" : this.getMilliseconds() //millisecond
             }
             if(/(y+)/.test(format)){ 
                 format=format.replace(RegExp.$1,(this.getFullYear()+"").substr(4- RegExp.$1.length));
             }
             for(var k in o){
                 if(new RegExp("("+ k +")").test(format)){
                     format = format.replace(RegExp.$1,RegExp.$1.length==1? o[k] :("00"+ o[k]).substr((""+o[k]).length));
                 }
             }
             return format;
         }

         //保存表单
         function AcceptClick(grid) {
             
             if (OPtype == "CHECK")
             {
                 dialogClose();
                 return;
             }

             var UnitCostTime = $("#UnitCostTime").val().trim();
             var CostTime = $("#CostTime").val().trim();
             var PlanStartTime = $("#PlanStartTime").val().trim();
             var PlanFinishTime = $("#PlanFinishTime").val().trim();
             var CustomerID = $("#CustomerID").val();
             var OrderComment = $("#OrderComment").val().trim();

             if (UnitCostTime.length == 0) {
                 dialogMsg("请录入单位生产耗时!", -1);
                 $("#UnitCostTime").focus();
                 return;
             }

             if (CostTime.length == 0) {
                 dialogMsg("请录入生产预计耗时!", -1);
                 $("#CostTime").focus();
                 return;
             }

             if (PlanStartTime.length == 0) {
                 dialogMsg("请录入计划开始时间!", -1);
                 $("#PlanStartTime").focus();
                 return;
             }

             if (PlanFinishTime.length == 0) {
                 dialogMsg("请录入计划完成时间!", -1);
                 $("#PlanFinishTime").focus();
                 return;
             }

             if (CustomerID.length == 0) {
                 dialogMsg("请设定客户!", -1);
                 $("#CustomerID").focus();
                 return;
             }

             if (!parseInt(UnitCostTime, 10)) {
                 dialogMsg("单位生产耗时必须为数字!", -1)
                 $("#UnitCostTime").focus();
                 return;
             }

             if (!parseInt(CostTime, 10)) {
                 dialogMsg("生产预计耗时必须为数字!", -1);
                 $("#CostTime").focus();
                 return;
             }

         //    if(! $("#ruleinfo").Validform() )
         //    {
         //         return false;
         //        //alarm("please input the data.");
         //    }

             $.ajax({
                 url: "GetSetMfg.ashx",
                 data: {
                     Action        : OPaction,
                     WoId          : WoId,
                     UnitCostTime  : UnitCostTime,
                     CostTime      : CostTime,
                     PlanStartTime : PlanStartTime,
                     PlanFinishTime: PlanFinishTime,
                     CustomerID    : CustomerID,
                     OrderComment  : OrderComment
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

         function listOptions() {
             var strListOptions = "";
             $.ajax({
                 url: "../BaseConfig/GetSetBaseConfig.ashx",
                 data: { Action: "MES_CUSTOMER_LIST" },
                 type: "post",
                 async: false, //这项要打开, 防止列表清单还没有显示完成的时候, 就发生了设定值的情况发生.
                 datatype: "json",
                 success: function (data) {
                     data = JSON.parse(data);
                     for (var i=0; i<data.length; i++) {
                         strListOptions += "<option value=\"" + data[i].CustomerID + "\" >" + data[i].CustomerName + "</option>";
                     }
                     $("#CustomerID").html("<option value=''>请选择...</option> " + strListOptions);
                     $("#CustomerID").val(originalCustomerID);
                 },
                 error: function (msg) {
                     alert(msg.responseText);
                 }
             });
         }


         function request(name) {
             var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)");
             var r = window.location.search.substr(1).match(reg);
             if (r != null) return unescape(r[2]); return null;
         }


         function onMaintainCustomer() {

             var sWidth = "600px";
             var sHeight = "480px"
             originalCustomerID = $("#CustomerID").val();
             dialogOpen({
                 id: "FormCustomerConfig",
                 title: "客户信息维护",
                 url: "../BaseConfig/CustomerConfig.aspx",
                 width: sWidth,
                 height: sHeight,
                 callBack: function (iframeId) {
                     top.frames[iframeId].AcceptClick(listOptions);
                 }
             });

         }


    </script>
    <div style="margin-left: 10px; margin-top: 20px; margin-right: 10px;">
            <table class="form" id="ruleinfo" style="margin-top:0px;"  border="0">
                <tr>
                    <th class="formTitle">订单编号<font color="red">*</font></th>
                    <td class="formValue">
                        <input type="text" class="form-control" id="WorkOrderNumber" isvalid="yes" checkexpession="NotNull" />
                    </td>
                    <th class="formTitle">产品物料编码<font color="red">*</font></th>
                    <td class="formValue">
                        <input type="text" class="form-control" id="GoodsCode" isvalid="yes" checkexpession="NotNull" />
                    </td>
                </tr>
                <tr>
                    <th class="formTitle">订单类型<font color="red">*</font></th>
                    <td class="formValue">
                        <input type="text" class="form-control" id="WorkOrderType" isvalid="yes" checkexpession="NotNull" />
                    </td>
                    <th class="formTitle">订单数量<font color="red">*</font></th>
                    <td class="formValue">
                        <input type="text" class="form-control" id="PlanQty" isvalid="yes" checkexpession="NotNull" />
                    </td>
                </tr>
                <tr>
                    <th class="formTitle">单位生产耗时<font color="red">*</font></th>
                    <td class="formValue">
                        <input type="text" class="form-control"  id="UnitCostTime" isvalid="yes" checkexpession="PositiveNum" />
                    </td>
                    <th class="formTitle">生产预计耗时<font color="red">*</font></th>
                    <td class="formValue">
                        <input type="text" class="form-control"  id="CostTime" isvalid="yes" checkexpession="PositiveNum" />
                    </td>
                 </tr>
                 <tr>
                    <th class="formTitle">计划开始时间<font color="red">*</font></th>
                    <td class="formValue">
                        <input type="text" onFocus="WdatePicker({dateFmt:'yyyy-MM-dd HH:mm', onpicked:setFinishTime, minDate:'%y-%M-%d 00:00:00',maxDate:'%y-%M-%d 23:59:59',readOnly:true, highLineWeekDay:true, isShowClear:false })" class="Wdate timeselect" id="PlanStartTime" isvalid="yes" checkexpession="NotNull" />
                    </td>
                    <th class="formTitle">计划完成时间<font color="red">*</font></th>
                    <td class="formValue">
                        <input type="text" onFocus="WdatePicker({dateFmt:'yyyy-MM-dd HH:mm', onpicked:setStartTime, minDate: '#F{$dp.$D(\'PlanStartTime\')}', maxDate:'%y-%M-{%d+1} 23:59:59',readOnly:true, highLineWeekDay:true, isShowClear:false })" class="Wdate timeselect"  id="PlanFinishTime" isvalid="yes" checkexpession="NotNull" />
                    </td>
<%--                <tr>
                    <th class="formTitle">客户名称</th>
                    <td class="formValue" colspan="2">
                        <input type="text" class="form-control"  id="CustomerName" isvalid="yes" checkexpession="NotNull"/>
                    </td>
                    <td ></td>
                </tr>
                <tr>
                    <th class="formTitle">客户LOGO</th>
                    <td class="formValue" colspan="2">
                         <input type="text" class="form-control"  id="CustomerLogo" isvalid="yes" checkexpession="NotNull" readonly/>
                    </td>
                    <td style="vertical-align:top">
                        <a id="btn_upload" class="btn btn-default" onclick="onUpload(event)" style="padding-top:2px"><i class="fa fa-upload"></i>&nbsp;上传</a>
                        <input type="hidden" id="UploadedFile" value=""/>
                    </td>                    
                </tr>
--%>
                <tr>
                    <th class="formTitle">客户信息</th>
                    <td class="formValue" colspan="2">
                        <select class="form-control" id="CustomerID"></select>
                    </td>
                    <td style="vertical-align:top"><a id="btn_MaintainCustomer"  class="btn btn-default" style="height:30px; padding-top:4px"><i class="fa fa-bars"></i>&nbsp;客户信息维护</a></td>
                </tr>
                <tr>
                    <th class="formTitle" style="vertical-align:top">简单说明</th>
                    <td class="formValue" colspan="3">
                        <textarea id="OrderComment"  class="form-control" style="height: 140px;"></textarea>
                    </td>
                </tr>
               
            </table>
    </div>
   <style>
    .form .formTitle {
        width:95px;
        font-size:9pt;
    }
    .form .formValue {
        width:150px;
        font-size:9pt;
    }

    .timeselect{
        width:167px;
        height:30px;
    }
  
    </style>
</body>
</html>

