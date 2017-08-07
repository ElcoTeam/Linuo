<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AbnormalDetailEdit.aspx.cs" Inherits="LiNuoMes.Mfg.AbnormalDetailEdit" %>

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
         var RFID = "";
         var OPtype   = "";
         var OPaction = "";

         $(function () {
                $('input').iCheck({
                    checkboxClass: 'icheckbox_square',
                    radioClass: 'iradio_square',
                    increaseArea: '20%'
                });

                $("#AbnormalType2").on('ifToggled', function (event) {
                    if ($("#AbnormalType2").is(':checked')) {
                        $("#AbnormalType3").iCheck('uncheck');
                    }
                });

                $("#AbnormalType3").on('ifToggled', function (event) {
                    if ($("#AbnormalType3").is(':checked')) {
                        $("#AbnormalType2").iCheck('uncheck');
                    }
                });

                $("#RFID").bind("keypress", function (event) {
                    var keycode = event.keyCode ? event.keyCode : event.which;
                    if (keycode == 13) {
                        RFID = $("#RFID").val().toUpperCase().trim();
                        $("#RFID").val(RFID);
                        AbId = "0";
                        InitialPage();
                    }
                });

                AbId = request('AbId');
                OPtype = request('OPtype');

                if (AbId == undefined) {
                    AbId = 0;
                }

                if (OPtype == undefined) {
                    OPtype = "CHECK";
                }

                if (OPtype == "CHECK") {
                    OPaction = "MFG_WIP_DATA_ABNORMAL_DETAIL";
                }
                else if (OPtype == "EDIT") {
                    OPaction = "MFG_WIP_DATA_ABNORMAL_EDIT";
                }
                else if (OPtype == "ADD") {
                    OPaction = "MFG_WIP_DATA_ABNORMAL_ADD";
                }

                $(":input").attr("disabled", true);

                if (OPtype != "CHECK") {
                    $("[EDITFLG]").attr("disabled", false);
                }

                if (OPtype == "EDIT") {
                    $("#RFID").attr("disabled", true);
                }

                if (OPtype != "ADD") {
                    InitialPage();
                }

         });
         
         function InitialPage() {

             $.ajax({
                 url: "GetSetMfg.ashx",
                 data: {
                     "Action": "MFG_WIP_DATA_ABNORMAL_DETAIL",
                     "AbId": AbId,
                     "RFID": RFID
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

             if (data.AbnormalType == "2") {
                 $("#AbnormalType2").iCheck("check");
             }
             else if (data.AbnormalType == "3") {
                 $("#AbnormalType3").iCheck("check");
             }

             if (OPtype != "CHECK") {
                 if (   data.AbnormalPoint == "1"
                     || data.AbnormalPoint == "2") {           //此处有歧义, 需求描述为: "第一、二个下线工位默认不选择，如选择，只允许选择其一"
                     // $("#AbnormalType3").iCheck("disable");  
                 }
                 else if (data.AbnormalPoint == "3") {         //此处有歧义, 需求描述为: "第三个下线工位固定为未完工，不可修改"
                     $("#AbnormalType2").iCheck("disable");     
                     $("#AbnormalType3").iCheck("disable");     
                     $("#AbnormalType3").iCheck("check");      //这项选中只是需求的字面意思, 其实实际是很不合理的.
                 }
             }

             $("#RFID").val(data.RFID);
             $("#WorkOrderNumber").val(data.WorkOrderNumber);
             $("#GoodsCode").val(data.GoodsCode);
             $("#AbnormalPoint").val(data.AbnormalPoint);
             $("#AbnormalTime").val(data.AbnormalTime);
             $("#AbnormalUser").val(data.AbnormalUser);
             $("#AbnormalReason").val(data.AbnormalReason);
         }
        
         function AcceptClick(grid) {
             
             if (OPtype == "CHECK")
             {
                 dialogClose();
                 return;
             }

             var RFID = $("#RFID").val().toUpperCase().trim();
             var AbnormalPoint = $("#AbnormalPoint").val();
             var AbnormalTime  = $("#AbnormalTime").val().trim();
             var AbnormalUser  = $("#AbnormalUser").val().trim();
             var AbnormalReason = $("#AbnormalReason").val().trim();

             $("#RFID").val(RFID);

             var AbnormalType = "1";

             if ($("#AbnormalType2").is(':checked')){
                 AbnormalType = "2";
             }

             if ($("#AbnormalType3").is(':checked')){
                 AbnormalType = "3";
             }

             if (AbnormalTime.length == 0) {
                 dialogMsg("请录入下线时间!", -1);
                 $("#AbnormalTime").focus();
                 return;
             }

             if (AbnormalUser.length == 0) {
                 dialogMsg("请录入下线人员!", -1);
                 $("#AbnormalUser").focus();
                 return;
             }

             if (AbnormalReason.length == 0) {
                 dialogMsg("请录入下线原因!", -1);
                 $("#AbnormalReason").focus();
                 return;
             }

             $.ajax({
                 url: "GetSetMfg.ashx",
                 data: {
                     "Action"        : OPaction,
                     "AbId"          : AbId,
                     "RFID"          : RFID,
                     "AbnormalPoint" : AbnormalPoint,
                     "AbnormalType"  : AbnormalType,
                     "AbnormalTime"  : AbnormalTime,
                     "AbnormalUser"  : AbnormalUser,
                     "AbnormalReason": AbnormalReason
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
    <div style="margin-left: 10px; margin-top: 10px; margin-right: 10px;">
            <table class="form" style="margin-top:0px;"  border="0">
                <tr>
                    <td class="formTitle">MES码:</td>
                    <td colspan="3">
                        <input EDITFLG="true" type="text" class="form-control" id="RFID" />
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
                <tr>
                    <td class="formTitle">下线工序:</td>
                    <td>
                        <select class="form-control" id="AbnormalPoint">
                            <option value ="1">下线点1</option>
                            <option value ="2">下线点2</option>
                            <option value ="3">下线点3</option>
                        </select>
                    </td>
                    <td class="formTitle">下线类型:</td>
                    <td>
                        <input EDITFLG="true" type="checkbox" id="AbnormalType2" value="2">
                        <label for="AbnormalType2" class="formTitle" style="font-weight:normal; color:blueviolet; text-align:left;" >报废</label>
                        <input EDITFLG="true" type="checkbox" id="AbnormalType3" value="3" >
                        <label for="AbnormalType3" class="formTitle" style="font-weight:normal; color:blueviolet; text-align:left;" >未完工</label>
                   </td>
                </tr>
                <tr>
                    <td class="formTitle">下线时间:</td>
                    <td>
                        <input EDITFLG="true" type="text" id="AbnormalTime" onFocus="WdatePicker({dateFmt:'yyyy-MM-dd HH:ss', readOnly:true})" class="Wdate timeselect"/>
                    </td>
                    <td class="formTitle">下线人员:</td>
                    <td>
                        <input EDITFLG="true" type="text" class="form-control"  id="AbnormalUser"  />
                    </td>
                 </tr>
                <tr>
                    <td class="formTitle" style="vertical-align:top">下线原因:</td>
                    <td colspan="3">
                        <textarea EDITFLG="true" id="AbnormalReason"  style="height: 160px;width:552px"></textarea>
                    </td>
                </tr>
               
            </table>
    </div>
   <style>
    .formTitle {
        width:60px;
        font-size:9pt;
        padding:5px!important;
    }
    .formValue  {
        width:160px;
        font-size:9pt;
    }

    .form-control  {
        width:180px;
        font-size:9pt;
    }
  
    </style>
</body>
</html>

